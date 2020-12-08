/**
* Created by Anushka on 19/11/18.
* Purpose : Test class for NES_DashboardControllerTest class

*/
@isTest
public class NES_DashboardControllerTest { 
    
    @TestSetup
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));
        
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        
        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, true);
        
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);
        
        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        
        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(sectionComponent);
        componentList.add(formComponent);
        componentList.add(messageComponent);
        componentList.add(documentComponent);
        insert componentList;
        
        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship3 = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship4 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship5 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
        Enrollment_Component_Affiliation__c affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);
        
        // Create a Standard User
        
        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, schlYear.Id, false);
        insert ProgramEnrollmentTest;
        
    }
    
    
    /**
* Created by Anushka on 20/11/18.
* Purpose : This method is a Test method for getRelatedStudents method of NES_DashboardController class.
*/
    
    /*static testMethod void testGetRelatedStudents() {
        hed__Relationship__c  relationship = [SELECT hed__Contact__c  FROM hed__Relationship__c  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: relationship.hed__Contact__c  AND IsActive = TRUE LIMIT 1];
        
        System.runAs(u){
            List<NES_DashboardUtilities.StudentInformation> studentInformation =  NES_DashboardController.getAssociatedStudents();
            System.assertNotEquals(null,studentInformation );
            NES_DashboardController.getRelatedStudents(null);
            studentInformation =  NES_DashboardController.getRelatedStudents(UserInfo.getUserId());
            System.assertNotEquals(null,studentInformation );
        }
        
    }*/
    /**
* Created by Raju on 30/11/18.
* Purpose : This method is a Test method for both getTerminationReasons and terminateApplication methods of NES_DashboardController class.
*/
    static testMethod void testTerminateApplication() {
        hed__Program_Enrollment__c hpe = [SELECT Id, Status__c FROM hed__Program_Enrollment__c WHERE CreatedDate = TODAY LIMIT 1];
        Opportunity opty=Peak_TestUtils.createOpportunity(hpe.Id);
        Test.startTest();
        // NES_DashboardController.terminateApplication(opty.Id, 'Values To be added');
        //NES_DashboardController.getTerminationReasons();
        Test.stopTest();
    }
    /**
* Created by Raju on 06/12/18.
* Purpose : This method is a Test method for both getOpenCases and getClosedCases methods of NES_DashboardController class.

*/
    static testMethod void testgetClosedCases() {
        
        hed__Relationship__c  relationship = [SELECT hed__Contact__c  FROM hed__Relationship__c  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: relationship.hed__Contact__c  AND IsActive = TRUE  LIMIT 1];
        
        system.runAs(u){
            Test.startTest();
            Case caseRecord=Peak_TestUtils.createCase(relationship.hed__Contact__c,'In Progress');
            Case caseRecord1=Peak_TestUtils.createCase(relationship.hed__Contact__c,'Closed');
            //NES_DashboardController.getOpenCases();
            //NES_DashboardController.getClosedCases();
            Test.stopTest();
        }
    }
    
    //Created by Jagadeesh Bokam for US:216449
   /* static testMethod void getRelatedStudentsWithoutECATest() {
       
        hed__Relationship__c  relationship1 = [SELECT hed__Contact__c  FROM hed__Relationship__c  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: relationship1.hed__Contact__c  AND IsActive = TRUE LIMIT 1]; 
        
        List<Enrollment_Component_Affiliation__c> listEca = [select id from Enrollment_Component_Affiliation__c];
        delete listEca;
        
        System.runAs(u){
            List<NES_DashboardUtilities.StudentInformation> studentInformation =  NES_DashboardController.getAssociatedStudents();
            System.assertNotEquals(null,studentInformation );
            NES_DashboardController.getRelatedStudents(null);
            studentInformation =  NES_DashboardController.getRelatedStudents(UserInfo.getUserId());
            System.assertNotEquals(null,studentInformation );
        }
        
    }*/
    
    
    
    static testMethod void testGetRelatedStudentsInfo() {
        hed__Relationship__c  relationship = [SELECT hed__Contact__c  FROM hed__Relationship__c  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: relationship.hed__Contact__c  AND IsActive = TRUE LIMIT 1];
        
        System.runAs(u){
            List<NES_DashboardUtilities.StudentsInformation> studentInformation =  NES_DashboardController.getAssociatedStudentsInfo();
            System.assertNotEquals(null,studentInformation );
            
        }
        
    }
    
     static testMethod void testGetRelatedStudentsInfoInactivePE() {
        hed__Relationship__c  relationship = [SELECT hed__Contact__c  FROM hed__Relationship__c  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: relationship.hed__Contact__c  AND IsActive = TRUE LIMIT 1];
        hed__Program_Enrollment__c progEnrollment = [Select Id, Status__c from hed__Program_Enrollment__c limit 1];
        progEnrollment.Status__c ='Inactive';
        update progEnrollment;
        System.runAs(u){
            List<NES_DashboardUtilities.StudentsInformation> studentInformation =  NES_DashboardController.getAssociatedStudentsInfo();
            System.assertNotEquals(null,studentInformation );
            
        }
        
    }
        
    static testMethod void testUtilityMethods(){
        hed__Program_Enrollment__c progEnrollment = [Select Id,hed__Account__r.ITR_Start_Date__c,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c limit 1];
        List<Account> academicPrograms = [Select Id, Name, ParentId, Registration_Start_Date__c,recordType.Name, Registration_End_Date__c from Account where  recordType.Name = 'Academic Program'];
        progEnrollment.Status__c =NES_DashboardUtilities.INACTIVE_STATUS;
        NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        progEnrollment.Status__c =NES_DashboardUtilities.COMPLETE_STATUS;
        NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        progEnrollment.Status__c =NES_DashboardUtilities.WITHDRAWN_STATUS;
        NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        NES_DashboardHelper.getGradeLevel('K');
        NES_DashboardHelper.getGradeLevel('1');
        NES_DashboardHelper.getGradeLevel('2');
        NES_DashboardHelper.getGradeLevel('3');
		NES_DashboardHelper.getGradeLevel('4');        
    } 
    
}