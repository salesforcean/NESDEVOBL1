/**
 * Created by Ritvik on 05-11-2018.
 * Purpose - Test class for CriteriaGroupBusinessLogic apex class.
 */
@isTest
private class NES_CriteriaGroupTriggerTest {


    @TestSetup
    static void setup(){
      Peak_TestUtils.createNESBusinessLogicSwitch('CriteriaGroupTrigger', true);
        }
        
    @isTest
    static void UnitTestPositiveScenario1(){

        //Inserting Enrollment Component of record type 'Form'.
        Enrollment_Component__c enrollCompRecord = Peak_TestUtils.createEnrollmentComponent(null,'Form',false);
        enrollCompRecord.Name = 'Test Enrollment Component';
        insert enrollCompRecord;

        //Creating criteria group for the enrollment component inserted above.
        Criteria_Group__c criteriaGroupRecord1 = Peak_TestUtils.createCriteriaGroup('Test Criteria Group1',enrollCompRecord.Id,false);

        Test.startTest();

        insert criteriaGroupRecord1;
        Criteria_Group__c cgRecord = [SELECT ID, Group_Number__c FROM Criteria_Group__c WHERE  Enrollment_Component__c =: enrollCompRecord.Id];
        update criteriaGroupRecord1;
        System.assertEquals(1, cgRecord.Group_Number__c);

        Test.stopTest();


    }

    @isTest
    static void UnitTestPositiveScenario2(){

        //Creating Enrollment Component of record type 'Form'.
        Enrollment_Component__c enrollCompRecord = Peak_TestUtils.createEnrollmentComponent(null,'Form',false);
        enrollCompRecord.Name = 'Test Enrollment Component';
        insert enrollCompRecord;
        //Creating criteria group for the enrollment component inserted above.
        Criteria_Group__c criteriaGroupRecord1 = Peak_TestUtils.createCriteriaGroup('Test Criteria Group1',enrollCompRecord.Id,true);

        Criteria_Group__c criteriaGroupRecord2 = Peak_TestUtils.createCriteriaGroup('Test Criteria Group2',enrollCompRecord.Id,false);


        Test.startTest();

        insert criteriaGroupRecord2;
        Criteria_Group__c criteriaGroupRecord3 = Peak_TestUtils.createCriteriaGroup('Test Criteria Group3',enrollCompRecord.Id,true);

        List<Criteria_Group__c> cgRecord = [SELECT ID, Group_Number__c FROM Criteria_Group__c WHERE Enrollment_Component__c =: enrollCompRecord.Id];
        System.assertEquals(2, cgRecord[1].Group_Number__c);


        Test.stopTest();

    }
}