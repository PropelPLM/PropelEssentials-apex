@isTest
public with sharing class TestUtil {
    private static Id adminPermissionSetId;
    private static Id adminProfileId;

    public static Id getAdminProfileId() {
        if (TestUtil.adminProfileId == null) {
            TestUtil.adminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
        }
        return TestUtil.adminProfileId;
    }

    public static Id getPimAdminPermissionSet() {
        if (TestUtil.adminPermissionSetId == null) {
            TestUtil.adminPermissionSetId = [select Id from PermissionSet where Name = 'Propel_PIM_Sys_Admin'].Id;
        }
        return TestUtil.adminPermissionSetId;
    }

    public static User getAdminWithPermissionSet() {
        User adminUser = TestUtil.getAdminUser();
        insert adminUser;

        insert new PermissionSetAssignment(
            PermissionSetId = TestUtil.getAdminPermissionSet(),
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
            ProfileId = TestUtil.getAdminProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            Title = 'Tester',
            Username = 'clowntown@propel.com.' + Math.random()
        );
    }
}
