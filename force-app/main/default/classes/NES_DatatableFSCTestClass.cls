/**

    * Created by ali.khan (Ness Tech) on 10/22/19.
    * This test class covers NES_DatatableFSC.cls

*/

@isTest
public with sharing class NES_DatatableFSCTestClass {
        
    public static String queryFields = 'Id, Name';
    public static String querysObjectAPIName = 'Account';
    public static String whereClauseIDFieldAPIName = 'Name';
    public static String whereClauseIDFieldValue = Peak_TestConstants.ACCOUNT_NAME;
    
    // dataSetup here...
    @testSetup
    static void testSetup() {
        Account testAccount = Peak_TestUtils.createTestAccount();
        Contact testContact = Peak_TestUtils.createTestContact();
        // School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
    }

    // Test fetching of data from aura component.
    @isTest
    public static void testGetData() {
        
        List<String> queryParams  =  new List<String>{queryFields, querysObjectAPIName, whereClauseIDFieldAPIName, whereClauseIDFieldValue};
        List<sObject> objResults;
        Exception err;


        Test.startTest();
        try {

            objResults = 
                NES_DatatableFSC.getData(queryParams);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();

        system.assertNotEquals(null, objResults, 'objResults is null!');
        system.assertEquals(null, err, 'exceptions!');


    }

    // Test updating of data from aura component.
    @isTest
    public static void testUpdateRecords() {

        List<Account> accs = [SELECT Id, Name from Account];
        // Map<String, String> dependentPicklistByControllingFieldValue;
        Exception err;


        Test.startTest();
        try {
            
            NES_DatatableFSC.updateRecords(accs);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();
        
        system.assertEquals(null, err, 'exceptions!');


    }

    // Test insertRecords from aura component.
    @isTest
    public static void testInsertRecords() {


        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='TEST123'));
        accList.add(new Account(Name='TEST124'));
        List<Id> insertedRecIDs;
        Exception err;


        Test.startTest();
        try {
            
                insertedRecIDs = 
                    NES_DatatableFSC.insertRecords(accList);
                // System.debug(JSON.serialize(insertedRecIDs));

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();
        
        system.assertNotEquals(null, insertedRecIDs, 'insertedRecIDs is null!');
        system.assertEquals(null, err, 'exceptions!');


    }

    // Test createPriorSchoolRecord & InsertRecordGeneric from aura component.
    @isTest
    public static void testCreatePriorSchoolRecord() {


        // QUERY TEST DATA...
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c,          
                Registration_Start_Date__c FROM Account
                WHERE RecordType.Name = 'Academic Program' LIMIT 1
        ];
        // System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];

        //Create a student enrollment for the CareTaker Contact
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYears[0].Id, true);

        // pass the details to the createPriorSchoolRecord
        String priorSchoolRecID;
        Exception err;
        

        Test.startTest();
        try {

            
                priorSchoolRecID = 
                    NES_DatatableFSC.createPriorSchoolRecord(progEnrollment.Id);
                

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();


        system.assertNotEquals(null, priorSchoolRecID, 'priorSchoolRecID is null!');
        system.assertEquals(null, err, 'exceptions!');


    }


}