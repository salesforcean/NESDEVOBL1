/**
 * Created by: Ashish Sharma on 12/04/18
 * Class Name: NES_DocumentAuthorization
 * Test Class Name: NES_DocumentAuthorizationTest
 * Helper Class Name: NES_DocumentAuthorizationHelper
 * Purpose : Service class for document authorization
 * Modified By: Ashish Sharma on 01/09/19
*/
@RestResource(urlMapping='/DocumentAuthorization/v1/*')
global with sharing class NES_DocumentAuthorization {
    private static Peak_ApexLog logger = new Peak_ApexLog('DocumentAuthorization');

    /**
     * Created by: Ashish Sharma on 01/09/19
     * Parameters: N/A
     * Return Type: AuthorizationResponse
     * Purpose : HttpGet method to process the 'get' http requests and authorize the user's
     *           Enrollment Document privileges
     * Modified By: Raymond Garcia 1/14/19
    */
    @HttpGet
    global static NES_DocumentAuthorizationHelper.AuthorizationResponse doGet() {
        //instantiate rest response and request
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        //get parameters from the request
        String user = req.params.get(NES_DocumentAuthorizationHelper.UPLOADED_BY_USER_ID_PARAMETER);
        String location = req.params.get(NES_DocumentAuthorizationHelper.LOCATION_ID_PARAMETER);
        String action = req.params.get(NES_DocumentAuthorizationHelper.ACTION_PARAMETER);

        if (String.isBlank(action)) {
            return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.ACTION_REQUIRED_MESSAGE);
        } else if (action == NES_DocumentAuthorizationHelper.POST_ACTION || action == NES_DocumentAuthorizationHelper.GET_ACTION) {
            return processRequest(location, user);
        } else if (action == NES_DocumentAuthorizationHelper.PATCH_ACTION) {
            return doPatch();
        } else if (action == NES_DocumentAuthorizationHelper.DELETE_ACTION) {
            return doDelete();
        } else {
            return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.INVALID_ACTION_MESSAGE);
        }
    }

    /**
     * Created by: Raymond Garcia 1/14/19
     * Parameters: String, String
     * Return Type: AuthorizationResponse
    */
    private static NES_DocumentAuthorizationHelper.AuthorizationResponse processRequest(String location, String user) {
        try {
            //validate request parameters and return the response if request parameters are invalid
            NES_DocumentAuthorizationHelper.AuthorizationResponse response =
                    NES_DocumentAuthorizationHelper.validateRequestParameters(location, user);

            if (response != null) {
                return response;
            }

            //get user information from user id parameter which holds the federation id
            User userDetail = NES_DocumentAuthorizationHelper.getUserDetails(user);

            //check if the user's profile is caretaker profile
            if (userDetail.Document_Authorization__c == NES_DocumentAuthorizationHelper.CARETAKER) {

                //check if uploadedByUserId's location Id is invalid
                if (userDetail.ContactId == null || userDetail.Contact.AccountId != location) {
                    return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.INVALID_LOCATION_MESSAGE);
                    //return success if location Id is valid
                } else {
                    return NES_DocumentAuthorizationHelper.setResponse(200, true, NES_DocumentAuthorizationHelper.SUCCESS_MESSAGE);
                }
                //check if the profile contatins school
            } else if (userDetail.Document_Authorization__c == NES_DocumentAuthorizationHelper.SCHOOL &&
                    NES_DocumentAuthorizationHelper.isSharedAccount(user, location)) { //Check that the Account a direct share record for this User or a Group the user belongs to.

                return NES_DocumentAuthorizationHelper.setResponse(200, true, NES_DocumentAuthorizationHelper.SUCCESS_MESSAGE);
                //profile does not contain school nor is it a caretaker profile
            } else if (userDetail.Document_Authorization__c == NES_DocumentAuthorizationHelper.ENROLLMENT_SUPPORT) {

                return NES_DocumentAuthorizationHelper.setResponse(200, true, NES_DocumentAuthorizationHelper.SUCCESS_MESSAGE);
            } else {
                return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.INVALID_LOCATION_MESSAGE);
            }
        } catch (Exception e) {
            logger.logException('processRequest', e);
            logger.saveLogs();
            return NES_DocumentAuthorizationHelper.setResponse(400, false, e.getMessage());
        }
    }

    /**
     * Created by: Ashish Sharma on 01/09/19
     * Parameters: N/A
     * Return Type: AuthorizationResponse
     * Purpose : Method to process the 'patch' action and authorize the user's
     *           Enrollment Document privileges
    */
    global static NES_DocumentAuthorizationHelper.AuthorizationResponse doPatch() {
        return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.IMPLEMENTATION_PENDING_MESSAGE);
    }

    /**
     * Created by: Ashish Sharma on 01/09/19
     * Parameters: N/A
     * Return Type: AuthorizationResponse
     * Purpose : Method to process the 'delete' action and authorize the user's
     *           Enrollment Document privileges
    */
    global static NES_DocumentAuthorizationHelper.AuthorizationResponse doDelete() {
        return NES_DocumentAuthorizationHelper.setResponse(400, false, NES_DocumentAuthorizationHelper.IMPLEMENTATION_PENDING_MESSAGE);
    }
}