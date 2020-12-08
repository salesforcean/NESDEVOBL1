/* Change Log:
*         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
*/
@IsTest
public class NES_RegistrationControllerTest {
    public static User u;
    @TestSetup static void setup() {
        Account account = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        //User u = Peak_TestUtils.createStandardUser();
        // system.debug('user '  + u);
        u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1]; 
        system.debug('user '  + u);
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);
        
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgramAccount.Id, 'Process', True);
    }
    
    private class mockCalloutForGET implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String body = 'test body';
            res.setBody(body);
            return res; 
        }
    }
    //added for the US166467 : Jagadeesh
    private class mockCalloutForGETnotAvailable implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String body = '{"_id":"caretaker2268382","status":"success","isUsernameAvailable":false}';
            res.setBody(body);
            return res; 
        }
    }
    
    private class mockCalloutForGETavailable implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String body = '{"_id":"caretaker2268382","status":"success","isUsernameAvailable":true}';
            res.setBody(body);
            return res; 
        }
    }
    private class mockCalloutForPOST implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(201);
            String body = '{"data": {"pearsonConnexusUserId": "ed2213ed6d384246a45291417ce6eacb","pearsonConnexusUsername": "rdehler105"}}';
            res.setBody(body);
            return res;
        }
    }
    @IsTest
    static void testCheckUserNameAvailibility() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForGET());
        Test.startTest();
        Peak_Response peakResponse = NES_RegistrationController.checkUserNameAvailability('testUser');
        System.assertEquals(peakResponse.success ,false);
        Test.stopTest();
    }    
    
    
    @IsTest
    static void testValidateAndCreateRecords() {
        Test.setMock(HttpCalloutMock.class, new mockCalloutForPOST());
        Account accnt = Peak_TestUtils.createTestAccount();
        List<School_Year__c> schoolYears = Peak_TestUtils.createSchoolYears();
        Account testAccnt = Peak_TestUtils.createAccountForNewStudentData(accnt.Id, schoolYears[0].Id);
        Test.startTest();
        NES_IdamUtilities.idamAccessToken = 'dummytoken';
        String GTMHiddenFields = '{"clientID":"","device_type":"","keyword":"","campaignName":"","utm_source":"","utm_medium":"","experimentID":"","timestamp":"","gclickid":""}';
        Peak_Response peakResponse = NES_RegistrationController.validateAndCreateRecords('test', 'User', 'testUser@sample.com', 'test.user' ,'test####123', accnt.Id, 'midname', 'suffix', '12345', 'ME', 'Home', '123-123-1234', true,GTMHiddenFields);
        
        Test.stopTest();
        System.assertEquals(true, peakResponse.success);
    }
    
    @IsTest
    static void testValidateAndCreateRecordsNegative() {
        Test.setMock(HttpCalloutMock.class, new mockCalloutForPOST());
        Account accnt = Peak_TestUtils.createTestAccount();
        List<School_Year__c> schoolYears = Peak_TestUtils.createSchoolYears();
        Account testAccnt = Peak_TestUtils.createAccountForNewStudentData(accnt.Id, schoolYears[0].Id);
        Test.startTest();
        NES_IdamUtilities.idamAccessToken = 'dummytoken';
        String GTMHiddenFields = '{"clientID":"","device_type":"","keyword":"","campaignName":"","utm_source":"","utm_medium":"","experimentID":"","timestamp":"","gclickid":""}';
        Peak_Response peakResponse = NES_RegistrationController.validateAndCreateRecords('test', 'User', 'testUsercom', 'test.user' ,'test####123', accnt.Id, 'midname', 'suffix', '12345', 'ME', 'Home', '123-123-1234', true,GTMHiddenFields);
        
        Test.stopTest();
        System.assertEquals(false, peakResponse.success);
    }
    
    @IsTest
    static void testValidateAndCreateRecordsNegative2() {
        Test.setMock(HttpCalloutMock.class, new mockCalloutForPOST());
        Account accnt = Peak_TestUtils.createTestAccount();
        List<School_Year__c> schoolYears = Peak_TestUtils.createSchoolYears();
        Account testAccnt = Peak_TestUtils.createAccountForNewStudentData(accnt.Id, schoolYears[0].Id);
        Test.startTest();
        NES_IdamUtilities.idamAccessToken = null;
        String GTMHiddenFields = '{"clientID":"","device_type":"","keyword":"","campaignName":"","utm_source":"","utm_medium":"","experimentID":"","timestamp":"","gclickid":""}';
        Peak_Response peakResponse = NES_RegistrationController.validateAndCreateRecords('test', 'User', 'testUser@sample.com', 'test.user' ,'test####123', accnt.Id, 'midname', 'suffix', '12345', 'ME', 'Home', '123-123-1234', true,GTMHiddenFields);
        
        Test.stopTest();
        System.assertEquals(false, peakResponse.success);
    }
    
    @IsTest
    static void testEmailExists(){
        Test.startTest();
        Boolean emailExists;
        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :'Caretaker Community User'];
        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            User u = [
                Select id, contactId, Email
                from User
                where ProfileId = :standardProfile.Id
                and isActive = True
                limit 1
            ];
            emailExists = NES_RegistrationController.emailExists(u.Email);
            System.assertEquals(true, emailExists);
        }
        
        emailExists = NES_RegistrationController.emailExists('raytest@testerson.com');
        System.assertEquals(false, emailExists);
        Test.stopTest();
    }
    
    /**
* Created by Ashish Sharma on 12/21/18
* Parameters: NA
* Return Type: void
* Purpose : Task #66396, test method for getInputParameter
*/
    @IsTest
    static void testGetInputParameter(){
        Account account = Peak_TestUtils.createTestAccount();
        Contact testContact = Peak_TestUtils.createContact('Test Contact', account.Id,'Students',True);
        
        //Test if contact id is blank
        System.assertEquals(false, NES_RegistrationController.getInputParameter(null).success);
        
        //Test if parameter is blank
        System.assertEquals(false, NES_RegistrationController.getInputParameter(testContact.Id).success);
        
        NES_RegistrationController.saveInputParameter(testContact.Id, '1');
        
        //Test if parameter is not blank
        System.assertEquals('1', NES_RegistrationController.getInputParameter(testContact.Id).parameter);
        
        //Test if contact id is blank
        System.assertEquals(false, NES_RegistrationController.saveInputParameter(null, '1').success);
    }
    
    /**
* Created by Anushka Bansal on 01/10/2019
* Parameters: NA
* Return Type: void
* Purpose : Task #66396, test method for grabStudents
*/
    @IsTest
    static void testGrabStudents(){
        //User u = [Select id from User where Alias =: Peak_TestConstants.STANDARD_ALIAS];
        //User u = Peak_TestUtils.createStandardUser();
        hed__Relationship__c  relationship = [Select id, hed__Contact__c from hed__Relationship__c  limit 1];
        User u = [Select id, contactId from User where contactId =: relationship.hed__Contact__c ];
        System.debug('user --> ' + u);
        System.runAs(u){
            NES_EvaluateUtil.NewStudentData data = NES_RegistrationHelper.grabStudents();
            System.assertNotEquals(data, null);
        }
    }
    
    @IsTest
    static void testPickListRetrieves() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForGET());
        Test.startTest();
        List<String> stateList = NES_RegistrationController.getStateValuesIntoList();
        System.assert(stateList.size()>0);
        List<String> phoneTypeList = NES_RegistrationController.getPhoneTypeValuesIntoList();
        System.assert(phoneTypeList.size()>0);
        List<String> suffixList = NES_RegistrationController.getSuffixValuesIntoList();
        System.assert(suffixList.size()>0);
        Test.stopTest();
    }   
    
    /**
* Created by Jagadish on 07/16/2020
* Parameters: NA
* Return Type: void
* Purpose : US 148923, test method for doubleOptIn
*/
    
    @IsTest
    static void testdoubleOptIn() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForPOST());
        Account accnt = Peak_TestUtils.createTestAccount();
        List<School_Year__c> schoolYears = Peak_TestUtils.createSchoolYears();
        Account testAccnt = Peak_TestUtils.createAccountForNewStudentData(accnt.Id, schoolYears[0].Id);
        Test.startTest();
        NES_IdamUtilities.idamAccessToken = 'dummytoken';
        String GTMHiddenFields = '{"clientID":"","device_type":"","keyword":"","campaignName":"","utm_source":"","utm_medium":"","experimentID":"","timestamp":"","gclickid":""}';
        Peak_Response peakResponse = NES_RegistrationController.validateAndCreateRecords('test', 'User', 'testUser@sample.com', 'test.user' ,'test####123', accnt.Id, 'midname', 'suffix', '12345', 'ME', 'Home', '123-123-1234', false,GTMHiddenFields);
        Test.stopTest();
        System.assertEquals(true, peakResponse.success);
    }  
    
    //added for the US166467 : Jagadeesh
    @IsTest
    static void testVerifyUserNameNotAvailibility() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForGETnotavailable());
        Test.startTest();
        Peak_Response peakResponse = NES_RegistrationController.VeriftyUserNameAvailability('testUser');
        System.assertEquals(peakResponse.success ,false);
        Test.stopTest();
    }
    @IsTest
    static void testVerifyUserNameAvailibility() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForGETavailable());
        Test.startTest();
        Peak_Response peakResponse = NES_RegistrationController.VeriftyUserNameAvailability('testUser');
        System.assertEquals(peakResponse.success ,true);
        
        Test.stopTest();
    }
}