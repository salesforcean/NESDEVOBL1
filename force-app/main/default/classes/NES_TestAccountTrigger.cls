/**
 * Created by Ritvik on 05-11-2018.
 * Purpose : Test class for AccountBusinessLogic.
 */

@isTest
private class NES_TestAccountTrigger {

    @TestSetup
        static void setup(){
       Peak_TestUtils.createNESBusinessLogicSwitch('AccountTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
          Account account = Peak_TestUtils.createTestAccount();
        Account account2=Peak_TestUtils.createAccountRecord('TestAccount','Household');
          School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account2.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        }
        
    //This test method for insert account record trigger functionality.
    @isTest
    static void UnitTestPositiveScenario1(){

        Test.startTest();
        List<Account> listOfAccountToUpdate = new List<Account>();
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account accountOne = Peak_TestUtils.createTestAccount();

        accountOne.RecordTypeId = householdRecordTypeId;
        accountOne.Type_of_Living_Accommodations__c = 'With more than one family in a house or an apartment due to loss of housing or economic hardship';
        listOfAccountToUpdate.add(accountOne);
        Account accountSecond = Peak_TestUtils.createTestAccount();

        accountSecond.RecordTypeId = householdRecordTypeId;
        accountSecond.Type_of_Living_Accommodations__c = 'In a shelter';
        listOfAccountToUpdate.add(accountSecond);
        Account accountThird = Peak_TestUtils.createTestAccount();


        accountThird.RecordTypeId = householdRecordTypeId;
        accountThird.Type_of_Living_Accommodations__c = 'In a temporary trailer, campground, car, or park due to the lack of alternative accommodations';

        listOfAccountToUpdate.add(accountThird);
        Account accountFourth = Peak_TestUtils.createTestAccount();


        accountFourth.RecordTypeId = householdRecordTypeId;
        accountFourth.Type_of_Living_Accommodations__c = 'Awaiting foster care placement';
        listOfAccountToUpdate.add(accountFourth);
        Account accountFifth = Peak_TestUtils.createTestAccount();

        accountFifth.RecordTypeId = householdRecordTypeId;
        accountFifth.Type_of_Living_Accommodations__c = 'In a hotel or motel';
        listOfAccountToUpdate.add(accountFifth);
        Account accountSixth = Peak_TestUtils.createTestAccount();

        accountSixth.RecordTypeId = householdRecordTypeId;
        accountSixth.Type_of_Living_Accommodations__c = 'A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        listOfAccountToUpdate.add(accountSixth);

        update listOfAccountToUpdate;
        System.assertEquals(accountOne.Calculated_ID__c,accountOne.School_Id__c);
        Test.stopTest();
    }

    //This test method for update account record trigger functionality.
    @isTest
    static void UnitTestPositiveScenario2(){
        Account account = Peak_TestUtils.createTestAccount();
        account.School_Id__c = null;
        Test.startTest();
        update account;

        System.assertEquals(account.Calculated_ID__c,account.School_Id__c);
        Test.stopTest();
    }
    @isTest
    static void calculateHomelessRiskFlagTest(){
       // Account account=Peak_TestUtils.createAccountRecord('TestAccount','Household');
       Account account = [Select id , Type_of_Living_Accommodations__c from Account where RecordType.DeveloperName = 'Household' limit 1];
        Test.startTest();
        account.Type_of_Living_Accommodations__c='A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        update account;

        System.assertEquals('Potential Homeless', [SELECT HomelessRiskFlag__c FROM hed__Program_Enrollment__c LIMIT 1][0].HomelessRiskFlag__c);
        Test.stopTest();
    }
}