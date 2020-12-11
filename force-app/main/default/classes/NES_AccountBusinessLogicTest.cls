/**
 * Created by Ajith on 17-04-2019.
 */

@isTest
public with sharing class NES_AccountBusinessLogicTest {
    @TestSetup
    static void setup(){
        Peak_TestUtils.createNESBusinessLogicSwitch('AccountTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        Id AccountHouseholdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account householdAccount = new Account();
        householdAccount.Name = 'Household Account';
        householdAccount.RecordTypeId = AccountHouseholdRecordTypeId;
        householdAccount.LC_HighestLevelofEducation__c = 'High school graduate';
        insert householdAccount;
        
    }
    static testMethod void createUniqueIDTest(){
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
    }
    static testMethod void populateSchoolIDTest(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Educational Institution' limit 1];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        update account1;
    }
    static testMethod void calculateHomelessRiskFlagTest(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household'];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        account1.Type_of_Living_Accommodations__c = 'A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        update account1;
    }
    static testMethod void calculateLTSTest1(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household'];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        account1.Type_of_Living_Accommodations__c = 'A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        account1.Internet_Connection_Type__c = 'DSL';
        update account1;
    }
    static testMethod void calculateLTSTest2(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household'];
        account1.Internet_Connection_Type__c = 'Cable';
        account1.LC_HighestLevelofEducation__c = 'High school graduate';
        account1.Mktg_Customer_Loyalty__c = 'Test Customer Loyalty';
        account1.Computer_in_Home__c = 'Yes';
        update account1;
    }
    
}