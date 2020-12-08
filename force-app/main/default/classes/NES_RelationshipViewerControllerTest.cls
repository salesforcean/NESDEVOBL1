/**
 * Created by ajith on 17/12/18.
 */

@isTest
public class NES_RelationshipViewerControllerTest {

    @TestSetup
    static void setup(){

        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();

        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(null, 'Question', false);
        componentList.add(questionComponent);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(null, 'Section', false);
        componentList.add(sectionComponent);
        Enrollment_Component__c sectionComponentOne = Peak_TestUtils.createEnrollmentComponent(null, 'Section', false);
        componentList.add(sectionComponentOne);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(null, 'Form', false);
        componentList.add(formComponent);
        Enrollment_Component__c formComponentOne = Peak_TestUtils.createEnrollmentComponent(null, 'Form', false);
        componentList.add(formComponentOne);
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(null, 'Stage', false);
        componentList.add(stageComponent);
        Enrollment_Component__c stageComponentOne = Peak_TestUtils.createEnrollmentComponent(null, 'Stage', false);
        componentList.add(stageComponentOne);
        Enrollment_Component__c stageComponentTwo = Peak_TestUtils.createEnrollmentComponent(null, 'Stage', false);
        componentList.add(stageComponentTwo);
        Enrollment_Component__c stageComponentThree = Peak_TestUtils.createEnrollmentComponent(null, 'Stage', false);
        componentList.add(stageComponentThree);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponent);
        Enrollment_Component__c processComponentOne = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentOne);
        Enrollment_Component__c processComponentTwo = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentTwo);
        Enrollment_Component__c processComponentThree = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentThree);
        Enrollment_Component__c processComponentFour = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentFour);
        Enrollment_Component__c processComponentFive = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentFive);
        Enrollment_Component__c processComponentSix = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentSix);
        Enrollment_Component__c processComponentSeven = Peak_TestUtils.createEnrollmentComponent(null, 'Process', false);
        componentList.add(processComponentSeven);
        Insert componentList;

        //Insert ECR's with child as Questions and Parent as Section
        Enrollment_Component_Relationship__c enrollCompRelSectionOne = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelSectionTwo = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponentOne.Id);
        //Insert ECR's with child as Section and Parent as Form
        Enrollment_Component_Relationship__c enrollCompRelFormOne = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelFormTwo = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponentOne.Id);
        //Insert ECR's with child as Form and Parent as Stage
        Enrollment_Component_Relationship__c enrollCompRelStageOne = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelStageTwo = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponentOne.Id);
        Enrollment_Component_Relationship__c enrollCompRelStageThree = Peak_TestUtils.createEnrollmentComponentRelationship(formComponentOne.Id, stageComponentTwo.Id);
        Enrollment_Component_Relationship__c enrollCompRelStageFour = Peak_TestUtils.createEnrollmentComponentRelationship(formComponentOne.Id, stageComponentThree.Id);
        //Insert ECR's with child as Stage and Parent as Process
        Enrollment_Component_Relationship__c enrollCompRelProcessOne = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessTwo = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponentOne.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessThree = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentOne.Id, processComponentTwo.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessFour = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentOne.Id, processComponentThree.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessFive = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentTwo.Id, processComponentFour.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessSix = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentTwo.Id, processComponentFive.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessSeven = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentThree.Id, processComponentSix.Id);
        Enrollment_Component_Relationship__c enrollCompRelProcessEight = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentThree.Id, processComponentSeven.Id);

    }

    static testMethod void unitTestPositiveCases(){
        Enrollment_Component__c ecQuestion = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' LIMIT 1];
        Enrollment_Component__c ecForm = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Form' LIMIT 1];
        Test.startTest();
        String recordTypeId = NES_RelationshipViewerController.getECRecordType(ecQuestion.Id);
        Peak_Response questionResponse = NES_RelationshipViewerController.getQuestionRelatedECs(ecQuestion.Id);
        Peak_Response formResponse = NES_RelationshipViewerController.getFormRelatedECs(ecForm.Id);

        System.assert(questionResponse.relationShipViewResults.size() > 0, 'Fatal Error');
        System.assert(formResponse.relationShipViewResults.size() > 0, 'Fatal Error');
        Test.stopTest();

    }

    static testMethod void unitTestNegativeCases(){
        Enrollment_Component__c ecQuestion = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' LIMIT 1];
        Enrollment_Component__c ecForm = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Form' LIMIT 1];
        Test.startTest();
        Peak_Response questionResponse = NES_RelationshipViewerController.getQuestionRelatedECs(ecForm.Id);
        Peak_Response formResponse = NES_RelationshipViewerController.getFormRelatedECs(ecQuestion.Id);

        System.assert(questionResponse.relationShipViewResults.size() == 0, 'Fatal Error');
        System.assert(formResponse.relationShipViewResults.size() == 0, 'Fatal Error');
        Test.stopTest();

    }

}