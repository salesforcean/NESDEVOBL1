/**
 * Created by triciaigoe on 2019-04-05.
 * 11/05/19 - Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim)
 * 05/11/19 - Added logic to rerun the Assignment logic for waitlist logic for the bug 111337(Anitha A) .
 */

public without sharing class NES_AddStudentCBLQueueable implements Queueable {

    private Id programEnrollmentId;

    public void execute(QueueableContext context) {


        List<hed__Program_Enrollment__c> programEnrollments = [
                SELECT Id, hed__Contact__c, Start_Year__c, hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
                    EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c,
                    (SELECT Id, Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__c FROM Annual_Student_Information__r)
                FROM hed__Program_Enrollment__c
                WHERE Id = : programEnrollmentId
        ];

        if(programEnrollments.size() > 0) {

            //Mark Membring 3/19/2020  Moved from the enrollment triggers to reduce the soql count (154059)
            programEnrollments = NES_BusinessLogicUtils.calculateAddressEligibility(programEnrollments);
            //Commented Deprecate Technology flag logic for US 476956
            //programEnrollments = NES_BusinessLogicUtils.flagTechnologyAction(programEnrollments);
            update programEnrollments;


            try {
                NES_AnnualStudentInfoBusinessLogic.populateProgramGradeLevel(programEnrollments[0].Annual_Student_Information__r, null);
                List<hed__Program_Enrollment__c> pes = NES_EntranceAgeUtility.processProgramEnrollments(programEnrollments);
                update pes;
                //added by anithap
                List<hed__Program_Enrollment__c> listOfProgramEnrollmentsToUpdate = NES_BusinessLogicUtils.waitListCalculator(new Set<Id>{programEnrollmentId});
                //Start-Added logic for the 111337 Bug
                 NES_ECACompletion.shouldRunCompletion = true;
                 NES_Constants.runAssignment = true;
                //Start -Added logic for the 111337 Bug
                 update listOfProgramEnrollmentsToUpdate;
                List<hed__Program_Enrollment__c> enrollments = NES_BusinessLogicUtils.calculateWhyFlagged(new Set<Id>{programEnrollmentId});
                NES_BusinessLogicUtils.runWhyFlagged = false;
                update enrollments;

                //Mark Membrino 2/24/2020 Moved this call from the enrollment trigger to here. 
                Set<string> activePEIds = new Set<string>();
                activePEIds.add(programEnrollmentId);
                NES_BusinessLogicUtils.updateContactStartYear(activePEIds);
            } catch(Exception ex) { System.debug('Exception Thrown:' + ex.getMessage()); }


        }
    }

    public NES_AddStudentCBLQueueable(Id enrollmentId) {

        this.programEnrollmentId = enrollmentId;
    }

}