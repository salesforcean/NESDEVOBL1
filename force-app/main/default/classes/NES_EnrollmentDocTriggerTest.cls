/**
* Created by Raju on 01-12-2018.
* Purpose : Test class for NES_EnrollmentDocBusinessLogic class.
* Change Log:
*         2019-08-14 initial for #101932 User Story (Chinnamanaidu Neerasa)
*         2019-09-6 initial for #101932 User Story (Chinnamanaidu Neerasa)
*         Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-10
 * Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
 *         added 2019-11-18 initial for #113765 User Story (Chinnamanaidu Neerasa)
 *      2020-04-23 Test setup and method for US 125320 (Krishna Peddanagammol)
*/
@isTest
public class NES_EnrollmentDocTriggerTest {
    @TestSetup
    static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged',true);
        
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'EnrollmentDocTrigger' , Active__c = true);
        insert logicSwitch ;
        
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged',true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Last Document Upload Date', true);
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Testy5', 'Household'); 
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        Contact TestContact = Peak_TestUtils.createTestContact();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, true);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = 'Charter School Notification Form';
        enrollmentDocument1.Status_Reason__c = 'Submitted';
        update enrollmentDocument1;
        
        Annual_Student_Information__c annualStudentInformation = Peak_TestUtils.createAnnualStudentInformation('Test ASI',ProgramEnrollmentTest.Id,schlYear.Id,true);
        
        Document_Review__c documentReview = Peak_TestUtils.createDocumentReviewRecord(academicAccount.Id, houseHoldAccount.Id);
        
        School_Year__c pSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('PreviousYear',System.today().addYears(-1));
        
        
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,pSchoolYear.Id, false);
        progEnrollment.Status__c = 'In Progress';
        progEnrollment.CounselingFlag__c = 'Stop';
        progEnrollment.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment.PORFlag__c ='Pending';
        progEnrollment.Start_Year__c = pSchoolYear.Id;
        progEnrollment.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.DisciplinaryFlagOverride__c = 'Pending Review';
        
        
        insert progEnrollment;
        
        hed__Program_Enrollment__c progEnrollmentHousehold = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,pSchoolYear.Id, false);
        progEnrollmentHousehold.Household_Program_Enrollment__c = progEnrollment.Id;
        Insert progEnrollmentHousehold;
        
        Opportunity newOpportunity = new Opportunity(
            Program_Enrollment__c = progEnrollment.Id,
            Name = Peak_TestConstants.OPP_NAME,
            StageName = 'Open',
            CloseDate = Peak_TestConstants.TODAY,
            Notes__c ='56988'
        );
        insert newOpportunity;
        
        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Stage', false);
        componentList.add(stageComponent);
        
        Enrollment_Component__c stageComponent2 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Process', false);
        stageComponent2.Component_Type__c = 'Household';
        componentList.add(stageComponent2);
        
        
        insert componentList;
        Enrollment_Component_Relationship__c componentRelationship = new Enrollment_Component_Relationship__c();
        componentRelationship.Parent_Enrollment_Component__c = stageComponent2.Id;
        componentRelationship.Child_Enrollment_Component__c = stageComponent.Id;
        componentRelationship.Order__c = 2;
        insert componentRelationship;
        
        Enrollment_Component_Relationship__c componentRelationship2 = new Enrollment_Component_Relationship__c();
        componentRelationship2.Parent_Enrollment_Component__c = stageComponent.Id;
        componentRelationship2.Child_Enrollment_Component__c = stageComponent2.Id;
        componentRelationship2.Order__c = 2;
        insert componentRelationship2;
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id, false);
        affiliationStage.Status__c = 'In Progress';
        enrollmentComponentAffiliations.add(affiliationStage);
        
        Enrollment_Component_Affiliation__c affiliationStage2 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollmentHousehold.Id, stageComponent2.Id, false);
        affiliationStage2.Status__c = 'Not Started';
        enrollmentComponentAffiliations.add(affiliationStage2);
        
        insert enrollmentComponentAffiliations;   
        
        // Test Setup for US#125320 by Krishna Peddanagammol on 2020-04-23 
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument2.Type__c = 'Immunization Records';
        enrollmentDocument2.Enrollment_Component_Affiliation__c = affiliationStage.Id;
        update enrollmentDocument2;
        
    }
    
    static testMethod void testReviewDocumentsBefore_InsertOne() {
        
        Account parentAccount = Peak_TestUtils.createAccountRecord('Testy4', 'Educational Institution');
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
        
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schoolYear.Id);
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Testy5', 'Household');
        
        contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccount.Id);
        
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTakerContact.Id, schoolYear.Id, true);
        
        Document_Review__c documentReview = Peak_TestUtils.createDocumentReviewRecord(academicProgram.Id, houseHoldAccount.Id);
        
        Test.startTest();
        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment.id, documentReview.id, false);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment.id);
        system.assertEquals(documentReview.id, enrollmentDocument.Document_Review__c);
        Test.stopTest();
    }
    
    //Added by Ritvik on 01/09/2019.
    static testMethod void testReviewDocumentsBefore_InsertTwo(){
        Contact contact = [Select id from Contact limit 1];
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        //Account academicAccount = [Select id from Account where RecordType.Name = 'Academic Program' limit 1];
        Account academicAccount = [Select id from Account where RecordTypeId = :RecordTypeId limit 1]; // Added by Anand
        
        Account householdAccount = [SELECT Id FROM Account WHERE Name = 'Testy5' LIMIT 1];
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id];
        Document_Review__c documentReview = [SELECT Id FROM Document_Review__c WHERE Academic_Program__c =: academicAccount.Id];
        documentReview.Status__c = 'In Progress';
        documentReview.Household__c = householdAccount.Id;
        documentReview.Queue_Type__c = 'Academic';
        update documentReview;
        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.Id,'','',false);
    }
    
    
    /**
*  Created by Anand on 07-12-2018.
* Purpose : Test class for NES_EnrollmentDocBusinessLogic class. updateDateReviewedMethod
*/
    
    static testMethod void updateFinalConfirmationDateTest() {
        Enrollment_Document__c enrollmentdocument = [select Id,Date_Reviewed__c,Status_Reason__c from Enrollment_Document__c Where Status_Reason__c = 'Submitted'];
        enrollmentDocument.Type__c = 'Charter School Notification Form';
        enrollmentdocument.Status_Reason__c = 'Submitted';
        update enrollmentdocument;
        Enrollment_Document__c endoc1 = [select Date_Reviewed__c from Enrollment_Document__c Where Id = :enrollmentdocument.Id];
        //Negative Testing
        enrollmentDocument.Type__c = 'Charter School Notification Form';
        enrollmentdocument.Status_Reason__c = 'Submitted';
        enrollmentdocument.Date_Reviewed__c = System.Now().addYears(-1);
        update enrollmentdocument;
        Enrollment_Document__c endoc2 = [select Date_Reviewed__c from Enrollment_Document__c Where Id = :enrollmentdocument.Id];
        System.assertNotEquals(System.Now(), endoc2.Date_Reviewed__c);
    }
    
    /**
*  Created by Anand on 07-12-2018.
* Purpose : Test class for NES_EnrollmentDocBusinessLogic class. updateStatusMethod
*/
    
    static testMethod void updateStatusTestOnInsert(){
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'HHPORStatus' , Active__c = true);
        insert logicSwitch ;
        Boolean eVal=NES_LogicFeatureSwitch__c.getValues('HHPORStatus').Active__c;
        System.assertEquals(True,eVal);
        hed__Program_Enrollment__c progEnrollment=[select id,HHPORStatus__c FROM hed__Program_Enrollment__c LIMIT 1];
        progEnrollment.HHPORStatus__c='Invalid-Denied';
        update progEnrollment;
        hed__Program_Enrollment__c  programEnrollment1=[select Id,HHPORStatus__c FROM hed__Program_Enrollment__c WHERE Id=:progEnrollment.Id];
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment1.Id,'Choice Transfer Form','Invalid-Denied',true);
        
        Enrollment_Document__c enrollmentDoc2=[select Id,Status_Reason__c FROM Enrollment_Document__c WHERE ID=:enrollmentDocument1.Id ];
        System.assertEquals(programEnrollment1.HHPORStatus__c,enrollmentDoc2.Status_Reason__c);
        // Negative Testing if HHPORStatus_c is Null Then Update Shouldnot Happen
        programEnrollment1.HHPORStatus__c='';
        update programEnrollment1;
        hed__Program_Enrollment__c  programEnrollment2=[select Id,HHPORStatus__c FROM hed__Program_Enrollment__c WHERE Id=:programEnrollment1.Id];
        
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment2.Id,'Choice Transfer Form','Invalid-Denied',true);
        Enrollment_Document__c enrollmentDoc3=[select Id,Status_Reason__c FROM Enrollment_Document__c WHERE ID=:enrollmentDocument2.Id ];
        
    }
    /**
*  Created by Anand on 07-12-2018.
* Purpose : Test class for NES_EnrollmentDocBusinessLogic class. updateStatusTestOnUpdate.
*/
    static testMethod void updateStatusTestOnUpdate(){
        // On Update of document Status field status should equals to programEnrollment HHPORStatus
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'HHPORStatus' , Active__c = true);
        insert logicSwitch ;
        Boolean eVal=NES_LogicFeatureSwitch__c.getValues('HHPORStatus').Active__c;
        System.assertEquals(True,eVal);
        hed__Program_Enrollment__c progEnrollment=[select id,HHPORStatus__c FROM hed__Program_Enrollment__c LIMIT 1];
        progEnrollment.HHPORStatus__c='Invalid-Illegible';
        update progEnrollment;
        hed__Program_Enrollment__c  programEnrollment1=[select Id,HHPORStatus__c FROM hed__Program_Enrollment__c WHERE Id=:progEnrollment.Id];
        
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment1.Id,'Proof of Residence','Invalid-Illegible',true);
        enrollmentDocument1.Status_Reason__c = 'Submitted';
        update enrollmentDocument1;
        
        
        Enrollment_Document__c enrollmentDoc2=[Select Id,Status_Reason__c FROM Enrollment_Document__c WHERE Id=:enrollmentDocument1.Id];
        System.assertEquals('Submitted', enrollmentDoc2.Status_Reason__c);
        System.assertNotEquals(enrollmentDoc2.Status_Reason__c,'Exemption');
        
    }
    /**
* Created By Anand
*
*/
    static testMethod void calculateWhyFlagTest(){
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1 ];
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment.Id,'Choice Transfer Form','Invalid-Denied',True);
        Enrollment_Document__c enrollmentDocument4 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment.Id,'Choice Transfer Form','Invalid-Denied',True);
        List<Enrollment_Document__c> enrollmentDocToUpdate = [Select Id,Status_Reason__c From Enrollment_Document__c Where Status_Reason__c LIKE 'Invalid%'];
        
        Enrollment_Document__c enrollmentDocTest= [SELECT Program_Enrollment__r.WhyFlagged__c FROM Enrollment_Document__c WHERE Id =:enrollmentDocToUpdate[0].Id];
        System.assertNotEquals(enrollmentDocTest.Program_Enrollment__r.WhyFlagged__c , 'Same');
    }
    
    
    static testMethod void docECAStatusUpdatesTest(){
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, PORFlag__c FROM hed__Program_Enrollment__c WHERE PORFlag__c ='Pending' LIMIT 1 ];
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>([SELECT Id FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c =:programEnrollment.Id]);
        System.debug('enrollmentComponentAffiliations++'+enrollmentComponentAffiliations);
        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment.id, null, null, false);
        
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations2 = new List<Enrollment_Component_Affiliation__c>([SELECT Id FROM Enrollment_Component_Affiliation__c WHERE Status__c ='Not Started']);
        System.debug('enrollmentComponentAffiliations++'+enrollmentComponentAffiliations);
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollment.id, null, null, false);
        Test.startTest();
        enrollmentDocument.Enrollment_Component_Affiliation__c = enrollmentComponentAffiliations[0].Id;
        insert enrollmentDocument;
        enrollmentDocument.Type__c = 'Charter School Notification Form';
        enrollmentDocument.Status_Reason__c = 'Verified';
        update enrollmentDocument;
        
        enrollmentDocument2.Enrollment_Component_Affiliation__c = enrollmentComponentAffiliations2[0].Id;
        insert enrollmentDocument2;
        Test.stopTest();
    }
    
    
    
    // Task number 104355(user story 101932), Chinnamnaidu Neerasa August 14,2019.
    static testMethod void updateDocumentECAStatusTest(){
        
        // Create Program Enrollment Document Record.
        Account account                            = Peak_TestUtils.createTestAccount();
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        Contact contact                            = Peak_TestUtils.createTestContact('Students', account.Id);
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c              = previousSchoolYear.Id;
        insert progEnrollment1;
        
        //create Enrollment Component Record
        Enrollment_Component__c enrollmentComp = new Enrollment_Component__c();
        enrollmentComp.Assignment_Logic__c = '(1 OR 2 OR 3)';
        enrollmentComp.Document_Type__c = '504 Plan';
        enrollmentComp.Document_Submission_End_Date__c = Date.today().addDays(3);
        enrollmentComp.Document_Submission_Start_Date__c = Date.today().addDays(-3);
        enrollmentComp.Component_Type__c = 'Household';
        insert enrollmentComp;
        
        //create Enrollment Component Affiliation Record.
        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'In Progress';
        compAffiliation.Date_Completed__c = System.today();
        compAffiliation.Deferral_Date__c = System.today();
        compAffiliation.Program_Enrollment__c = progEnrollment1.Id;
        compAffiliation.Enrollment_Component__c = enrollmentComp.id;
        insert compAffiliation;
        
        // Create Enrollment Document Record.
        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :'Caretaker Community User'];
        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            User u = [
                SELECT id, contactId
                FROM User
                WHERE ProfileId = :standardProfile.Id
                AND isActive = True
                LIMIT 1
            ];
            Enrollment_Document__c doc = new Enrollment_Document__c();
            doc.Program_Enrollment__c = progEnrollment1.Id;
            doc.Document_Link__c = 'test';
            doc.Document__c = 'Test';
            doc.Type__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_TYPE;
            doc.Enrollment_Component_Affiliation__c=compAffiliation.Id;
            insert doc;
            
            // Update Enrollment Document Record.
            Enrollment_Document__c enrd = [SELECT Id,Program_Enrollment__c,Status_Reason__c FROM Enrollment_Document__c WHERE Id=:doc.Id];
            enrd.Status_Reason__c= 'Verified';
            
            // start test
            Test.startTest();
            
            update enrd;
            enrd.Status_Reason__c= 'Requested';
            update enrd; 
            Enrollment_Component_Affiliation__c eca=[  SELECT Id, Status__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c,
                                                     Enrollment_Component__c, Enrollment_Component__r.Component_Type__c FROM Enrollment_Component_Affiliation__c WHERE Id =:compAffiliation.Id];
            
            // force completion of any async processing
            Test.stopTest();
            
            // Assert statements for Enrollment Component Affiliation.
            System.assertEquals('In Progress', eca.Status__c);
            System.assertNotEquals(null, eca.Status__c);
            
        }
    }
    
    /**
* Change Log: Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-10
**/
    //Start-added for #107180 User Story (Task 108660) on 2019-09-10    
   /* static testMethod void filedPAHStatusTest(){
        //Create Program Enrollment Document Record.
        Account account                            = Peak_TestUtils.createTestAccount();
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        Contact contact                            = Peak_TestUtils.createTestContact('Students', account.Id);
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c              = previousSchoolYear.Id;
        insert progEnrollment1; 
        // Create Enrollment Document Record.
        Enrollment_Document__c doc = new Enrollment_Document__c();
        doc.Program_Enrollment__c = progEnrollment1.Id;
        doc.Document_Link__c = 'test';
        doc.Document__c = 'Test';
        doc.Type__c = 'Home School Prior Academic History';
        doc.Status_Reason__c= 'Verified';
        // start test
        Test.startTest();
        insert doc;
        hed__Program_Enrollment__c programIDs = [Select Id,PAHStatus__c from hed__Program_Enrollment__c where ID = :progEnrollment1.id] ;
        // Force completion of any async processing 
        Test.StopTest(); 
        //assert values 
        system.assertEquals('Verified', programIDs.PAHStatus__c);
        
    }*/
    //End-added for #107180 User Story (Task 108660) on 2019-09-10   
    
    



// Task number 111013(user story 110763), Chinnamnaidu Neerasa Sept 04,2019.
    static testMethod void updateECAStatusToDeferredTest(){
        
        // Create Program Enrollment Document Record.
        Account account                            = Peak_TestUtils.createTestAccount();
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        Contact contact                            = Peak_TestUtils.createTestContact('Students', account.Id);
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c              = previousSchoolYear.Id;
        insert progEnrollment1;
        
        //create Enrollment Component Record
        Enrollment_Component__c enrollmentComp = new Enrollment_Component__c();
        enrollmentComp.Assignment_Logic__c = '(1 OR 2 OR 3)';
        enrollmentComp.Document_Type__c = 'Proof of Age';
        enrollmentComp.Document_Submission_End_Date__c = Date.today().addDays(3);
        enrollmentComp.Document_Submission_Start_Date__c = Date.today().addDays(-3);
        enrollmentComp.Component_Type__c = 'Household';
        insert enrollmentComp;
        
        //create Enrollment Component Affiliation Record.
        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'Deferred';
        compAffiliation.Date_Completed__c = System.today();
        compAffiliation.Deferral_Date__c = System.today();
        compAffiliation.Program_Enrollment__c = progEnrollment1.Id;
        compAffiliation.Enrollment_Component__c = enrollmentComp.id;
        insert compAffiliation;
        
        // Create Enrollment Document Record.
        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :'Caretaker Community User'];
        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            User u = [
                SELECT id, contactId
                FROM User
                WHERE ProfileId = :standardProfile.Id
                AND isActive = True
                LIMIT 1
            ];
            
            Enrollment_Document__c doc = new Enrollment_Document__c();
            doc.Program_Enrollment__c = progEnrollment1.Id;
            doc.Document_Link__c = 'test deferred';
            doc.Document__c = 'Test deferred';
            doc.Type__c = 'Proof of Age';
            doc.Enrollment_Component_Affiliation__c=compAffiliation.Id;
            insert doc;
            
            // Update Enrollment Document Record.
            Enrollment_Document__c enrd = [SELECT Id,Program_Enrollment__c,Status_Reason__c FROM Enrollment_Document__c WHERE Id=:doc.Id];
            enrd.Status_Reason__c= 'Verified';
            
            // start test.
            Test.startTest();
            
            update enrd;
            enrd.Status_Reason__c= 'Deferred-Extension Approved by Principal';
            update enrd; 
            Enrollment_Component_Affiliation__c eca=[  SELECT Id, Status__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c,
                                                     Enrollment_Component__c, Enrollment_Component__r.Component_Type__c FROM Enrollment_Component_Affiliation__c WHERE Id =:compAffiliation.Id];
            eca.Status__c='Deferred';
            update eca;
            // force completion of any async processing
            Test.stopTest();
            
            // Assert statements for Enrollment Component Affiliation.
            System.assertEquals('Deferred', eca.Status__c);
            System.assertNotEquals(null, eca.Status__c);
            
        }
    }
    
    // Task number 118320(user story 113765), Chinnamnaidu Neerasa Nov 18,2019.
    static testMethod void updateDocumentRevStatusTest(){
       School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name ='2018-2019'];
        Account academicAccount = [SELECT Id FROM Account where School_Year__c = :schoolYear.id limit 1 ];
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c  LIMIT 1];
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
       
            // start test.
            Test.startTest();
            enrollmentDocument1.Type__c = 'Charter School Notification Form';
            enrollmentDocument1.Status_Reason__c = 'Submitted';
            update enrollmentDocument1;
            Document_Review__c parDocRev = new Document_Review__c ();
            if (academicAccount.Id!= null){
            parDocRev = [SELECT id,Status__c FROM Document_Review__c WHERE Academic_Program__c =: academicAccount.Id];
            }   
           //Stop test.
            Test.stopTest();
            
            System.assertEquals('In Progress', parDocRev.Status__c );
            
        }
    
    // Test method for US#125320 by Krishna Peddanagammol on 2020-04-23 
    static testMethod void updateDocPendingStatusTest(){
        Enrollment_Document__c ed = [SELECT Id, Enrollment_Component_Affiliation__c FROM Enrollment_Document__c 
                                     WHERE Type__c = 'Immunization Records'];
        Test.startTest(); // start test     
            ed.Status_Reason__c = 'Pending';
            update ed;    
            Enrollment_Component_Affiliation__c eca = [SELECT Id, Program_Enrollment__r.Id, Status__c FROM Enrollment_Component_Affiliation__c 
                                                   WHERE Id = :ed.Enrollment_Component_Affiliation__c Limit 1];
            
        Test.stopTest(); //Stop test            
        System.assertEquals('In Progress', eca.Status__c );                 
     }  
}