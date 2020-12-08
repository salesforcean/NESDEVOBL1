/**
 * Created by Ritvik on 26-10-2018.
 Purpose : Handler class for EnrollmentComponentCriteriaTrigger
 */

public with sharing class NES_EnrollmentCompCriteriaHandler {
    NES_EnrollmentCompCriteriaBusinessLogic logicHandler = new NES_EnrollmentCompCriteriaBusinessLogic();

    public void handleBeforeInsert(List<Enrollment_Component_Criteria__c> newList){
        logicHandler.GenerateNumber(newList);
    }

    public void handleAfterInsert(List<Enrollment_Component_Criteria__c> newList){

    }

}