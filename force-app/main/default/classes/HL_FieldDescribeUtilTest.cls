/**

    * Created by ali.khan (Ness Tech) on 10/18/19.
    * Test class covers following code coverage: 
        - HL_FieldDescribeUtil.cls
        - PopulatePicklist.cls
        - NES_FBBFetchDependentPicklist.cls

*/

@isTest
public with sharing class HL_FieldDescribeUtilTest {


    public static String sObjectAPIName = 'Enrollment_Document__c';
    public static String ctrlField = 'Type__c';
    public static String theField = 'Status_Reason__c';
    public static String ctrlFieldPicklistValue = 'Proof of Residence'; // '504 Plan'; // 'Evaluation';


    // Test fetching of dependent picklist values from PopulatePicklist
	@isTest
	public static void testFetchPicklistByControllingFieldValue_PopulatePicklist() {

        
        List<Map<String, String>> dependentPicklistOptions;
        Exception err;


        Test.startTest();
        try {

                dependentPicklistOptions = 
                    PopulatePicklist.getDependentPicklistValues(sObjectAPIName, theField, ctrlField, ctrlFieldPicklistValue);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();

        system.assertNotEquals(null, dependentPicklistOptions, 'dependentPicklistOptions is null!');
        system.assertEquals(null, err, 'exceptions!');


	}

    // Test fetching of dependent picklist by value from NES_FBBFetchDependentPicklist
	@isTest
	public static void testFetchDependentPicklist_NES_FBBFetchDependentPicklist() {

        
        Map<String, String> dependentPicklistByControllingFieldValue;
        Exception err;


        Test.startTest();
        try {
            
            NES_FBBFetchDependentPicklist.DependentPickDefinition 
                dpld = new NES_FBBFetchDependentPicklist.DependentPickDefinition(sObjectAPIName, theField, ctrlField, ctrlFieldPicklistValue);

            dependentPicklistByControllingFieldValue = NES_FBBFetchDependentPicklist.getDependentOptions(dpld);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();

        system.assertNotEquals(null, dependentPicklistByControllingFieldValue, 'dependentPicklistByControllingFieldValue is null!');
        system.assertEquals(null, err, 'exceptions!');


	}

    // Test fetching of dependent picklist values from HL_FieldDescribeUtil
	@isTest
	public static void test_HL_FieldDescribeUtil_fetchDependentPicklist() {

        // String sObjectAPIName = 'Enrollment_Document__c';
        // String ctrlField = 'Type__c';
        // String theField = 'Status_Reason__c';

        Map<String, Map<String, String>> dependentPicklistsMap;

        Exception err;
        Test.startTest();
        try {
            dependentPicklistsMap = HL_FieldDescribeUtil.getDependentOptions(sObjectAPIName, ctrlField, theField);
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        system.assertNotEquals(null, dependentPicklistsMap, 'dependentPicklistsMap is null!');
        system.assertEquals(null, err, 'exceptions!');

	}


}