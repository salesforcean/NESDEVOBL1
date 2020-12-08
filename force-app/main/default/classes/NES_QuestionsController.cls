/**
 * Created by triciaigoe on 1/25/19.
 * 2019-10-07 Added Skip For Now #US108687 (Ali Khan)
 */

public without sharing class NES_QuestionsController {

    /**
    * Created by Ashish Sharma on 11/14/18.
    * Parameters: ID
    * Return Type: List<NES_DashboardUtilities.Question>
    * Purpose : This method is used to get the related Child enrollment component of QUESTION_RT record type using sectionComponentId
    and using those child components get the required question components information
    */
    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getRelatedQuestions(Id sectionComponentId, Id enrollmentId){
        return NES_QuestionsHelper.getRelatedQuestions2(enrollmentId, null, sectionComponentId, true);
    }

    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getRelatedQuestions2(Id sectionComponentId, Id enrollmentId){
        return NES_QuestionsHelper.getRelatedQuestions2(enrollmentId, null, sectionComponentId, true);
    }

    /**
    * Created by Ashish Sharma on 11/14/18.
    * Parameters: ID
    * Return Type: List<Enrollment_Component_Picklist_Option__c>
    * Purpose : This method is used to retrieve and return all the Enrollment_Component_Picklist_Option__c records related to questionComponentId
    */
    @AuraEnabled
    public static List<Enrollment_Component_Picklist_Option__c> getRelatedPicklistOptions(Id questionComponentId) {
        return NES_QuestionsHelper.getRelatedPicklistOptions(questionComponentId);
    }

    // submit and save answers to the questions
    @AuraEnabled
    public static Peak_Response submitQuestions(Id enrollmentId, String questions, Id processComponentId, Id sectionComponentId) {
        return NES_QuestionsHelper.submitQuestions(enrollmentId, questions, sectionComponentId, processComponentId);
    }

    // #US108687 (Ali Khan)
    @AuraEnabled
    public static Peak_Response grabNextURL(Id enrollmentId, Id processComponentId, Id sectionComponentId) {
        Peak_Response peakResponse = new Peak_Response();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.Name, Program_Grade_Level__r.Grade_Level__r.Name FROM hed__Program_Enrollment__c WHERE Id = :enrollmentId];
        String urlString = NES_QuestionsHelper.grabNextURL(enrollmentId, sectionComponentId, programEnrollment.hed__Contact__r.Name, processComponentId, programEnrollment.Program_Grade_Level__r.Grade_Level__r.Name, programEnrollment.hed__Contact__c, false);
        peakResponse.success = true;
        peakResponse.messages.add(urlString);
        return peakResponse;
    }    
    // #US108687 (Ali Khan)
   
    //Save one answer and analyze current assignment
    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> evaluateQuestion(Id enrollmentId, String questions, Id sectionComponentId, Id processId) {
        return NES_QuestionsHelper.getRelatedQuestions2(enrollmentId, questions, sectionComponentId, true);
    }

    @AuraEnabled
    public static List<Enrollment_Component__c> getRelatedMessages(Id enrollmentComponentId, Id programEnrollmentId){
        return NES_EnrollmentHelper.getRelatedMessages(enrollmentComponentId, programEnrollmentId);
    }

    @AuraEnabled
    public static Id getSchoolId(Id enrollmentId) {
        return NES_QuestionsHelper.grabSchoolId(enrollmentId);
    }

    @AuraEnabled
    public static String getSectionName(Id sectionId){
        return NES_QuestionsHelper.getSectionName(sectionId);
    }

    @AuraEnabled
    public static String grabNameOfStudent(Id studentId, Id programEnrollmentId) {
        return NES_EnrollmentUtils.getStudentName(studentId, programEnrollmentId);
    }
    
    //Swapna:For GTM
    @AuraEnabled
    public static String getformName(Id sectionId){
        return NES_QuestionsHelper.getformName(sectionId);
    }
    
}