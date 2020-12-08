/**
 * Created by himanshu on 26/03/19.
 * Purpose : Used to run the WaitlistCalculator logic in Batch Format
 */

global class NES_WaitListCalculatorBatch implements Database.Batchable<SObject>, Database.Stateful{
    private static Peak_ApexLog logger = new Peak_ApexLog('WaitListCalculatorBatch');
    public Set<Id> setOfProgramEnrollmentToProcess {get; set;}
    public NES_WaitListCalculatorBatch(Set<Id> setOfProgramEnrollment) {
        this.setOfProgramEnrollmentToProcess = setOfProgramEnrollment;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('In Batch Apex');
        return Database.getQueryLocator([SELECT Id FROM hed__Program_Enrollment__c WHERE Id IN:setOfProgramEnrollmentToProcess]);
    }

    global void execute(Database.BatchableContext BC, List<hed__Program_Enrollment__c> scope){
        System.debug('scope++'+scope);
        Set<Id> setOfProgramEnrollment = new Set<Id>();
        for(hed__Program_Enrollment__c programIterator : scope){
            setOfProgramEnrollment.add(programIterator.Id);
        }
        List<hed__Program_Enrollment__c> listOfProgramEnrollmentsToUpdate = NES_BusinessLogicUtils.waitListCalculator(setOfProgramEnrollment);
        try {
            System.debug('In Try Update');
            NES_ECACompletion.shouldRunCompletion = true; //136077-changed to true to trigger Assignment logic
            NES_Constants.runAssignment = true;//136077-changed to true to trigger Assignment logic
            NES_ProgramEnrollmentHandler.runCBL = false;
            update listOfProgramEnrollmentsToUpdate;
            List<hed__Program_Enrollment__c> programEnrollments = NES_BusinessLogicUtils.calculateWhyFlagged(setOfProgramEnrollment);
            NES_BusinessLogicUtils.runWhyFlagged = false;
            update programEnrollments;
        } catch(Exception ex) {
            System.debug('Exception Thrown:' + ex.getMessage());
            logger.logException('populateProgramGradeLevel', ex);
            logger.saveLogs();
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}