/**
 * Created by Anushka Bansal on 19-12-2018.
 */

@IsTest
public with sharing class NES_PlacementAndElectiveTriggerTest {
    @TestSetup static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
         academicProgramAccount.Electives_Exclude_from_Auto_Course_Sel__c = 'Art;Music'; //added by anitha P US 117571
        Update academicProgramAccount;
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        //added
          Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment.Id, currentSchoolYear.Id, true);
        
        
    }
    /**
     * Created By Anushka 19/12/2018
     * Purpose : To test CalculateLTS method on Insert
     */
    static testMethod void testInsertCalculateLTS(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        Test.startTest();
        Placement_and_Elective__c pne = Peak_TestUtils.createPlacementAndElective(progEnrollment.Id,false);
        pne.Course_Requested__c = 'World History';
        insert pne;
        System.assertEquals(pne.Course_Requested__c,'World History');
        Test.stopTest();
    }

    /**
     * Created By Anushka 19/12/2018
     * Purpose : To test CalculateLTS method on Update
     */
    static testMethod void testUpdateCalculateLTS(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        Placement_and_Elective__c pne = Peak_TestUtils.createPlacementAndElective(progEnrollment.Id,true);
        Test.startTest();
        pne.Course_Requested__c = 'World History';
        pne.Level_Requested__c = 'Advanced';
        update  pne;
        System.assertEquals(pne.Course_Requested__c,'World History');
        Test.stopTest();
    }
    
     /**
     * Created By AnithaP 15/11/2019 for US  117571 (Task #118637)
     * Purpose : To test excludeAutoCourseFromASI method 
     */
    static testMethod void testexcludeAutoCourseFromASI(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];   
        Test.startTest();
        Placement_and_Elective__c pne = Peak_TestUtils.createPlacementAndElective(progEnrollment.Id,false);
        pne.Course_Requested__c = 'Music';
        insert pne;
        Annual_Student_Information__c asi = [select ID ,Exclude_AutoCourse__c from Annual_Student_Information__c
                                            where Program_Enrollment__c = :progEnrollment.id];
        Test.stopTest();
        System.assertEquals(asi.Exclude_AutoCourse__c,true);
       
    }
    
    static testMethod void testRunPlacment(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];   
        Placement_and_Elective__c pne = Peak_TestUtils.createPlacementAndElective(progEnrollment.Id,true);
        Test.startTest();
        pne.Course_Requested__c = null;
        NES_Constants.runAssignment = true;
        update  pne;
        Test.stopTest();
    }
    
}