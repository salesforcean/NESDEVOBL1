/**
 *  
 *  code from: https://medium.com/@aneudupi/custom-picklist-component-using-lwc-e6014a0de9c5
 * 
 *  @Usage: 
        List<Map<String, String>> options = PicklistSelectorController.getAllProcessOptions();
        System.debug(JSON.serialize(options));
 *
 *        
 */
public with sharing class PicklistSelectorController {

    @AuraEnabled
    public static List<Map<String, String>> getAllProcessOptions(){

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


    /**
        >>> BELOW NOT NEEDED FOR OUR PURPOSE >>>
            @AuraEnabled
            public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
                List < Map < String, String >> options = new List < Map < String, String >> ();
                Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
                if (objType == null) {
                    return options;
                }
                Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
                Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
                if (fieldMap.get(fieldName) == null) {
                    return options;
                }
                List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
                for (Schema.PicklistEntry f: pickListValues) {
                    Map < String, String > values = new Map < String, String > {
                        'label' => f.getLabel(),
                        'value' => f.getValue()
                    };
                    options.add(values);
                }
                return options;
            }
            @AuraEnabled
            public static Map < Object, List < Map < String, String >>> getDependentOptions(String objApiName, String fieldName, String contrFieldApiName) {
                return FieldUtilityClass.getFieldDependenciesMaps(objApiName, contrFieldApiName, fieldName);
            }
            @AuraEnabled
            public static String getFieldLabel(String objName, String fieldName) {
                return FieldUtilityClass.getFieldLabel(objName, fieldName);
            }
        >>> END >>>
    */

}