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

        try {
            //added by Shravani US#389103 7/03/2021 
            /*           
            hed__Program_Enrollment__c spe = [Select ID,Enrollment_Type__c,Status__c From hed__Program_Enrollment__c Where Id = :studPEID];
            
            if(spe.Status__c=='Inactive' && spe.Enrollment_Type__c=='Returning Student'){
                spe.Enrollment_Type__c = 'Initial Enrollment';
                //spe.Enrollment_Type__c = 'Re-enrolling student';
                update spe; 
            }
            */
            NES_EnrollmentReactivationBase process = getProcessInstance(studPEID, reactivationType);
            process.execute();
            message='Re-enrollment Success: Student was successfully Re-enrolled.';
            peakResponse.success = true;

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
            }
            when else {
                 throw new NES_EnrollmentReactivationBase.EnrollmentReactivation_Exception(
                     'Error - Reactivation Type is invalid. Supported values are => ' + JSON.serialize(NES_EnrollmentReactivationBase.Reactivation.values()));
            }

        }

        return instance;

    }

}