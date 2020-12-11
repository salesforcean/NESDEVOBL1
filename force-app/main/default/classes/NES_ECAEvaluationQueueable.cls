public without sharing class NES_ECAEvaluationQueueable implements Queueable 
{
	@testVisible
    private static Boolean doChainJob = true;
    Public Set<Enrollment_Component_Affiliation__c> newAffiliations =new Set<Enrollment_Component_Affiliation__c>();
    private Id programEnrollmentId;
  
    /*public NES_ECAEvaluationQueueable(Set<Enrollment_Component_Affiliation__c> newAffiliations,Id enrollmentId) {
       this.newAffiliations = newAffiliations;
       this.programEnrollmentId = enrollmentId;
    }*/
    public void execute(QueueableContext context) {
	
        Peak_ApexLog logger = new Peak_ApexLog('ECAEvaluationQueueable');
        logger.logInfo('NES_ECAEvaluationQueueable', 'new affiliations: ' + newAffiliations);

        logger.saveLogs();


        //Mark Membrino 7/16/2020 Order the insert of the affiliations so:
        //  Questions, Messages and Text goes in first.
        //  Sections and Documents second
        //  Forms and Flags third
        //  Stages last.  This was added to prevent forms from being completed early because their children were not interted first.
        List<Enrollment_Component_Affiliation__c> group1 = new List<Enrollment_Component_Affiliation__c>();
        List<Enrollment_Component_Affiliation__c> group2 = new List<Enrollment_Component_Affiliation__c>();
        List<Enrollment_Component_Affiliation__c> group3 = new List<Enrollment_Component_Affiliation__c>();
        List<Enrollment_Component_Affiliation__c> group4 = new List<Enrollment_Component_Affiliation__c>();
        
        for (Enrollment_Component_Affiliation__c i : newAffiliations) {
            if (i.EC_Record_Type__c == NES_DashboardUtilities.QUESTION_RT || i.EC_Record_Type__c == NES_DashboardUtilities.TEXT_RT || i.EC_Record_Type__c == NES_DashboardUtilities.MESSAGE_RT)
                group1.add(i);
            else if (i.EC_Record_Type__c == NES_DashboardUtilities.SECTION_RT || i.EC_Record_Type__c == NES_DashboardUtilities.DOCUMENT_RT)
                group2.add(i);
            else if (i.EC_Record_Type__c == NES_DashboardUtilities.FORM_RT || i.EC_Record_Type__c == NES_DashboardUtilities.FLAG_RT)
                group3.add(i);
            else
                group4.add(i);
        }

        List<Enrollment_Component_Affiliation__c> affilsToInsert = new List<Enrollment_Component_Affiliation__c>();
        affilsToInsert.addAll(group1);
        affilsToInsert.addAll(group2);
        affilsToInsert.addAll(group3);
        affilsToInsert.addAll(group4);

        insert affilsToInsert;
        
        //Mark the PE as ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollmentId, Initial_ECA_Creation_Complete__c = true);
        update pe;
        if(doChainJob) {
        
        System.enqueueJob(new NES_AddStudentCBLQueueable(programEnrollmentId));
        }
    }
    
}