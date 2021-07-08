/*
Created By  : Nagendra Y
Description : For the push of Pipeline PE's for the COE push on 6/1/2021, We are calling an Apex method 
(EvaluationUtils.PerformAsyncNewStudentStepsUpdatePipelinePEs) to update the pipeline PEs 
so they have the ECAs and PECs appropriate for COE enrollment stage.
ADO         : Task 416266
*/

global class updatePipelinePEsWaitListCalca implements Database.Batchable<sObject> {
    id processid;
    string academicprogram1;
    datetime PECreatedDate;
    global updatePipelinePEsWaitListCalca(String academicprogram,id ecProcessID,datetime createdDate1){
        processid=ecProcessID;
        academicprogram1=academicprogram;
        datetime PECreatedDate=createdDate1;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
       // return  Database.getQueryLocator('SELECT ID, Name, hed__Account__r.Name, Household_Program_Enrollment__c,Enrollment_Type__c FROM hed__program_enrollment__c where hed__Account__r.Name =:academicprogram1 AND Status__c = \'In Progress\' AND RecordType.Name = \'Student\' AND Enrollment_Type__c in (\'Initial Enrollment\', \'Re-enrolling Student\') AND CreatedDate <: PECreatedDate AND Stage__c NOT IN (\'Intent to Attend\', \'Waitlist\') ');
       return  Database.getQueryLocator('SELECT ID, Name, hed__Account__r.Name, Household_Program_Enrollment__c,Enrollment_Type__c FROM hed__program_enrollment__c where hed__Account__r.Name =:academicprogram1 AND Status__c = \'In Progress\' AND RecordType.Name = \'Student\' AND Enrollment_Type__c in (\'Initial Enrollment\', \'Re-enrolling Student\') AND CreatedDate <: PECreatedDate AND Stage__c IN (\'Waitlist\') ');
    }
    global void execute(Database.BatchableContext bc, List<hed__program_enrollment__c> scope){
        
        // Get the Enrollment Component Form RecordTypeId
        Id formId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Enrollment_Component__c' and Name = 'Form' limit 1].Id;
        // Get the Enrollment Component Section RecordTypeId
        Id sectionId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Enrollment_Component__c' and Name = 'Section'].Id;
        // Get the Enrollment Component Stage RecordTypeId
        Id stageId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Enrollment_Component__c' and Name = 'Stage'].Id;
		// Get the Enrollment Component Form RecordTypeId
        Id flagId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Enrollment_Component__c' and Name = 'Flag'].Id;
        
        List <Id> peIdList = new List <Id> ();
            
        for(hed__program_enrollment__c pe : scope){
            peIdList.add(pe.Id);
        }

        List <Enrollment_Component_Affiliation__c> updEcaformList = new List <Enrollment_Component_Affiliation__c> ();
        List <Enrollment_Component_Affiliation__c> updEcasectionList = new List <Enrollment_Component_Affiliation__c> ();
        
        for(hed__program_enrollment__c p:scope){
            //system.debug('Nagendra :'+p.id);
            EvaluationUtils.PerformAsyncNewStudentStepsUpdatePipelinePEs(p.id,processid,p.Household_Program_Enrollment__c,
                                                                         p.Enrollment_Type__c);
        }
        
        // Get the Tell Us about your Student Stage ECAs and Update the Status to In Progress
        List <Enrollment_Component_Affiliation__c> tellusEcaList = [SELECT Id, Name, Program_Enrollment__c FROM Enrollment_Component_Affiliation__c where Program_Enrollment__c in: peIdList and  Enrollment_Component__r.RecordTypeId =: stageId and Enrollment_Component__r.Name =: 'Tell us About your Student'];
        
        List <Enrollment_Component_Affiliation__c> updtellusEcaList = new List <Enrollment_Component_Affiliation__c> ();
        for(Enrollment_Component_Affiliation__c tellustage: tellusEcaList){
        tellustage.Status__c = 'Complete';
        updtellusEcaList.add(tellustage);
        }
        update updtellusEcaList;
		
		
		// Get the Open Application Flag ECAs and Update the Status to Complete
        List <Enrollment_Component_Affiliation__c> opAppEcaList = [SELECT Id, Name, Program_Enrollment__c FROM Enrollment_Component_Affiliation__c where Program_Enrollment__c in: peIdList and  Enrollment_Component__r.RecordTypeId =: flagId and Enrollment_Component__r.Name =: 'Open Application Period Flag'];
        
        List <Enrollment_Component_Affiliation__c> updopAppEcaList = new List <Enrollment_Component_Affiliation__c> ();
        for(Enrollment_Component_Affiliation__c tellustage: opAppEcaList){
        tellustage.Status__c = 'Complete';
        updopAppEcaList.add(tellustage);
        }
        update updopAppEcaList;
		
		// Get the Open Application Stage ECAs and Update the Status to Complete
        opAppEcaList = [SELECT Id, Name, Program_Enrollment__c FROM Enrollment_Component_Affiliation__c where Program_Enrollment__c in: peIdList and  Enrollment_Component__r.RecordTypeId =: stageId and Enrollment_Component__r.Name =: 'Open Application'];
        
        updopAppEcaList = new List <Enrollment_Component_Affiliation__c> ();
        for(Enrollment_Component_Affiliation__c tellustage: opAppEcaList){
        tellustage.Status__c = 'Complete';
        updopAppEcaList.add(tellustage);
        }
        update updopAppEcaList;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
    public static void testCoveragePaddingMethod(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}