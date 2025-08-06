@IsTest
public with sharing class DMLTest {
    @IsTest
    static void testReturnResult() {
        Account newAcc = new Account(Name = 'Test1');
        List<Database.SaveResult> insertResult = Database.insert(new List<SObject>{ newAcc });
        DML.ReturnResult dmlResult = new DML.ReturnResult(insertResult);
        System.assertEquals(1, dmlResult.numOfSuccesses, 'Failure');
        System.assertEquals(newAcc.Id, dmlResult.successResults[0].successId, ' should match and store the Id');
        Account newAcc2 = new Account(Name = 'Test2');
        List<Database.UpsertResult> upsertResult = Database.upsert(new List<SObject>{ newAcc, newAcc2 });
        DML.ReturnResult dmlResult2 = new DML.ReturnResult(upsertResult);
        System.assertEquals(2, dmlResult2.numOfSuccesses, 'Failure');
        System.assertEquals(newAcc2.Id, dmlResult2.successResults[1].successId, ' should match and store the Id');
    }

    @isTest
    static void testInsert() {
        DML.insertRecords(new Account(Name = 'Test Single Record'));
        DML.insertRecords(new Account(Name = 'Test Single with Boolean'), false);
        DML.insertRecords(new List<Account>{ new Account(Name = 'Test List') });
        DML.insertRecords(new List<Account>{ new Account(Name = 'Test List with Boolean') }, false);

        List<Account> accs = [SELECT Id, Name FROM Account];
        System.assert(accs.size() == 4, 'Failure: all accounts were not created.');

        // test updates
        for (Account acc : accs) {
            acc.Name = 'Update Test';
        }
        DML.updateRecords(accs[0]);
        DML.updateRecords(accs[1], false);
        DML.updateRecords(new List<Account>{ accs[2] });
        DML.updateRecords(new List<Account>{ accs[3] }, false);

        for (Account acc : [SELECT Id, Name FROM Account]) {
            System.assert(acc.Name == 'Update Test', 'Failure: account ' + acc.Name + ' failed');
        }

        // upsert tests
        accs = [SELECT Id, Name FROM Account];
        for (Account acc : accs) {
            acc.Name = 'Upsert Test';
        }
        DML.upsertRecords(accs[0]);
        DML.upsertRecords(accs[1]);
        DML.upsertRecords(new List<Account>{ accs[2] });
        DML.upsertRecords(new List<Account>{ accs[3] }, false);

        for (Account acc : [SELECT Id, Name FROM Account]) {
            System.assert(acc.Name == 'Upsert Test', 'Failure: account ' + acc.Name + ' failed');
        }

        // delete test
        accs = [SELECT Id, Name FROM Account];
        DML dToTheM = new DML();
        dToTheM.instanceDeleteRecords(new List<Account>{ accs[0] });
        DML.deleteRecords(new List<Account>{ accs[1] });
        DML.deleteRecords(new List<Account>{ accs[2] }, false);

        accs = [SELECT Id, Name FROM Account];
        System.assert(accs.size() == 1, 'Failure: dml delete missed some accounts');
    }

    @isTest
    static void testWoSharing() {
        DML.WoSharing woShare = new DML.WoSharing();

        // Test insertRecordsForce method
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test WoSharing Insert 1'),
            new Account(Name = 'Test WoSharing Insert 2')
        };

        Database.SaveResult[] insertResults = woShare.insertRecordsForce(testAccounts);
        System.assert(
            insertResults.size() == 2,
            'Failure: insertRecordsForce did not return expected number of SaveResults'
        );
        System.assert(insertResults[0].isSuccess(), 'Failure: insertRecordsForce failed for first record');
        System.assert(insertResults[1].isSuccess(), 'Failure: insertRecordsForce failed for second record');

        // Verify records were inserted
        List<Account> insertedAccs = [
            SELECT Id, Name
            FROM Account
            WHERE Name LIKE 'Test WoSharing Insert%'
            ORDER BY Name
        ];
        System.assert(
            insertedAccs.size() == 2,
            'Failure: insertRecordsForce did not insert expected number of records'
        );
        System.assert(
            insertedAccs[0].Name == 'Test WoSharing Insert 1',
            'Failure: first inserted record name incorrect'
        );
        System.assert(
            insertedAccs[1].Name == 'Test WoSharing Insert 2',
            'Failure: second inserted record name incorrect'
        );

        // Test existing updateRecordsForce method
        List<Database.SaveResult> srs = DML.insertRecords(new Account(Name = 'Test WoSharing Update'));
        System.assert(srs.size() > 0, 'Failure: DML insert did not return a SaveResult');

        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'Test WoSharing Update'];
        accs[0].Name = 'Test WoSharing Updated';

        woShare.updateRecordsForce(accs);

        accs = [SELECT Id, Name FROM Account WHERE Id = :accs[0].Id];
        System.assert(accs[0].Name == 'Test WoSharing Updated', 'Failure: updateRecordsForce failed');
    }

    @isTest
    static void testReturnErrorResult() {
        List<String> errorFields = new List<String>{ 'Name', 'Temp' };
        String errorMsg = 'There was an error';

        DML.ReturnErrorResult returnErrorResult = new DML.ReturnErrorResult(errorFields, errorMsg);

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
