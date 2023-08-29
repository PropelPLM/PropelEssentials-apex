@IsTest
public with sharing class SoslBuilderTest {
    @IsTest
    static void searchStringFormulation() {
        String searchString = 'test';
        String soslString = new SoslBuilder()
            .addSearchTerm(searchString)
            .addSearchField('Name')
            .addTargetObject('Account')
            .toString();
        system.assertEquals(
            soslString,
            'FIND {test} IN Name FIELDS RETURNING ' +
            'Account(Id,Name)',
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
