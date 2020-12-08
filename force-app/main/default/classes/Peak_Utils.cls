/**
 * Created by Ritvik on 28-09-2018.
 */

// ===================
// Share general utility methods
// ===================
global without sharing class Peak_Utils {

    // Return true/false to determine guest user
    global static Boolean isGuestUser() {
        Boolean isGuest = false;
        if (UserInfo.getUserType() == 'Guest' || UserInfo.getUserName() == Peak_TestConstants.GUEST_USERNAME){
            isGuest = true;
        }
        return isGuest;
    }

    @AuraEnabled
    public static String getGuestType(){
        return UserInfo.getUserType();
    }

        //Swapna Added for GTM
 //Swapna Added for GTM
    @AuraEnabled
    public static String getHousehold(){
      //  Contact c;
        List<Contact> cl = [SELECT Account.Name,Account.Household_Id__c from Contact where Id IN (select ContactId from User where Id = :UserInfo.getUserId())];
         if(cl.size() >0)
               return cl[0].Account.Household_Id__c;
       else return null;
    }
    
    
    @AuraEnabled
    public static Boolean isGuest(){
        return Peak_Utils.isGuestUser();
    }

    // Get the current year
    @AuraEnabled
    public static Integer getYear(){
        return System.Today().year();
    }

    // Get the site prefix
    @AuraEnabled
    global static String getSitePrefix(){
        return System.Site.getPathPrefix();
    }
    // Get the site prefix
    @AuraEnabled
    global static String getResourceUrl(){
        String baseUrl = System.Site.getPathPrefix() + '/';
        String resourceUrl = baseUrl.replace('/s/', '/resource/');
        return resourceUrl;
    }
    @AuraEnabled
    public static String getSalesforceBaseURL(){
        String sfBaseURL = System.Url.getOrgDomainUrl().toExternalForm();
        return sfBaseURL;
    }
    

    // Get picklist values for any object, any field
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){
        // Thanks http://salesforce.stackexchange.com/questions/4992/how-to-get-a-picklist-all-values-in-apex-controller
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }

    // Build string from list
    public static String buildStringFromList(List<String> sourceList){
        String stringOutput = '';
        for(String thisString:sourceList) {
            stringOutput +=  (stringOutput==''?'':', ')+thisString;
        }
        return stringOutput;
    }

    // Build comma list string from a set
    public static String buildStringFromSet(Set<String> sourceSet){
        List<String> sourceList = new List<String>();
        sourceList.addAll(sourceSet);
        return buildStringFromList(sourceList);
    }


    // Get User
    public static User getUser(){
        return getUser(UserInfo.getUserId());
    }
    // Get User
    public static User getUser(Id userId){
        // BannerPhotoUrl, IsProfilePhotoActive
        User user;

        List<User> userList = [select
                Id, Email,PostalCode
        from User
        where Id = :UserInfo.getUserId()];

        if (!Peak_Utils.isNullOrEmpty(userList)) {
            user = userList[0];
        }

        return user;
    }

    public static Boolean isNullOrEmpty(List<Object> objectList) {
        if (objectList == null || objectList.size() == 0) {
            return true;
        }
        return false;
    }

    public static List<String> createListFromMultiPicklist(String multiPicklistValue){

        List<String> multiPicklistValueList = multiPicklistValue.split(';');
        return multiPicklistValueList;
    }

    public static Boolean doesStringContainListItem(List<String> compareList, String targetString){

        for(String compareString : compareList){

            //If list contains target string, return true
            if(targetString.contains(compareString)){
                return true;
            }
        }
        return false;
    }

    // Get the fieldmap for an object
    public static Map<String, Schema.SObjectField> getFieldSchema(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType schema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = schema.getDescribe().fields.getMap();

        return fieldMap;
    }

    /*
        Take a list of objects, get their IDs. Handy for getting a list of Objects than using their IDs in a where clause of another query
        List<SObject> orderRoles = some query;
        Set<Id> contactIds = new Set<Id> (Peak_Utils.toIds(orderRoles , 'Contact__c')); This would get Ids from the Contact__c field of our collection.
        new query - select something from something where someID in : contactIds
     */
    public static List<Id> toIds(List<SObject> records, final String fieldName) {
        List<Id> ids = new List<Id>();
        for (SObject record : records)
        {
            Id idVal = (Id)record.get(fieldName);
            ids.add(idVal);
        }
        return ids;
    }

    /**
     * Created by ajith on 05/12/18.
     * Purpose : This is the Utility method to get record type Ids by name
     * Params : objectAPI Name and Record Type Name 
     */

     public static Map<String,Id> getRecordTypesByObject(String objectName){
         Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
         List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
         Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
         for(Schema.RecordTypeInfo info : recordTypeInfo){
             recordTypeNameIdMap.put(info.getName(),info.getRecordTypeId());
         }
         return recordTypeNameIdMap;
     }
    
    @AuraEnabled
    public static String retrieveLogo(String instituteId) {
        String newId = NES_Utilities.retrieveLogo(instituteId);
        return newId;
    }
    
}