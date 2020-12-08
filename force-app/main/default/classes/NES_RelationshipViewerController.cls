/**
 * Created by ajith on 04/12/18.
 * Purpose : This is the Controller class for the Lightning component NES_RelationshipViewerComponent
 */

public with sharing class NES_RelationshipViewerController {



    /**
     * Created by ajith on 18/12/18.
     * Purpose : To get Determine the record type name of the passed Id from the FED
     * Params : Enrollment Component Id
     */
    @AuraEnabled
    public static String getECRecordType(Id ecId){
        Enrollment_Component__c ecComponent = [SELECT Id, RecordType.Name FROM Enrollment_Component__c WHERE Id =:ecId];
        return ecComponent.RecordType.Name;
    }

    /**
     * Created by ajith on 04/12/18.
     * Purpose : To get the related EC's for question EC Id Passed in
     * Params : Question Enrollment Component Id
     */
    @AuraEnabled
    public static Peak_Response getQuestionRelatedECs(Id questionEcId){
        Peak_Response peakResponse = NES_RelationshipViewerHelper.getRelatedECComponents_Question(questionEcId);
        return peakResponse;
    }

    /**
     * Created by ajith on 04/12/18.
     * Purpose : To get the related EC's for question EC Id Passed in
     * Params : Form Enrollment Component Id
     */
    @AuraEnabled
    public static Peak_Response getFormRelatedECs(Id formEcId){
        Peak_Response peakResponse = NES_RelationshipViewerHelper.getRelatedECComponents_Form(formEcId);
        return peakResponse;
    }
}