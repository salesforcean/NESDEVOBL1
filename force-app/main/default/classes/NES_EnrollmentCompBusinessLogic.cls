/**
 * Created by ajith on 31/10/18.
 */

public class NES_EnrollmentCompBusinessLogic {

    /**
    * Created by Ritvik on 31/10/18.
    */
    /*public void ECCompletionCheck(Map<Id, Enrollment_Component__c> newMap, Map<Id, Enrollment_Component__c> oldMap){
        List<Enrollment_Component__c> newList = newMap.values();
        Error_Messages__mdt errorMessage = new Error_Messages__mdt();
        errorMessage = [SELECT Error_Message__c FROM Error_Messages__mdt WHERE DeveloperName = 'EC_ChildNotComplete'];

        Map<Id,list<Enrollment_Component_Relationship__c>> recordMap = new Map<Id,list<Enrollment_Component_Relationship__c>>();

        for(Enrollment_Component__c record : [SELECT Id, (SELECT Child_Enrollment_Component__c,Child_Enrollment_Component__r.Status__c FROM Enrollment_Component_Relationships1__r)
                                                     FROM Enrollment_Component__c
                                                     WHERE Id IN:newMap.keySet() AND
                                                           Status__c = 'Complete']){
            if(record.Enrollment_Component_Relationships1__r.size() > 0){
                for (Enrollment_Component_Relationship__c ecrRecord : record.Enrollment_Component_Relationships1__r) {

                    if (recordMap.containsKey(record.Id)) {
                        recordMap.get(record.Id).add(ecrRecord);
                    } else {
                        recordMap.put(record.Id, new List<Enrollment_Component_Relationship__c>{ecrRecord});
                    }
                }
            }
        }

        for(Enrollment_Component__c ecRecord : newList){
            System.debug('ecRecordId:'+ecRecord.Id);
           // System.debug('ECRSize:'+recordMap.get(ecRecord.Id).size());
           // @raju have commented above system.debug stat
            if(recordMap!=null&& recordMap.containsKey(ecRecord.Id)&&recordMap.get(ecRecord.Id).size() != 0) {
                for (Enrollment_Component_Relationship__c ecrRecord : recordMap.get(ecRecord.Id)) {
                    System.debug('ecRecord.Status__c'+ ecRecord.Status__c);
                    System.debug('Status:'+ ecrRecord.Child_Enrollment_Component__r.ID);
                    if (ecRecord != ecrRecord.Child_Enrollment_Component__r && ecrRecord.Child_Enrollment_Component__r.Status__c != 'Complete' && ecRecord.Status__c == 'Complete') {
                        //ecRecord.Status__c = 'Not Complete';
                        ecRecord.addError(errorMessage.Error_Message__c);
                        break;
                    }
                }
            }
        }
    }*/

}