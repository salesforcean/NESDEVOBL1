/**

    * Created by ali km on 11/27/2019 for [US 119348]
        - This class handles following Enrollment Reactivations
            -> SOFT
            -> FULL
        - Usage: 
            NES_EnrollmentReactivation enrollmentReactivation 
                = new NES_EnrollmentReactivation(PEID, reactivationType); // FULL OR SOFT
            enrollmentReactivation.execute();
    * Code changes for Bug #122743 on 2019-12-24 (Krishna Peddanagammol) 
    * Code changes for Bug #124652 on 2020-01-06 (Krishna Peddanagammol)
    * Code changes for US #168874 on 2020-04-30 (Krishna Peddanagammol)

    * May/11/2020 :: [168070] :: ALI KM :: DEPRECATED CLASS, code merged into below classes: 
        => NES_EnrollmentReactivationBase.cls
        => NES_StudentReactivation.cls
    
 */

public without sharing class NES_EnrollmentReactivation {


    // public enum Reactivation {SOFT, FULL}
    // public enum ReactivatedBy {Caretaker, Staff}

    // public static final String COMMUNITY_USER_PROFILE_PREFIX = 'Caretaker'; 
    // public static final String PE_WITHDRAWAL_REASON_CODES = 'Inactive, Time Expired, Ineligible'; //Removed Withdrawn Status for US #168874 on 2020-04-30 by Krishna Peddanagammol
    // public static final String PE_REACTIVATION_REASON_CODE = 'In Progress'; 
    // public static final String ED_REACTIVATION_REASON_CODE = 'Submitted';
    // public static final String STUD_PE_RECORD_TYPE_ID 
    //     = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();

    // public Reactivation type {get; private set;}
    // public Profile currentUserProfile {get; private set;}
    // public hed__Program_Enrollment__c studPE {get; private set;}
    // public List<Special_Education__c> studSEList {get; private set;}
    // public List<Annual_Student_Information__c> studASIList {get; private set;}
    // public List<Enrollment_Component_Affiliation__c> ecaList {get; private set;}
    // public List<Enrollment_Document__c> edList {get; private set;}
            

    // public NES_EnrollmentReactivation(String stud_PEID, String reactivationType) {
        
    //     this.type=this.getReactivationType(reactivationType);
    //     this.init(stud_PEID);    

    // }

    // @TestVisible private void init(String stud_PEID) {

    //     // Validate stud_PEID is not blank/null
    //     if (String.isBlank(stud_PEID)) {
    //         throw new InvalidParameterValue_Exception('BLANK OR Null Program Enrollment Id, Id:' + stud_PEID);
    //     }
        
    //     // Validate stud_PEID is of type ProgramEnrollment
    //     Schema.sObjectType paramEntityType = Id.valueOf(stud_PEID).getSObjectType();
    //     // System.assert(entityType == hed__Program_Enrollment__c.sObjectType);
    //     if (paramEntityType !=hed__Program_Enrollment__c.sObjectType) { // ensure we have PD ID
    //         throw new InvalidParameterValue_Exception('Not a Program Enrollment Record Id, Id:' + stud_PEID);
        // }

    //     // fetch records... 
    //     // PE
    //     this.studPE =
    //         [SELECT Id, Name, hed__Contact__r.Name,hed__Account__r.Registration_Start_Date__c, hed__Account__r.OwnerId,
    //             hed__Account__r.Registration_End_Date__c, hed__Account__r.Confirmation_End_Date__c,hed__Contact__r.AccountId, 
    //             AcademicPerformanceEligibility__c, RecordTypeId, RecordType.Name, Status__c, 
    //             (SELECT Id,StageName FROM Opportunities__r)
    //           FROM hed__Program_Enrollment__c WHERE Id = :stud_PEID];
    //     System.debug(JSON.serialize(studPE));    
    //     // Validate stud_PEID if right RecordType
    //     if (this.studPE.RecordTypeId != STUD_PE_RECORD_TYPE_ID) {
    //         throw new InvalidParameterValue_Exception(
    //             'This Program Enrollment Id is not eligible for Student Enrollment Reactivation, Id:' + stud_PEID + '; RecordType:' + RecordType.Name);
        // }

    //     // get currentUser.Profile details
    //     this.currentUserProfile = [Select Id, Name from Profile where id = : UserInfo.getProfileId()];
    //     System.debug(logginglevel.DEBUG, JSON.serialize(currentUserProfile));

    //     // if its SOFT then exit.
    //     if (this.type==Reactivation.SOFT) {
    //         return;
    //     }
        
    //     // ECAs --- Commented for Bug #122743 (Krishna Peddanagammol)
    //     //this.ecaList = new List<Enrollment_Component_Affiliation__c>
    //     //    ([SELECT Id, SystemModstamp, Enrollment_Component__c,Enrollment_Component__r.Reactivation_Status__c, Name,Program_Enrollment__c,Status__c
    //     //    FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__r.Reactivation_Status__c!=null AND Program_Enrollment__c = :studPE.Id]);
        
    //     // ECAs query changed for Bug #122743 (Krishna Peddanagammol)
    //     This.ecaList = new List<Enrollment_Component_Affiliation__c>
    //         ([SELECT Id, SystemModstamp, Enrollment_Component__c,Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Status__c,Order__c
    //         FROM Enrollment_Component_Affiliation__c WHERE   Program_Enrollment__c = :studPE.Id AND( (( Status__c= 'Complete' AND
    //         (Enrollment_Component__r.RecordType.Name = 'Section' OR Enrollment_Component__r.RecordType.Name = 'Form'
    //         OR Enrollment_Component__r.RecordType.Name = 'Question'  OR Enrollment_Component__r.RecordType.Name = 'Question Group'
    //         OR Enrollment_Component__r.RecordType.Name = 'Document' OR Enrollment_Component__r.RecordType.Name = 'Flag'
    //         OR Enrollment_Component__r.RecordType.Name = 'Message' OR Enrollment_Component__r.RecordType.Name = 'Text' )) 
	// 	//added for bug 149148
	//     or ( (  Status__c= 'In Progress' or Status__c= 'Complete' ) 
    //         and (Enrollment_Component__r.RecordType.Name = 'Stage' AND Order__c != 1))))]); 
        
    //     System.debug('ecaList:' + JSON.serialize(ecaList));            
    //     // if (ecaList.isEmpty()) {
    //     //     return;
    //     // }

    //     // EDs
    //     this.edList = new List<Enrollment_Document__c>
    //         ([ SELECT Id, Status_Reason__c FROM Enrollment_Document__c WHERE Enrollment_Component_Affiliation__c IN :ecaList ]);
    //     System.debug('edList:' + JSON.serialize(edList));    
    //     // if (edList.isEmpty()) {
    //     //     return;
    //     // }

    //     // ASI
    //     this.studASIList = new List<Annual_Student_Information__c>
    //         ([SELECT Id FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :studPE.Id]);
    //     System.debug('studASIList:' + JSON.serialize(studASIList));

    //     // SE
    //     this.studSEList = new List<Special_Education__c>
    //         ([SELECT Id FROM Special_Education__c WHERE Program_Enrollment__c = :studPE.Id]);
    //     System.debug('studSEList:' + JSON.serialize(studSEList));

    // }

    // @TestVisible private void validate() {

    //         // check if Profile has access to run this button ? 
    //         this.validateUserProfile();

    //         // check if PE qualifies for reactivation
    //         this.validatePE();

    // }

    // public void execute() {        

    //     // validate: profile, PE, Oppty
    //     this.validate();

    //     // if its SOFT, discontinue & exit.
    //     if (this.type==Reactivation.SOFT) {

    //         // reset fields on PE
    //         this.resetPE();

    //         // run the Opportunity Creation & opp.reactivation fields update
    //         this.createPEOpportunity();
            
    //     } else if (this.type==Reactivation.FULL) {
            
    //         // process ECAs
    //         this.processECAs();

    //         // process EDs
    //         this.processEDs();

    //         // reset fields on PE
    //         this.resetPE();

    //         // reset fields on ASI
    //         this.resetStudASIs();

    //         // reset fields on SE
    //         this.resetStudSEList();

    //         // run the Opportunity Creation & opp.reactivation fields update
    //         this.createPEOpportunity();

    //     }

    // }

    // @TestVisible private void validateUserProfile() {

    //     NES_Enrollment_Process_Settings__mdt enrollmentSettings = 
    //         [Select Id, MasterLabel, Reactivation_Whitelist__c from NES_Enrollment_Process_Settings__mdt limit 1];
    //     System.debug(JSON.serialize(enrollmentSettings));

    //     if (!enrollmentSettings.Reactivation_Whitelist__c.toLowerCase().Contains(this.currentUserProfile.Name.toLowerCase())) {
    //         throw new NoAccess_Exception('You do not have access to Enrollment Reactivation funtionality. Please reach out to your Salesforce Admin for help.');
    //     }

    // }
        
    // @TestVisible private void validatePE() {

    //     Boolean isInsert = true;
    //     hed__Program_Enrollment__c programEnrollment = this.studPE;
                
    //     if(programEnrollment.hed__Account__r.Registration_Start_Date__c == null  
    //         || programEnrollment.hed__Account__r.Registration_End_Date__c == null ||
    //             ! (PE_WITHDRAWAL_REASON_CODES.containsIgnoreCase(programEnrollment.Status__c)) ||
    //                 ! (System.today() >= programEnrollment.hed__Account__r.Registration_Start_Date__c) ||
    //                     ! (System.today() <= programEnrollment.hed__Account__r.Registration_End_Date__c) ) {
    //                         isInsert = false;
    //     } else if(!programEnrollment.Opportunities__r.isEmpty() ) {
    //         for(Opportunity opp:programEnrollment.Opportunities__r) {                
                
    //             if (opp.StageName<>'Closed Lost') {                    
                    
    //                 isInsert = false;
    //                 break;

    //             }
    //         }
    //     }
    //     else { // if no associated Oppty's found, you can't reactivate.
    //         isInsert = false;
    //     }

    //     if (!isInsert) {
    //         throw new EnrollmentReactivation_Exception(
    //             'Program Enrollment does not qualify for Reactivation. PE.Id:' + programEnrollment.Id);
    //     }

    // }
        
    // @TestVisible private void processECAs() {

    //     List<Enrollment_Component_Affiliation__c> ecaToUpdate = new List<Enrollment_Component_Affiliation__c>();
        
    //     // Set Submitted ECA's to 'In Progress' or 'Not Started' based on EC Recordtype 
    //     // for Bug #122743 (Krishna Peddanagammol)
        //for (Enrollment_Component_Affiliation__c eca : this.ecaList) {
    //         if(eca.Enrollment_Component__r.RecordType.Name == 'Form'){
    //             eca.Status__c = 'In Progress';   
    //         }else{ 
    //             eca.Status__c = 'Not Started';
    //         }
    //         ////added for bug 149148
    //         if(eca.Enrollment_Component__r.RecordType.Name == 'Stage' && eca.Order__c == 2 ){
    //             eca.Status__c = 'In Progress';   
    //         }else{ 
    //             eca.Status__c = 'Not Started';
    //         }
    //         ecaToUpdate.add(eca);            
        //}
        
    //     // Commented for  Bug #122743 (Krishna Peddanagammol)
    //     //for (Enrollment_Component_Affiliation__c eca : this.ecaList) {
    //     //    ecaToUpdate.add(new Enrollment_Component_Affiliation__c(id = eca.Id, status__c= eca.Enrollment_Component__r.Reactivation_Status__c));            
    //     //}

    //     if (ecaToUpdate.size()>0) {
    //         update ecaToUpdate;
    //     }
    // }

    // @TestVisible private void processEDs() {
        
    //     List<Enrollment_Document__c> edToUpdate = new List<Enrollment_Document__c>();

    //     for (Enrollment_Document__c ed : edlist) {
	// 	    edToUpdate.add(new Enrollment_Document__c(id=ed.id, status_reason__c=ED_REACTIVATION_REASON_CODE));
    //     }
    //     if (edList.size()>0) {
    //         update edToUpdate;
    //     }

    // }

    // @TestVisible private void resetPE() {

    //     // AcademicPerformanceEligibility => set to Pending if not Null in oldValue
    //     String AcademicPerformanceEligibility = String.isBlank(this.studPE.AcademicPerformanceEligibility__c) ? null  : 'Pending';

    //     hed__Program_Enrollment__c toUpdatePE = new hed__Program_Enrollment__c( 
    //         id = this.studPE.Id,
    //         Status__c = PE_REACTIVATION_REASON_CODE, 
    //         CounselingFlag__c = null,
    //         AcademicPerformanceEligibility__c = AcademicPerformanceEligibility,
    //         EntranceAgeEligibilityOverride__c = null,
    //         Start_Date_of_Disciplinary_Action__c = null,
    //         End_Date_of_Disciplinary_Action__c = null,
    //         DisciplinaryPastActions__c = null,
    //         DisciplinaryFlagOverride__c = null,
    //         isPlacementReady__c = false, 
    //         EvaluatePlacementScore__c = true, 
    //         EvaluatePlacementExclude__c = true,
    //         EvaluatePlacementBucket__c = true,
    //         PlacementFlag__c = null,
    //         WaitlistCounter__c = null,  //Need for re enroll
    //         Waitlist_Time_Date_Stamp__c = null,  //Need for re enroll
    //         Waitlist_Time_Date_Stamp_Override__c = null    //Need for re enroll
    //     );

    //     update toUpdatePE;

    // }

    // @TestVisible private void resetStudASIs() {
        
    //     List<Annual_Student_Information__c> toUpdateASIs = new List<Annual_Student_Information__c>();
        
    //     for (Annual_Student_Information__c asi : this.studASIList) {
    //         toUpdateASIs.add( new Annual_Student_Information__c (
    //             id = asi.Id,
    //             HowStudentPlacementCompleted__c = null,
    //             CoursesFinalized__c = null,
    //             Math_Placement_Level__c = null,
    //             LA_Placement_Level__c = null,
    //             Science_Placement_Level__c = null,
    //             Final_Grade_Level__c = null,
    //             AutomatedPlacementExclude__c = false,
	// 			StudentPlacementBucket__c = null
    //         ));
    //     }
    //     if (toUpdateASIs.size()>0) {
    //         update toUpdateASIs;
    //     }

    // }
        
    // @TestVisible private void resetStudSEList() {
        
    //     List<Special_Education__c> toUpdateSEs = new List<Special_Education__c>();

    //     for (Special_Education__c se : this.studSEList) {
    //         toUpdateSEs.add( new Special_Education__c(
    //             id = se.Id,
    //             FormallyExitedIEP__c = null,
    //             IEPHistory__c = null,
    //             IEPLastUpdated__c = null,
    //             IEP__c = null
    //         ));
    //     }
    //     if (toUpdateSEs.size()>0) {
    //         update toUpdateSEs;
    //     }
    // }

    // @TestVisible private void createPEOpportunity() {

    //     hed__Program_Enrollment__c progEnrollment = this.studPE;
    //     //Fix For Bug #124652 by (Krishna Peddanagammol)
    //     ReactivatedBy userType =  (this.currentUserProfile.Name.Contains(COMMUNITY_USER_PROFILE_PREFIX)) ? ReactivatedBy.Caretaker : ReactivatedBy.Staff;

    //     Opportunity oppty = new Opportunity(
    //         Name = progEnrollment.hed__Contact__r.Name+'Opportunity',
    //         AccountId = progEnrollment.hed__Contact__r.AccountId,
    //         Program_Enrollment__c = progEnrollment.Id,
    //         StageName ='Open',
    //         Reactivation__c = true,
    //         CloseDate = progEnrollment.hed__Account__r.Confirmation_End_Date__c.date(),
    //         OwnerId = progEnrollment.hed__Account__r.OwnerId,
    //         How_Student_Was_Reactivated__c = userType.name()
    //     );

    //     if (this.type==Reactivation.SOFT) {
    //         oppty.Soft_Reactivation_Date__c = Date.today();
    //     } else {
    //         oppty.Full_Reactivation_Date__c = Date.today();
    //         oppty.Full_Reactivation_User__c = UserInfo.getUserId();
    //     }

    //     insert oppty;

    // }
        
    // public Reactivation getReactivationType(String reactivationType) {

    //     Reactivation type;

    //     switch on reactivationType.toUpperCase() {
    //         when 'FULL' {
    //             type = Reactivation.FULL;
    //         }
    //         when 'SOFT' {
    //             type =  Reactivation.SOFT;
    //         }
    //         when else {
    //              throw new NES_EnrollmentReactivation.EnrollmentReactivation_Exception(
    //                  'EnrollmentReactivation error, reactivation type is invalid. Supported values are => FULL, SOFT.');
    //         }
    //     }

    //     return type;

    // }

    // public class EnrollmentReactivation_Exception extends Exception {}
    // public class InvalidParameterValue_Exception extends Exception {}
    // public class NoAccess_Exception extends Exception {}


}