/**
    MIT License

    Copyright (c) 2018 Alex

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

@IsTest
public with sharing class QueryBuilderTest {

    @TestSetup
    public static void init() {
        createAccount(1);
    }

    @IsTest
    public static void testFrom1() {
        List<Account> accounts = (List<Account>) new QueryBuilder('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom5() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom6() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom7() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom8() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testAddSubQuery1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Id')
                .addSubQuery('SELECT Id FROM Contacts')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testAddSubQuery2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Id')
                .addSubQuery(new QueryBuilder('Contacts'))
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testField1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testField2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField(Account.Name)
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testField3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new Account(Name = 'test'))
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields21() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields22() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields23() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields('Name, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields31() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new List<String>{
                        'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields32() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new List<String>{
                        'Id', 'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields33() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new List<String>{
                        'Name', 'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new Set<String>{
                        'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields7() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllCreatable()
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields11() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllCreatable(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllCreatable(Account.getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields13() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllCreatable(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsAllUpdatable1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllUpdatable()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFieldsAllUpdatable2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllUpdatable('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFieldsAllUpdatable3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllUpdatable(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFieldsAllUpdatable4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllUpdatable(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testConditionManager() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition())
                .preview()
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testAddConditionsWithOrder() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditionsWithOrder('1 and (2 or 3) and 4')
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testAddGroupBy1() {
        String accountQueryStr = new QueryBuilder(Account.class)
                .addGroupBy('Id, Name')
                .toString();
        System.assertEquals(true, accountQueryStr.contains('SELECT Id FROM Account WITH SECURITY_ENFORCED GROUP BY Id, Name'), accountQueryStr);

        accountQueryStr = new QueryBuilder(Account.class)
                .addGroupBy(Account.Name)
                .toString();
        System.assertEquals('SELECT Id FROM Account WITH SECURITY_ENFORCED GROUP BY Name', accountQueryStr);
    }

    @IsTest
    public static void testInstanciateAndOtherSettings() {
        String accountQueryStr = new QueryBuilder()
                .addFrom(Account.class)
                .setOffset(1)
                .setScope(QueryBuilder.FilterScope.MINE)
                .setForView(true)
                .setForView()
                .setForReference(true)
                .setForReference()
                .setUpdateTracking(true)
                .setUpdateTracking()
                .setUpdateViewstat()
                .setUpdateViewstat(true)
                .setWithSecurityEnforced()
                .setWithSecurityEnforced(true)
                .setCheckFLS()
                .setCheckFLS(true)
                .toString();
        System.assertEquals('SELECT Id FROM Account USING SCOPE MINE WITH SECURITY_ENFORCED OFFSET 1 FOR VIEW UPDATE TRACKING, VIEWSTAT', accountQueryStr);

        // Code coverage for corer cases in toString()
        accountQueryStr = new QueryBuilder()
                .addFrom(Account.class)
                .setForView(false)
                .setForReference(true)
                .setUpdateTracking(true)
                .toString();

        accountQueryStr = new QueryBuilder()
                .addFrom(Account.class)
                .setUpdateViewstat(true)
                .toString();

        String accountQueryCountStr = new QueryBuilder(Account.class)
                .setScope(QueryBuilder.FilterScope.MINE)
                .setOffset(1)
                .setLimit(1)
                .toStringCount();
        System.assertEquals('SELECT count() FROM Account USING SCOPE MINE LIMIT 1 OFFSET 1', accountQueryCountStr);

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToQueryLocator() {
        Database.QueryLocator accounts = new QueryBuilder(Account.class)
                .toQueryLocator();
        System.assertNotEquals(null, accounts);
    }

    @IsTest
    public static void testSimpleCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition('Name = \'Account-1\''))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testSimpleCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition())
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testNullCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').isNull())
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition(Account.Name).isNull())
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition(Account.Name).notNull())
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.Name).eq('Account-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').ne('Account-1'))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').eq(1))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition5() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').ne(0))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition6() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gt(0))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition7() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gte(1))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition8() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lt(0))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition9() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lte(-1))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition10() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('IsDeleted').eq(true))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition11() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('IsDeleted').ne(false))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('CreatedDate').lt('TODAY'))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());

        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('CreatedDate').gt('TODAY'))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());

        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('CreatedDate').lte('TODAY'))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());

        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('CreatedDate').gte('TODAY'))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testLikeCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyBoth('ccount-'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition(Account.Name).likeAnyBoth('ccount-'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyLeft('ccount-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyRight('Account-'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new Set<Id>()))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new List<Id>()))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInCondition3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Name').inCollection(new List<String>{
                        'Account-1'
                }))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition4() {
        List<String> inList = new List<String>();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition(Account.Name).inCollection(inList))
                .endConditions()
                .toList();
        System.assertEquals(0, accounts.size());

        inList.add('Account-1');
        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition(Account.Name).inCollection(inList))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition5() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Name').inCollection(new Set<String>{
                        'Account-1'
                }))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition6() {
        Set<Id> accIds = new QueryBuilder('Account').toIdSet();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());

        // The following are not valid for typing issue but will increase code coverage
        Set<String> stringSet = new Set<String>(); // Test coverage for empty set
        String accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(stringSet))
                .endConditions()
                .toString();

        Set<Decimal> decSet = new Set<Decimal>(); // Test coverage for empty set
        accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(decSet))
                .endConditions()
                .toString();

        decSet.add(1);
        accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(decSet))
                .endConditions()
                .toString();

        //Test list of Decimal
        List<Decimal> decList = new List<Decimal>(); // Test coverage for empty list
        accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(decList))
                .endConditions()
                .toString();

        decList.add(1);
        accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(decList))
                .endConditions()
                .toString();
    }

    @IsTest
    public static void testInCondition7() {
        List<String> accIds = new List<Id>(new QueryBuilder('Account').toIdSet());
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition8() {
        String accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new QueryBuilder('Contact')))
                .endConditions()
                .toString();
        System.assertEquals(true, accountQureyStr.contains('SELECT Id FROM Account WHERE Id IN (SELECT Id FROM Contact)'), accountQureyStr);
        System.assertEquals(true, accountQureyStr.contains('WITH SECURITY_ENFORCED'), accountQureyStr);

        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection([select Id from Account]))
                .endConditions()
                .toString();

        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new Map<Id, SObject>([select Id from Account])))
                .endConditions()
                .toString();
    }

    @IsTest
    public static void testNotInCondition() {
        String accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(new QueryBuilder('Contact')))
                .endConditions()
                .toString();
        System.assertEquals(true, accountQureyStr.contains('SELECT Id FROM Account WHERE Id NOT IN (SELECT Id FROM Contact)'), accountQureyStr);
        System.assertEquals(true, accountQureyStr.contains('WITH SECURITY_ENFORCED'), accountQureyStr);

        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn([select Id from Account]))
                .endConditions()
                .toString();

        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(new Map<Id, SObject>([select Id from Account])))
                .endConditions()
                .toString();

        Set<Id> idSet = new Set<Id>();
        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(idSet))
                .endConditions()
                .toString();

        idSet.add([select Id from account limit 1][0].Id);
        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(idSet))
                .endConditions()
                .toString();

        List<String> strList = new List<String>();
        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(strList))
                .endConditions()
                .toString();

        strList.add('someString');
        accountQureyStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(strList))
                .endConditions()
                .toString();
    }

    @IsTest
    public static void testIncludesCondition1() {
        String accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.IncludesCondition('Id').includes('includedId'))
                .endConditions()
                .toString();

        System.assertEquals(true, accountQueryStr.contains('SELECT Id FROM Account WHERE Id includes'), accountQueryStr);

    }

    @IsTest
    public static void testIncludesCondition2() {
        String accountQueryStr = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.IncludesCondition('Id').excludes('excludedId'))
                .endConditions()
                .toString();

        System.assertEquals(true, accountQueryStr.contains('SELECT Id FROM Account WHERE Id excludes (\'excludedId\')'), accountQueryStr);
        System.assertEquals(true, accountQueryStr.contains('WITH SECURITY_ENFORCED'), accountQueryStr);

    }

    @IsTest
    public static void testComplexCondition0() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        System.assertEquals('', complex.toString());
    }

    @IsTest
    public static void testComplexCondition1() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.startCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition2() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition3() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.orCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition4() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .add(complex)
                .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition5() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .add(complex)
                .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition6() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        complex.andCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition7() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        createAccount(2);

        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-2'));
        complex.orCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testLimit1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setLimit(-1)
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testLimit2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setLimit(1)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLimit3() {
        createAccount(2);
        Decimal dec = 1;
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setLimit(dec)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testSetOffset() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setOffset(1)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testOrder1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc('Name')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrder2() {

        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder3() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc('Name')
                .addOrderAsc('Id')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrder4() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .addOrderDesc('Id')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder5() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc(Account.Name)
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);

        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc(Account.Name)
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrder(new QueryBuilder.Order(Account.Name)
                    .setSortingOrderAsc()
                    .setNullsOrderLast())
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);

        accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrder(new QueryBuilder.Order(Account.Name)
                    .setSortingOrderDesc()
                    .setNullsOrderLast())
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testPreview() {
        QueryBuilder qb = new QueryBuilder(Account.class).preview();
        System.assertEquals(
                'SELECT Id FROM Account WITH SECURITY_ENFORCED',
                qb.toString(),
                'Failure: tostring bad'
        );
    }

    @IsTest
    public static void testPreviewCount() {
        QueryBuilder qb = new QueryBuilder(Account.class).previewCount();
        System.assertEquals(
                'SELECT Id FROM Account WITH SECURITY_ENFORCED',
                qb.toString(),
                'Failure: tostring bad'
        );
    }

    @IsTest
    public static void testToString() {
        String queryString = new QueryBuilder(Account.class)
                .toString();
        System.assertEquals(true, queryString.contains('SELECT Id FROM Account'), queryString);
        System.assertEquals(true, queryString.contains('WITH SECURITY_ENFORCED'), queryString);
    }

    @IsTest
    public static void testToCountString() {
        String queryString = new QueryBuilder(Account.class)
                .toStringCount();
        System.assertEquals('SELECT count() FROM Account', queryString);
    }

    @IsTest
    public static void testToCountString2() {
        String queryString = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
                .endConditions()
                .toStringCount();
        System.assertEquals('SELECT count() FROM Account WHERE Name = \'Account-1\'', queryString);
    }

    @IsTest
    public static void testResetResult() {
        QueryBuilder accountQueryBuilder = new QueryBuilder('Account');
        List<Account> accounts = (List<Account>) accountQueryBuilder
                .toList();
        System.assertEquals(1, accounts.size());

        createAccount(2);
        accounts = (List<Account>) accountQueryBuilder.toList();
        System.assertEquals(1, accounts.size());

        accountQueryBuilder.resetResult();
        accounts = (List<Account>) accountQueryBuilder.toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testToMap1() {
        Map<Id, SObject> accounts = new QueryBuilder('Account')
                .addField('Name')
                .toMap();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToMap2() {
        Map<Id, Account> accounts = new Map<Id, Account>();
        new QueryBuilder('Account')
                .addField('Name')
                .toMap(accounts);
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToSobject() {
        Account account = (Account) new QueryBuilder('Account')
                .toSObject();
        System.assertNotEquals(null, account);
    }

    @IsTest
    public static void testToSobject2() {
        SObject account = (Account) new QueryBuilder('Account')
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').isNull())
                .endConditions()
                .toSObject();
        System.assertEquals(null, account);
    }

    @IsTest
    public static void testToIdSet() {
        Set<Id> accountIds = new QueryBuilder('Account')
                .toIdSet();
        System.assertEquals(1, accountIds.size());
    }

    @IsTest
    public static void testExtractIds() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        createContact(accId);
        Set<Id> extractedIds = new QueryBuilder('Contact')
                .addField('AccountId')
                .extractIds('AccountId');
        System.assertEquals(1, extractedIds.size());
        System.assert(extractedIds.contains(accId));

        extractedIds = new QueryBuilder('Contact')
                .addField('AccountId')
                .addField('ReportsToId')
                .extractIds('ReportsToId');
        System.assertEquals(0, extractedIds.size());
    }

    @IsTest
    public static void testExtractField1() {
        List<Object> accountNames = new QueryBuilder('Account')
                .addField('Name')
                .extractField('Name');
        System.assertEquals(1, accountNames.size());

        accountNames = new QueryBuilder('Account')
                .addField('Name')
                .extractField(Account.Name);
        System.assertEquals(1, accountNames.size());
    }

    @IsTest
    public static void testClone1() {
        QueryBuilder qb1 = new QueryBuilder('Account');
        System.assertEquals('SELECT Id FROM Account', qb1.toString());

        QueryBuilder qb2 = qb1.cloneQueryBuilder();
        qb2.addField('Name');

        qb1.resetResult();
        System.assertEquals('SELECT Id FROM Account', qb1.toString());
        System.assertEquals('SELECT Name FROM Account', qb2.toString());
    }

    @IsTest
    public static void testClone2() {
        QueryBuilder qb1 = new QueryBuilder('Account');
        qb1.toList();

        QueryBuilder qb2 = qb1.cloneQueryBuilder(true);
        createAccount(2);

        System.assertEquals(qb1.toList(), qb2.toList());
    }

    @IsTest
    public static void testStub1() {
        String expectedSoql = 'SELECT Name FROM Account';

        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToString(expectedSoql)
                .applyStub();

        System.assertEquals(expectedSoql, stubbedQueryBuilder.toString());
    }

    @IsTest
    public static void testStub2() {
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToList(new List<Account>{
                        new Account(Name = 'Stubbed-Account')
                })
                .applyStub();

        List<Account> accounts = (List<Account>) stubbedQueryBuilder.toList();
        System.assertEquals(1, accounts.size());
        System.assertEquals('Stubbed-Account', accounts[0].Name);
    }

    @IsTest
    public static void testStub3() {
        String expectedSoql = 'SELECT count() FROM Account';

        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToStringCount(expectedSoql)
                .applyStub();

        System.assertEquals(expectedSoql, stubbedQueryBuilder.toStringCount());
    }

    @IsTest
    public static void testStub4() {
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToCount(1)
                .applyStub();

        System.assertEquals(1, stubbedQueryBuilder.toCount());
    }

    @IsTest
    public static void testStub5() {
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToMap(new Map<Id, SObject>([select Id from Account]))
                .applyStub();

        System.assertEquals(1, stubbedQueryBuilder.toMap().keySet().size());
    }

    @IsTest
    public static void testStub6() {
        Account acc = [select Id, Name from Account limit 1][0];
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToSObject(acc)
                .applyStub();

        System.assertEquals('Account-1', stubbedQueryBuilder.toSObject().get('Name'));
    }

    @IsTest
    public static void testStub7() {
        Account acc = [select Id, Name from Account limit 1][0];
        Set<Id> idSet = new Set<Id>{acc.Id};
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubToIdSet(idSet)
                .applyStub();

        System.assertEquals(1, stubbedQueryBuilder.toIdSet().size());

        stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubExtractIds(idSet)
                .applyStub();

        System.assertEquals(1, stubbedQueryBuilder.extractIds('Id').size());

        String[] nameList = new List<String>{'Account-stub'};
        stubbedQueryBuilder = new QueryBuilder(Account.class)
                .buildStub()
                .addStubExtractField(nameList)
                .applyStub();

        System.assertEquals('Account-stub', String.valueOf(stubbedQueryBuilder.extractField('Name')[0]));
    }

    //Utility methods
    private static Account createAccount(Integer i) {
        Account result = new Account();
        result.Name = 'Account-' + i;
        result.NumberOfEmployees = 0;
        insert result;
        return result;
    }

    private static Contact createContact(Id accId) {
        Contact result = new Contact();
        result.LastName = 'Contact-' + accId;
        result.AccountId = accId;
        result.Email = 'email' + accId + '@example.com';
        result.Description = accId;
        insert result;
        return result;
    }
}
