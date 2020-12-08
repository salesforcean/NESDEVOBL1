/**
 * Created by Anand on 11/19/2018.
 * ClassName: NES_ExperianIntegration
 * Description: Experian Api to Validate address
 *
 */

public without sharing class NES_ExperianIntegration {
/*
* Method Name: searchAddress
* Description: Used to convert string to JSON
* @param: String address,String countryCode
* @return String
*/
    @AuraEnabled
    public static String searchAddress(String address) {
        address.trim();
        address = address.replaceAll(' ', '%20');
        String apiKey = 'c7c47a78-47ee-49f1-9772-d42d86e5c11b';
        String endpointUrl = 'https://api.edq.com/capture/address/v2/search?query=';
        HttpResponse result;
        // Create Http Request
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        endpointUrl = endpointUrl + address + '&country=USA'+ '&auth-token=' + apiKey;
        request.setEndpoint(endpointUrl);
        request.setHeader('Auth-Token', apiKey);
        // Create a Http Call
        try{
        Http http = new Http();
        result = http.send(request);
        }catch(System.CalloutException e) {
            System.debug('Exception: '+ e);

        }
        String jsonResponse = result.getBody();
        System.debug('jsonResponse#####'+jsonResponse);
        return jsonResponse;
    }

    // grab all the questions associated with the address group
    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getQuestions(Id groupId, Id enrollmentId) {
        List<NES_EvaluateUtil.Question> questions = NES_IntegrationUtils.grabQuestions(groupId, enrollmentId);
        return questions;
    }
/*
* Method Name: getFormattedAddress
* Description: To get the formatted address like city, street, Postcode, country etc.
* @param: String address,String countryCode
* @return String
*/
    @AuraEnabled
    public static String getFormattedAddress(String addressId) {
        String apiKey = 'c7c47a78-47ee-49f1-9772-d42d86e5c11b';
        String endpointUrl = 'https://api.edq.com/capture/address/v2/format?country=USA&id='+addressId+'&auth-token='+apiKey;
        HttpResponse result;
        // Create Http Request
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        //endpointUrl = endpointUrl + address + '&auth-token=' + apiKey;
        request.setEndpoint(endpointUrl);
        request.setHeader('Auth-Token', apiKey);
        // Create a Http Call
        try{
            Http http = new Http();
            result = http.send(request);
        }catch(System.CalloutException e) {
            System.debug('Exception: '+ e);

        }
        String jsonResponse = result.getBody();
        return jsonResponse;
    }
    /*
* Method Name: getSearchSettings
* Description: Used to Address_Search_Settings__c customSettings Instances to the apex
* @return Address_Search_Settings__c
*/

    @AuraEnabled
    public static Address_Search_Settings__c getSearchSettings() {
        Address_Search_Settings__c addressValues = Address_Search_Settings__c.getInstance();
        return addressValues;
    }

    @AuraEnabled
    public static void saveAddressFields(Id groupId, Id programEnrollmentId, String questionJSON, Boolean apiValidated) {

        try{
            List<NES_EvaluateUtil.Question> questionDataList = (List<NES_EvaluateUtil.Question>)JSON.deserialize(questionJSON, List<NES_EvaluateUtil.Question>.class);
            NES_IntegrationUtils.saveTheAnswers(programEnrollmentId, groupId, questionDataList, apiValidated);
        } catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
        }
    }

    public class AddressData{
        @AuraEnabled
        public String addressLine1{get;set;}
        @AuraEnabled
        public String addressLine2{get;set;}
        @AuraEnabled
        public String addressLine3{get;set;}
        @AuraEnabled
        public String locality{get;set;}
        @AuraEnabled
        public String province{get;set;}
        @AuraEnabled
        public String postalCode{get;set;}
        @AuraEnabled
        public String country{get;set;}

        public AddressData() {}
    }
}