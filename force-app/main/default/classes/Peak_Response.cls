// ===================
// Custom Response wrapper
// ===================
public with sharing class Peak_Response {
    @AuraEnabled public Boolean success{get;set;} // success or failure
    @AuraEnabled public List<String> messages{get;set;}  // messages to display
    @AuraEnabled public List<SObject> results{get;set;} // results to iterate over - use this when querying SOjbects directoy
    @AuraEnabled public List<Peak_ContentObject> peakResults{get;set;} // custom results to iterate over - use this when creating a list of custom wrapper classes
    @AuraEnabled public String status{get;set;}//program enrollment status
    @AuraEnabled public List<String> pickListValues{get;set;}//It holds picklist values of specific object's field
    @AuraEnabled public Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>> relationShipViewResults {get; set;}
//	@AuraEnabled public String AccountId{get;set;} //Swapna:for GTM
    //Start: Task #66396 Ashish Sharma 12/21/2018
    @AuraEnabled public String parameter{get; set;}
    //End
    
    public Peak_Response(){
        success = true;
        messages = new List<String>();
        results = new List<SObject>();
        peakResults = new List<Peak_ContentObject>();
        pickListValues = new List<String>();
        relationShipViewResults = new Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>();
    }
}