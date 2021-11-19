/**
 * Created by Ritvik on 01-11-2018.
 */

public with sharing class NES_ECUtilities {    

    /**
    * Created By Ajith on 31-12-2018.
    * purpose : Wrapper Class for sending the request to the Experian Marketing Services
    */
    public class phoneValidatorWrap{

        public Long NumberKey;
        public String DefaultCountryCode;

        public phoneValidatorWrap(Long NumberKey, String DefaultCountryCode){
            this.NumberKey = NumberKey;
            this.DefaultCountryCode = DefaultCountryCode;
        }
    }

    /**
    * Created By Ajith on 31-12-2018.
    * purpose : Wrapper Class to hold the data from the request response from Experian Marketing Services
    */
    public class GlobalPhoneInfo{

        public Long phoneKey {get; set;}
        public String PhoneType {get; set;}
        public String Certainty {get; set;}

        public GlobalPhoneInfo(Long phoneKey, String phoneType, String certainty){

            this.phoneKey = phoneKey;
            this.PhoneType = phoneType;
            this.Certainty = certainty;
        }
    }

    /**
    * Created By Ajith on 31-12-2018.
    * purpose : Method to construct the query for the ECAs EC of type Question and Phone
    *           and query the records based on the PE on the ECA record
    * params : List of ECA records
    */

    public static Map<Long, Enrollment_Component_Affiliation__c> configureQuery(List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations) {
        Map<Enrollment_Component_Affiliation__c, String> ecaToQueryMap = new Map <Enrollment_Component_Affiliation__c, String>();
        //Map to hold the phone number and related ECA 
        Map<Long, Enrollment_Component_Affiliation__c> phoneToECAMap = new Map<Long, Enrollment_Component_Affiliation__c>();

        for(Enrollment_Component_Affiliation__c eca : enrollmentComponentAffiliations){

            String data = eca.Enrollment_Component__r.Answer_Target__c;
            //Split the Target field to get the Object and Field API Names
            String fieldApiName = data.substring(data.indexOf('.') + 1, data.length());
            String objectApiName = data.substring(0, data.indexOf('.'));

            String query;
            if(objectApiName == 'Account') {
                query = 'SELECT Id, ' + fieldApiName + ' FROM Account WHERE Id = \'' + eca.Program_Enrollment__r.hed__Contact__r.AccountId + '\' ';
            } else if(objectApiName == 'Contact') {
                query = 'SELECT Id, ' + fieldApiName + ' FROM Contact WHERE Id = \'' + eca.Program_Enrollment__r.hed__Contact__c + '\' ';
            } else if(objectApiName == 'hed__Program_Enrollment__c') {
                query = 'SELECT Id, ' + fieldApiName + ' FROM hed__Program_Enrollment__c WHERE Id = \'' + eca.Program_Enrollment__c + '\' ';
            } else {
                query = 'SELECT Id, ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE Program_Enrollment__c = \'' + eca.Program_Enrollment__c + '\' ';
            }
            if(String.isNotBlank(query)){
                query += ' LIMIT 1 ';
                ecaToQueryMap.put(eca, query);
                List<SObject> childRecords = new List<SObject>();
                System.debug(query);
                query.remove('(');
                query.remove(')');
                //Query the Records
                childRecords = Database.query(query);
                if(!childRecords.isEmpty()){
                    SObject childRecord = childRecords[0];
                    System.debug('NES_ECUtilities:: configureQuery:: childRecord:: '+childRecord);
                    System.debug('NES_ECUtilities:: configureQuery:: field name:: '+childRecord.get(fieldApiName));
                    String phoneNumber = (String)childRecord.get(fieldApiName);
                    String trimPhoneNumber = phoneNumber.replaceAll('[^0-9]', '');
                    System.debug('NES_ECUtilities:: configureQuery:: field name::: '+ trimPhoneNumber);
                    phoneToECAMap.put(Long.valueOf(trimPhoneNumber), eca);
                }
            }
        }

        return phoneToECAMap;
    }

    /**
    * Created By Ajith on 31-12-2018.
    * purpose : Method to construct Http request and return response of the request

    */
    public static HttpCalloutMock mock = null;
    public static HttpResponse createHttpRequestForPhoneData(String method, String endpoint, String authToken, String body) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);

        if(method == 'POST') {
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('auth-token', authToken);
            request.setHeader('authorization', 'Bearer '+ authToken);
            request.setBody(body);
        }

       HttpResponse response = null;
       // if--else condition added by raju 
        if (Test.isRunningTest() && (mock!=null)) {
            return mock.respond(request);
        } else {
           //Send the request
           Http http = new Http();
           response = http.send(request);
        }
        
        return response;
    }
     

}