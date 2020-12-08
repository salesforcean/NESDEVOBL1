/* Author- VaniShravan Katta
Date 9/28/2020
Description- To delete Enrollment Component Affilication records*/

global class deleteEnrollmentComAff implements Database.Batchable<sObject> 
{   
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id from Enrollment_Component_Affiliation__c]);
    }    
    global void execute(Database.BatchableContext bc, List<Enrollment_Component_Affiliation__c> scope){
        if(scope.size()>0){
            delete scope;
        }
    }  
    global void finish(Database.BatchableContext bc){
        
    }
    
    
}