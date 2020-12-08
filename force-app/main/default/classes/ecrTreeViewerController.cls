/**
 *  
 *  all server/apex things needed by ecrTreeViewer LWC component are here.
 *
 *        
 */
public with sharing class ecrTreeViewerController {

    @AuraEnabled
    public static List<Map<String, String>> getProcessOptions(){

        List<Map<String, String>> options = new List<Map<String, String>>();
        Map<String, String> tempValues; 

        for (Enrollment_Component__c processEC : [
            SELECT      Id, Process_Academic_Program__r.Name 
            FROM        Enrollment_Component__c 
            WHERE       Process_Academic_Program__c != null 
            ORDER BY    CreatedDate DESC 
            LIMIT       50
        ]) 
        {
            options.add( 
                new Map<String, String>{
                    'label' => processEC.Process_Academic_Program__r.Name,
                    'value' => processEC.Id
                } 
            );
        }
    
        return options;        
        
    }

    @AuraEnabled
    public static Enrollment_Component__c getProcessECById(String ecId){
        return [SELECT Id, Process_Academic_Program__r.Name, Process_Academic_Program__c
            FROM Enrollment_Component__c WHERE Id = :ecId];
    }

}