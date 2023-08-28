@IsTest
public with sharing class SoslBuilderTest {
    @IsTest
    static void searchStringFormulation() {
        System.runAs(TestUtil.getAdminWithPermissionSet()) {
            String searchString = 'test';
            String soslString = new SoslBuilder()
                .addSearchTerm(searchString)
                .addSearchField('Name')
                .addTargetObject('Digital_Asset__c')
                .toString();
            system.assertEquals(
                soslString,
                'FIND {test} IN Name FIELDS RETURNING ' + PIM.getStaticNamespace() +
                'Digital_Asset__c(Id,Name)',
                'SOSL String formulated incorrectly'
            );

            soslString = new SoslBuilder()
                .addSearchTerm(searchString)
                .toString();
            system.assertEquals(
                soslString,
                'FIND {test} IN ALL FIELDS',
                'SOSL String formulated incorrectly'
            );
        }
    }
}
