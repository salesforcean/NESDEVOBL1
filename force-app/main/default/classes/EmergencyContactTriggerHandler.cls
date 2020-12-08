/**
 * @description       : This class handles Trigger update on Emergency_Contact__c object.
 * @author            : Mark Membrino
 * @last modified on  : 10-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-01-2020   Mark Membrino                        Initial Version - kicks-off PEC re-calculations on update to CareTaker/HouseHold Emergency_Contact__c record.
**/
public class EmergencyContactTriggerHandler 
{
    static Boolean hasRunHandleAfter = false;
    // static Boolean hasRunAfterUpdate = false;
    // static Boolean hasRunAfterInsert = false;

    static List<Emergency_Contact__c> newList;
    static Map<Id, Emergency_Contact__c> newMap;
    static Map<Id, Emergency_Contact__c> oldMap;

    public static void init(List<SObject> newLst, Map<Id, SObject> nuMap, Map<Id, SObject> olMap) {
        newList = (List<Emergency_Contact__c>) newLst;
        newMap = (Map<Id, Emergency_Contact__c>) nuMap;
        oldMap = (Map<Id, Emergency_Contact__c>) olMap;
    }
    

    public static void handleAfterInsert(List<SObject> newList, Map<Id, SObject> newMap) 
    {
        init(newList,newMap, null);
        handleAfter();
    }

    public static void handleAfterUpdate(List<SObject> newList, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) 
    {
        init(newList,newMap, oldMap);
        handleAfter();
    }

    public static void handleAfter() 
    {
        if (hasRunHandleAfter) { return; }

        hasRunHandleAfter = true;

        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate>(); //How we track field changes in the new ECA model.
        Map<String, Object> fieldsToValue;
        Emergency_Contact__c oldEC;
        hed__Program_Enrollment__c queriedPE;
        for(Emergency_Contact__c emergencyContact : newList)
        {
            // if not new ECA Model, skip this record.
            if ( !(peMapQueried.size()>0 && peMapQueried.get(emergencyContact.Program_Enrollment__c).hed__Account__r.Use_Updated_ECA_Process__c) ) 
                continue;

            fieldsToValue = emergencyContact.getPopulatedFieldsAsMap();
            oldEC = (oldMap!=null ? oldMap.get(emergencyContact.Id) : null);
            queriedPE = peMapQueried.get(emergencyContact.Program_Enrollment__c);

            for (String str : fieldsToValue.keySet()) 
            {
                if (
                    emergencyContact.get(str) != null && 
                    ( oldEC == null || emergencyContact.get(str) != oldEC.get(str) )
                ) {
                    //These are for the new ECA processing model.  
                    EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                    newFieldUpdate.programEnrollmentId = emergencyContact.Program_Enrollment__c;
                    newFieldUpdate.objectAndFieldName = 'Emergency_Contact__c.' + str;
                    newFieldUpdate.newValue = emergencyContact.get(str);
                    newFieldUpdate.studentOrHousehold = (queriedPE.RecordType.Name == 'Student') ? 'Student' : 'Household';
                    fieldUpdateList.add(newFieldUpdate);
                }           
            }
        }

        System.debug ('EmergencyContactTrigger  fieldUpdateList:' + fieldUpdateList);
        
        if (fieldUpdateList.size() > 0)
            EvaluationUtils.evaluateChangedFields(fieldUpdateList);
    }

    public static Map<Id, hed__Program_Enrollment__c> peMapQueried {
        get {
            if (peMapQueried==null && allPEIds!=null) {
                peMapQueried = new Map<Id, hed__Program_Enrollment__c>([
                    SELECT  Id, hed__Account__r.Use_Updated_ECA_Process__c, Recordtype.Name  
                    FROM    hed__Program_Enrollment__c
                    WHERE   Id IN :allPEIds
                ]);
            }
            return peMapQueried;
        }
        set;
    }

    public static Set<Id> allPEIds {
        get {
            if (allPEIds==null) {
                allPEIds = new Set<Id>();
                for (Emergency_Contact__c ec : newList) {
                    allPEIds.add(ec.Program_Enrollment__c);
                }
            }
            return allPEIds;
        }
        set;
    }
}