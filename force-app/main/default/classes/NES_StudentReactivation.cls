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
        
 */
public class NES_StudentReactivation extends NES_EnrollmentReactivationBase {
    
    public static final String PE_WITHDRAWAL_REASON_CODES = 'Inactive, Time Expired, Ineligible'; //Removed Withdrawn Status for US #168874 on 2020-04-30 by Krishna Peddanagammol
    public static final String PE_REACTIVATION_REASON_CODE = 'In Progress'; 
    public static final String ED_REACTIVATION_REASON_CODE = 'Submitted';

    public List<Special_Education__c> studSEList {get; private set;}
    public List<Annual_Student_Information__c> studASIList {get; private set;}
    public List<Enrollment_Document__c> edList {get; private set;}


    public NES_StudentReactivation(String stud_PEID, Reactivation type) {
       
        super(stud_PEID, type);
        this.initialize();    

    }


    @TestVisible private void initialize() {

        // if its SOFT then exit.
        if (this.type==Reactivation.SOFT) {
            return;
        }
        
        //Start: Fix for Bug #195463 on 2020-06-25 (Krishna Peddanagammol)
        List<Enrollment_Component_Affiliation__c> eca = [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Enrollment_Component__r.RecordType.Name 
                                                        FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c = :studPE.Id AND 
                                                        Enrollment_Component__r.RecordType.Name = 'Stage' AND Order__c != 1];
        List<Id> stageEC = new List<Id>();
        for(Enrollment_Component_Affiliation__c eca2:eca){
            stageEC.add(eca2.Enrollment_Component__r.Id);
        }
        List<Enrollment_Component_Relationship__c> formECRs = [SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name 
                                                                FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c in :stageEC AND 
                                                                Child_Enrollment_Component__r.RecordType.Name = 'Form'];
        System.debug(formECRs.size());
        List<Id> formEC = new List<Id>();
        for(Enrollment_Component_Relationship__c ecr:formECRs){
        formEC.add(ecr.Child_Enrollment_Component__r.Id);
        }
        List<Enrollment_Component_Relationship__c> sectionECRs = [SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name 
                                                                    FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c in :formEC AND 
                                                                    Child_Enrollment_Component__r.RecordType.Name = 'Section'];
        System.debug(sectionECRs.size());
        List<Id> allIds = new List<Id>();

        //Fix for defect #210102 on 2020-07-15 (Mark Membrino)
        for(Enrollment_Component_Affiliation__c stageeca:eca){
            allIds.add(stageeca.Enrollment_Component__r.Id);
        }
        for(Enrollment_Component_Relationship__c formecr:formECRs){
            allIds.add(formecr.Child_Enrollment_Component__c);
        }
        for(Enrollment_Component_Relationship__c sececr:sectionECRs){
            allIds.add(sececr.Child_Enrollment_Component__c);
        }
        System.debug(allIds.size());
        this.ecaList = [SELECT Id, SystemModstamp,
                        Program_Enrollment__r.Enrollment_Type__c,
                        Enrollment_Component__r.Needed_for_Re_enrollment__c,
                        Enrollment_Component__r.Needed_for_ITR__c,
                        Enrollment_Component__c,
                        Enrollment_Component__r.Assignment_Logic__c,//Added for Open Application User story 451172 -->DK
                        Enrollment_Component__r.Name,  //Added for Open Application User story 451172 -->DK
					    Enrollment_Component__r.RecordType.Name, 
                       	Program_Enrollment__r.Open_Application__c, //Added for Open Application User story 451172 -->DK
                        Program_Enrollment__r.Program_Grade_Level__c, //Added for Open Application User story 451172 -->DK
                        Name,Program_Enrollment__c,
                        Status__c,Order__c 
                        FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c = :studPE.Id AND Enrollment_Component__c in :allIds AND 
                        (Status__c = 'In Progress' OR Status__c = 'Complete') ORDER BY Order__c ASC];
        System.debug(this.ecaList.size());    
        //End : Fix for Bug #195463 on 2020-06-25 (Krishna Peddanagammol)

        // EDs
        this.edList = new List<Enrollment_Document__c>
            ([ SELECT Id, Status_Reason__c FROM Enrollment_Document__c WHERE Enrollment_Component_Affiliation__c IN :ecaList ]);
        System.debug('edList:' + JSON.serialize(edList));    

        // ASI
        this.studASIList = new List<Annual_Student_Information__c>
            ([SELECT Id FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :studPE.Id]);
        System.debug('studASIList:' + JSON.serialize(studASIList));

        // SE
        this.studSEList = new List<Special_Education__c>
            ([SELECT Id FROM Special_Education__c WHERE Program_Enrollment__c = :studPE.Id]);
        System.debug('studSEList:' + JSON.serialize(studSEList));
        
       
        
    }


    @TestVisible private void validate() {

            // check if PE qualifies for reactivation
            this.validatePE();

    }

    
    public override void execute() {        

        // validate: PE, Oppty
        this.validate();

        // if its SOFT, discontinue & exit.
        if (this.type==Reactivation.SOFT) {

            // reset fields on PE
            this.resetPE();

            // run the Opportunity Creation & opp.reactivation fields update
            this.createPEOpportunity();

        } else if (this.type==Reactivation.FULL) {
            
            // process ECAs  Added for making Form status as In Progress, for Defect 244255
            this.processECAs('FULL-REACTIVATION');
            
            // process EDs
            this.processEDs();

            // reset fields on PE
            this.resetPE();

            // reset fields on ASI
            this.resetStudASIs();

            // reset fields on SE
            this.resetStudSEList();

            // run the Opportunity Creation & opp.reactivation fields update
            this.createPEOpportunity();

        }

    }


    @TestVisible private void validatePE() {   
        
        Boolean isInsert = true;
        hed__Program_Enrollment__c programEnrollment = this.studPE;

        if(programEnrollment.hed__Account__r.Registration_Start_Date__c == null  
            || programEnrollment.hed__Account__r.Registration_End_Date__c == null ||
                ! (PE_WITHDRAWAL_REASON_CODES.containsIgnoreCase(programEnrollment.Status__c)) ||
                    ! (System.today() >= programEnrollment.hed__Account__r.Registration_Start_Date__c) ||
                        ! (System.today() <= programEnrollment.hed__Account__r.Registration_End_Date__c) ) {
                            isInsert = false;
        } else if(!programEnrollment.Opportunities__r.isEmpty() ) {
            for(Opportunity opp:programEnrollment.Opportunities__r) {                
                
                if (opp.StageName<>'Closed Lost') {    
                    system.debug('in NES_StudentReactivation-->opp.StageBlock-->'+opp.StageName);
                    isInsert = false;
                    break;
                }
            }
        }
        else { // if no associated Oppty's found, you can't reactivate.
            isInsert = false;
        }

        if (!isInsert) {
            throw new EnrollmentReactivation_Exception(
                'Program Enrollment does not qualify for Reactivation.');
        }

    }


    @TestVisible private void processEDs() {

        List<Enrollment_Document__c> edToUpdate = new List<Enrollment_Document__c>();
        
        for (Enrollment_Document__c ed : edlist) {
		    edToUpdate.add(new Enrollment_Document__c(id=ed.id, status_reason__c=ED_REACTIVATION_REASON_CODE));
        }
        if (edList.size()>0) {
            update edToUpdate;
        }

    }


    @TestVisible private void resetPE() {

        // AcademicPerformanceEligibility => set to Pending if not Null in oldValue
        String AcademicPerformanceEligibility = String.isBlank(this.studPE.AcademicPerformanceEligibility__c) ? null  : 'Pending';

         // Defect: 490665 Start: Naveen
        String WaitlistFlagVal = '';
           if(this.studPE.Program_Grade_Level__r.ActivateWaitlist__c == TRUE && this.studPE.Program_Grade_Level__r.StartWaitlist__c <= System.now() && this.studPE.Program_Grade_Level__r.EndWaitlist__c >= System.now()){
           	WaitlistFlagVal = 'Active';
           }
        //Defect: 490665 End: Naveen
        
        hed__Program_Enrollment__c toUpdatePE = new hed__Program_Enrollment__c( 
            id = this.studPE.Id,
            Status__c = PE_REACTIVATION_REASON_CODE, 
            CounselingFlag__c = null,
            AcademicPerformanceEligibility__c = AcademicPerformanceEligibility,
            EntranceAgeEligibilityOverride__c = null,
            Start_Date_of_Disciplinary_Action__c = null,
            End_Date_of_Disciplinary_Action__c = null,
            DisciplinaryPastActions__c = null,
            DisciplinaryFlagOverride__c = null,
            isPlacementReady__c = false, 
            EvaluatePlacementScore__c = true, 
            EvaluatePlacementExclude__c = true,
            EvaluatePlacementBucket__c = true,
            PlacementFlag__c = null,
            Open_Application__c = null, //Added for Open Application User story 451172 -->DK
            WaitlistCounter__c = null,  //Need for re enroll
            Waitlist_Time_Date_Stamp__c = null,  //Need for re enroll
            Waitlist_Time_Date_Stamp_Override__c = null,
            Waitlist_Released__c = null,//RAVI
            Waitlist_Released_Dt__c = null,//RAVI
            WaitlistFlag__c = WaitlistFlagVal // Defect 490665: Naveen
            
        );

        update toUpdatePE;

    }


    @TestVisible private void resetStudASIs() {
        
        List<Annual_Student_Information__c> toUpdateASIs = new List<Annual_Student_Information__c>();
        
        for (Annual_Student_Information__c asi : this.studASIList) {
            toUpdateASIs.add( new Annual_Student_Information__c (
                id = asi.Id,
                HowStudentPlacementCompleted__c = null,
                CoursesFinalized__c = null,
                Math_Placement_Level__c = null,
                LA_Placement_Level__c = null,
                Science_Placement_Level__c = null,
                Final_Grade_Level__c = null,
                AutomatedPlacementExclude__c = false,
				StudentPlacementBucket__c = null
            ));
        }
        if (toUpdateASIs.size()>0) {
            update toUpdateASIs;
        }

    }


    @TestVisible private void resetStudSEList() {
        
        List<Special_Education__c> toUpdateSEs = new List<Special_Education__c>();
        
        for (Special_Education__c se : this.studSEList) {
            toUpdateSEs.add( new Special_Education__c(
                id = se.Id,
                FormallyExitedIEP__c = null,
                IEPHistory__c = null,
                IEPLastUpdated__c = null,
                IEP__c = null
            ));
        }
        if (toUpdateSEs.size()>0) {
            update toUpdateSEs;
        }
    }


    @TestVisible private void createPEOpportunity() {

        hed__Program_Enrollment__c progEnrollment = this.studPE;
        //Fix For Bug #124652 by (Krishna Peddanagammol)
        ReactivatedBy userType =  (this.currentUserProfile.Name.Contains(COMMUNITY_USER_PROFILE_PREFIX)) ? ReactivatedBy.Caretaker : ReactivatedBy.Staff;

        Opportunity oppty = new Opportunity(
            Name = progEnrollment.hed__Contact__r.Name+'Opportunity',
            AccountId = progEnrollment.hed__Contact__r.AccountId,
            Program_Enrollment__c = progEnrollment.Id,
            StageName ='Open',
            Reactivation__c = true,
            CloseDate = progEnrollment.hed__Account__r.Confirmation_End_Date__c.date(),
            OwnerId = progEnrollment.hed__Account__r.OwnerId,
            How_Student_Was_Reactivated__c = userType.name()
        );

        if (this.type==Reactivation.SOFT) {
            oppty.Soft_Reactivation_Date__c = Date.today();
        } else {
            oppty.Full_Reactivation_Date__c = Date.today();
            oppty.Full_Reactivation_User__c = UserInfo.getUserId();
        }

        insert oppty;

    }

}