/**
 * Created by: Ashish Sharma on 12/07/18
 * Class Name: NES_DocumentAuthorizationHelper
 * Test Class Name: NES_DocumentAuthorizationTest
 * Purpose : Helper class for NES_DocumentAuthorization service
 * Modified By: Ashish Sharma on 01/09/19
*/
global with sharing class NES_DocumentAuthorizationHelper {
    //Constants
    public static final String LOCATION_ID_PARAMETER = 'locationid';
    public static final String ACTION_PARAMETER = 'action';
    public static final String UPLOADED_BY_USER_ID_PARAMETER = 'uploadedByUserId';
    public static final String LOCATION_ID_REQUIRED_MESSAGE = 'locationid is required';
    public static final String UPLOADED_BY_USER_ID_REQUIRED_MESSAGE = 'uploadedByUserId is required';
    public static final String ACTION_REQUIRED_MESSAGE = 'action is required';
    public static final String USER_NOT_FOUND_MESSAGE = 'unable to find user';
    public static final String INVALID_ACTION_MESSAGE = 'action is invalid';
    public static final String IMPLEMENTATION_PENDING_MESSAGE = 'not yet implemented';
    public static final String INVALID_LOCATION_MESSAGE = 'location not valid for user';
    public static final String PROGRAM_ENROLLMENT_UNAVAILABLE = 'no program enrollment found';
    public static final String CREATE_ENROLLMENT_DOCUMENT_MESSAGE = 'no permission to create Enrollment Document record';
    public static final String SUCCESS_MESSAGE = 'success';
    public static final String ENROLLMENT_DOCUMENT_OBJECT = 'Enrollment_Document__c';
    public static final String SEARCH_OPERATOR = '%';
    public static final String GET_ACTION = 'GET';
    public static final String POST_ACTION = 'POST';
    public static final String PATCH_ACTION = 'PATCH';
    public static final String DELETE_ACTION = 'DELETE';
    public static final String CARETAKER = 'Caretaker';
    public static final String ENROLLMENT_SUPPORT = 'Enrollment Support';
    public static final String SCHOOL = 'School';

    /**
     * Created by: Ashish Sharma on 12/07/18
     * Parameters: String, String, String
     * Return Type: AuthorizationResponse
     * Purpose : Method to validate request parameters
    */
    public static AuthorizationResponse validateRequestParameters(String locationId, String uploadedByUserId){
        //validate locationid parameters
        if(String.isBlank(locationId)){
            return setResponse(400, false, LOCATION_ID_REQUIRED_MESSAGE);
        }

        //validate uploadedByUserId parameters
        if(String.isBlank(uploadedByUserId)){
            return setResponse(400, false, UPLOADED_BY_USER_ID_REQUIRED_MESSAGE);
        }else{
            boolean isUserExist = false;
//Swapna:Changed from FederationIdentifier check to PearsonUID check part of 110616
            for(User user : [SELECT Id FROM User WHERE PearsonUID__c =: uploadedByUserId LIMIT 1]){
                isUserExist = true;
            }

            if(!isUserExist){
                return setResponse(400, false, USER_NOT_FOUND_MESSAGE);
            }
        }

        return null;
    }

    /**
     * Created by: Ashish Sharma on 12/10/18
     * Parameters: String
     * Return Type: User
     * Purpose : Method to get user's details
    */
    public static User getUserDetails(String uploadedByUserId){
        if(String.isNotBlank(uploadedByUserId)){
            //Swapna:Changed from FederationIdentifier check to PearsonUID check part of 110616
            for(User tempUser : [SELECT ContactId, Contact.AccountId, Document_Authorization__c FROM User
                                 WHERE PearsonUID__c =: uploadedByUserId LIMIT 1]){
                return tempUser;
            }
        }

        return null;
    }

    /***
     * Created by: Raymond Garcia 1/14/19
     * Parameter: ID contactID, ID locationID
     * Return type: boolean
     * Purpose: Method to check if a user has access of an account shared with them or a group they belong to
     ***/
    public static boolean isSharedAccount(String fedID, String locationID){
        List<ID> idsToCheck = new List<Id>();

        //query for user
        ////Swapna:Changed from FederationIdentifier check to PearsonUID check part of 110616
        for(User user : [SELECT ID FROM User WHERE PearsonUID__c =: fedID LIMIT 1]){
            idsToCheck.add(user.ID);
        }

        //query for groups
        for(GroupMember groupMem: [SELECT groupId FROM GroupMember WHERE UserOrGroupId IN: idsToCheck]){
            idsToCheck.add(groupMem.groupId);
        }

        //query for account access to either user or group, if a share record exists for the specified account, return true
        if([SELECT Id FROM Accountshare WHERE AccountId =: locationID AND UserOrGroupId IN :idsToCheck LIMIT 1].size() > 0){
            return true;
        }

        return false;
    }

    /**
     * Created by: Ashish Sharma on 12/07/18
     * Parameters: Integer, boolean, String
     * Return Type: AuthorizationResponse
     * Purpose : Method to set the response of the http request
    */
    public static AuthorizationResponse setResponse(Integer statusCode, boolean authorized, String message){
        RestContext.response.statusCode = statusCode;
        return new AuthorizationResponse(authorized, message);
    }

    /**
     * Created by: Ashish Sharma on 12/04/18
     * Purpose : Wrapper class to store the response
    */
    global class AuthorizationResponse{
        global boolean authorized;
        global String message;

        global AuthorizationResponse(boolean authorized, String message){
            this.authorized = authorized;
            this.message = message;
        }
    }
}