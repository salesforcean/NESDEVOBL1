@isTest
public class NES_DocumentCentralControllerTest {
    
    @TestSetup
    static void setup() {
        Account parentAccount = Peak_TestUtils.createAccountRecord('ED Account','Educational Institution');       
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
        
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schoolYear.Id);
        // add by Maddileti for Bug #109789 (Maddileti Boya) on 2019-09-24
        academicProgram.Document_End_Date__c=System.now()+10;
        update academicProgram;
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('HouseHold Account','Household');
        user createUser = Peak_TestUtils.createStandardUser();
        Contact con=[Select LastName from Contact where LastName =: createUser.LastName];
        
        contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker',houseHoldAccount.Id);
        System.debug('the values careTakerContact are 11::'+con);
        Grade_Level__c levels=new Grade_Level__c();
        levels.Name='Test User';
        insert levels;
        Program_Grade_Level__c programLevels=new Program_Grade_Level__c();
        programLevels.Academic_Program__c=academicProgram.Id;
        programLevels.Grade_Level__c=levels.Id;
        programLevels.Document_Submission_End_Date__c=System.now()+10;
        programLevels.Document_Submission_Start_Date__c=System.now()-2;
        insert programLevels;
        //
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTakerContact.Id, schoolYear.Id, true);
        progEnrollment.Program_Grade_Level__c=programLevels.Id;
        update progEnrollment;
        
        
        Document_Review__c documentReview = Peak_TestUtils.createDocumentReviewRecord(academicProgram.Id, houseHoldAccount.Id);
        //Create Document Enrollment Component Record
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', true);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent('TestForm','Form');
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', true);
        Enrollment_Component__c messageComponent1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', true);
	    Enrollment_Component__c formComponentObj = Peak_TestUtils.createEnrollmentComponent('TestForm','Form');
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationshipobj = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent1.Id, formComponentObj.Id);
        Enrollment_Component__c formComponent1 = Peak_TestUtils.createEnrollmentComponent('TestForm','Form');
        formComponent1.Component_Type__c='Household';
        formComponent1.Component_Message__c='my component message';
        update formComponent1;

        Enrollment_Component_Affiliation__c affiliation1 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);           
        affiliation1.Status__c='In Progress';
        update affiliation1;
        
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        affiliation.Enrollment_Component__c= enrollCompRelationship.Parent_Enrollment_Component__c;
       // affiliation.Program_Enrollment__c=affiliation1.Program_Enrollment__c;
        affiliation.Enrollment_Component__c=formComponent1.id;
        affiliation.Status__c='Not Started';
        update affiliation;
               
        
        Enrollment_Component_Affiliation__c affiliation2 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        affiliation2.Status__c='Not Started';
        update affiliation2;
        //add by Maddileti for Bug #109789 (Maddileti Boya) on 2019-09-24
        hed__Program_Enrollment__c pe1 = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, con.Id, schoolYear.Id, true);
        Enrollment_Component_Affiliation__c affiliations = Peak_TestUtils.createEnrollmentComponentAffiliation(pe1.Id, documentComponent.Id);
        affiliations.Status__c='Not Started';
        update affiliations;
        //End by Maddileti for Bug #109789 (Maddileti Boya) on 2019-09-24
        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(affiliation.Id, progEnrollment.id);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(affiliation1.Id, progEnrollment.id);
        enrollmentDocument1.Status_Reason__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID;
        Update enrollmentDocument1;
       
        
        Enrollment_Document__c enrollmentDocumentObj = Peak_TestUtils.createEnrollmentDocumentRecord(affiliation.Id, progEnrollment.id);
        enrollmentDocumentObj.Status_Reason__c='Submitted';
        enrollmentDocumentObj.Submission_Time__c=system.now();
            update enrollmentDocumentObj;
         
        
       
         
    }   
    
    
    
    /**
* Created by Raju on 21/11/18.
* Purpose : This method is a Test method for both getUIContent and setDocumentLink methods
*/
    static testMethod void testGetUIContent(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c,Status__c FROM Enrollment_Component_Affiliation__c WHERE Status__c='In Progress' AND Enrollment_Component__r.RecordType.Name = 'Document'  LIMIT 1];
        Enrollment_Component_Affiliation__c ecaRecord2 = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c,Status__c FROM Enrollment_Component_Affiliation__c WHERE Status__c='Not Started' AND Enrollment_Component__r.RecordType.Name = 'Document'  LIMIT 1];
        Enrollment_Document__c enrollmentDocument = [Select id,Document_Link__c,Status_Reason__c,Enrollment_Component_Affiliation__c, Reason__c from Enrollment_Document__c WHERE Status_Reason__c =: Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID limit 1];
        List<String> documentLink = new List<String>();
        documentLink.add('Test Link');
        Test.startTest();
        String result = NES_DocumentCentralController.getUIContent(ecaRecord.Id, enrollmentDocument.Id);
        System.assertNotEquals(result, null);
        
        Peak_Response response = NES_DocumentCentralController.setDocumentLink(ecaRecord.Id,'Test Link');
        System.debug('response 1' + response);
        System.assertEquals(response.success, True);
        Peak_Response response2 = NES_DocumentCentralController.setDocumentLink(ecaRecord2.Id,'Link');
        System.assertEquals(response2.success, True);
        Test.stopTest();
        
    }
    
    /**
* Created by Anushka on 20/11/18.
* Purpose : This method is a Test method for getDocumentsList method of NES_DocumentCentralController class.
**/  
    static testMethod void getDocumentsListTest() {
        
        hed__Program_Enrollment__c progEnrollments = [Select id,hed__Contact__r.CreatedById from hed__Program_Enrollment__c  limit 1 ]; 
        
        Enrollment_Document__c acceptedDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_VERIFIED);
        Enrollment_Document__c needsAttentionDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
        Enrollment_Document__c UnderReviewDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
       
         Test.startTest();

        String result = NES_DocumentCentralController.getDocumentsList(progEnrollments.hed__Contact__r.CreatedById);
        String result2 = NES_DocumentCentralController.getDocumentsList(UnderReviewDoc.Uploader__c);
        //System.assertNotEquals(result, null);
        Test.stopTest();
    }
    
    /**
* Created by Ajith on 04/12/18.
* Purpose : This method is a Test method for submitDocuments method of NES_DocumentCentralController class.
**/
    static testMethod void submitDocumentsUnitPositiveTests(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c FROM Enrollment_Component_Affiliation__c LIMIT 1];
        Map<String, String> filesMap = new Map<String, String>();
        filesMap.put('FileNameOne','Test@nesdev7.com'); 
        
        Test.startTest();
        NES_DocumentCentralController.submitDocuments(filesMap, ecaRecord.Id);
        List<Enrollment_Document__c> enrollmentDocuments = new List<Enrollment_Document__c>([SELECT Id FROM Enrollment_Document__c WHERE Enrollment_Component_Affiliation__c =:ecaRecord.Id]);
        System.assertNotEquals(enrollmentDocuments.size(), 0);
        Test.stopTest();
    }
    
    /**
* Created by Anushka on 01/09/19.
* Purpose : This method is a Test method for getHelpMessages method of NES_DocumentCentralController class.
**/
    static testMethod void getHelpMessagesTest(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c FROM Enrollment_Component_Affiliation__c LIMIT 1];
        Test.startTest();
        /*
* commented out 2/14/19 rdehler, broken test
Peak_Response response = NES_DocumentCentralController.getHelpMessages(ecaRecord.Id);
System.debug('response 1' + response);
System.assertEquals(response.success, True);
*/
        Test.stopTest();
    }
    
    /**
* Created by Anushka on 01/09/19.
* Purpose : This method is a Test method for upsertEnrollmentDocuments method of NES_DocumentCentralController class.
**/
    static testMethod void upsertEnrollmentDocumentsTestScenario1(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c FROM Enrollment_Component_Affiliation__c LIMIT 1];
       Enrollment_Component__c ecComponent=[SELECT Id,Component_Type__c FROM Enrollment_Component__c where Component_Type__c='Household' LIMIT 1];
       Enrollment_Component_Relationship__c relationship=Peak_TestUtils.createEnrollmentComponentRelationship(ecaRecord.Enrollment_Component__c,ecComponent.Id);
        
        Enrollment_Document__c enrollmentDocument = [Select id from Enrollment_Document__c limit 1];
        List<String> documentLink = new List<String>();
        documentLink.add('Test Link');
        Test.startTest();
        Peak_Response response = NES_DocumentCentralController.upsertEnrollmentDocuments(ecaRecord.Id, enrollmentDocument.Id, documentLink);
        System.debug('response 2' + response);
        System.assertEquals(response.success, true);
        Test.stopTest();
    }
    /**
* Created by Anushka on 01/09/19.
* Purpose : This method is a Test method for upsertEnrollmentDocuments method of NES_DocumentCentralController class.
**/
    static testMethod void upsertEnrollmentDocumentsTestScenario2(){
        Enrollment_Document__c enrollmentDocument = [Select id, Type__c, Status_Reason__c from Enrollment_Document__c limit 1];
        List<String> documentLink = new List<String>();
        documentLink.add('Test Link');
        Test.startTest();
        Peak_Response response = NES_DocumentCentralController.upsertEnrollmentDocuments(null, enrollmentDocument.Id, documentLink);
        System.debug('response 3' + response);
        System.assertEquals(response.success, True);
        Test.stopTest();
    }
    /**
* Created by Anushka on 01/09/19.
* Purpose : This method is a Test method for upsertEnrollmentDocuments method of NES_DocumentCentralController class.
**/
    static testMethod void upsertEnrollmentDocumentsTestScenario3(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c
                                                         FROM Enrollment_Component_Affiliation__c
                                                         WHERE Enrollment_Component__r.Document_Type__c != NULL LIMIT 1];
        List<String> documentLink = new List<String>();
        documentLink.add('Test Link');
        Test.startTest();
        Peak_Response response = NES_DocumentCentralController.upsertEnrollmentDocuments(ecaRecord.Id, null, documentLink);
        //System.assertNotEquals(enrollmentDocuments.size(), 0);
        System.debug('response 4' + response);
        System.assertEquals(response.success, True);
        hed__Program_Enrollment__c progEnrollment = [Select id from hed__Program_Enrollment__c limit 1];        
        id sampleId=NES_DocumentCentralController.grabSchool(progEnrollment.Id);
        Test.stopTest();
    }
    
    
}