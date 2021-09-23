/**

    * Created by ali km on 11/27/2019 for [US 119348]
        - This is a handler for the main Enrollment reactivation class NES_EnrollmentReactivations.cls
    *
    * Change Log: 
    * Modified By   ::  on Date     ::  US/Bug #    ::  Description
    * Ali KM        ::  May/7/2020  :: [US 168070]  ::  Adding a call to Re-enrollment process on 'NES_StudentReenrollmentAction' 
                                                        component button click on PE Stud page-layout.
    * Ali km        ::  May/11/2020 :: [US 168070]  ::  test coverage summary:
                                                            NES_StudentReactivation (95%) 247,253,254,260,264,265
                                                            NES_StudentReenrollment (90%) 39,40,41
                                                            NES_EnrollmentReactivationBase (89%) 72,82,89,99,100,101,150
                                                            NES_EnrollmentReactivationHandler (100%)                                                        
    * 

*/
public without sharing class NES_EnrollmentReactivationHandler {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('EnrollmentReactivation');

    @AuraEnabled
    public static Peak_Response reactivateStudent(Id studPEID, String reactivationType) {
        
        Peak_Response peakResponse = new Peak_Response();
        String message;
        

        
        hed__Program_Enrollment__c peRecord = [Select Id, Status__c, hed__Contact__c,Enrollment_Type__c,
                                                (select id,Withdrawal_Category__c from Enrollments__r order by createddate desc)  
                                                from hed__Program_Enrollment__c where Id =: studPEID limit  1];
             //Staff End – Full ReActivation button logic is to ensure all the forms related to initial enrollment are displayed 
             //    when it is clicked for the PE with Status = Inactive and Enrollment type =’Returning Student’. 
       
        try {
            //Staff End – Full ReActivation button logic is to ensure all the forms related to initial enrollment are displayed 
            //    when it is clicked for the PE with Status = Inactive and Enrollment type =’Returning Student’
            if(peRecord.Status__c == 'Inactive' && peRecord.Enrollment_Type__c == 'Returning Student' && reactivationType.toUpperCase() == 'FULL'){
                //NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,reactivationType.toUpperCase());
               //Sravani: Added Code for Reinstatement
                NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,'InitReactivation');
                message='Re-enrollment Success: Student was successfully Re-enrolled.';
                peakResponse.success = true;
            }
            else
            if(peRecord.Status__c == 'Inactive' && peRecord.Enrollment_Type__c == 'Returning Student' && reactivationType.toUpperCase() == 'SOFT'){
                 message='Program Enrollment is eligible only for Full ReActivation.';
              peakResponse.success = false;
            }
            //a)PE Status = 'Withdrawn' and the latest Enrollment record's Withdrawal category = 'No Show'
            else 
            if(peRecord.Status__c == 'Withdrawn' && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'No Show' && reactivationType.toUpperCase() == 'RE_ENROLLMENT'){
               // NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,reactivationType.toUpperCase());
                NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,'InitReEnrollment'); 
                message='Re-enrollment Success: Student was successfully Re-enrolled.';
                peakResponse.success = true;
            }
            else
            //b)PE Status = 'Withdrawn' and the latest Enrollment record's Withdrawal category ='Prior To Engagement' or 'Withdrawal During School Year' --> Same Year Re-Enrollment path
            if(peRecord.Status__c == 'Withdrawn' && (peRecord.Enrollments__r[0].Withdrawal_Category__c == 'Prior To Engagement' || 
                                                    peRecord.Enrollments__r[0].Withdrawal_Category__c == 'Withdrawal During School Year')
                                                                                && reactivationType.toUpperCase() == 'RE_ENROLLMENT'){
                //Sravani:Added code
                NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,'SYReEnroll');                                                                  

                NES_EnrollmentReactivationBase process = getProcessInstance(studPEID, reactivationType);
                process.execute();
                message='Re-enrollment Success: Student was successfully Re-enrolled.';
            }
            else{
                //Sravani :Added code
                if(peRecord.Status__c == 'Withdrawn')
                 NES_ReEnrUtilities.InitreenrollingStudent(peRecord.hed__Contact__c, peRecord.Id,'SYReEnroll');   //End Code                                                               
                NES_EnrollmentReactivationBase process = getProcessInstance(studPEID, reactivationType);
                System.debug('test11-----------'+process);
                process.execute();
                message='Re-enrollment Success: Student was successfully Re-enrolled.';
                peakResponse.success = true;
            }

        } catch (Exception e) {

            message = 'Action Failed: ' + e.getMessage();
            peakResponse.success = false;
            peakResponse.status = e.getMessage();
            logger.logException('EnrollmentReactivation', e);
            logger.saveLogs();

        }

        peakResponse.messages.add(message);
        return peakResponse;

    }

    public static NES_EnrollmentReactivationBase getProcessInstance(String studPEID, String reactivationType) {
        
        NES_EnrollmentReactivationBase instance;

        switch on reactivationType.toUpperCase() {

            when 'FULL' {
                instance = new NES_StudentReactivation(studPEID, NES_EnrollmentReactivationBase.Reactivation.FULL);
            }
            when 'SOFT' {
                instance = new NES_StudentReactivation(studPEID, NES_EnrollmentReactivationBase.Reactivation.SOFT);
            }
            when 'RE_ENROLLMENT' {
                instance = new NES_StudentReenrollment(studPEID, NES_EnrollmentReactivationBase.Reactivation.RE_ENROLLMENT);
                System.debug('test10---------');
            }
            when else {
                 throw new NES_EnrollmentReactivationBase.EnrollmentReactivation_Exception(
                     'Error - Reactivation Type is invalid. Supported values are => ' + JSON.serialize(NES_EnrollmentReactivationBase.Reactivation.values()));
            }

        }

        return instance;

    }

}