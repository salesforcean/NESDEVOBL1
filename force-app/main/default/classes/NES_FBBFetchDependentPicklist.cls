/**
    * Created by ali.khan (Ness Tech) on 10/17/19.
    * This class generates dependent picklist, piggy backing on HL_FieldDescribeUtil.cls
*/

public with sharing class NES_FBBFetchDependentPicklist {


    public NES_FBBFetchDependentPicklist() {
    }


    public static Map<String, String> getDependentOptions(DependentPickDefinition dpld) {

        if (String.isBlank(dpld.ctrlFieldPicklistValue)) {
            System.debug('Controlling Field Picklist Value is Empty.');
            return null;
        }

        Map<String, Map<String, String>> objResults = getDependentOptionsAll(dpld);
        // System.debug('::getDependentOptions::');
        // System.debug(JSON.serialize(objResults));
        if (!(objResults.size() > 0)  || !objResults.containsKey(dpld.ctrlFieldPicklistValue)) {
            system.debug('Controlling Field Picklist entry not found.');
			return null;
        }
        System.debug('objResults');
        System.debug(JSON.serialize(objResults.get(dpld.ctrlFieldPicklistValue)));
        return objResults.get(dpld.ctrlFieldPicklistValue);

	}

    public static Map<String, Map<String, String>> getDependentOptionsAll(DependentPickDefinition dpld) {

        Schema.SobjectField cntrlField = Schema.getGlobalDescribe().get(dpld.sObjectAPIName).getDescribe().fields.getMap().get(dpld.ctrlField);
        Schema.SobjectField field = Schema.getGlobalDescribe().get(dpld.sObjectAPIName).getDescribe().fields.getMap().get(dpld.theField);

        Map<String, Map<String, String>> objResults = HL_FieldDescribeUtil.getDependentOptionsImpl(field, cntrlField);
        System.debug(JSON.serialize(objResults));

        return objResults;

    }

    public class DependentPickDefinition {

        public DependentPickDefinition(String sObjectAPIName, String theField, String ctrlField, String ctrlFieldPicklistValue) {

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