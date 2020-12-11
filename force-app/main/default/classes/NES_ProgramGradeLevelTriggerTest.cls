/**
* Created by Anushka Bansal on 23-12-2018.
*/

@IsTest
public with sharing class NES_ProgramGradeLevelTriggerTest {
    @TestSetup static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('Waitlist Flag Calculation', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        system.debug(academicProgramaccount + 'academicProgramaccount');
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('TestGrade', true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',academicProgramAccount.Id, gradeLevel.Id, System.now(), false);
        programGradeLevel.ActivateWaitlist__c = True;
        programGradeLevel.StartWaitlist__c = System.today();
        programGradeLevel.EndWaitlist__c = System.today();
        insert programGradeLevel;
        Opportunity optyTest1 = Peak_TestUtils.createOpportunity('oldOpty',account.Id,System.Today(),'Open',False);
        optyTest1.Semester_Indicator__c='First';
        optyTest1.Final_Semester_Indicator__c='Second';
        optyTest1.Earliest_Final_Confirmation_Date__c=System.today();
        optyTest1.Program_Enrollment__c=progEnrollment.Id;
        Insert  optyTest1;

    }

    /**
    * Created By Anushka 23/12/2018
    * Purpose : Test waitlistCalculator method on insert
    */
    static testMethod void testInsertProgramGradeLevel(){

        Account acc = [Select id from Account limit 1];
        system.debug('academic ' + acc);
        Grade_Level__c gradeLevel = [select id from Grade_Level__c];
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',acc.Id, gradeLevel.Id, System.now(), false );
        Test.startTest();
        insert programGradeLevel;
        System.assertNotEquals(programGradeLevel, null);
        Test.stopTest();
    }


     /**
    * Created By Anushka 23/12/2018
    * Purpose : Test waitlistCalculator method on update
    */
    static testMethod void testUpdateProgramGradeLevel(){
        Program_Grade_Level__c programGradeLevel = [Select id, ActivateWaitlist__c  from Program_Grade_Level__c limit 1];
        programGradeLevel.ActivateWaitlist__c = True;
        Test.startTest();
        update programGradeLevel;
        System.assertEquals(programGradeLevel.ActivateWaitlist__c, True);
        Test.stopTest();
    }
}