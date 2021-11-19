/*
* Created by Anand on 01/03/2018.
* ClassName: NES_MDRIntegration
* Purpose : To get School names based on the input given using Azure school APi
*/
public without sharing class NES_MDRIntegration {
    private static Peak_ApexLog logger = new Peak_ApexLog('MDRIntegration');

    public static final String SCHOOL_API_KEY = label.NES_MDR_Api_Key;
    public static final String API_Version = label.NES_MDR_Api_Version;
    public static final String URL = label.NES_MDR_Url;

    /*
   * Method Name: getSchoolSearchSettings
   * Description: Used to School_Search_Settings__c customSettings Instances to the apex
   * @return School_Search_Settings__c
   */
    @AuraEnabled
    public static School_Search_Settings__c getSchoolSearchSettings() {
        School_Search_Settings__c schoolValues = School_Search_Settings__c.getInstance();
        System.debug('schoolValues::' + schoolValues);
        return schoolValues;
    }

    // grab all the questions associated with the school search group
    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getQuestions(Id groupId, Id enrollmentId) {
        List<NES_EvaluateUtil.Question> questions = NES_IntegrationUtils.grabQuestions(groupId, enrollmentId);
        return questions;
    }

    /*Created by Anand
   * Method Name: searchSchool
   * Params: String previousSchoolName,String previousSchoolCity,String previousSchoolState
   * @return Peak_Response
   */
    @AuraEnabled
    public static String searchSchool(String previousSchoolName, String previousSchoolCity, String previousSchoolState) {
        SchoolAddressData[] schoolResponse ;
        // Create a JSONbody request with the input parameters
        String jsonBody = getJsonBody(previousSchoolName, previousSchoolCity, previousSchoolState);
        // Create a Http Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL + 'api-version=' + API_Version + '&api-key=' + SCHOOL_API_KEY);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);
        // Make a http request with the given request
        try {
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            if (!Test.isRunningTest())
                response = http.send(request);
            String responseBody = response.getBody().replaceAll('@odata.context', 'dataContext');
            responseBody = responseBody.replaceAll('@search.score', 'searchScore');
            System.debug('Response===>>>' + responseBody);
            // Deserialize the response body to school wrapper class
            schoolResponse = ((SchoolWrapper) System.JSON.deserialize(responseBody, SchoolWrapper.class)).value;
            //System.debug('schoolWrapper==>>' + schoolResponse);
            return JSON.serialize(schoolResponse);
        } catch (Exception e) {
            logger.logException('searchSchool', e);
            logger.saveLogs();
            return null;
        }
    }

    // Grab response and place into appropriate target fields
    @AuraEnabled
    public static Peak_Response updateEnrollmentAnswerTarget(String schoolAddress, Id questionGroupId, Id programEnrollmentId, Boolean apiValidated) {

        Peak_Response peakResponse = new Peak_Response();

        try {
            // Deserialze the response given from the front end to schoolAddress wrapper
            SchoolAddressData schoolData = (SchoolAddressData) JSON.deserialize(schoolAddress, SchoolAddressData.class);

            // Grab map of response name and actual returned data
            Map<String, String> apiFieldMap = new Map<String, String>();

            if(String.isNotBlank(schoolData.schoolName)) {
                apiFieldMap.put('schoolName', schoolData.schoolName);
            }
            if(String.isNotBlank(schoolData.streetAddress)) {
                apiFieldMap.put('streetAddress', schoolData.streetAddress);
            }
            if(String.isNotBlank(schoolData.postalCode)) {
                apiFieldMap.put('postalCode', schoolData.postalCode);
            }
            if(String.isNotBlank(schoolData.city)) {
                apiFieldMap.put('city', schoolData.city);
            }
            if(String.isNotBlank(schoolData.stateAbbr)) {
                apiFieldMap.put('stateAbbr', schoolData.stateAbbr);
            }
            if(String.isNotBlank(schoolData.districtName)) {
                apiFieldMap.put('districtName', schoolData.districtName);
            }
            if(String.isNotBlank(schoolData.countryAbbr)) {
                apiFieldMap.put('countryAbbr', schoolData.countryAbbr);
            }

            NES_IntegrationUtils.savingAnswers(programEnrollmentId, questionGroupId, apiFieldMap, apiValidated);
            peakResponse.messages.add('Saved successfully');

        } catch(Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('updateEnrollmentAnswerTarget', e);
            logger.saveLogs();
        }

        return peakResponse;

    }

    /**
     *
     *Created   By Anand
     * Purpose: To generate Json request Body for Http Request
     * @param previousSchoolName
     * @param previousSchoolCity
     * @param previousSchoolState
     *
     * @return
     *
     */
    @AuraEnabled
    public static String getJsonBody(String previousSchoolName, String previousSchoolCity, String previousSchoolState) {
        String searchString = previousSchoolName + ' ' + previousSchoolCity + ' ' + previousSchoolState;
        SerializeSchoolData dataToSerialize = new SerializeSchoolData(previousSchoolName,previousSchoolCity,previousSchoolState);
        String requestBody = JSON.serialize(dataToSerialize).replaceAll('selectString', 'select');
        System.debug('requestBody===>>>' + requestBody);
        return requestBody;
    }

    //Created by Luke Stevens
    @AuraEnabled
    public static List<State__mdt> getStates() {
        List<State__mdt> states = new List<State__mdt>([SELECT Label, State_Abbreviation__c FROM State__mdt ORDER BY Label]);
        return states;
    }

    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> evaluateQuestions(Id enrollmentId, String questions, Id sectionComponentId) {
        system.debug('NES_QuestionsHelper.getRelatedQuestions2(' + enrollmentId + ', ' + questions + ', ' +  sectionComponentId + ', ' +  false +')');
        return NES_QuestionsHelper.getRelatedQuestions2(enrollmentId, questions, sectionComponentId, false);
    }

    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getRelatedQuestions(Id sectionComponentId, Id enrollmentId){
        return NES_QuestionsHelper.getRelatedQuestions2(enrollmentId, null, sectionComponentId, false);
    }

    /**
     * Created By Anand
     * Purpose : Wrappeer Class to Deserialize the Data
     */

    public class SchoolWrapper {
        @AuraEnabled
        public String dataContext;  //https://alpha-bweber-mdr.search.windows.net/indexes('azuresql-index')/$metadata#docs(*)
        @AuraEnabled
        public SchoolAddressData[] value;
    }
    public class SchoolAddressData {
        @AuraEnabled
        public Double searchScore;  //3.0951552
        @AuraEnabled
        public String schoolName;   //Hebron High School
        @AuraEnabled
        public String streetAddress;    //509 S Main St
        @AuraEnabled
        public String city; //Hebron
        @AuraEnabled
        public String postalCode;   //46341
        @AuraEnabled
        public String stateAbbr;    //IN
        @AuraEnabled
        public String countryAbbr;  //USA
        @AuraEnabled
        public String districtName;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public String faxNumber;
    }
/**
     * Created By Anand
     * Purpose : Wrappeer Class to serialize the Data
     */
    public class SerializeSchoolData {

        public String search;
        public String searchFields;
        public String selectString;
        // public Integer top ;
        // public String skip ;

        public SerializeSchoolData(String schoolName, String city, String state){

            Boolean fieldSupplied = false;

            this.search = '';
            this.searchFields = '';
            this.selectString = '';

            if(!String.isEmpty(schoolName)){
                this.search += schoolName;
                this.searchFields += 'schoolName';
                fieldSupplied = true;
            }

            if(!String.isEmpty(city)) {
                this.search += fieldSupplied ? ' ' + city : city;
                this.searchFields += fieldSupplied ? ',' + 'city' : 'city';
                fieldSupplied = true;
            }

            if(!String.isEmpty(state)) {
                this.search += fieldSupplied ? ' ' + state : state;
                this.searchFields += fieldSupplied ? ',' + 'stateAbbr' : 'stateAbbr';
                fieldSupplied = true;
            }

            this.selectString = 'schoolName,streetAddress,city,districtName,stateAbbr,postalCode,countryAbbr,faxNumber,phoneNumber';
        }

        public SerializeSchoolData(String search) {
            this.search = search;
            this.searchFields = 'schoolName,city,stateAbbr';
            this.selectString = 'schoolName,streetAddress,city,districtName,stateAbbr,postalCode,countryAbbr,faxNumber';
            //this.top = 5;

        }
    }
}