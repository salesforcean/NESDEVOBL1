/** 

    @author: Ali KM (Ness Tech)
    * Created this test class on 04/17/2020 for [US 166761]
    * Test coverage for 
        => NES_ECDataImportExport.cls (86% coverage)
        => NES_EnrollmentCompentBuilder.cls (100% coverage)

*/

@isTest(SeeAllData=false isParallel=true)
public with sharing class NES_ECDataImportExportTest {

    @TestSetup 
    static void setup() {

        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        // School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));


        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);


        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        academicProgram.Registration_End_Date__c=Date.today().addMonths(1);
        academicProgram.Registration_Start_Date__c=Date.newInstance(2017,11,11);
        academicProgram.Confirmation_End_Date__c = Date.today().addMonths(1);
        update academicProgram;


        // Create STUDENT PE
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, false);
        progEnrollment.Status__c='Inactive';
        insert progEnrollment;


        // NOT SURE WHY WE NEED Relationship
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);


        // Create nodes (w/ECs)
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false); // Level 1 process
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false); // Level 2 stages 
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false); // Level 3 forms
        // Level 4 sections
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c documentComponentForForm = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        // Level 5 questionGroups / questions (for sections)
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        Enrollment_Component__c questionComponentForSection1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false); 
        Enrollment_Component__c questionComponentForSection2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c messageComponentForSection = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        // Level 6 questions 
        Enrollment_Component__c questionComponentForQG1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c questionComponentForQG2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c questionComponentForQG3 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        

        // insert nodes
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        componentList.add(processComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(sectionComponent);
        componentList.add(documentComponentForForm);
        componentList.add(questionGroupComponent);
        componentList.add(questionComponentForSection1);
        componentList.add(questionComponentForSection2);
        componentList.add(messageComponentForSection);
        componentList.add(questionComponentForQG1);
        componentList.add(questionComponentForQG2);
        componentList.add(questionComponentForQG3);
        insert componentList;
        

        // tie the nodes (by ECRs)
        Enrollment_Component_Relationship__c stageECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id); // level-1
        Enrollment_Component_Relationship__c formECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id); // level-2
        Enrollment_Component_Relationship__c sectionECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id); // level-3
        Enrollment_Component_Relationship__c documentECR = Peak_TestUtils.createEnrollmentComponentRelationship(documentComponentForForm.Id, formComponent.Id); // level-3
        
        Enrollment_Component_Relationship__c questionGroupECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c questionToSectionECR1 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForSection1.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c questionToSectionECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForSection2.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c messageToSectionECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponentForSection.Id, sectionComponent.Id); // level-4


        Enrollment_Component_Relationship__c questionGroupECR1 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG1.Id, questionGroupComponent.Id); // level-5
        Enrollment_Component_Relationship__c questionGroupECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG2.Id, questionGroupComponent.Id); // level-5
        Enrollment_Component_Relationship__c questionGroupECR3 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG3.Id, questionGroupComponent.Id); // level-5
        
    }

    static testMethod void processExport_Positive() {

        // fetch the processID
        Enrollment_Component__c processEC = [SELECT Id, 
                                                    Name, 
                                                    Description__c, 
                                                    Process_Academic_Program__c, 
                                                    RecordTypeId
                                            FROM    Enrollment_Component__c 
                                            WHERE   Process_Academic_Program__c != null
                                            ORDER BY CreatedDate DESC][0];

        
        Test.startTest(); // Export the process
            NES_EnrollmentCompentBuilder.enrollmentComponentData ecData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processEC.Id);
            Id exportRecID = NES_ECDataImportExport.ExportData(ecData);
        Test.stopTest();
        
        // check if export was successful
        System.assertNotEquals(null, exportRecID, 'test export failed, ecrTree export returned null ID.');

        // compare the ecrTree record with processEC
        ecrTree__c exportRec = NES_ECDataImportExport.getECRTreeByParentIDs(processEC.Id, NES_ECDataImportExport.EC_DATA_CLASS_TYPE);
        System.assertNotEquals(null, exportRec, 'process export failed, no ecrTree__c record found.');

    }

    static testMethod void processExport_Negative() {

        Test.startTest(); // Export the process
            String processId ='a2921000001pR9wAZZ'; // some random ID
            NES_EnrollmentCompentBuilder.enrollmentComponentData ecData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processId);
            Id exportRecID = NES_ECDataImportExport.ExportData(ecData);
        Test.stopTest();

        System.assertNotEquals(null, exportRecID); // should be null for -ve scenarios

    }

    static testMethod void processImport_Positive() {

        // fetch the processID
        Enrollment_Component__c processEC = [SELECT Id, 
                                                    Name, 
                                                    Description__c, 
                                                    Process_Academic_Program__c, 
                                                    RecordTypeId
                                            FROM    Enrollment_Component__c 
                                            WHERE   Process_Academic_Program__c != null
                                            ORDER BY CreatedDate DESC][0];

        // Export the process
        NES_EnrollmentCompentBuilder.enrollmentComponentData ecData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processEC.Id);
        Id exportRecID = NES_ECDataImportExport.ExportData(ecData);

        // check if export was successful
        System.assertNotEquals(null, exportRecID, 'test export failed, ecrTree export returned null ID.');

        Test.startTest(); // Import the process
			NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processEC.Id);
        Test.stopTest();

        // assert to check if data actually got queried
        System.assertNotEquals(0, thisProcessData.allIds.size(), 'thisProcessData.allIds not found');
        System.assertNotEquals(0, thisProcessData.componentOrderMap.size(), 'thisProcessData.componentOrderMap not found');
        System.assertNotEquals(0, thisProcessData.questionParentIds.size(), 'thisProcessData.questionParentIds not found');
        System.assertNotEquals(0, thisProcessData.stageRelationships.size(), 'thisProcessData.stageRelationships not found');
        System.assertNotEquals(0, thisProcessData.formRelationships.size(), 'thisProcessData.formRelationships not found');
        System.assertNotEquals(0, thisProcessData.sectionRelationships.size(), 'thisProcessData.sectionRelationships not found');
        System.assertNotEquals(0, thisProcessData.questionGroupRelationships.size(), 'thisProcessData.questionGroupRelationships not found');
        System.assertNotEquals(0, thisProcessData.questionRelationships.size(), 'thisProcessData.questionRelationships not found');
        

    }

    static testMethod void processImport_Negative() {

        // fetch the processID
        Enrollment_Component__c processEC = [SELECT Id, 
                                                    Name, 
                                                    Description__c, 
                                                    Process_Academic_Program__c, 
                                                    RecordTypeId
                                            FROM    Enrollment_Component__c 
                                            WHERE   Process_Academic_Program__c != null
                                            ORDER BY CreatedDate DESC][0];

        Test.startTest(); // Import the process
            // Export the process w/out importing it. So basically there is no ecrTree_c record for this process.
            NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
            NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processEC.Id);
            // NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processEC.Id);
        Test.stopTest();
        
        // compare the ecrTree record with processEC, shouldn't be the case.
        try {
            ecrTree__c exportRec = NES_ECDataImportExport.getECRTreeByParentIDs(processEC.Id, NES_ECDataImportExport.EC_DATA_CLASS_TYPE);
        } catch (ListException ex) {
            
            System.assertEquals('List index out of bounds: 0', ex.getMessage(), 'should have failed');
        }

        // assert to check if data actually got queried
        System.assertNotEquals(0, thisProcessData.allIds.size(), 'thisProcessData.allIds not found');
        System.assertNotEquals(0, thisProcessData.componentOrderMap.size(), 'thisProcessData.componentOrderMap not found');
        System.assertNotEquals(0, thisProcessData.questionParentIds.size(), 'thisProcessData.questionParentIds not found');
        System.assertNotEquals(0, thisProcessData.stageRelationships.size(), 'thisProcessData.stageRelationships not found');
        System.assertNotEquals(0, thisProcessData.formRelationships.size(), 'thisProcessData.formRelationships not found');
        System.assertNotEquals(0, thisProcessData.sectionRelationships.size(), 'thisProcessData.sectionRelationships not found');
        System.assertNotEquals(0, thisProcessData.questionGroupRelationships.size(), 'thisProcessData.questionGroupRelationships not found');
        System.assertNotEquals(0, thisProcessData.questionRelationships.size(), 'thisProcessData.questionRelationships not found');

    }

}