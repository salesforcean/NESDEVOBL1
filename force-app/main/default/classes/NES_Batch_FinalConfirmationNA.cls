/**
* Created by Krishna Peddanagammol on 4/14/20.
* Created for the task #167744.
*/

global with sharing class NES_Batch_FinalConfirmationNA  implements DataBase.Batchable<SObject>, Schedulable {
    private static Peak_ApexLog logger = new Peak_ApexLog('UpdateHardStopTimeConstraint');
    global NES_Batch_FinalConfirmationNA() {
        
    }
    
    // Find all the current in progress program enrollments
    global List<SObject> start(Database.BatchableContext BC){
        
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND RecordType.Name = 'Student' AND V2_External_ID__c = null];
        return programEnrollments;
    }
    
    // Fetch the corresponding ECA's in Confirmation of Enrollment or Intent to Attend (CalCA) stage's
    // and mark the ECA's of EC's with Confirmation of Enrollment form and
    // Confirmation of Enrollment Notice or Intent to Attend Notice section as NA
    // and update the Confirmation Hold flag to released. 
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
       
        Set<Id> programEnrollmentIds = new Set<Id>();
        for(hed__Program_Enrollment__c pe : (List<hed__Program_Enrollment__c>) scope) {
            programEnrollmentIds.add(pe.Id);
        }
      
        // Update ECA's for Confirmation of Enrollment form and 
        // Confirmation of Enrollment Notice or Intent to Attend Notice section to NA
        List<Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
        List<Id> ids = new List<Id> ();  
        //Commented for US 216464
        /*for (Enrollment_Component_Affiliation__c affiliation : 
             [SELECT Id
              FROM Enrollment_Component_Affiliation__c
              WHERE Program_Enrollment__c in :programEnrollmentIds AND 
              ( (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Confirmation of Enrollment Notice')
               OR (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Intent to Attend Notice')
               OR (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Final Confirmation') )
             ]) 
        {
            //affiliation.Status__c = 'Not Applicable';
            Enrollment_Component_Affiliation__c n = new Enrollment_Component_Affiliation__c(id = affiliation.id, Status__c = 'Not Applicable' );
            ecas.add(n);
        }*/
        //Updated for US #216464 for first set of updates (Test date: 29-Sep-2020) 
        for (Enrollment_Component_Affiliation__c affiliation : 
             [SELECT Id
              FROM Enrollment_Component_Affiliation__c
              WHERE Program_Enrollment__c in :programEnrollmentIds AND 
              ( (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Alternative Shipping Address Information')
               OR (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Parent/Legal Guardian (Caretaker) Acknowledgement')
               OR (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Parent / Legal Guardian (Caretaker) Acknowledgement') )
             ]) 
        {
            //affiliation.Status__c = 'Not Applicable';
            Enrollment_Component_Affiliation__c n = new Enrollment_Component_Affiliation__c(id = affiliation.id, Status__c = 'Not Applicable' );
            ecas.add(n);
        }
        /*//Updated for US #216464 for first set of updates (Test date: 05-Oct-2020) 
        for (Enrollment_Component_Affiliation__c affiliation : 
             [SELECT Id
              FROM Enrollment_Component_Affiliation__c
              WHERE Program_Enrollment__c in :programEnrollmentIds AND 
              ( (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Confirmation of Enrollment Notice for Spring Semester')
               OR (Enrollment_Component__r.RecordType.Name = 'Section' AND Enrollment_Component__r.Name = 'Intent to Attend Notice for Spring Semester') )
             ]) 
        {
            //affiliation.Status__c = 'Not Applicable';
            Enrollment_Component_Affiliation__c n = new Enrollment_Component_Affiliation__c(id = affiliation.id, Status__c = 'Not Applicable' );
            ecas.add(n);
        }*/
        try {
            Database.update(ecas);
        } catch (exception e) {
            System.debug('Dml Exception ::' + e.getMessage());
            logger.logException('execute', e);
            logger.saveLogs();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_Batch_FinalConfirmationNA(), 200);
    }
    
}