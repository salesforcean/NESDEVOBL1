/**
 * Created by Ritvik on 30-10-2018.
 * Purpose : Functions for enrollment confirmation under specific program enrolled.
 */

public class NES_ApplicationSummary {

    @AuraEnabled
    public static void setFinalConfirmationViewed(hed__Program_Enrollment__c ProgramEnrollment){
           ProgramEnrollment.Viewed_Final_Confirmation__c = true;
           update ProgramEnrollment;
    }

    @AuraEnabled
    public static String getSuccessfulEnrollmentMessage(hed__Program_Enrollment__c ProgramEnrollment){
        return('Confirmed...');

    }
}