/**
 * Created by Ritvik on 26-10-2018.
 * Purpose : Business logic class for EnrollmentComponentCriteriaTrigger called by EnrollmentComponentCriteriaHandler class.
 */

public with sharing class NES_EnrollmentCompCriteriaBusinessLogic {
   public void GenerateNumber(List<Enrollment_Component_Criteria__c> newList){

       //Map to store no. of criteria number records  associated to enrollment component record.
       Map<Id,Set<Decimal>> enrollCriteriaComponentMap = new Map<Id,Set<Decimal>>();

       //Storing records in Map
       for(Enrollment_Component__c ecRecord:[SELECT Id,(SELECT Criteria_Number__c FROM Enrollment_Component_Criteria__r) FROM Enrollment_Component__c]) {

           //Checking is any enrollment component component criteria associated with enrollment component
           if(ecRecord.Enrollment_Component_Criteria__r.size() == 0){
               Set<Decimal> criteriaNumber = new Set<Decimal>();
               enrollCriteriaComponentMap.put(ecRecord.Id,criteriaNumber);
           }
           else {
               for (Enrollment_Component_Criteria__c eccRecord : ecRecord.Enrollment_Component_Criteria__r) {

                   if (enrollCriteriaComponentMap.containsKey(ecRecord.Id)) {
                       enrollCriteriaComponentMap.get(ecRecord.Id).add(eccRecord.Criteria_Number__c);
                   } else {
                       enrollCriteriaComponentMap.put(ecRecord.Id, new Set<Decimal>{
                               eccRecord.Criteria_Number__c
                       });
                   }
               }
           }
       }

       Error_Messages__mdt errorMessage = new Error_Messages__mdt();
       errorMessage = [SELECT Error_Message__c FROM Error_Messages__mdt WHERE DeveloperName ='EC_Maximum'];

       //Logic for setting Criteria Number field
       for (Enrollment_Component_Criteria__c record : newList) {
           if (enrollCriteriaComponentMap.get(record.Enrollment_Component__c) != null && enrollCriteriaComponentMap.get(record.Enrollment_Component__c).size() < 100) {
               //Generating new unique value for Criteria Number field
               record.Criteria_Number__c = enrollCriteriaComponentMap.get(record.Enrollment_Component__c).size() + 1;
               enrollCriteriaComponentMap.get(record.Enrollment_Component__c).add(enrollCriteriaComponentMap.get(record.Enrollment_Component__c).size() + 1);
           } else {
               //Comment out broken logic 2019-02-05
               //Comment out broken logic again 2019-02-21.  Please contact rdehler before re-enabling
               //record.addError(errorMessage.Error_Message__c);
           }
       }
   }
}