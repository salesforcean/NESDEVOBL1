/*
* Purpose: Test class for NES_DocumentFileReferenceListController 
* Change Log:
*         2019-08-13 initial for #101928 User Story (Chinnamanaidu Neerasa)
*/
@isTest(SeeAllData=false)
private with sharing class NES_DocumentFileRefListControllerTest {
    
    static testMethod void updateDFRTest() {
        
        // Create Program Enrollment Document Record.
        Account account                            = Peak_TestUtils.createTestAccount();
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        Contact contact                            = Peak_TestUtils.createTestContact('Students', account.Id);
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c              = previousSchoolYear.Id;
        insert progEnrollment1;
        
        // Create Enrollment Document Record
        List <Document_File_References__c> newlist = new List <Document_File_References__c>();
        Enrollment_Document__c enrolldocmt         = new Enrollment_Document__c ();
        enrolldocmt.Document__c           = 'test document';
        enrolldocmt.Notes__c              = 'notes test';
        enrolldocmt.Program_Enrollment__c = progEnrollment1.id;
        insert enrolldocmt;
        
        // Create Document Reference File Record
        Document_File_References__c documentreference  = new Document_File_References__c ();
        
        documentreference .Document_Link__c = 'test document';
        documentreference .File_Path__c = 'notes test';
        documentreference .Version__c = 2;
        documentreference .Enrollment_Document__c = enrolldocmt.id;
        insert documentreference; 
        
        //create utility settings
        
        Utility_Settings__c userref = new Utility_Settings__c();
        userref.Name='Testdata';
        userref.Document_Download__c=false;
        insert userref;
        
        // start test
        test.startTest();
        
        // calling two methods from classes  
        newlist  = NES_DocumentFileRefListController.getDocList(enrolldocmt.id);
        userref  = NES_DocumentFileRefListController.getUtilitySettings();
        
        // force completion of any async processing
        Test.stopTest();
        
        // retrieve utility settings
        List< Utility_Settings__c > objUser = [SELECT Id, SetupOwnerId, Document_Download__c FROM Utility_Settings__c WHERE SetupOwnerId = : userref.SetupOwnerId ]; 
        
        // comparing method results - positive test and negative test.
        Document_File_References__c dref2 = new Document_File_References__c ();
        for (Document_File_References__c dref1 : newlist) {
            if (dref1.id == documentreference.id){
                dref2.id = dref1.id;
            }
        }
        
        for(Utility_Settings__c usr1 :objUser) {
            if (usr1.setupOwnerId == userref.SetupOwnerId) {
                userref.setupOwnerId = usr1.SetupOwnerId;
            }
        }
        
        // Assert statements for Document file reference
        system.assertEquals( documentreference.id, dref2.id);
        system.assertNotEquals( null, dref2.id);
        
        // Assert statements for Utility settings
        system.assertEquals(userref.SetupOwnerId, userref.SetupOwnerId);
        system.assertnotEquals(null, userref.SetupOwnerId);
        
    }
}