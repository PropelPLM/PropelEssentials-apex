@IsTest
public with sharing class DMLTest {

    @IsTest
    static void testReturnResult() {
        Account newAcc = new Account(Name='Test1');
        List<Database.SaveResult> insertResult = Database.insert(new SObject[]{newAcc});
        DML.ReturnResult dmlResult = new DML.ReturnResult(insertResult);
        System.assertEquals(1, dmlResult.numOfSuccesses);
        System.assertEquals(
            newAcc.Id,
            dmlResult.successResults[0].successId,
            ' should match and store the Id'
        );
        Account newAcc2 = new Account(Name='Test2');
        List<Database.UpsertResult> upsertResult = Database.upsert(new SObject[]{newAcc, newAcc2});
        DML.ReturnResult dmlResult2 = new DML.ReturnResult(upsertResult);
        System.assertEquals(2, dmlResult2.numOfSuccesses);
        System.assertEquals(
            newAcc2.Id,
            dmlResult2.successResults[1].successId,
            ' should match and store the Id'
        );
    }
}
