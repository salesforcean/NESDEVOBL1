/**
 *  
 * 2020-05-26 created class for #US169194  (Mark Membrino)
 *   
*/

global with sharing class Batch_FECTaskCreation implements DataBase.Batchable<SObject>, Schedulable {

    public static final String PE_STATUS = 'In Progress';
    public static final String STUD_PE_RECORD_TYPE_ID = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    public static final String CASE_RECORD_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Support').getRecordTypeId();
    public static final String NEW_TASK_RECORD_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
    public static final String NEW_TASK_DEFAULT_PRIORITY = 'High';
    public static final String NEW_TASK_STATUS = 'Open';
    public static final Integer NEW_TASK_DUE_DATE_DAYS = 1;
    public static List<FEC_Task_Creation_Rule__mdt> fecTaskCreationRules {get; private set;}
    public static Date today {get; private set;}
    public List<Case> cases {get; private set;}

    // Find all the current in progress program enrollments for evaluation
    global List<SObject> start(Database.BatchableContext BC){

        return [SELECT  Id, 
                        OwnerId,
                        Owner.Type,
                        RecordTypeId,
                        RecordType.Name,
                        Program_Enrollment__c, 
                        Program_Enrollment__r.Total_Forms__c,
                        Program_Enrollment__r.Total_Forms_Completed__c,
                        Program_Enrollment__r.Percent_Complete__c,
                        Program_Enrollment__r.CreatedDate,

                        Program_Enrollment__r.Date_Today__c,
                        Program_Enrollment__r.hed__Contact__c
                FROM    Case 
                WHERE   ( Program_Enrollment__c != NULL 
                        AND Program_Enrollment__r.RecordTypeId = :STUD_PE_RECORD_TYPE_ID 
                        AND Program_Enrollment__r.Status__c = :PE_STATUS )
                        AND RecordTypeId = :CASE_RECORD_ID
                ORDER BY CreatedDate DESC];

    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {

        cases = (List<Case>) scope;
        today = getDateValue(datetime.now());
        fecTaskCreationRules = getTaskCreationRules();
        Map<String, Id> caseTypeToCaseMap = new Map<String, Id>();
        List<sObject> newRecs = new List<SObject>();
        
        for (Task t :   
                [SELECT Id, Subject, Type, SubType__c, RecordTypeId, RecordType.Name, WhoID, 
                    Who.Type, WhatId, What.Type 
                FROM Task
                WHERE WhatId = :cases])
        {
            // map of case (CaseId + Type + Subtype) => CaseId/WhatId
            caseTypeToCaseMap.put((t.WhatId+':'+t.Type+ ':' +t.SubType__c), t.WhatId);
        }

        for (Case c : cases) {
            
            Integer noDaysSinceStartPE = (getDateValue(c.Program_Enrollment__r.CreatedDate)).daysBetween(c.Program_Enrollment__r.Date_Today__c);
            Decimal percentCompletePE = c.Program_Enrollment__r.Percent_Complete__c;
            
            for (FEC_Task_Creation_Rule__mdt rule : fecTaskCreationRules) {
                if (noDaysSinceStartPE >= rule.lowerLimitInDays__c && percentCompletePE < rule.thresholdPercent__c)
                {
                    String existingTaskKey = c.Id + ':' + rule.taskTypeDefault__c + ':' + rule.taskSubTypeDefault__c;
                    if (caseTypeToCaseMap.get(existingTaskKey)==null) {
                        // createNewTask
                        newRecs.add(setNewTask(c, rule));
                    }
                    break;
                }
            }
        }
        
        if (newRecs.size()>0) {
            insert newRecs;
        }

    }

    global void finish(Database.BatchableContext BC) {
        // send mail or do something after batch has run
    }

    global void execute(SchedulableContext sc) {

        //To schedule.
        //Batch_FECTaskCreation sc=new Batch_FECTaskCreation(); 
        //System.schedule('Batch_FECTaskCreation',' 0 0 5 * * ?', sc);
        Database.executeBatch(new Batch_FECTaskCreation(), 200);
    }

    public static Date getDateValue(DateTime dtVal) {
        return date.newinstance(dtVal.year(), dtVal.month(), dtVal.day());
    }

    public static List<FEC_Task_Creation_Rule__mdt> getTaskCreationRules() {
        return ([ SELECT Id, MasterLabel, DeveloperName, thresholdPercent__c, lowerLimitInDays__c,
                    upperLimitInDays__c, taskTypeDefault__c, taskSubTypeDefault__c, Order__c
                FROM FEC_Task_Creation_Rule__mdt
                Where order__c > 0  //The initial task that goes with the case has an entry with an order of 0
                ORDER BY Order__c DESC ]);
    }

    public static Task setNewTask(Case cs, FEC_Task_Creation_Rule__mdt rule) {
        

        string newSubject;
        id taskOwner;
        //The initial call should not include the actual completion and should use the owner from the case even if it is a queue.
        if (rule.Order__c == 0) {
            newSubject = rule.taskTypeDefault__c + ' - ' + rule.taskSubTypeDefault__c;
            taskOwner = cs.OwnerId;
        }
        else {
            newSubject = rule.taskTypeDefault__c + ' - ' + rule.taskSubTypeDefault__c + ' - actual completion: ' + cs.Program_Enrollment__r.Percent_Complete__c + '%';
            String ownerIdPrefix = String.valueOf(cs.OwnerId).substring(0,3);
            if (ownerIdPrefix == '00G')  //If the case is still owned by queue then put the task in the household pool for review.
                taskOwner = label.Household_Pool_Queue_ID;
            else
                taskOwner = cs.OwnerId;
        }
        
        Task nu = new Task (
            WhatId = cs.Id,
            OwnerID = taskOwner,
            Status = NEW_TASK_STATUS,
            WhoId = cs.Program_Enrollment__r.hed__Contact__c,
            Priority = NEW_TASK_DEFAULT_PRIORITY,
            ActivityDate = System.today().addDays(NEW_TASK_DUE_DATE_DAYS), // aka Due Date
            RecordTypeId = NEW_TASK_RECORD_ID,
            Subject = newSubject,
            Type = rule.taskTypeDefault__c,
            SubType__c = rule.taskSubTypeDefault__c);

        System.debug ('New Task ' + nu);
        return nu;
    }

    public class FECTaskCreationException extends Exception {}
    
}