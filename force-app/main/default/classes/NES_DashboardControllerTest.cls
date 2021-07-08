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
        academicProgram.ITR_Start_Date__c = system.today() - 10;
        academicProgram.ITR_End_Date__c = system.today() + 10;
        update academicProgram;
        Grade_Level__c gradeLevel12 = Peak_TestUtils.createGradeLevel('12', true);
        Grade_Level__c gradeLevel1 = Peak_TestUtils.createGradeLevel('1', true);
        Program_Grade_Level__c programGradeLevelTwelth = Peak_TestUtils.createProgramGradeLevel('Twelth Grade',academicProgram.Id, gradeLevel12.Id, System.now(), false);
        insert programGradeLevelTwelth;
        Program_Grade_Level__c programGradeLevelFirst = Peak_TestUtils.createProgramGradeLevel('First Grade',academicProgram.Id, gradeLevel1.Id, System.now(), false);
        insert programGradeLevelFirst;
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
* Created by Raju on 30/11/18.
* Purpose : This method is a Test method for both getTerminationReasons and terminateApplication methods of NES_DashboardController class.
**/
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
**/
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
    
    static testmethod void testITRUtilities(){
        Id studentContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<Contact> studentRec = [Select Id, FirstName,AccountId, LastName,RecordTypeId from contact where RecordTypeId =:studentContactRT];
        List<hed__program_enrollment__c> peList = [Select Id,Start_Year__c,Program_Grade_Level__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId, OwnerId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType];
        NES_ITRUtilities.ITRResults response = NES_DashboardController.createITRforNextYear(studentRec[0].Id,peList[0].Id);                
    }
    static testMethod void testUtilityMethods(){
        string btnLbl ='';
        hed__Program_Enrollment__c progEnrollment = [Select Id,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.ITR_Start_Date__c,Program_Grade_Level__r.Grade_Level__r.Name,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c limit 1];
        List<Account> academicPrograms = [Select Id, Name, ParentId, Registration_Start_Date__c,recordType.Name, Registration_End_Date__c from Account where  recordType.Name = 'Academic Program'];
        progEnrollment.Status__c =NES_DashboardUtilities.INACTIVE_STATUS;
        btnLbl = NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        system.assertEquals(btnLbl, 'Reactivate');
        progEnrollment.Status__c =NES_DashboardUtilities.COMPLETE_STATUS;
        btnLbl = NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        system.assertEquals(btnLbl, 'TELL US ABOUT NEXT YEAR');

        //progEnrollment.Status__c =NES_DashboardUtilities.WITHDRAWN_STATUS;
        //btnLbl = NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        //system.assertEquals('Contact Us',btnLbl );
        NES_DashboardHelper.getGradeLevel('K');
        NES_DashboardHelper.getGradeLevel('1');
        NES_DashboardHelper.getGradeLevel('2');
        NES_DashboardHelper.getGradeLevel('3');
        NES_DashboardHelper.getGradeLevel('4');        
    } 
    
    static testMethod void testITRExceptionTest(){
    NES_DashboardHelper.getButtonLabelName(new hed__Program_Enrollment__c(),new List<Account>()); 
 }
    static testMethod void testITRException(){
        hed__Program_Enrollment__c progEnrollment = [Select Id,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.ITR_Start_Date__c,Program_Grade_Level__r.Grade_Level__r.Name,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c limit 1];
        List<Account> academicPrograms = [Select Id, Name, ParentId,ITR_Start_Date__c,ITR_End_Date__c, Registration_Start_Date__c,recordType.Name, Registration_End_Date__c from Account where  recordType.Name = 'Academic Program'];
        List<Program_Grade_Level__c> PGLTwelthGrade = [Select Id, Grade_Level__c,Grade_Level__r.Name from  Program_Grade_Level__c];
        progEnrollment.Status__c =NES_DashboardUtilities.INACTIVE_STATUS;
        NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);
        progEnrollment.Status__c =NES_DashboardUtilities.COMPLETE_STATUS;
        progEnrollment.ITR_Eligibility_NY__c = 'Yes';
        progEnrollment.Program_Grade_Level__c = PGLTwelthGrade[0].Id;  
        test.startTest();
        update progEnrollment;
        String buttonLbl1 = NES_DashboardHelper.getButtonLabelName([Select Id,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.ITR_Start_Date__c,Program_Grade_Level__r.Grade_Level__r.Name,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c Where id =: progEnrollment.Id limit 1],academicPrograms);
        system.assertEquals('TELL US ABOUT NEXT YEAR', buttonLbl1);
        progEnrollment.ITR_Exception_Date_NY__c = system.today() +5;
        progEnrollment.ITR_Eligibility_NY__c = '';
        update progEnrollment;
        String buttonLbl2 = NES_DashboardHelper.getButtonLabelName([Select Id,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.ITR_Start_Date__c,Program_Grade_Level__r.Grade_Level__r.Name,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c Where id =: progEnrollment.Id limit 1],academicPrograms);
        system.assertEquals('Complete', buttonLbl2);
        academicPrograms[0].ITR_Start_Date__c = system.today() -10;
        academicPrograms[0].ITR_End_Date__c = system.today() -1;
        update academicPrograms;
        List<Program_Grade_Level__c> PGLFirstGrade = [Select Id, Grade_Level__c,Grade_Level__r.Name from  Program_Grade_Level__c where Grade_Level__r.Name = '1'];
        progEnrollment.Program_Grade_Level__c = PGLFirstGrade[0].Id;  
        update progEnrollment;
        String buttonLbl3 = NES_DashboardHelper.getButtonLabelName([Select Id,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.ITR_Start_Date__c,Program_Grade_Level__r.Grade_Level__r.Name,hed__Account__r.ITR_End_Date__c, Status__c from hed__Program_Enrollment__c Where id =: progEnrollment.Id limit 1],[Select Id, Name, ParentId,ITR_Start_Date__c,ITR_End_Date__c, Registration_Start_Date__c,recordType.Name, Registration_End_Date__c from Account where recordType.Name = 'Academic Program' and id =:academicPrograms[0].Id]);
        system.assertEquals('TELL US ABOUT NEXT YEAR', buttonLbl3);
        progEnrollment.Status__c =NES_DashboardUtilities.WITHDRAWN_STATUS;
        //NES_DashboardHelper.getButtonLabelName(progEnrollment,academicPrograms);       
        //String buttonLbl4 = NES_DashboardHelper.getButtonLabelName(progEnrollment,new List<Account>());
        //system.assertEquals('Contact Us', buttonLbl4);
        test.stopTest();
        List<Peak_Apex_Log__c> apLogs= [select id from Peak_Apex_Log__c];
        system.assertEquals(0,apLogs.size());
    } 
    
}