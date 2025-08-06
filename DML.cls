/**
 * Standard DML
 */
public with sharing class DML {
    public class AccessException extends Exception {
    }
    public class DMLException extends Exception {
    }
    public DML() {
    }

    /**
     * insert
     */
    public static Database.SaveResult[] insertRecords(SObject record) {
        return insertRecords(new List<SObject>{ record });
    }
    public static Database.SaveResult[] insertRecords(SObject record, Boolean dmoBool) {
        return insertRecords(new List<SObject>{ record }, dmoBool);
    }
    public static Database.SaveResult[] insertRecords(SObject[] records) {
        return insertRecords(records, true);
    }
    public static Database.SaveResult[] insertRecords(SObject[] records, Boolean dmoBool) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = dmoBool;
        return insertRecords(records, dmo);
    }
    public static Database.SaveResult[] insertRecords(SObject[] records, Database.DMLOptions dmo) {
        if (records == null || records.size() == 0) {
            return new List<Database.SaveResult>{};
        }
        Schema.sObjectType typ = records[0].getSObjectType();
        Schema.DescribeSobjectResult describe = typ.getDescribe();
        if (typ.getDescribe().isCreateable() != true) {
            throwException('to create object ' + typ.getDescribe().getName());
        }
        Map<String, Object> fieldsMap = records[0].getPopulatedFieldsAsMap();
        for (String field : fieldsMap.keySet()) {
            if (describe.fields.getMap().containsKey(field)) {
                Schema.DescribeFieldResult dfr = describe.fields.getMap().get(field).getDescribe();
                if (dfr.isPermissionable() && dfr.isCreateable() && !dfr.isAccessible()) {
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
        return updateRecords(new List<SObject>{ record });
    }
    public static Database.SaveResult[] updateRecords(SObject record, Boolean dmoBool) {
        return updateRecords(new List<SObject>{ record }, dmoBool);
    }
    public static Database.SaveResult[] updateRecords(SObject[] records) {
        return updateRecords(records, true);
    }
    public static Database.SaveResult[] updateRecords(SObject[] records, Boolean dmoBool) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllOrNone = dmoBool;
        return updateRecords(records, dmo);
    }
    public static Database.SaveResult[] updateRecords(SObject[] records, Database.DMLOptions dmo) {
        if (records == null || records.size() == 0) {
            return new List<Database.SaveResult>{};
        }
        Schema.sObjectType typ = records[0].getSObjectType();
        Schema.DescribeSobjectResult describe = typ.getDescribe();
        if (typ.getDescribe().isUpdateable() != true) {
            throwException('to update object ' + typ.getDescribe().getName());
        }
        Map<String, Object> fieldsMap = records[0].getPopulatedFieldsAsMap();
        for (String field : fieldsMap.keySet()) {
            if (describe.fields.getMap().containsKey(field)) {
                Schema.DescribeFieldResult dfr = describe.fields.getMap().get(field).getDescribe();
                if (field != 'Id' && !dfr.isCalculated() && !dfr.isUpdateable() && dfr.isPermissionable()) {
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
        return upsertRecords(new List<SObject>{ record });
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
            throwException(' to delete records ' + records[0].getSObjectType().getDescribe().getName());
        }

        List<Database.DeleteResult> results = Database.delete(toDelete, allOrNone);
        return results;
    }

    /**
     * force DML (danger)
     * ** Mainly for Standard object. Avoid using this as much as possible.
     */
    public without sharing class WoSharing {
        public Database.SaveResult[] insertRecordsForce(List<SObject> records) {
            // NOPMD Business Requirement - used when we must skip permisison checks for history or approvals without escalating permissions for the Read & Approve users
            Database.SaveResult[] results = new List<Database.SaveResult>{};
            if (records == null || records.size() == 0) {
                return results;
            }
            Schema.SObjectType recordsType = getObjectType(records);
            database.DMLOptions dmo = new database.DMLOptions();
            dmo.optAllOrNone = true;
            if (canBypassPermissions(recordsType)) {
                results = Database.insert(records, dmo); // NOPMD Business Requirement: do not escalate permissions to insert these records to Read & Approve users, used for history and approval activities where giving access would result in a less secure system
            } else {
                results = DML.insertRecords(records, dmo); // NOTE this actually DOES check perms, needed for security review
            }
            return results;
        }
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
            Boolean commonConditions = (false);
            return commonConditions;
        }

        private Schema.SObjectType getObjectType(SObject[] records) {
            if (records == null || records.size() == 0) {
                return null;
            }
            return records[0].getSObjectType();
        }
    }

    public class ReturnErrorResult {
        @AuraEnabled
        public List<String> errorFields { get; private set; }
        @AuraEnabled
        public String errorMsg { get; private set; }

        public ReturnErrorResult(List<String> pErrorFields, String pErrorMsg) {
            this.errorFields = pErrorFields;
            this.errorMsg = pErrorMsg;
        }
    }
    public class ReturnSuccessResult {
        @AuraEnabled
        public Id successId { get; private set; }

        public ReturnSuccessResult(Id pId) {
            this.successId = pId;
        }
    }
    public class ReturnResult {
        @AuraEnabled
        public Integer numOfErrors { get; private set; }
        @AuraEnabled
        public Integer numOfSuccesses { get; private set; }
        @AuraEnabled
        public List<ReturnErrorResult> errorResults { get; private set; }
        @AuraEnabled
        public List<ReturnSuccessResult> successResults { get; private set; }

        public ReturnResult() {
        } // NOPMD empty constructor needed for apex

        public ReturnResult(List<Database.SaveResult> pSaveResults) {
            this.numOfErrors = 0;
            this.numOfSuccesses = 0;
            this.errorResults = new List<ReturnErrorResult>();
            this.successResults = new List<ReturnSuccessResult>();

            if (pSaveResults != null && !pSaveResults.isEmpty()) {
                for (Database.SaveResult sr : pSaveResults) {
                    if (sr.isSuccess()) {
                        numOfSuccesses += 1;
                        successResults.add(new ReturnSuccessResult(sr.getId()));
                    } else {
                        numOfErrors += 1;
                        for (Database.Error err : sr.getErrors()) {
                            errorResults.add(new ReturnErrorResult(err.getFields(), err.getMessage()));
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
                for (Database.UpsertResult sr : pSaveResults) {
                    if (sr.isSuccess()) {
                        numOfSuccesses += 1;
                        successResults.add(new ReturnSuccessResult(sr.getId()));
                    } else {
                        numOfErrors += 1;
                        for (Database.Error err : sr.getErrors()) {
                            errorResults.add(new ReturnErrorResult(err.getFields(), err.getMessage()));
                        }
                    }
                }
            }
        }
    }

    private static void throwException(String msg) {
        throw new AccessException('insufficient permissions ' + msg);
    }
}
