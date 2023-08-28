@isTest
public with sharing class TestUser {
    private static Id adminPermissionSetId;
    private static Id adminProfileId;

    public static Id getAdminProfileId() {
        if (TestUser.adminProfileId == null) {
            TestUser.adminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
        }
        return TestUser.adminProfileId;
    }

    public static Id getPimAdminPermissionSet() {
        if (TestUser.adminPermissionSetId == null) {
            TestUser.adminPermissionSetId = [select Id from PermissionSet where Name = 'Propel_PIM_Sys_Admin'].Id;
        }
        return TestUser.adminPermissionSetId;
    }

    public static User getAdminWithPermissionSet() {
        User adminUser = TestUser.getAdminUser();
        insert adminUser;

        insert new PermissionSetAssignment(
            PermissionSetId = TestUser.getAdminPermissionSet(),
            AssigneeId = adminUser.Id
        );

        return adminUser;
    }

    public static User getAdminUser() {
        return new User(
            Alias = String.valueOf(Math.random()).right(5),
            CompanyName = 'Propel',
            Email = 'test_admin@test.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Clown',
            LastName = 'Town',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = TestUser.getAdminProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            Title = 'Tester',
            Username = 'clowntown@propel.com.' + Math.random()
        );
    }
}
