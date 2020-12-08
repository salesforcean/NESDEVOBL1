/**
 * Created by Anushka Bansal on 27-11-2018.
 */

@IsTest
public with sharing class NES_SpecialEdBusinessLogicTest {
    @TestSetup static void setup() {
      Peak_TestUtils.createNESBusinessLogicSwitch('SpecialEdTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Peak_TestUtils.createNESBusinessLogicSwitch(NES_EntranceAgeUtility.ENTRANCE_AGE_CUSTOM_SETTING_VALUE, true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment.Id, currentSchoolYear.Id, true);
        
    }


    static testMethod void testInsertSpecialEducation(){
     hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
     Test.startTest();
     Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(progEnrollment.Id, false);
     specialEducation.IEPLastUpdated__c = 'Within the last year';
     specialEducation.Gifted__c = 'Documenting';
     insert specialEducation;
     NES_Constants.runAssignment = true;
     System.assertNotEquals(null, specialEducation);
     Test.stopTest();
    }
    
    static testMethod void updateSpecialEducationTest(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(progEnrollment.Id, true);
        Test.startTest();
        specialEducation.IEP__c = 'Documenting';
        specialEducation.IEPLastUpdated__c = 'Within the last year';
        specialEducation.Gifted__c = 'Documenting';
        update specialEducation;
        System.assertEquals(specialEducation.IEP__c ,'Documenting');
        Test.stopTest();
    }
}