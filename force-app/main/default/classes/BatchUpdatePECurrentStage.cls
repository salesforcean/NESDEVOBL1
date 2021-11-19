global class BatchUpdatePECurrentStage implements Database.Batchable<SObject> {
    // 4/23/2020  Created by Mark Membrino to initialize a new field that was added to the PE called Stage.
    // For every Student PE that does not have it's stage set, look at the associated ECAs and find the ECA of
    // record type Stage that is in a status of 'In Progress'.  That is the student's current stage.    
    global BatchUpdatePECurrentStage() {
        
    }
    
    global List<SObject> start(Database.BatchableContext context) {
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND RecordType.Name = 'Student' ];
        return programEnrollments;
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */ 
    global void execute(Database.BatchableContext context, List<hed__Program_Enrollment__c> scope) {
        List<Id> programEnrollmentIds = new List<Id>();
        for(SObject programEnrollment : scope) {
            programEnrollmentIds.add(programEnrollment.Id);
        }

        //Collect the data you need.
        Set<Id> pesToUpdateSet = new Set<Id>();
        list <hed__Program_Enrollment__c> pesToUpdateList = new List<hed__Program_Enrollment__c> ();

        for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Name,
                                                                        Date_Became_In_Progress__c, LastModifiedDate 
                                                                    FROM Enrollment_Component_Affiliation__c
                                                                    WHERE Program_Enrollment__c in :programEnrollmentIds
                                                                    and Enrollment_Component__r.RecordType.Name = 'Stage'
                                                                    and  Status__c = 'In Progress'
                                                                    order by LastModifiedDate desc] ) {
            if (!pesToUpdateSet.contains(affiliation.Program_Enrollment__c)){
                //Not sure we always have that date became in progress so use last modified as a back up.
                Datetime stageSetToDate;
                if (affiliation.Date_Became_In_Progress__c != null) 
                    stageSetToDate = affiliation.Date_Became_In_Progress__c;
                else
                    stageSetToDate = affiliation.LastModifiedDate;
                
                hed__Program_Enrollment__c newPE = new hed__Program_Enrollment__c(id = affiliation.Program_Enrollment__c, 
                                                                                    stage__c = affiliation.Enrollment_Component__r.Name,
                                                                                    Stage_Date__c = stageSetToDate);
                pesToUpdateSet.add(affiliation.Program_Enrollment__c);
                pesToUpdateList.add(newPE);
            }
        }   

        if (pesToUpdateList.size() > 0)
            update pesToUpdateList;
    }
    

    global void finish(Database.BatchableContext context) {
        
    }
}