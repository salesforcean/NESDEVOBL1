/**
 * Created by Ashish Sharma on 12/26/18
 * Class Name: NES_IdamUtilitiesTest
 * Purpose : Test class for NES_IdamUtilities
 * 
 * Change Log:
 * Sumanth:25 Aug 2020: Added 'testEnrollmentDocumentUpdate' method for to cover Enrollment Document changes 
 *                      in 'pushUserInfoToSIS' method for US # 216780
 * Rakesh RamaSwamy: 25 Aug 2020: Added 'testProgramEnrollmentUpdate' method for to cover Program Enrollment changes 
 *                      in 'pushUserInfoToSIS' method for US # 216777
*/
@isTest
private with sharing class NES_IdamUtilitiesTest {
    static final String COMPLETE_STATUS = 'Complete';

    /**
     * Created by Ashish Sharma on 12/26/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Method to setup the test data
    */
    @TestSetup
    static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('OpportunityTrigger', true);

        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018')); 
        Contact contact = Peak_TestUtils.createTestContact('Caretaker', account.Id);
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
    }

    /**
     * Created by Ashish Sharma on 12/26/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to send message to SIS with Program Enrollment Id to retrieve student information without access token
    */
    static testMethod void testPushToSISNoToken() {
        Test.setMock(HttpCalloutMock.class, new IDAMCallout(null, 400, 'Error', false, false));

        Test.startTest();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM Contact LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        progEnrollment.Status__c = COMPLETE_STATUS;
        insert progEnrollment;
        Test.stopTest();

        //Assert test if SIS_Integration_Status__c is error
        System.assertEquals(null, [SELECT SIS_Integration_Status__c FROM hed__Program_Enrollment__c
                                   WHERE Id =: progEnrollment.Id][0].SIS_Integration_Status__c);
    }

    /**
     * Created by Ashish Sharma on 12/26/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to send message to SIS with Program Enrollment Id to retrieve student information with error
    */
    static testMethod void testPushToSISWithError() {
        NES_IdamUtilities.idamAccessToken = 'Test';
        Test.setMock(HttpCalloutMock.class, new IDAMCallout(null, 400, 'Error', true, false));

        Test.startTest();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM Contact LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        insert progEnrollment;

        Opportunity newOpp = Peak_TestUtils.createOpportunity(progEnrollment.Id);
        progEnrollment.Status__c = COMPLETE_STATUS;
        update progEnrollment;

        newOpp.StageName = 'Closed Won';
        update newOpp;

        Enrollment__c enrollmentRecord = new Enrollment__c(Program_Enrollment__c = progEnrollment.Id, School_Year__c = [SELECT Id FROM School_Year__c LIMIT 1][0].Id);
        insert enrollmentRecord;

        Set<Id> programEnrollmentIds = new Set<Id>();
        programEnrollmentIds.add(progEnrollment.Id);
        NES_IdamUtilities.pushToSIS(programEnrollmentIds);
        Test.stopTest();

        //Assert test if SIS_Integration_Status__c is error
        System.assertEquals('400 : 400: Error', [SELECT SIS_Integration_Status__c FROM hed__Program_Enrollment__c
                                            WHERE Id =: progEnrollment.Id][0].SIS_Integration_Status__c);
    }

    /**
     * Created by Ashish Sharma on 12/26/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to send message to SIS with Program Enrollment Id to retrieve student information with exception
    */
    static testMethod void testPushToSISWithException() {
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test123', 200, 'Ok', false, true));

        Test.startTest();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM Contact LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        progEnrollment.Status__c = COMPLETE_STATUS;
        update progEnrollment;
        Test.stopTest();

        //Assert test if SIS_Integration_Status__c is blank
        System.assertEquals(null, [SELECT SIS_Integration_Status__c FROM hed__Program_Enrollment__c
                                   WHERE Id =: progEnrollment.Id][0].SIS_Integration_Status__c);
    }

    /**
     * Created by Ashish Sharma on 12/26/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to send message to SIS with Program Enrollment Id to retrieve student information
    */
    static testMethod void testPushToSIS() {
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));

        Test.startTest();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM Contact LIMIT 1][0].Id,
                                                                                           [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Opportunity newOpp = Peak_TestUtils.createOpportunity(progEnrollment.Id);
        newOpp.StageName = 'Closed Won';
        update newOpp;

        progEnrollment.Status__c = COMPLETE_STATUS;
        update progEnrollment;

        Enrollment__c enrollmentRecord = new Enrollment__c(Program_Enrollment__c = progEnrollment.Id, School_Year__c = [SELECT Id FROM School_Year__c LIMIT 1][0].Id);
        insert enrollmentRecord;

        Set<Id> programEnrollmentIds = new Set<Id>();
        programEnrollmentIds.add(progEnrollment.Id);
        NES_IdamUtilities.pushToSIS(programEnrollmentIds);
        Test.stopTest();

        //Assert test if SIS_Integration_Status__c is success
        System.assertEquals('Successfully Sent to SIS', [SELECT SIS_Integration_Status__c FROM hed__Program_Enrollment__c
                                                         WHERE Id =: progEnrollment.Id][0].SIS_Integration_Status__c);
    }

    
    /**
     * Created by Ashish Sharma on 12/26/18
     * Purpose : HttpCalloutMock class to set the test response
    */
    private class IDAMCallout implements HttpCalloutMock {
        String accessToken;
        Integer statusCode;
        String status;
        boolean isError;
        boolean isThrowException;

        private IDAMCallout(String accessToken, Integer statusCode, String status, boolean isError, boolean isThrowException){
            this.accessToken = accessToken;
            this.statusCode = statusCode;
            this.status = status;
            this.isError = isError;
            this.isThrowException = isThrowException;
        }

        public HttpResponse respond(HTTPRequest req) {
            NES_IdamUtilities.ClientResponseData responseData = new NES_IdamUtilities.ClientResponseData();
            responseData.access_token = accessToken;
            responseData.client_id = '12345';
            responseData.expires_in = '20181211';

            NES_IdamUtilities.ClientResponse response = new NES_IdamUtilities.ClientResponse();
            response.data = responseData;

            HttpResponse res = new HttpResponse();

            if(isError && req.getEndpoint().contains('eventemitter')){
                res.setStatus('Error');
                res.setStatusCode(400);
            }else{
                res.setStatus(status);
                res.setStatusCode(statusCode);
            }

            String body = (isThrowException == true ? 'dummy body' : JSON.serialize(response));
            res.setBody(body);
            return res;
        }
    }
    
    //Added by Jagadish for 148923
    static testMethod void optInSMSTest() {
        Test.setMock(HttpCalloutMock.class, new NES_RegisterDoubleOptInClsTest.MockResponseEnableOptIn()); 
        contact careTaker = [select id, SMS_Phone_Number__c from contact limit 1];
        careTaker.Phone = '1234567890';
        update careTaker;
        NES_RegisterDoubleOptInCls.apigeeAccessToken = 'dummy';
        NES_IdamUtilities.optInSMS(careTaker.Id);
    }
    
    // Added by Guravaiah Gunturi for US# 216772,216768
    static testMethod void testpushSTDLCCTUserInfoAndHouseholdAddressChangeToSIS(){
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));
        
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
		UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        String orgId = UserInfo.getOrganizationId();
        User CTUsr = factoryObj.createNewUser('Cont0818'+orgId+'@pearson.com', usrRole.Id, 'CTAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','Cont0818'+orgId+'@pearson.com');
        insert CTUsr;  
        System.runAs(CTUsr)
        {
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Account_Record_Type_Text__c = 'Household';
            acc.ShippingCity='Texas';
            acc.ShippingCountry = 'USA';
            acc.ShippingPostalCode='452146';
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'Contact Last Name';
            con.FirstName = 'Contact First Name';
            con.Email = 'contact@pearson.com';
            con.Contact_Record_Type_Text__c = 'Caretaker';
            con.AccountId = acc.id;
            con.Commuity_User__c = CTUsr.id;
            insert con;
            Test.startTest();
            con.Request_Type__c = 'UserInfo Update';
            update con;
            acc.Request_Type__c = 'Address Change';
            update acc;
            
            system.assertEquals(null, con.SIS_Integration_Status__c);
            system.assertEquals(null, acc.SIS_Integration_Status__c);
            
            Test.stopTest();
            
        } 
        
    }        
    
    // USER STORY #. 216780 
    // Created By: Sumanth Krishna   
	static testMethod void testEnrollmentDocumentUpdate(){
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
		UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        String orgId = UserInfo.getOrganizationId();
        User CTUsr = factoryObj.createNewUser('Cont0818'+orgId+'@pearson.com', usrRole.Id, 'CTAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','Cont0818'+orgId+'@pearson.com');
        insert CTUsr;  
        System.runAs(CTUsr)
        {                        
            Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId(); 
            Account HHAcc = factoryObj.createNewAccount('HouseHoldAcc',recordTypeIdHH,null,null,null) ; // Household
            insert HHAcc;
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
            Contact CTcon = factoryObj.createNewContact('CTContact',recordTypeIdCT,HHAcc.Id,null); 
            insert CTcon;
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            List<Contact> stdContList = factoryObj.createListOfContacts('StdContact',recordTypeIdSTD,HHAcc.Id,CTcon.id,1);
            insert stdContList;                        
            
            Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION).getRecordTypeId();
            Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();
            Account TNCASchool = factoryObj.createNewAccount('TNCA',recordTypeIdEI,null,null,null);   //Educational Instituation
            insert TNCASchool;
            
            Account TNCAAcademicProgram = factoryObj.createNewAccount('TNCA 2019-2020',recordTypeIdAP,TNCASchool.id,system.today(),null);
            insert TNCAAcademicProgram;
            
            User STDUsr;
            List<User> usrList = new List<User>();
            Profile STDProfile = [select id,name from profile where name='Student Community User'];
            STDUsr = factoryObj.createnewPortalUser('STDUser@pearson.com', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','STDUser@pearson.com',stdContList.get(0).id);
            usrList.add(STDUsr);
            insert usrList; 
            
			stdContList.get(0).Caretaker_Id__c = CTCon.id;
            stdContList.get(0).Commuity_User__c = STDUsr.id;
            update stdContList.get(0);
            
            Id recordTypeIdPECaretaker  = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get(CS_Constants.PROGRAM_ENROLLMENT_CARETAKER).getRecordTypeId();
            Id recordTypeIdPEStudent  = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get(CS_Constants.PROGRAM_ENROLLMENT_RECTYPE_STUDENT).getRecordTypeId();
            
            List<hed__Program_Enrollment__c> peList = new List<hed__Program_Enrollment__c>();           
            hed__Program_Enrollment__c pe1 = factoryObj.createNewProgramEnrollmentWithRecordType(stdContList.get(0).id, TNCAAcademicProgram.id, 'Complete',recordTypeIdPEStudent);
            peList.add(pe1);
            insert peList;            
            
            Enrollment_Document__c EDoc = new Enrollment_Document__c();
            EDoc.Type__c = 'Custody Order';
            EDoc.Status_Reason__c = 'Verified';
            EDoc.Program_Enrollment__c = peList.get(0).id;
            insert EDoc;            
            
            Test.startTest();
            EDoc.Status_Reason__c = 'Submitted';
            update EDoc;
            system.assertEquals(null, EDoc.SIS_Integration_Status__c);
            Test.stopTest();
        }
    }
    
    // USER STORY #. 216777 
    // Created By: Rakesh Ramaswamy 
	static testMethod void testProgramEnrollmentUpdate(){
    
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
		UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        String orgId = UserInfo.getOrganizationId();
        User CTUsr = factoryObj.createNewUser('Cont0818'+orgId+'@pearson.com', usrRole.Id, 'CTAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','Cont0818'+orgId+'@pearson.com');
        insert CTUsr;  
        System.runAs(CTUsr)
        {
            
            Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId(); 
            Account HHAcc = factoryObj.createNewAccount('HouseHoldAcc',recordTypeIdHH,null,null,null) ; // Household
            insert HHAcc;
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
            Contact CTcon = factoryObj.createNewContact('CTContact',recordTypeIdCT,HHAcc.Id,null); 
            insert CTcon;
            
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            List<Contact> stdContList = factoryObj.createListOfContacts('StdContact',recordTypeIdSTD,HHAcc.Id,CTcon.id,1);
            insert stdContList;                        
            
            Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION).getRecordTypeId();
            Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();
            Account TNCASchool = factoryObj.createNewAccount('TNCA',recordTypeIdEI,null,null,null);   //Educational Instituation
            insert TNCASchool;
            
            Account TNCAAcademicProgram = factoryObj.createNewAccount('TNCA 2019-2020',recordTypeIdAP,TNCASchool.id,system.today(),null);
            insert TNCAAcademicProgram;
            
            User STDUsr;
            List<User> usrList = new List<User>();
            Profile STDProfile = [select id,name from profile where name='Student Community User'];
            STDUsr = factoryObj.createnewPortalUser('STDUser@pearson.com', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','STDUser@pearson.com',stdContList.get(0).id);
            usrList.add(STDUsr);
            insert usrList; 
            
			stdContList.get(0).Caretaker_Id__c = CTCon.id;
            stdContList.get(0).Commuity_User__c = STDUsr.id;
            update stdContList.get(0);
            
            Id recordTypeIdPECaretaker  = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get(CS_Constants.PROGRAM_ENROLLMENT_CARETAKER).getRecordTypeId();
            Id recordTypeIdPEStudent  = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get(CS_Constants.PROGRAM_ENROLLMENT_RECTYPE_STUDENT).getRecordTypeId();
            List<hed__Program_Enrollment__c> peList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c pe1 = factoryObj.createNewProgramEnrollmentWithRecordType(CTcon.id, TNCAAcademicProgram.id, 'Complete',recordTypeIdPECaretaker);
            peList.add(pe1);
            hed__Program_Enrollment__c pe2 = factoryObj.createNewProgramEnrollmentWithRecordType(stdContList.get(0).id, TNCAAcademicProgram.id, 'Complete',recordTypeIdPEStudent);
            peList.add(pe2);
            insert peList;
            peList.get(1).Household_Program_Enrollment__c = peList.get(0).id;
            update peList;            
            
            Test.startTest();
            peList.get(0).OrderingHoldFlag__c = 'Summer School';
            update peList.get(0);
            system.assertEquals(null, peList.get(0).SIS_Integration_Status__c);
            Test.stopTest();
        }
    }  
    // USER STORY #. 216774 
    // Created By: Ravichandra Amrishetty 
    public static testMethod void testAdditionalHouseholdMember(){
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
		UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        String orgId = UserInfo.getOrganizationId();
        User usrObj = factoryObj.createNewUser('Cont0818'+orgId+'@pearson.com', usrRole.Id, 'ObjAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','Cont0818'+orgId+'@pearson.com');
        insert usrObj;  
        System.runAs(usrObj)
        {
            Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId(); 
            Account HHAccount = factoryObj.createNewAccount('HouseHoldAcc',recordTypeIdHH,null,null,null) ; // Household
            insert HHAccount;
			List<List<Contact>> CommunityList=new List<List<Contact>>();
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
			list<Contact> CTHouseHold1ConList =  factoryObj.createListOfContacts('CTContatact', recordTypeIdCT,HHAccount.Id, null, 3);
            insert CTHouseHold1ConList;
			
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            List<Contact> stdContList = factoryObj.createListOfContacts('StdContact',recordTypeIdSTD,HHAccount.Id,CTHouseHold1ConList.get(0).id,3);
            insert stdContList;
            
            Id recordTypeIdLC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_LEARNING_COACH).getRecordTypeId();
            List<Contact> lcContList = factoryObj.createListOfContacts('LearningContact',recordTypeIdLC,HHAccount.Id,null,4);
            insert lcContList;
            
            List<User> usrList = new List<User>();
            Profile CTProfile = [select id,name from profile where name='Caretaker Community User'];
			Profile LCProfile = [select id,name from profile where name='Learning Coach Community User'];
            Profile STDProfile= [select id,name from profile where name='Student Community User'];
            User CTUsr = factoryObj.createnewPortalUser('CTUser@pearson.com', 'CTUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', CTProfile.Id,'LastName','CTser@pearson.com',CTHouseHold1ConList.get(0).id);
			User LCUsr = factoryObj.createnewPortalUser('LCUser@pearson.com', 'LCUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', LCProfile.Id,'LastName','LCUser@pearson.com',lcContList.get(0).id);
            User STDUsr = factoryObj.createnewPortalUser('STDUser@pearson.com', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','LCUser@pearson.com',stdContList.get(0).id);
            usrList.add(LCUsr);
            usrList.add(CTUsr);
            usrList.add(STDUsr);
            
            Test.StartTest();
            insert usrList;
            lcContList.get(0).Commuity_User__c = LCUsr.id;
			lcContList.get(0).Request_Type__c = 'Additional Household Member';
			update lcContList.get(0);
            system.assertEquals('Additional Household Member', lcContList.get(0).Request_Type__c);
            system.assertEquals(null, lcContList.get(0).SIS_Integration_Status__c);
            CTHouseHold1ConList.get(0).Commuity_User__c = CTUsr.id;
			CTHouseHold1ConList.get(0).Request_Type__c = 'Additional Household Member';
			update CTHouseHold1ConList.get(0);
            system.assertEquals('Additional Household Member', CTHouseHold1ConList.get(0).Request_Type__c);
            system.assertEquals(null, CTHouseHold1ConList.get(0).SIS_Integration_Status__c);
            Test.StopTest();
            
        } 
    }

    @IsTest
    static void pushToSIS_TestForRestrictedAcademicProgram(){
        
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));

        // * Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        // * Create School Year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2020-2021', System.today());

        // * Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.Restrict_to_SIS__c = true;
        update academicProgram;

        // * Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('lastName', 'Caretaker', institutionAccount.Id);

        // * Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // * Create a Contact with 'Students' record type  
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // * Create PE
        hed__program_enrollment__c studPE = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert studPE;

        Test.StartTest();
            NES_IdamUtilities.pushToSIS(new Set<Id>{studPE.Id});        
        Test.StopTest();

        // refresh Student PE
        studPE = [
                    SELECT  Id, Status__c, Enrollment_Type__c, SIS_Integration_Status__c, hed__Account__r.Restrict_to_SIS__c 
                    FROM    hed__program_enrollment__c
                    WHERE   Id = :studPE.Id 
                ];
        system.assertEquals('In Progress', studPE.Status__c);
        system.assertEquals('Initial Enrollment', studPE.Enrollment_Type__c);
        system.assertEquals(true, studPE.hed__Account__r.Restrict_to_SIS__c);
       // system.assertEquals('Restricted to SIS', studPE.SIS_Integration_Status__c);//Sumanth:25-Oct-20:Commented out as this functionality is being moved to Flow:CS_PushEnrollmentToV2SystemsFlow as part of US # 334984
    }

    @IsTest
    static void pushToSIS_TestForUnrestrictedAcademicProgram(){
        
        Test.setMock(HttpCalloutMock.class, new IDAMCallout('Test', 200, 'Ok', false, false));

        // * Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        // * Create School Year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2020-2021', System.today());

        // * Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // * Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('lastName', 'Caretaker', institutionAccount.Id);

        // * Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // * Create a Contact with 'Students' record type  
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // * Create PE
        hed__program_enrollment__c studPE = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert studPE;

        // // * Create Opportunity
        // Opportunity newOpp = Peak_TestUtils.createOpportunity(studPE.Id);
        // newOpp.StageName = 'Closed Won';
        // update newOpp;

        Enrollment__c enrollmentRecord = new Enrollment__c(Program_Enrollment__c = studPE.Id, School_Year__c = schoolYear.Id);
        insert enrollmentRecord;

        Test.StartTest();
            NES_IdamUtilities.pushToSIS(new Set<Id>{studPE.Id});        
        Test.StopTest();

        // refresh Student PE
        studPE = [
                    SELECT  Id, Status__c, Enrollment_Type__c, SIS_Integration_Status__c, hed__Account__r.Restrict_to_SIS__c 
                    FROM    hed__program_enrollment__c
                    WHERE   Id = :studPE.Id 
                ];
        system.assertEquals('In Progress', studPE.Status__c);
        system.assertEquals('Initial Enrollment', studPE.Enrollment_Type__c);
        system.assertEquals(false, studPE.hed__Account__r.Restrict_to_SIS__c);
        system.assertEquals('Successfully Sent to SIS', studPE.SIS_Integration_Status__c);
    }
}