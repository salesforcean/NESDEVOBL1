/**
 * Created by: Ashish Sharma on 12/11/18
 * Class Name: NES_DocumentAuthorizationTest
 * Purpose : Test class for NES_DocumentAuthorization and NES_DocumentAuthorizationHelper
 * Modified By: Ashish Sharma on 01/09/19
*/
@isTest
private class NES_DocumentAuthorizationTest {
    //Constants
    static final String REQUEST_URI = '/services/apexrest/DocumentAuthorization/v1/*';
    static final String HTTP_GET_METHOD = 'GET';
    static final String HTTP_POST_METHOD = 'POST';
    static final String HTTP_PATCH_METHOD = 'PATCH';
    static final String HTTP_DELETE_METHOD = 'DELETE';
    static final String INVALID_LOCATION_ID = '123456';
    static final String INVALID_FEDERATION_ID = 'invalidfedrationid';
    static final String CARETAKER_FEDERATION_ID = 'TestCaretakerFederationId';
    static final String STAFF_FEDERATION_ID = 'TestStaffFederationId';
    static final String NON_CARETAKER_FEDERATION_ID = 'nonCareTaker';
    static final String COMMUNITY_USER_TYPE = 'CspLitePortal';
    static final String ACADEMY_PROGRAM_PROFILE = 'Academic Program';
    static final String CONTACT_NAME = 'Caretaker';
    static final String YEAR = '2018-2019';
    static final String CARETAKER_PROFILE_NAME = 'Caretaker Community User';
    static final String CARETAKER_USERNAME = 'caretaker@testuser.com';
    static final String SCHOOL_STAFF_USERNAME = 'schoolstaff@testuser.com';
    static final String EDIT_ACCESS_LEVEL = 'Edit';

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to setup test data
    */
    @TestSetup
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears(YEAR, Date.today());
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        Contact contact = Peak_TestUtils.createTestContact(CONTACT_NAME, academicProgram.Id);

        User schoolStaffUser = Peak_TestUtils.createGuestUser();
       // schoolStaffUser.FederationIdentifier = STAFF_FEDERATION_ID;
        schoolStaffUser.PearsonUID__c = STAFF_FEDERATION_ID; 
        schoolStaffUser.ProfileId = [SELECT Id FROM Profile WHERE Name like : ('%' + NES_DocumentAuthorizationHelper.SCHOOL + '%') LIMIT 1].Id;
        schoolStaffUser.UserName = SCHOOL_STAFF_USERNAME;
        schoolStaffUser.Document_Authorization__c = NES_DocumentAuthorizationHelper.SCHOOL;
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Pearson_Community_Manager' LIMIT 1];
        insert schoolStaffUser;

        User caretaker = Peak_TestUtils.createStandardUser();
       // caretaker.FederationIdentifier = CARETAKER_FEDERATION_ID;
        caretaker.PearsonUID__c = CARETAKER_FEDERATION_ID ;
        caretaker.ContactId = contact.Id;
        caretaker.ProfileId = [SELECT Id FROM Profile WHERE Name =: CARETAKER_PROFILE_NAME].Id;
        caretaker.UserName = CARETAKER_USERNAME;
        caretaker.Document_Authorization__c = NES_DocumentAuthorizationHelper.CARETAKER;
        insert caretaker;

        User nonCareTaker = Peak_TestUtils.createGuestUser();
       // nonCareTaker.FederationIdentifier = NON_CARETAKER_FEDERATION_ID;
         nonCareTaker.PearsonUID__c = NON_CARETAKER_FEDERATION_ID;
        nonCareTaker.Document_Authorization__c = NES_DocumentAuthorizationHelper.ENROLLMENT_SUPPORT;
        insert nonCareTaker;

    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service without locationid parameter
    */
    @isTest static void testServiceWithoutLocationId(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(null, null, HTTP_POST_METHOD);
        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.LOCATION_ID_REQUIRED_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service without uploadedByUserId parameter
    */
    @isTest static void testServiceWithoutUploadedByUserId(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, null, HTTP_POST_METHOD);
        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.UPLOADED_BY_USER_ID_REQUIRED_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service with invalid uploadedByUserId parameter
    */
    @isTest static void testServiceInvalidUser(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, INVALID_FEDERATION_ID, HTTP_POST_METHOD);
        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.USER_NOT_FOUND_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action
    */
    @isTest static void testServiceUpdateAction(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, CARETAKER_FEDERATION_ID, HTTP_PATCH_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.IMPLEMENTATION_PENDING_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for delete action
    */
    @isTest static void testServiceDeleteAction(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, CARETAKER_FEDERATION_ID, HTTP_DELETE_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.IMPLEMENTATION_PENDING_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with caretaker user with invalid locationid Id data type
    */
    @isTest static void testServiceCreateCareTakerActionInvalidLocationId(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, CARETAKER_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertNotEquals(responseBody.message, null);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with caretaker user with invalid locationid
    */
    @isTest static void testServiceCreateCareTakerActionInvalidLocation(){
        Id loctionId = [SELECT Id FROM Account WHERE RecordType.Name !=: ACADEMY_PROGRAM_PROFILE LIMIT 1][0].Id;

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(loctionId, CARETAKER_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.INVALID_LOCATION_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with caretaker user
    */
    @isTest static void testServiceCreateCareTakerAction(){
        
        //Swapna:Updated part of 110616 US
        Id loctionId = [SELECT Contact.AccountId FROM User WHERE PearsonUID__c  =: CARETAKER_FEDERATION_ID LIMIT 1][0].Contact.AccountId;

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(loctionId, CARETAKER_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.SUCCESS_MESSAGE);
        System.assertEquals(responseBody.authorized, true);
    }

     /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with school staff user and shared account
    */
    @isTest static void testServiceUpdateStaffActionWithValidLocation(){
        Id loctionId = [SELECT Id FROM Account LIMIT 1][0].Id;
//Swapna:Updated part of 110616 US
        insert new AccountShare(UserOrGroupId = [SELECT Id FROM User WHERE PearsonUID__c  =: STAFF_FEDERATION_ID].Id, AccountId = loctionId,
                                AccountAccessLevel = EDIT_ACCESS_LEVEL, OpportunityAccessLevel = EDIT_ACCESS_LEVEL);

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(loctionId, STAFF_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.SUCCESS_MESSAGE);
        System.assertEquals(responseBody.authorized, true);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with school staff user and no shared account
    */
    @isTest static void testServiceUpdateStaffActionWithoutValidLocation(){
        Id loctionId = [SELECT Id FROM Account LIMIT 1][0].Id;

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(loctionId, STAFF_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertEquals(responseBody.message, NES_DocumentAuthorizationHelper.INVALID_LOCATION_MESSAGE);
        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for update action with non caretaker user
    */
    @isTest static void testServiceNonCaretaker(){
        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, NON_CARETAKER_FEDERATION_ID, HTTP_POST_METHOD);

        System.assertNotEquals(responseBody.message, null);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for read action (invalid)
    */
    @isTest static void testServiceReadAction(){
        System.assertEquals(null, NES_DocumentAuthorizationHelper.getUserDetails(null));

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, NON_CARETAKER_FEDERATION_ID, HTTP_GET_METHOD);

       System.assertEquals(responseBody.authorized, true);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: NA
     * Return Type: void
     * Purpose : Method to test the service for blank action
    */
    @isTest static void testServiceBlankAction(){
        System.assertEquals(null, NES_DocumentAuthorizationHelper.getUserDetails(null));

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody = doServiceCallout(INVALID_LOCATION_ID, NON_CARETAKER_FEDERATION_ID, null);

        System.assertEquals(responseBody.authorized, false);
    }

    /**
     * Created by: Ashish Sharma on 12/11/18
     * Parameters: String, String, String
     * Return Type: NES_DocumentAuthorizationHelper
     * Purpose : Method to call the rest service and return the response
    */
    static NES_DocumentAuthorizationHelper.AuthorizationResponse doServiceCallout(String locationId, String uploadedByUserId, String action){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URI;
        request.httpMethod = HTTP_GET_METHOD;

        if(String.isNotBlank(locationId)){
            request.addParameter(NES_DocumentAuthorizationHelper.LOCATION_ID_PARAMETER, locationId);
        }

        if(String.isNotBlank(uploadedByUserId)){
            request.addParameter(NES_DocumentAuthorizationHelper.UPLOADED_BY_USER_ID_PARAMETER, uploadedByUserId);
        }

        if(String.isNotBlank(action)){
            request.addParameter(NES_DocumentAuthorizationHelper.ACTION_PARAMETER, action);
        }

        RestContext.request = request;
        RestContext.response = response;

        NES_DocumentAuthorizationHelper.AuthorizationResponse responseBody;

        Test.startTest();

        responseBody = NES_DocumentAuthorization.doGet();

        Test.stopTest();

        return responseBody;
    }
 }