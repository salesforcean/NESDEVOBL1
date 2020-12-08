/**
* Created by  on 04/05/2020.
* Created for the Spike # 169194 .
* Added by Chinna..
*/

global with sharing class NES_Batch_ECAPercent_TaskCreation  implements DataBase.Batchable<SObject>, Schedulable {
    global List<Task> task_list = new List<Task>();
    global NES_Batch_ECAPercent_TaskCreation() {
       
    }
   
    // Find all the current in progress program enrollments
    global List<SObject> start(Database.BatchableContext BC){
       
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id,Date_Today__c,Percent_Complete__c,CreatedDate
                                                               FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress'
                                                               AND RecordType.Name = 'Student'];
        return programEnrollments;
    }
   
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
       List<Case> caselist = new List<Case>();
        Set<Id> programEnrollmentIds = new Set<Id>();
        for(hed__Program_Enrollment__c programEnrollment : (List<hed__Program_Enrollment__c>)scope) {
            programEnrollmentIds.add(programEnrollment.Id);
        }
        //go find the cases for the PE's in.
         caselist = [select id,OwnerId,Program_Enrollment__c,Program_Enrollment__r.Percent_Complete__c,Program_Enrollment__r.CreatedDate,Program_Enrollment__r.Date_Today__c from Case where Program_Enrollment__c in:programEnrollmentIds];
          
        //to do get all tasks for all the cases in case list.
          // List<Case> caseListe = [select id, subject from Task where WhatId IN :trigger.New];
        
        
        
           //Build a map case id to a list of tasks. Map < id, list < task >> case to task list map.
           Map<Id, List<Task>> caseTask = new Map<Id, List<task>>();
           
        //create custom setting for the different percents.use custom meta data
        ////task, type and sub type
        //task owner is 'case' owner
        //task should not create 2 times, it should be created only once.
        ///iterate
        //test few records
        Percent_Complete__mdt[] percentSettings = [SELECT DeveloperName, MasterLabel,Days__c,Percent__c,Sub_Type__c,Task_Type__c
                                                                  FROM Percent_Complete__mdt ];
       
        for(Case c:caselist){
             Date created = (Date)c.Program_Enrollment__r.CreatedDate;
             Date tod = c.Program_Enrollment__r.Date_Today__c;
             Integer noOfDays = created.daysBetween(tod);
            
           // get the list of the task for the case from the map.
           // loop custom setting
            
            ////should have for loop, and the metadata should loop 
            //task need to create based on metadata type
            
            //check for <10% & within 3 days
            if(c.Program_Enrollment__r.Percent_Complete__c<percentSettings[0].Percent__c && noOfDays<=percentSettings[0].Days__c){
                Task tsk = new Task();
                tsk.OwnerId = c.OwnerId;
                tsk.Type ='Student Progress';
                tsk.TaskSubtype ='within 3 days';
                task_list.add(tsk);
            }
               //check for <33% & within 5 days
            else if(c.Program_Enrollment__r.Percent_Complete__c<percentSettings[1].Percent__c && noOfDays<=percentSettings[1].Days__c){
                Task tsk = new Task();
                tsk.OwnerId = c.OwnerId;
                tsk.Type ='Student Progress';
                tsk.TaskSubtype ='within 5 days';
                task_list.add(tsk);
            }
           //check for <45% & within 7 days
           else if(c.Program_Enrollment__r.Percent_Complete__c<percentSettings[2].Percent__c && noOfDays<=percentSettings[2].Days__c){
                Task tsk = new Task();
                tsk.OwnerId = c.OwnerId;
                tsk.Type ='Student Progress';
                tsk.TaskSubtype ='within 5 days';
                task_list.add(tsk);
            }
           //check for <75% & within 10 days
           else if(c.Program_Enrollment__r.Percent_Complete__c<percentSettings[3].Percent__c && noOfDays<=percentSettings[3].Days__c){
                Task tsk = new Task();
                tsk.OwnerId = c.OwnerId;
                tsk.Type ='Student Progress';
                tsk.TaskSubtype ='within 10 days';
                task_list.add(tsk);
            }
            //check for <90% & within 21 days
            else if(c.Program_Enrollment__r.Percent_Complete__c<percentSettings[4].Percent__c && noOfDays<=percentSettings[4].Days__c){
                Task tsk = new Task();
                tsk.OwnerId = c.OwnerId;
                tsk.Type ='Student Progress';
                tsk.TaskSubtype ='within 21 days';
                task_list.add(tsk);
            }
        }
                          
        if(task_list.size()>0){
            insert task_list;
        }
     }
   
    global void finish(Database.BatchableContext BC) {
       
    }
   
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_Batch_ECAPercent_TaskCreation(), 200);
    }
}