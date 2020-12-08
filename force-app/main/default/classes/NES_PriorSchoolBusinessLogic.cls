/**
 * Created by ajith on 12/12/18.
 */

public with sharing class NES_PriorSchoolBusinessLogic {

    public static void calculatePlacement(List<Prior_School__c> newList, Map<Id, Prior_School__c> oldMap){

        List<Id> peIds = new List<Id>();
        for(Prior_School__c ps : newList) {

            if(oldMap != null) {
                Prior_School__c oldPS = oldMap.get(ps.Id);
                if(ps.SchoolType__c != oldPS.SchoolType__c) {
                    peIds.add(ps.Program_Enrollment__c);

                }
            } else {
                peIds.add(ps.Program_Enrollment__c);
            }

        }

        if(peIds.size() > 0) {
            List<Annual_Student_Information__c> asis = [SELECT Id, Program_Enrollment__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN:peIds];
            NES_AnnualStudentInfoBusinessLogic.verifyAffiliationsComplete(asis);
        }

    }

}