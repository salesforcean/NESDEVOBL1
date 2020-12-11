/**
 * 
 * Created by ali km on May/06/2020 for [US 168070]
 *      - This class is the base call for following User/Button Actions
 *          -> PE.Soft Reactivation
 *          -> PE.FULL Reactivation
 *          -> PE.Re-enrollment
 *      
 */
public abstract class NES_EnrollmentReactivationBase {
    
    public enum Reactivation {SOFT, FULL, RE_ENROLLMENT } 
    public enum ReactivatedBy {Caretaker, Staff} 

    public static final String COMMUNITY_USER_PROFILE_PREFIX = 'Caretaker';  
    public static final String PE_WITHDRAWAL_STATUS = 'Withdrawn';
    public static final String PE_REACTIVATION_STATUS = 'In Progress';
    public static final String STUD_PE_RECORD_TYPE_ID 
        = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();

    public Reactivation type {get; protected set;} 
    public Profile currentUserProfile {get; private set;}
    public hed__Program_Enrollment__c studPE {get; private set;}
    public List<Enrollment_Component_Affiliation__c> ecaList {get; protected set;}

    public NES_EnrollmentReactivationBase(String stud_PEID, Reactivation type) { 

        this.type = type;
        init(stud_PEID);    

    }

    // does bulk of the process for each reactivation type (ex: FULL, SOFT, RE_ENROLLMENT)
    // to be implemented by child class
    public abstract void execute();


    @TestVisible protected void init(String stud_PEID) {

        setCurrentUserProfile();
        setStudPE(stud_PEID);

    }


    private void setCurrentUserProfile() {
        
        currentUserProfile = [Select Id, Name from Profile where id = : UserInfo.getProfileId()];    
        validateUserProfile();

    }


    private void setStudPE(String stud_PEID) {

        validateStudPEID(stud_PEID); // validate stud_PEID
        
        // Added Start_Year__r.Current_Year__c for 335376 by Shravani Pendyala
        // fetch PE rec 
        studPE =
            [SELECT Id, Start_Year__r.Current_Year__c,hed__Account__r.ParentId, Name, hed__Contact__r.Name,hed__Account__r.Registration_Start_Date__c, hed__Account__r.OwnerId,
                hed__Account__r.Registration_End_Date__c, hed__Account__r.Confirmation_End_Date__c,hed__Contact__r.AccountId, 
                AcademicPerformanceEligibility__c, RecordTypeId, RecordType.Name, Status__c, Household_Program_Enrollment__c,
                (SELECT Id,StageName FROM Opportunities__r)
              FROM hed__Program_Enrollment__c WHERE Id = :stud_PEID];

        preValidatePE(); // validate the stud_PE rec

    }
    

    @TestVisible protected void validateUserProfile() {
        
        NES_Enrollment_Process_Settings__mdt enrollmentSettings = 
            [SELECT Id, DeveloperName, MasterLabel, Reactivation_Whitelist__c 
                FROM NES_Enrollment_Process_Settings__mdt WHERE DeveloperName = :type.name() ];
        System.debug(JSON.serialize(enrollmentSettings));

        if (!enrollmentSettings.Reactivation_Whitelist__c.toLowerCase().Contains(currentUserProfile.Name.toLowerCase())) {
            throw new NoAccess_Exception('You do not have access to perform this action, please reach out to your Salesforce Admin for help.');
        }

    }


    @TestVisible protected void validateStudPEID(String stud_PEID) {

        // Validate stud_PEID is not blank/null
        if (String.isBlank(stud_PEID)) {
            throw new InvalidParameterValue_Exception('BLANK OR Null Program Enrollment Id:' + stud_PEID);
        }

        // Validate stud_PEID is of type ProgramEnrollment
        Schema.sObjectType paramEntityType = Id.valueOf(stud_PEID).getSObjectType();
        // System.assert(entityType == hed__Program_Enrollment__c.sObjectType);
        if (paramEntityType !=hed__Program_Enrollment__c.sObjectType) { // ensure we have PD ID
            throw new InvalidParameterValue_Exception('Not a Program Enrollment Record Id:' + stud_PEID);
        }

    }


    @TestVisible protected void preValidatePE() { 

        // Validate stud_PEID if right RecordType
        if (studPE.RecordTypeId != STUD_PE_RECORD_TYPE_ID) {
            throw new InvalidParameterValue_Exception(
                'This Program Enrollment is not eligible for Student ' +  type + ', Id:' 
                    + studPE.Id + '; RecordType:' + studPE.RecordType.Name + ', Expected: Student');
        } 
        
        // Added for 335376 by Shravani Pendyala
        if (studPE.Start_Year__r.Current_Year__c != true) {
            throw new InvalidParameterValue_Exception(
                'This Program Enrollment is not eligible; Start Year is Current Year:' + studPE.Start_Year__r.Current_Year__c + ', Expected: true');
        }

        // // move to implementing child class...
        // if (!PE_WITHDRAWAL_STATUS.equalsIgnoreCase(this.studPE.Status__c)) {
        //     throw new InvalidParameterValue_Exception(
        //         'This Program Enrollment is not eligible for Student ' +  this.type 
        //             + ', Id:' + this.studPE.Id + '; Status:' + this.studPE.Status__c + ', Expected: ' + PE_WITHDRAWAL_STATUS);
        // }

    }

    // move to implementing child class...
    @TestVisible protected Opportunity getNewOpportunity() { // template to initialize the Oppty & return

        hed__Program_Enrollment__c progEnrollment = studPE;
        ReactivatedBy userType =  
            (currentUserProfile.Name.Contains(COMMUNITY_USER_PROFILE_PREFIX)) ? ReactivatedBy.Caretaker : ReactivatedBy.Staff;

        return (
            new Opportunity(
                Name = progEnrollment.hed__Contact__r.Name+'Opportunity',
                AccountId = progEnrollment.hed__Contact__r.AccountId,
                Program_Enrollment__c = progEnrollment.Id,
                StageName ='Open',
                CloseDate = progEnrollment.hed__Account__r.Confirmation_End_Date__c.date(),
                OwnerId = progEnrollment.hed__Account__r.OwnerId,
                How_Student_Was_Reactivated__c = userType.name()             
            )
        );

    }


    @TestVisible protected void processECAs(String enrollmentType) {
        
        List<Enrollment_Component_Affiliation__c> ecaToUpdate = new List<Enrollment_Component_Affiliation__c>();

        //Fix for Bug #195463 on 2020-06-25 (Krishna Peddanagammol)
        //Added Else If condition for defect #210102

        Set<Id> ECAsOfTypeDocument = new Set<Id>();
        Set<Id> ECsOfTypeDocument = new Set<Id>();
        for (Enrollment_Component_Affiliation__c eca : ecaList) {
            if((eca.Enrollment_Component__r.RecordType.Name != 'Stage') && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')) {
                eca.Status__c = 'Not Started';
            }else if((eca.Enrollment_Component__r.RecordType.Name == 'Stage')  && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')){
                if(eca.Order__c == 2){
                    eca.Status__c = 'In Progress';
                }else if(eca.Order__c > 2){
                    eca.Status__c = 'Not Started';
                }
            }
            system.debug('Enrollment Type*********'+eca.Program_Enrollment__r.Enrollment_Type__c);
            //Added for making Form status as In Progress, This will run only for Re-Enrolling Students for Defect 244255
            if((eca.Enrollment_Component__r.RecordType.Name == 'Form') && enrollmentType == 'RE-ENROLLMENT') 
                eca.Status__c = 'In Progress';
            
            //store the ECAs of document because during a reenrollment, we have to update the Enrollment docs tied to these ECAs
            if (eca.Enrollment_Component__r.RecordType.Name == 'Document') {
                ECAsOfTypeDocument.add(eca.id);       
                ECsOfTypeDocument.add(eca.Enrollment_Component__c);

                //For Reenrollments, all ECAs should have been completed once and for documents, they should be marked as In Progress.
                if(type==Reactivation.RE_ENROLLMENT) 
                    eca.Status__c = 'In Progress';
            }
 
            ecaToUpdate.add(eca);     
        }
        
        if (ecaToUpdate.size()>0) {
           // Added code for the defect 228339 by Maddileti on 28-08-2020   
           // To bypass the auto-completion logic , passing Flag value from  NES_EnrollmentReactivationBase class to NES_AddStudentCBLQueueable class
           if(type==Reactivation.RE_ENROLLMENT) {
               //Mark any Enrollment document that is tied to any ECA we are opening as invalid.
               Set<id> EDsAlreadyAdded = new Set<Id> ();
               List<Enrollment_Document__c> allEDsToUpdate = new List<Enrollment_Document__c> ([select id, Status_Reason__c from Enrollment_Document__c where Enrollment_Component_Affiliation__c in :ECAsOfTypeDocument]);
               for (Enrollment_Document__c ed : allEDsToUpdate) {
                   ed.Status_Reason__c = 'Invalid-Reenrollment';
                   EDsAlreadyAdded.add(ed.id);
               }

               //MM 10/5/2020 We need to find the house docs that might be tied to a different ECA.
               List<Enrollment_Document__c> allHouseholdEDsToUpdate = new List<Enrollment_Document__c> ([select id, Status_Reason__c 
                                                                                from Enrollment_Document__c 
                                                                                where Program_Enrollment__c = :studPE.Household_Program_Enrollment__c
                                                                                and Enrollment_Component_Affiliation__r.Enrollment_Component__c in :ECsOfTypeDocument ]);
               for (Enrollment_Document__c ed : allHouseholdEDsToUpdate) {
                   ed.Status_Reason__c = 'Invalid-Reenrollment';
                   if (!EDsAlreadyAdded.contains(ed.id))
                       allEDsToUpdate.add(ed);
               }

               if (allEDsToUpdate.size() > 0)
                   update allEDsToUpdate;
           }
           
           update ecaToUpdate;
        }
    }


    // exception classes
    public class EnrollmentReactivation_Exception extends Exception {}
    public class InvalidParameterValue_Exception extends Exception {}
    public class NoAccess_Exception extends Exception {}
}