/**
 * Created by ajith on 01/10/18.
 */

public with sharing class NES_FormController {

    /*public static Map<Id, Enrollment_Component__c> componentMap;

    //This method would list of enrollment Components records that student needs to see based the program he enrolled.
    public static List<Enrollment_Component__c> getComponentsByAffiliation(String programEnrollmentId){
        List<Enrollment_Component__c> enrollmentComponents = new List<Enrollment_Component__c>();
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        List<String> componentsIds = new List<String>();
        for(Enrollment_Component_Affiliation__c affiliations : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c
                                                                       FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c =: programEnrollmentId]){

            enrollmentComponentAffiliations.add(affiliations);
            componentsIds.add(affiliations.Enrollment_Component__c);
        }

        if(enrollmentComponentAffiliations.size() > 0){
            String allFields = NES_Utilities2.selectAllFields('Enrollment_Component__c');
            String queryString = ' SELECT ' + allFields + ' FROM Enrollment_Component__c WHERE Id IN :componentsIds ORDER BY Order__c ';
            enrollmentComponents = Database.query(queryString);
            componentMap = new map<Id,Enrollment_Component__c>(enrollmentComponents);
        }

        return enrollmentComponents;
    }

    @AuraEnabled
    public static NES_FormResponse getFormInformation(String programEnrollmentId){
        System.debug('programEnrollmentId'+programEnrollmentId);
        List<Enrollment_Component__c> enrollmentComponents = new List<Enrollment_Component__c>();
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        List<String> componentsIds = new List<String>();
        for(Enrollment_Component_Affiliation__c affiliations : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c
        FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c =: programEnrollmentId]){

            enrollmentComponentAffiliations.add(affiliations);
            componentsIds.add(affiliations.Enrollment_Component__c);
        }

        if(enrollmentComponentAffiliations.size() > 0){
            String allFields = NES_Utilities2.selectAllFields('Enrollment_Component__c');
            String queryString = ' SELECT ' + allFields + ' FROM Enrollment_Component__c WHERE Id IN :componentsIds ORDER BY Order__c ';
            enrollmentComponents = Database.query(queryString);
            componentMap = new map<Id,Enrollment_Component__c>(enrollmentComponents);
        }

        NES_FormResponse response = new NES_FormResponse();
        Set<Id> componentIds = componentMap.keySet();
        String relFields = NES_Utilities2.selectAllFields('Enrollment_Component_Relationship__c');
        String relQuery = ' SELECT ' + relFields + ' ,Parent_Enrollment_Component__r.Label__c, Parent_Enrollment_Component__r.Question_Type__c, Child_Enrollment_Component__r.Label__c, Child_Enrollment_Component__r.Type__c ';
        relQuery += ' FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :componentIds ORDER BY Order__c ';
        System.debug('relQuery'+relQuery);
        List<Enrollment_Component_Relationship__c> enrollmentComponentRelationshipsList = new List<Enrollment_Component_Relationship__c>();
        enrollmentComponentRelationshipsList = Database.query(relQuery);

        for(Enrollment_Component_Relationship__c rel : enrollmentComponentRelationshipsList){
          if(rel.Parent_Enrollment_Component__c != null){
              NES_FormDetail parentForm = new NES_FormDetail();
              parentForm.FieldLabel = rel.Parent_Enrollment_Component__r.Label__c;
              if(rel.Child_Enrollment_Component__c != null){
                  NES_FormDetail childForm = new NES_FormDetail();
                  childForm.FieldLabel = rel.Child_Enrollment_Component__r.Label__c;
                  if(rel.Child_Enrollment_Component__r.Question_Type__c != null){
                      childForm.FieldType = rel.Child_Enrollment_Component__r.Question_Type__c;
                  }
                  parentForm.SubFormDetails.add(childForm);
              }
              response.detail.add(parentForm);
          }
        }
        return response;
    }

    public static void saveFormInformation(String enrollmentId, String response){
        String targetObj;
        String targetField;
        Enrollment_Component__c cmp = [SELECT Id, Type__c, Answer_Target__c FROM Enrollment_Component__c WHERE Id =:enrollmentId ];
        if(String.isNotBlank(response) && String.isNotBlank(cmp.Answer_Target__c)){
            String[] answer = cmp.Answer_Target__c.split('\\.');
            targetObj = answer[0];
            targetField = answer[1];
            sObject sObj = Schema.getGlobalDescribe().get(targetObj).newSObject();
            sObj.put(targetField,response);
            insert sObj;
        }
    }

//    @AuraEnabled
//    public static Pearson_FormResponse getFormInformation() {
//        Pearson_FormResponse peakResponse = new Pearson_FormResponse();
//        try {
//            String allFields = Pearson_Utilities.selectAllFields('Enrollment_Component__c');
//            String formQuery = 'SELECT ' + allFields +  ', (SELECT ' + allFields + ' FROM SubForm_Components__r ORDER BY Order__c) FROM ' +
//                    'Form_Component__c ORDER BY Order__c';
//
//            List<Enrollment_Component__c> whyList = new List<Enrollment_Component__c>();
//            whyList = Database.query(formQuery);
//
//            componentMap = new Map<Id, Enrollment_Component__c>(whyList);
//
//            for (Enrollment_Component__c formComponent : componentMap.values()) {
//                if (formComponent.Enrollment_Component__c == null) {
//                    Dev_FormDetail headerDetail = new Dev_FormDetail();
//                    headerDetail.FieldLabel = formComponent.Label__c;
//                    for (Form_Component__c subComponent : formComponent.SubForm_Components__r) {
//                        Dev_FormDetail detail = new Dev_FormDetail();
//                        detail.FieldLabel = subComponent.Label__c;
//                        if (subComponent.Type__c != null) {
//                            detail.FieldType = subComponent.Type__c;
//                        }
//                        if (subComponent.Values__c != null) {
//                            detail.SelectionOptions = subComponent.Values__c.split(';');
//                        }
//                        if(subComponent.Rule_Applies__c == TRUE){
//
//                        }
//                        if (!componentMap.get(subComponent.Id).SubForm_Components__r.isEmpty()) {
//                            detail.SubFormDetails = getLevel2Details(componentMap.get(subComponent.Id).SubForm_Components__r);
//                        }
//                        headerDetail.SubFormDetails.add(detail);
//                    }
//
//                    peakResponse.detail.add(headerDetail);
//                }
//            }
//
//        } catch (Exception e) {
//            peakResponse.success = false;
//            peakResponse.messages.add(e.getMessage());
//        }
//
//        return peakResponse;
//    }
//
//
//    public static List<Pearson_FormDetail> getLevel2Details(List<Enrollment_Component__c> formComponents) {
//        List<Pearson_FormDetail> level2 = new List<Pearson_FormDetail>();
//        for (Enrollment_Component__c subComponent : formComponents) {
//            Pearson_FormDetail detail = new Pearson_FormDetail();
//            detail.FieldLabel = subComponent.Label__c;
//            if (subComponent.Type__c != null) {
//                detail.FieldType = subComponent.Type__c;
//            }
//            if (subComponent.Values__c != null) {
//                detail.SelectionOptions = subComponent.Values__c.split(';');
//            }
//            if (!componentMap.get(subComponent.Id).SubForm_Components__r.isEmpty()) {
//                detail.SubFormDetails = getLevel3Details(componentMap.get(subComponent.Id).SubForm_Components__r);
//            }
//            level2.add(detail);
//        }
//
//        return level2;
//    }
//
//    public static List<Pearson_FormDetail> getLevel3Details(List<Enrollment_Component__c> formComponents) {
//        List<Pearson_FormDetail> level3 = new List<Pearson_FormDetail>();
//        for (Enrollment_Component__c subComponent : formComponents) {
//            Pearson_FormDetail detail = new Pearson_FormDetail();
//            detail.FieldLabel = subComponent.Label__c;
//            if (subComponent.Type__c != null) {
//                detail.FieldType = subComponent.Type__c;
//            }
//            if (subComponent.Values__c != null) {
//                detail.SelectionOptions = subComponent.Values__c.split(';');
//            }
//            level3.add(detail);
//        }
//
//        return level3;
//    }*/


}