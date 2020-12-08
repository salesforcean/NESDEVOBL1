/**
 * Created by Ritvik on 05-11-2018.
 * Purpose : Test class for EnrollmentComponentCriteriaBusinessLogic class.
 */

@isTest
private class NES_EnrollmentCompCriteriaTriggerTest {
    @TestSetup
    static void setup(){
        //Inserting Enrollment Component of record type 'Form'.
        Enrollment_Component__c enrollCompRecord = Peak_TestUtils.createEnrollmentComponent(null,'Form',false);
        enrollCompRecord.Name = 'Test Enrollment Component';
        insert enrollCompRecord;

        Criteria__c criteriaRecord = Peak_TestUtils.createCriteriaRecord('Test Criteria','Left field','>',false);
        criteriaRecord.Comparison_Field__c = 'Right field';
        insert criteriaRecord;
    }

    @isTest
    static void UnitTestPositiveScenarioMethodOne(){

        Enrollment_Component__c enrollmentComponent = [SELECT Id FROM Enrollment_Component__c WHERE Name = 'Test Enrollment Component'];
        Criteria__c criteria = [SELECT Id FROM Criteria__c WHERE Criteria_Field__c = 'Left field'];
        //Creating enrollment component criteria for the enrollment component inserted above.
        Enrollment_Component_Criteria__c EnrollCompCriteriaRecord1 = Peak_TestUtils.createEnrollCompCriteria('Test Enrollment Component Criteria1',enrollmentComponent.Id,false);
        EnrollCompCriteriaRecord1.Criteria__c = criteria.Id;
        EnrollCompCriteriaRecord1.Criteria_Type__c = 'Assignment';
        Test.startTest();
        insert EnrollCompCriteriaRecord1;

        Enrollment_Component_Criteria__c eccRecord = [SELECT Id, Criteria_Number__c FROM Enrollment_Component_Criteria__c WHERE Enrollment_Component__c =: enrollmentComponent.Id Limit 1];
        System.assertEquals(1, eccRecord.Criteria_Number__c);
        Test.stopTest();


    }

    @isTest
    static void UnitTestPositiveScenarioMethodTwo(){

        Enrollment_Component__c enrollmentComponent = [SELECT Id FROM Enrollment_Component__c WHERE Name = 'Test Enrollment Component'];
        Criteria__c criteria = [SELECT Id FROM Criteria__c WHERE Criteria_Field__c = 'Left field'];
        //Creating enrollment component criteria for the enrollment component inserted above.
        Enrollment_Component_Criteria__c EnrollCompCriteriaRecord1 = Peak_TestUtils.createEnrollCompCriteria('Test Enrollment Component Criteria1',enrollmentComponent.Id,false);
        EnrollCompCriteriaRecord1.Criteria__c = criteria.Id;
        EnrollCompCriteriaRecord1.Criteria_Type__c = 'Assignment';
        insert EnrollCompCriteriaRecord1;
        //Creating enrollment component criteria for the enrollment component inserted above.
        Enrollment_Component_Criteria__c EnrollCompCriteriaRecord2 = Peak_TestUtils.createEnrollCompCriteria('Test Enrollment Component Criteria2',enrollmentComponent.Id,false);
        EnrollCompCriteriaRecord2.Criteria__c = criteria.Id;
        EnrollCompCriteriaRecord2.Criteria_Type__c = 'Assignment';

        Test.startTest();
        insert EnrollCompCriteriaRecord2;
        //Creating enrollment component criteria for the enrollment component inserted above.
        Enrollment_Component_Criteria__c EnrollCompCriteriaRecord3 = Peak_TestUtils.createEnrollCompCriteria('Test Enrollment Component Criteria3',enrollmentComponent.Id,false);
        EnrollCompCriteriaRecord3.Criteria__c = criteria.Id;
        EnrollCompCriteriaRecord3.Criteria_Type__c = 'Assignment';
        insert EnrollCompCriteriaRecord3;
        List<Enrollment_Component_Criteria__c> eccRecord = [SELECT ID, Criteria_Number__c FROM Enrollment_Component_Criteria__c WHERE  Enrollment_Component__c =: enrollmentComponent.Id];
        System.assertEquals(2, eccRecord[1].Criteria_Number__c);
        Test.stopTest();

    }
}