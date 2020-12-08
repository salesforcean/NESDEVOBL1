/**
* Created by ali.khan (Ness Tech) on 10/17/19.
* This class generates dependent picklist options for aura component: dynamicePicklistFSC
*/

global with sharing class dynamicPicklistFSCController {
    
    
    @AuraEnabled
    global static List<Map<String, String>> getDependentPicklistValues(String sObjectAPIName, String picklistField, String ctrlField, String ctrlFieldPicklistValue) {
        
        System.debug('dynamicPicklistFSCController.getDependentPicklistValues(' + sObjectAPIName + ', ' + picklistField + ', ' + ctrlField + ', ' + ctrlFieldPicklistValue + ')');
        
        checkAccess(sObjectAPIName, new string[]{picklistField}, 'read');
        
        PicklistDefinition dpld = new PicklistDefinition(sObjectAPIName, picklistField, ctrlField, ctrlFieldPicklistValue);
        Map<String, String> objResults = getPicklistValues(dpld);
        
        List<Map<string, string>> options = new List<Map<string, string>>();
        if (objResults!=null) {
            for (String val : objResults.keySet()) {
                Map<string, string> newOptions = new Map<string, string>{};
                    newOptions.put('value', val);
                newOptions.put('label', objResults.get(val));
                options.add(newOptions);
            }
        }
        
        System.debug(JSON.serialize(options));
        return options;
        
    }
    
    // @AuraEnabled
    // global static list<Map<string, string> > getPicklistValues(string obj, String fld){
    //   checkAccess(obj, new string[]{fld}, 'read');
    
    // 	list<Map<string, string> > options = new list<Map<string, string> >();
    // 	Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);
    // 	Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    // 	map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    // 	list<Schema.PicklistEntry> values =
    // 		fieldMap.get(fld).getDescribe().getPickListValues();
    // 	for (Schema.PicklistEntry a : values)
    // 	{
    // 		Map<string, string> newOptions = new Map<string, string>{};
    // 		newOptions.put('value', a.getValue());
    // 		newOptions.put('label', a.getLabel());
    // 		options.add(newOptions);
    // 	}
    
    // 	return options;
    // }
    
    //     
    public static void checkAccess(string sObjectName, String[] fields, string accessType) {
        
        System.debug('dynamicPicklistFSCController.checkAccess(' + sObjectName + ', ' + fields + ', ' + accessType +')');
        // check if the object exists
        SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        if (sObj==null) {
            AuraHandledException e = new AuraHandledException('Unable to access to the SObject: ' + sObjectName);
            e.setMessage('Unable to access to the SObject: ' + sObjectName);
            throw e;
        }
        
        Map<String, Schema.SObjectField> sObjectFields = sObj.getDescribe().fields.getMap();
        String[] systemFields = new String[] {
            'Id',
                'IsDeleted',
                'CreatedBy',
                'CreatedById',
                'CreatedDate',
                'LastModifiedBy',
                'LastModifiedById',
                'LastModifiedDate',
                'SystemModstamp'
                };
                    for (String field : fields) {
                        // check if the field exists
                        Schema.SObjectField sObjField = sObjectFields.get(field);
                        if (sObjField==null) {
                            AuraHandledException e = new AuraHandledException('Unable to access to the SObjectField: ' + field);
                            e.setMessage('Unable to access to the SObjectField: ' + field);
                            throw e;
                        }
                        if (accessType == 'create') {
                            // Check if the user has access to field
                            if (systemFields.indexOf(field) > -1 || sObjectFields.get(field).getDescribe().isCalculated() || sObjectFields.get(field).getDescribe().isAutoNumber()) continue;
                            if (!sObjField.getDescribe().isCreateable()) {
                                // Pass error to client
                                // Due to a quirk with AuraHandledException, the message is only passed to the client when the message is set in both ways
                                // as it is below.
                                AuraHandledException e = new AuraHandledException('Access to one or more necessary fields is restricted for the current user. ' + field);
                                e.setMessage('Access to one or more necessary fields is restricted for the current user. ' + field);
                                throw e;
                            }
                            
                        } else if(accessType == 'read') {
                            if (!sObjField.getDescribe().isAccessible()) {
                                AuraHandledException e = new AuraHandledException('Access to one or more necessary fields is restricted for the current user.');
                                e.setMessage('Access to one or more necessary fields is restricted for the current user.');
                                throw e;
                            }
                        }
                        // else if(accessType == 'update') {
                        // 		if(systemFields.indexOf(field) > -1 || sobjectfields.get(field).getDescribe().isCalculated() || sobjectfields.get(field).getDescribe().isAutoNumber()) continue;
                        // 		if (!sobjectfields.get(field).getDescribe().isUpdateable()) {
                        // 			AuraHandledException e = new AuraHandledException('Access to one or more necessary fields is restricted for the current user.');
                        // 			e.setMessage('Access to one or more necessary fields is restricted for the current user.');
                        // 			throw e;
                        // 		}
                        // } else if(accessType == 'delete') {
                        // 	    if (!sobj.getDescribe().isDeletable()) {
                        // 		    AuraHandledException e = new AuraHandledException('Access to one or more necessary objects is restricted for the current user.');
                        // 		    e.setMessage('Access to one or more necessary objects is restricted for the current user.');
                        // 		    throw e;
                        // 	    }
                        // }                        
                    }
        
        
    }

    public static Schema.SObjectField safeGetSobjectField(String sObjectName, String sObjectFieldName) {
        SObjectType sObj = safeGetSObject(sObjectName);
        Schema.SObjectField sObjField = sObj.getDescribe().fields.getMap().get(sObjectFieldName);
        if (sObjField==null) {
            AuraHandledException e = new AuraHandledException('Unable to access to the SObjectField: ' + sObjectFieldName);
            e.setMessage('Unable to access to the SObjectField: ' + sObjectFieldName);
            throw e;
        }
        return sObjField;
    }

    public static SObjectType safeGetSObject(String sObjectName) {
        SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        if (sObj==null) {
            AuraHandledException e = new AuraHandledException('Unable to access to the SObject: ' + sObjectName);
            e.setMessage('Unable to access to the SObject: ' + sObjectName);
            throw e;
        }
        return sObj;
    }
    
    
    public static Map<String, String> getPicklistValues(PicklistDefinition dpld) {
        
        if (String.isBlank(dpld.ctrlField)) {
            // return normal picklist options
            System.debug('Controlling Field is Empty.');

	        Schema.SObjectField picklistField = safeGetSObjectField(dpld.sObjectAPIName, dpld.theField);
        	List<Schema.PicklistEntry> picklistEntries = picklistField.getDescribe().getPicklistValues();
            Map<String, String> objResults = new Map<String, String> ();
            for (Schema.PicklistEntry ple : picklistEntries) {
                objResults.put(ple.getLabel(), ple.getValue());
            }
			return objResults;            
        } else {
            // return dependent picklist options
            if (String.isBlank(dpld.ctrlFieldPicklistValue)) {
                System.debug('Controlling Field Picklist Value is Empty.');
                return null;
            }

//			Schema.SObjectField ctrlField = Schema.getGlobalDescribe().get(dpld.sObjectAPIName).getDescribe().fields.getMap().get(dpld.ctrlField);
//          Schema.SObjectField field = Schema.getGlobalDescribe().get(dpld.sObjectAPIName).getDescribe().fields.getMap().get(dpld.theField);
//          
			Schema.SObjectField ctrlField = safeGetSObjectField(dpld.sObjectAPIName, dpld.ctrlField);
            Schema.SObjectField picklistField = safeGetSObjectField(dpld.sObjectAPIName, dpld.theField);

            Map<String, Map<String, String>> objResults = HL_FieldDescribeUtil.getDependentOptionsImpl(picklistField, ctrlField);
            System.debug(JSON.serialize(objResults));
            
            //Map<String, Map<String, String>> objResults = getDependentOptionsAll(dpld);
            if (!(objResults.size() > 0) || !objResults.containsKey(dpld.ctrlFieldPicklistValue)) {
                system.debug('Controlling Field Picklist Value not found.');
                return null;
            }
            System.debug('objResults: ' + JSON.serialize(objResults.get(dpld.ctrlFieldPicklistValue)));
            return objResults.get(dpld.ctrlFieldPicklistValue);
        }    
    }
        
    public class PicklistDefinition {
        
        public PicklistDefinition(String sObjectAPIName, String theField, String ctrlField, String ctrlFieldPicklistValue) {
            this.sObjectAPIName = sObjectAPIName;
            this.theField = theField;
            this.ctrlField = ctrlField;
            this.ctrlFieldPicklistValue = ctrlFieldPicklistValue;
        }
        
        @InvocableVariable(required=true label='1. sObject API Name')
        public String sObjectAPIName;
        
        @InvocableVariable(required=true label='2. Dependent Field API Name')
        public String theField;
        
        @InvocableVariable(required=true label='3. Controlling Field API Name')
        public String ctrlField;
        
        @InvocableVariable(required=true label='4. Controlling Field Picklist Value')
        public String ctrlFieldPicklistValue;
        
    }
    
}