/**
 * Standard DML
 */
public with sharing class DML {
    public class AccessException extends Exception {}
    public class DMLException extends Exception {}
    public DML() {}

    public static Boolean isBlockedByReferences(String errMessage) {
        final String DELETE_BLOCKED_ERR_MESSAGE_PT1 = 'Your attempt to delete',
            DELETE_BLOCKED_ERR_MESSAGE_PT2 = 'could not be completed because it is associated with the following';
        return errMessage.contains(DELETE_BLOCKED_ERR_MESSAGE_PT1)
            && errMessage.contains(DELETE_BLOCKED_ERR_MESSAGE_PT2);
    }

    public static Map<System.Type, List<String>> parseBlockingReferenceErrorMessage(String errMessage) {
        Map<System.Type, List<String>> blockersByType = new Map<System.Type, List<String>>();
        if (String.isEmpty(errMessage)) { return blockersByType; }
        for (String reference : errMessage.split('\n')) {
            List<String> namesOfBlockers = new List<String>();
            try {
                System.Type sysType = PIM.resolveFuzzyLabelToCustomSObjType(reference.substringBefore('.:'));
                for (String blockingObjName : reference.substringAfter('.:').split(',')) {
                    namesOfBlockers.add(blockingObjName.trim());
                }
                blockersByType.put(sysType, namesOfBlockers);
            } catch (Exception e) {
                if (e.getMessage().contains(PIM.NO_TYPE_FOUND)) { continue; }
                throw new DMLException(e);
            }
        }
        return blockersByType;
    }

    public List<Database.SaveResult> create(List<SObject> records, Boolean allOrNone) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = allOrNone;
        return DML.insertRecords( records, dmo );
    }

    public Database.SaveResult publish(SObject evt) {
        return EventBus.publish(evt);
    }

    /**
     * insert
     */
    public static Database.SaveResult[] insertRecords(SObject record) {
        return insertRecords(new SObject[]{record});
    }
    public static Database.SaveResult[] insertRecords(SObject record, Boolean dmoBool) {
        return insertRecords(new SObject[]{record}, dmoBool);
    }
    public static Database.SaveResult[] insertRecords(SObject[] records) {
        return insertRecords(records, true);
    }
    public static Database.SaveResult[] insertRecords(SObject[] records, Boolean dmoBool) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = dmoBool;
        return insertRecords( records, dmo );
    }
    public static Database.SaveResult[] insertRecords(SObject[] records, Database.DMLOptions dmo) {
        if ( records == null || records.size() == 0) {
            return new Database.SaveResult[]{};
        }
        Schema.sObjectType typ = records[0].getSObjectType();
        Schema.DescribeSobjectResult describe = typ.getDescribe();
        if (typ.getDescribe().isCreateable() != true) {
            throwException('to create object ' + typ.getDescribe().getName());
        }
        Map<String, Object> fieldsMap = records[0].getPopulatedFieldsAsMap();
        for (String field : fieldsMap.keySet()) {
            if ( describe.fields.getMap().containsKey( field )) {
                Schema.DescribeFieldResult dfr = describe.fields.getMap().get(field).getDescribe();
                if (dfr.isPermissionable() && dfr.isCreateable() && !dfr.isAccessible() ) {
                    throwException('to create field ' + dfr.getName());
                }
            }
        }
        return Database.insert(records, dmo); // NOPMD checked above in this method
    }

    /**
     * update
     */
    public static Database.SaveResult[] updateRecords(SObject record) {
        return updateRecords(new SObject[]{record});
    }
    public static Database.SaveResult[] updateRecords(SObject record, Boolean dmoBool) {
        return updateRecords(new SObject[]{record}, dmoBool);
    }
    public static Database.SaveResult[] updateRecords(SObject[] records) {
        return updateRecords(records, true);
    }
    public static Database.SaveResult[] updateRecords(SObject[] records, Boolean dmoBool) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = dmoBool;
        return updateRecords( records, dmo );
    }
    public static Database.SaveResult[] updateRecords(SObject[] records , Database.DMLOptions dmo) {
        if ( records == null || records.size() == 0) {
            return new Database.SaveResult[]{};
        }
        Schema.sObjectType typ = records[0].getSObjectType();
        Schema.DescribeSobjectResult describe = typ.getDescribe();
        if ( typ.getDescribe().isUpdateable() != true) {
            throwException('to update object ' + typ.getDescribe().getName());
        }
        Map<String, Object> fieldsMap = records[0].getPopulatedFieldsAsMap();
        for (String field : fieldsMap.keySet()) {
            if ( describe.fields.getMap().containsKey( field )) {
                Schema.DescribeFieldResult dfr = describe.fields.getMap().get(field).getDescribe();
                if (field != 'Id' && !dfr.isCalculated() && !dfr.isUpdateable()  && dfr.isPermissionable() ){
                    throwException('to update field ' + dfr.getName());
                }
            }
        }
        return Database.update(records, dmo); // NOPMD checked above in this method
    }

    /**
     * upsert
     */
    public static Database.UpsertResult[] upsertRecords(SObject record) {
        return upsertRecords(new SObject[]{record});
    }
    public static Database.UpsertResult[] upsertRecords(SObject[] records) {
        return upsertRecords(records, true);
    }
    public static Database.UpsertResult[] upsertRecords(SObject[] records, Boolean dmoBool) {
        List<Database.UpsertResult> results = new List<Database.UpsertResult>();
        if (records == null || records.size() == 0) {
            return results;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, records);

        // default to the ID of the records
        // TODO: add externalIdField
        results = Database.upsert(decision.getRecords(), dmoBool); // NOPMD checked above in this method

        // calling method may expect the records to have new Id's
        for (Integer i = 0; i < records.size() && results.size() > 0; i++) {
            if (results[i].isSuccess()) {
                records[i].Id = results[i].getId();
            }
        }
        return results;
    }

    /**
     * delete
     */
    public List<Database.DeleteResult> instanceDeleteRecords(SObject[] records) {
        return deleteRecords(records, true);
    }
    public List<Database.DeleteResult> instanceDeleteRecordsFromIds(List<Id> recordIds) {
        return Database.delete(recordIds, true);
    }

    public static List<Database.DeleteResult> deleteRecords(SObject[] records) {
        return deleteRecords(records, true);
    }
    public static List<Database.DeleteResult> deleteRecords(SObject[] records, boolean allOrNone) {
        List<Database.DeleteResult> ret = new List<Database.DeleteResult>();
        if (records == null || records.size() == 0) {
            return ret;
        }
        List<SObject> toDelete = new List<Sobject>();
        for (sobject so : records) {
            Schema.DescribeSobjectResult dsr = so.getSObjectType().getDescribe();
            if (dsr.isAccessible() && dsr.isDeletable()) {
                toDelete.add(so);
            }
        }
        if (toDelete.size() != records.size()) {
            throwException(
                ' to delete records ' + records[0].getSObjectType().getDescribe().getName()
            );
        }

        List<Database.DeleteResult> results = Database.delete(toDelete, allOrNone);
        return results;
    }

    /**
     * force DML (danger)
     * ** Mainly for Standard object. Avoid using this as much as possible.
     */
    public without sharing class WoSharing {
        public Database.SaveResult[] updateRecordsForce(SObject[] records) {
            // NOPMD Business Requirement - used when we must skip permisison checks for history or approvals without escalating permissions for the Read & Approve users
            Database.SaveResult[] results = new List<Database.SaveResult>{};
            if (records == null || records.size() == 0) {
                return results;
            }
            Schema.SObjectType recordsType = getObjectType(records);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.optAllOrNone = true;
            if (canBypassPermissions(recordsType)) {
                results = Database.update(records, dmo); // NOPMD Business Requirement: must update these records/tables without escalating permissions for the Read & Approve users
            } else {
                results = DML.updateRecords(records, dmo); // NOTE this actually DOES check perms, needed for security review
            }
            return results;
        }

        private Boolean canBypassPermissions(Schema.SObjectType recordsType) {
            Boolean commonConditions = (
                recordsType == Task__c.sObjectType
            );
            return commonConditions;
        }

        private Schema.SObjectType getObjectType(SObject[] records) {
            if (records == null || records.size() == 0) { return null; }
            return records[0].getSObjectType();
        }
    }

    /**
     * @description If there is an error this method will throw a DML exception for you.
     * @param results DeleteResult list
     * @exception
     */
    public static void throwDmlException(List<Database.DeleteResult> results) {
        List<DMLResult> parsedResults = new List<DMLResult>();
        for (Database.DeleteResult result : results) {
            parsedResults.add(new DMLResult(result));
        }

        List<String> errorMessages = PIM.grepStrings(parsedResults, 'errorMessage');
        String compiledErrorMessages = '';
        Boolean hasError = false;
        for (String errorMessage : errorMessages) {
            if (errorMessage == null || errorMessage == '') {
                continue;
            }

            hasError = true;
            compiledErrorMessages += errorMessage;
        }

        if (hasError) {
            throw new DMLException(
                compiledErrorMessages == null
                    ? 'Error in DML'
                    : compiledErrorMessages
            );
        }
    }

    private static void throwException(String msg) {
        throw new AccessException('insufficient permissions ' + msg);
    }

    public void insertImmediate(List<SObject> objectsToCommit, System.Savepoint savePoint) {
        insertImmediate(objectsToCommit, true, savePoint);
    }

    public void insertImmediate(
        List<SObject> objectsToCommit,
        Boolean allOrNothing,
        System.Savepoint savePoint
    ) {
        List<Database.SaveResult> srList = Database.insertImmediate(objectsToCOmmit);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug(
                        String.format(
                            '[{0}] The following error has occurred: {1}. Error fields: {2}',
                            new List<String>{
                                String.valueOf(err.getStatusCode()),
                                err.getMessage(),
                                String.join(err.getFields(), ', ')
                            }
                        )
                    );
                }
                if (allOrNothing && savePoint != null) {
                    Database.rollback(savePoint);
                }
            }
        }
    }

    public class ReturnErrorResult {
        @AuraEnabled public List<String> errorFields { get; private set; }
        @AuraEnabled public String errorMsg { get; private set; }

        public ReturnErrorResult(List<String> pErrorFields, String pErrorMsg) {
            this.errorFields = pErrorFields;
            this.errorMsg = pErrorMsg;
        }
    }
    public class ReturnSuccessResult {
        @AuraEnabled public Id successId { get; private set; }

        public ReturnSuccessResult(Id pId) {
            this.successId = pId;
        }
    }
    public class ReturnResult {
        @AuraEnabled public Integer numOfErrors { get; private set; }
        @AuraEnabled public Integer numOfSuccesses { get; private set; }
        @AuraEnabled public List<ReturnErrorResult> errorResults { get; private set; }
        @AuraEnabled public List<ReturnSuccessResult> successResults { get; private set; }


        public ReturnResult() {} // NOPMD empty constructor needed for apex

        public ReturnResult(List<Database.SaveResult> pSaveResults) {
            this.numOfErrors = 0;
            this.numOfSuccesses = 0;
            this.errorResults = new List<ReturnErrorResult>();
            this.successResults = new List<ReturnSuccessResult>();

            if (pSaveResults != null && !pSaveResults.isEmpty()) {
                for (Database.SaveResult sr :pSaveResults) {
                    if (sr.isSuccess()) {
                        numOfSuccesses += 1;
                        successResults.add(new ReturnSuccessResult(sr.getId()));
                    } else {
                        numOfErrors += 1;
                        for (Database.Error err :sr.getErrors()) {
                            errorResults.add(new ReturnErrorResult(
                                err.getFields(),
                                err.getMessage()
                            ));
                        }
                    }
                }
            }
        }

        public ReturnResult(List<Database.UpsertResult> pSaveResults) {
            this.numOfErrors = 0;
            this.numOfSuccesses = 0;
            this.errorResults = new List<ReturnErrorResult>();
            this.successResults = new List<ReturnSuccessResult>();

            if (pSaveResults != null && !pSaveResults.isEmpty()) {
                for (Database.UpsertResult sr :pSaveResults) {
                    if (sr.isSuccess()) {
                        numOfSuccesses += 1;
                        successResults.add(new ReturnSuccessResult(sr.getId()));
                    } else {
                        numOfErrors += 1;
                        for (Database.Error err :sr.getErrors()) {
                            errorResults.add(new ReturnErrorResult(
                                err.getFields(),
                                err.getMessage()
                            ));
                        }
                    }
                }
            }
        }
    }

    /* Helps to encapsulate all the metadata required to find out the blockers of a delete operation
     * When an SObject is referenced by another SObject in a field that has its deleteConstraint set to 'Restrict',
     * the Apex DB will block the operation.
     *
     * However, the error message returned is quite terrible, as
     *      1. they point to the SObject's name, which is a problem if its a junction object not meant to be exposed
     *          to the users.
     *      2. it is truncated if there are too many fields
     *      3. do not provide further contextual information such as quality of life metadata like IDs (that can be linked to).
     */
    public class BlockingReferenceResolver {

        public System.Type typeOfBlocker;
        public List<String> blockingNames;
        // make PIM a singleton
        PIM pimUtilService = new PIM();
        // this should be resolved as an abstract method on BlockingReferenceResolver if there are other use cases (which i think there are just global search '<deleteConstraint>Restrict</deleteConstraint>'
        public String fieldToIdentifyBlocker;
        @TestVisible
        private QueryBuilder qbInstance = new QueryBuilder();

        public BlockingReferenceResolver(System.Type typeOfBlocker) {
            this.typeOfBlocker = typeOfBlocker;
            this.blockingNames = new List<String>();
        }

        public BlockingReferenceResolver(System.Type typeOfBlocker, List<String> blockingNames) {
            this.typeOfBlocker = typeOfBlocker;
            this.blockingNames = blockingNames == null
                ? new List<String>()
                : blockingNames;
        }

        public void addBlockers(List<String> blockingNames) {
            if (blockingNames == null || blockingNames.isEmpty()) { return; }
            this.blockingNames.addAll(blockingNames);
        }

        public Boolean isEmpty() {
            return this.blockingNames == null || this.blockingNames.isEmpty();
        }


        /* Formats query fields by finding out which fields are relational fields and appending .Name to it for a
         * user friendly name.
         */
        @TestVisible
        private List<String> getRelationalQueryFields() {
            List<String> queryFields = new List<String>();
            List<Schema.DescribeFieldResult> relationalFieldDFRs = PIM.getCustomRelationalFieldsFromSysType(this.typeOfBlocker);
            for (Schema.DescribeFieldResult dfr : relationalFieldDFRs) {
                queryFields.add(dfr.relationshipName + '.Name');
            }
            return queryFields;
        }

        // condition can be improved in the future
        public List<SObject> resolveBlockingReferences() {
            if (this.typeOfBlocker == null) { throw new DMLException(System.Label.Argument_cannot_be_null + ': typeOfBlocker'); }
            return this.qbInstance.addFrom(this.typeOfBlocker)
                .addFields(getRelationalQueryFields())
                .addConditions()
                    .add(new QueryBuilder.InCondition('Name').inCollection(this.blockingNames))
                .endConditions()
                .toList();
        }

        // formatting can done on FE in the future, needs to have a 'supercharged' Exception object with class level properties.
        public String getErrorMessage() {
            List<SObject> referencedSObjects = this.resolveBlockingReferences();
            return String.format(
                '{0}(s): {1}. ',
                new List<String> {
                    pimUtilService.getLabelFromSObjType(typeOfBlocker),
                    String.join(PIM.grepStrings(referencedSObjects, this.fieldToIdentifyBlocker), ', ')
                }
            );
        }
    }


    private class DMLResult {
        final Id recordId { get; set; }
        String errorMessage { get; set; }

        public DMLResult(Database.DeleteResult result) {
            this.recordId = recordId;
            if (!result.isSuccess()) {
                this.errorMessage = constructErrorMessage(result.getErrors());
            }
        }

        String constructErrorMessage(List<Database.Error> errors) {
            List<String> errorMessages = new List<String>();
            for (Database.Error error : errors) {
                List<String> errorMessageComponents = new List<String>{ error.getMessage() };
                if (error.getMessage().contains('Required fields are missing')) {
                    errorMessageComponents.add('Missing fields: ' + error.getFields());
                }
                errorMessages.add(String.join(errorMessageComponents, '. '));
            }
            return String.join(errorMessages, '. ');
        }
    }
}
