/**
 * Created by Ritvik on 25/10/18.
 * Purpose : Class to handle business logic for Criteria Group trigger handler
 */

public class NES_CriteriaGroupBusinessLogic {
  /**
   * Created by Ritvik on 25/10/18.
   * Purpose : Method to generate Unique auto number for Group Number field of criteria group object on before insert trigger functionality.
   * Params : newList,which has list of newly inserted records of Criteria Group object.
   */
    public void GenerateNumber(List<Criteria_Group__c> newList){
        System.debug('newList:'+newList);
        //Map to store no. of group number records  associated to enrollment component record.
        Map<Id,Set<Decimal>> criteriaGroupMap = new Map<Id,Set<Decimal>>();

        //Storing records in Map
        for(Enrollment_Component__c ecRecord:[SELECT Id,(SELECT Group_Number__c FROM Criteria_Groups__r) FROM Enrollment_Component__c]) {
            //Checking is any criteria group record associated with enrollment component
            if(ecRecord.Criteria_Groups__r.size() == 0){
                Set<Decimal> groupNumber = new Set<Decimal>();
                criteriaGroupMap.put(ecRecord.Id,groupNumber);
            }
            else {
                for (Criteria_Group__c cgRecord : ecRecord.Criteria_Groups__r) {

                    if (criteriaGroupMap.containsKey(ecRecord.Id)) {
                        criteriaGroupMap.get(ecRecord.Id).add(cgRecord.Group_Number__c);
                    } else {
                        criteriaGroupMap.put(ecRecord.Id, new Set<Decimal>{
                                cgRecord.Group_Number__c
                        });
                    }
                }
            }
        }

        //Getting error message from custom metadata type.
        Error_Messages__mdt errorMessage = new Error_Messages__mdt();
        errorMessage = [SELECT Error_Message__c FROM Error_Messages__mdt WHERE DeveloperName = 'EC_Maximum'];

        //Logic for setting Group Number field
            for (Criteria_Group__c record : newList) {
                //Checking for criteria group associated with one enrollment component should be 99
                if (criteriaGroupMap.containsKey(record.Enrollment_Component__c) && criteriaGroupMap.get(record.Enrollment_Component__c).size() < 100) {
                    //Generating & seting new unique value for Group Number field
                    record.Group_Number__c = criteriaGroupMap.get(record.Enrollment_Component__c).size() + 1;
                    criteriaGroupMap.get(record.Enrollment_Component__c).add(criteriaGroupMap.get(record.Enrollment_Component__c).size() + 1);
                } else {
                    record.addError(errorMessage.Error_Message__c);
                }
            }

        }
}