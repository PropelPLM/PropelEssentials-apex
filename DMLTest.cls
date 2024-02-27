@IsTest
public with sharing class DMLTest {

    @IsTest
    static void testReturnResult() {
        Account newAcc = new Account(Name='Test1');
        List<Database.SaveResult> insertResult = Database.insert(new SObject[]{newAcc});
        DML.ReturnResult dmlResult = new DML.ReturnResult(insertResult);
        System.assertEquals(1, dmlResult.numOfSuccesses, 'Failure');
        System.assertEquals(
            newAcc.Id,
            dmlResult.successResults[0].successId,
            ' should match and store the Id'
        );
        Account newAcc2 = new Account(Name='Test2');
        List<Database.UpsertResult> upsertResult = Database.upsert(new SObject[]{newAcc, newAcc2});
        DML.ReturnResult dmlResult2 = new DML.ReturnResult(upsertResult);
        System.assertEquals(2, dmlResult2.numOfSuccesses, 'Failure');
        System.assertEquals(
            newAcc2.Id,
            dmlResult2.successResults[1].successId,
            ' should match and store the Id'
        );
    }

    @isTest
    static void testInsert() {
        DML.insertRecords(new Account(Name = 'Test Single Record'));
        DML.insertRecords(new Account(Name = 'Test Single with Boolean'), false);
        DML.insertRecords(new List<Account> { new Account(Name = 'Test List') });
        DML.insertRecords(new List<Account> { new Account(Name = 'Test List with Boolean') }, false);

        List<Account> accs = [select Id, Name from Account];
        System.assert(accs.size() == 4, 'Failure: all accounts were not created.');

        // test updates
        for (Account acc :accs) {
            acc.Name = 'Update Test';
        }
        DML.updateRecords(accs[0]);
        DML.updateRecords(accs[1], false);
        DML.updateRecords(new List<Account> { accs[2] });
        DML.updateRecords(new List<Account> { accs[3] }, false);

        for (Account acc :[select Id, Name from Account]) {
            System.assert(acc.Name == 'Update Test', 'Failure: account ' + acc.Name + ' failed');
        }

        // upsert tests
        accs = [select Id, Name from Account];
        for (Account acc :accs) {
            acc.Name = 'Upsert Test';
        }
        DML.upsertRecords(accs[0]);
        DML.upsertRecords(accs[1]);
        DML.upsertRecords(new List<Account> { accs[2] });
        DML.upsertRecords(new List<Account> { accs[3] }, false);

        for (Account acc :[select Id, Name from Account]) {
            System.assert(acc.Name == 'Upsert Test', 'Failure: account ' + acc.Name + ' failed');
        }

        // delete test
        accs = [select Id, Name from Account];
        DML dToTheM = new DML();
        dToTheM.instanceDeleteRecords(new List<Account> { accs[0] });
        DML.deleteRecords(new List<Account> { accs[1] });
        DML.deleteRecords(new List<Account> { accs[2] }, false);

        accs = [select Id, Name from Account];
        System.assert(accs.size() == 1, 'Failure: dml delete missed some accounts');
    }

    @isTest
    static void testWoSharing() {
        DML.WoSharing woShare = new DML.WoSharing();
        List<Database.SaveResult> srs = DML.insertRecords(new Account(Name = 'Test WoSharing'));
        System.assert(srs.size() > 0, 'Failure: DML insert did not return a SaveResult');

        List<Account> accs = [select Id, Name from Account];
        accs[0].Name = 'Test WoSharing Update';

        woShare.updateRecordsForce(accs);

        accs = [select Id, Name from Account];
        System.assert(accs[0].Name == 'Test WoSharing Update', 'Failure: WoSharing failed');
    }

    @isTest
    static void testReturnErrorResult() {
        List<String> errorFields = new List<String> {
            'Name',
            'Temp'
        };
        String errorMsg = 'There was an error';

        DML.ReturnErrorResult returnErrorResult = new DML.ReturnErrorResult(
            errorFields,
            errorMsg
        );

        System.assert(returnErrorResult.errorMsg == 'There was an error', 'Failure');
    }

    @isTest
    static void testReturnSuccessResutl() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        DML.ReturnSuccessResult returnSuccessResult = new DML.ReturnSuccessResult(acc.Id);
        System.assert(returnSuccessResult.successId == acc.Id, 'Failure');
    }
}
