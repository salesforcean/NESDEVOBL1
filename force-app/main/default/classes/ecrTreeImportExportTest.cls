/** 

    @author: Ali KM (Ness Tech)
    * Created this test class on 05/18/2020 for [US 166761]
    * Test coverage for: 
        => ecrTreeImportExport.cls (83% coverage)
        => ecrTreeViewerController (% coverage)
        => ecrTreeGenerator (84% coverage)
        => ecrTreeParser (86% coverage)
        => ecrConsumerFormat (100% coverage)
        => ecrProducerFormat (92% coverage)
        => ecNode (100% coverage)
        => ecrTreeUtils (91% coverage)
        => ecNodeQueue (93% coverage)

*/
@isTest(SeeAllData=false isParallel=true)
public with sharing class ecrTreeImportExportTest {
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

    static testMethod void ecrTreeViewerController_Test() {

        List<Map<String, String>> academicProgramOptions;
        Enrollment_Component__c academicProgramEC;

        Enrollment_Component__c processEC 
                                    = [ SELECT Id, 
                                            Name, 
                                            Description__c, 
                                            Process_Academic_Program__c, 
                                            RecordTypeId
                                        FROM    Enrollment_Component__c 
                                        WHERE   Process_Academic_Program__c != null
                                        ORDER BY CreatedDate DESC ][0];

        Test.startTest();
            // for method: getProcessOptions
             academicProgramOptions = ecrTreeViewerController.getProcessOptions();

            // for method: getProcessECById
            academicProgramEC = ecrTreeViewerController.getProcessECById(processEC.Id);
        Test.stopTest();

        System.assertNotEquals(0, academicProgramOptions.size());
        System.assertEquals(processEC.Id, academicProgramEC.Id);

    }

    static testMethod void ecNodeQueue_Test() {

        ecNodeQueue q = new ecNodeQueue();
        Map<Id, ecNode> ecsMap = new Map<Id, ecNode>();

        for (Enrollment_Component__c ec: [ SELECT Id, Name, Assignment_Logic__c, RecordTypeId, 
            RecordType.Name, Completion_Logic__c, Is_Required__c, External_Id__c 
                FROM Enrollment_Component__c ORDER BY CreatedDate DESC LIMIT 5]) 
        {
            q.enqueue(new Map<Id, ecNode>{ ec.Id => (new ecNode(ec, 1))});
        }                           
        
        q.size();
        q.peek();
        q.dequeue();
        q.dequeue();
        q.isEmpty();
        q.peek();

    }

    static testMethod void processExport_Positive() {

        // fetch the processID
        Enrollment_Component__c processEC 
                                    = [ SELECT Id, 
                                            Name, 
                                            Description__c, 
                                            Process_Academic_Program__c, 
                                            RecordTypeId
                                        FROM    Enrollment_Component__c 
                                        WHERE   Process_Academic_Program__c != null
                                        ORDER BY CreatedDate DESC ][0];

        
        Test.startTest(); // Export the process
            String treeString = ecrTreeImportExport.ExportTree(processEC.Id);
        Test.stopTest();
        
        // check if export was successful
        System.assertNotEquals('Something went wrong with export, Please reach out support Admin.', 
                                    treeString, 'test export failed, ecrTree export returned null ID.');


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
        String treeString = ecrTreeImportExport.ExportTree(processEC.Id);
        // check if export was successful
        System.assertNotEquals('Something went wrong with export, Please reach out support Admin.', 
                                        treeString, 'test export failed, ecrTree export returned null ID.');
        
        Test.startTest(); // Import the process
            ecrConsumerFormat processTree = ecrTreeImportExport.ImportTree(processEC.Id);
        Test.stopTest();

    }

    static testMethod void getProcessTree_Positive() {

        // fetch the processID
        Enrollment_Component__c processEC 
                                    = [ SELECT Id, 
                                            Name, 
                                            Description__c, 
                                            Process_Academic_Program__c, 
                                            RecordTypeId
                                        FROM    Enrollment_Component__c 
                                        WHERE   Process_Academic_Program__c != null
                                        ORDER BY CreatedDate DESC ][0];

        
        Test.startTest(); // Export the process
            ecNode nodeTree = ecrTreeImportExport.getProcessTree(processEC.Id);
        Test.stopTest();
        
        // check if export was successful
        System.assertNotEquals(null, nodeTree, 'test export failed, ecrTree export returned null ID.'); 

    }

}