@isTest(SeeAllData=false)
private class dynamicPicklistFSCControllerTest {
    
    static testMethod void test1() {
        // test ideal scenario
        Test.startTest();
        List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Document__c', 'Status_Reason__c', 'Type__c', 'Gifted Documentation');
        System.assertNotEquals(null, plValues);
        System.assert(plValues.size()>0);
        Test.stopTest();
    }
    
    static testMethod void test2() {
        // test no control field value match
        Test.startTest();
        List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Document__c', 'Status_Reason__c', 'Type__c', 'Gifted Documentationx');
        System.assertNotEquals(null, plValues);
        System.assert(plValues.size()==0);
        Test.stopTest();
    }
    
    
    static testMethod void test3() {
        // test no control field value
        Test.startTest();
        List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Document__c', 'Status_Reason__c', 'Type__c', '');
        System.assertNotEquals(null, plValues);
        System.assert(plValues.size()==0);
        Test.stopTest();
    }
    
    static testMethod void test4() {
        // test no control field, no control field value
        Test.startTest();
        List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Annual_Student_Information__c', 'Grade_Level_Requested__c', '', '');
        System.assertNotEquals(null, plValues);
        System.assert(plValues.size()>0);
        Test.stopTest();
    }
    
    static testMethod void test5() {
        // test invalid sobject
        try {
            Test.startTest();
            List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Documentx__c', 'Status_Reason__c', '', '');
            Test.stopTest();
            System.assert(false, 'Exception expected.');            
        } catch (AuraHandledException e) {
            String message = e.getMessage();
            System.assert(e.getMessage().contains('Unable to access to the SObject:'), 'message=' + e.getMessage());
        }
    }
    
    static testMethod void test6() {
        // test invalid sobject field
        try {
            Test.startTest();
            List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Document__c', 'Status_Reasonx__c', '', '');
            Test.stopTest();
            System.assert(false, 'Exception expected.');            
        } catch (AuraHandledException e) {
            String message = e.getMessage();
            System.assert(e.getMessage().contains('Unable to access to the SObjectField:'), 'message=' + e.getMessage());
        }
    }
    
    static testMethod void test7() {
        // test invalid control field
        Test.startTest();
        List<Map<String, String>> plValues = dynamicPicklistFSCController.getDependentPicklistValues('Enrollment_Document__c', 'Status_Reason__c', 'Typex__c', '');
        System.assertNotEquals(null, plValues);
        System.assert(plValues.size()==0);
        Test.stopTest();
    }
    
    static testMethod void test8() {
        // test invalid field
        try {
            Test.startTest();
            SObjectField sObjField = dynamicPicklistFSCController.safeGetSObjectField('Enrollment_Document__c', 'Status_Reasonx__c');
            Test.stopTest();
            System.assert(false, 'Exception expected.');            
        } catch (AuraHandledException e) {
            String message = e.getMessage();
            System.assert(e.getMessage().contains('Unable to access to the SObjectField:'), 'message=' + e.getMessage());
        }
    }
    
    static testMethod void test9() {
        // test invalid sobject 
        try {
            Test.startTest();
            SObjectField sObjField = dynamicPicklistFSCController.safeGetSObjectField('Enrollment_Documentx__c', 'Status_Reason__c');
            Test.stopTest();
            System.assert(false, 'Exception expected.');            
        } catch (AuraHandledException e) {
            String message = e.getMessage();
            System.assert(e.getMessage().contains('Unable to access to the SObject:'), 'message=' + e.getMessage());
        }
    }
    
}