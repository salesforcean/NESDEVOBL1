/**
* Created by ajith on 15/10/18.
* Purpose : This Class Would contain required methods for the User Registration
* Change Log:
*         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
*/
public without sharing class NES_RegistrationController {
    
    /**
* Created by ajith on 15/10/18.
* Purpose : This method would validate the User Name availability by sending a request to the forge rock using REST
*/
    @AuraEnabled
    public static Peak_Response checkUserNameAvailability(String userInput){
        Peak_Response peakResponse = NES_RegistrationHelper.verifyUsername(userInput);
        return peakResponse;
    }
    
    
    /**
* Created by ajith on 15/10/18.
* Purpose : This method would validate and Create the required Account, Opportunity, Contact, Portal user and Program enrollments
*           based on the values passed from the FED. The records are created in salesforce and also in Forge Rock
*/
    @AuraEnabled
    public static Peak_Response validateAndCreateRecords(String fName, String lName, String email, String uName, String password, String schoolId, string mName, string suffix, string zipCode, string state, string phoneType, string phone, boolean smsOptOut, String gtmHiddenFields){
        System.debug('fName:'+fName+'.....lName:'+lName+'........email:'+email+'.......uName:'+uName+'........password:'+password+'..........'+String.valueOf(gtmHiddenFields));
        Peak_Response peakResponse = NES_RegistrationHelper.createNewRecords(fName, lName, email, uName, password, schoolId, mName, suffix, zipCode, state, phoneType, phone, smsOptOut,gtmHiddenFields);
        return peakResponse;
    }
    
    /**
* Created by Ritvik on 16/11/18.
* Modified by Ritvik on 19/11/18.
* Purpose : Method to check whether Email for active caretaker profile exists or not while doing new registration.
*/
    @AuraEnabled
    public static Boolean emailExists(String email){
        Boolean exists = NES_RegistrationHelper.doesEmailExist(email);
        return exists;
    }
    
    
    /**
* Created by Ashish Sharma on 12/21/18
* Parameters: ID, String
* Return Type: Peak_Response
* Purpose : Task #66396, this method is used to save the InputParameter__c on the contact record
*/
    @AuraEnabled
    public static Peak_Response saveInputParameter(Id contactID, String parameter){
        return NES_RegistrationHelper.saveInputParameter(contactID, parameter);
    }
    
    /**
* Created by Ashish Sharma on 12/21/18
* Parameters: ID
* Return Type: Peak_Response
* Purpose : Task #66396, this method is used to gey the InputParameter__c from the contact record
*/
    @AuraEnabled
    public static Peak_Response getInputParameter(Id contactID){
        return NES_RegistrationHelper.getInputParameter(contactID);
    }
    
    @AuraEnabled
    public static List<String> getStateValuesIntoList(){
        List<String> pickListValuesList = new List<String>();
        List<State__mdt> stateList = [Select State_Abbreviation__c from State__mdt order by State_Abbreviation__c ];
        for(State__mdt obj: stateList) {
            pickListValuesList.add(obj.State_Abbreviation__c);
        }
        return pickListValuesList;
    }
    
    @AuraEnabled        
    public static List<String> getPhoneTypeValuesIntoList(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.hed__PreferredPhone__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getSuffixValuesIntoList(){
        List<String> pickListValuesList = new List<String>();
        List<Suffix__mdt> stateList = [Select label from Suffix__mdt order by label ];
        for(Suffix__mdt obj: stateList) {
            pickListValuesList.add(obj.label);
        }
        return pickListValuesList;
    }
    
    //added for the US166467 : Jagadeesh
    /** purpose : To verify usename availability **/
    @AuraEnabled
    public static Peak_Response VeriftyUserNameAvailability(String userInput){
        Peak_Response peakResponse = NES_RegistrationHelper.verifyUsernameAvailabilty(userInput);
        return peakResponse;
    }
    
    
}