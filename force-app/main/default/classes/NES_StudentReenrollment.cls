/**
 * 
 * Created by ali km on May/04/2020 for [US 168070]
 *      - This class handles Re-enrollment process for STUD_PE rec
 *  Change Log :  
 *  2020-08-18 Added createECAsForMigratedStudent method for the migrated students to create ECAs for #US223531
 */
public without sharing class NES_StudentReenrollment extends NES_EnrollmentReactivationBase {

    public static final String PE_RE_ENROLLMENT_TYPE_DEFAULT = 'Re-enrolling student';

    public NES_StudentReenrollment(String stud_PEID, Reactivation type) {

        super(stud_PEID, type);
        validate();
        setECAList();

    }


    @TestVisible private void validate() { 

        // move to implementing child class...
        if (!PE_WITHDRAWAL_STATUS.equalsIgnoreCase(this.studPE.Status__c)) {
            throw new InvalidParameterValue_Exception(
                'This Program Enrollment is not eligible for Student ' +  this.type 
                    + '; Status:' + this.studPE.Status__c + ', Expected: ' + PE_WITHDRAWAL_STATUS);
        }

    }


    public override void execute() { 
         
        // process ECAs  Added for making Form status as In Progress, for Defect 244255
        processECAs('RE-ENROLLMENT');

        //To Run Assignment Logic
        
        
        // reset fields on PE
        processPE();
       // processECAs('RE-ENROLLMENT');
       
        // run the Opportunity Creation
        createPEOpportunity();
        
         
        //#US223531 Start (Jagadish Babu)
        //Run for migrated students
        createECAsForMigratedStudent();
        //#US223531 End (Jagadish Babu)
    }


    @TestVisible private void processPE() {

        hed__Program_Enrollment__c toUpdatePE = new hed__Program_Enrollment__c( 
            Id = this.studPE.Id,
            Status__c = PE_REACTIVATION_STATUS,
            Enrollment_Type__c = PE_RE_ENROLLMENT_TYPE_DEFAULT,
            WaitlistFlag__c = null,
            WaitlistCounter__c = null,
            Waitlist_Time_Date_Stamp__c = null,
            Waitlist_Time_Date_Stamp_Override__c = null,
            Initial_ECA_Creation_Complete__c = true
        );
        update toUpdatePE;

    }


    @TestVisible private void createPEOpportunity() {

        Opportunity newOppty = this.getNewOpportunity();
        insert newOppty;

    }


    @TestVisible private void setECAList() {

        // query & set ecaList
        ecaList = 
            new List<Enrollment_Component_Affiliation__c>
                ([
                    SELECT  Id, SystemModstamp, Enrollment_Component__c,Status__c,Order__c,
                            Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c,
                            Enrollment_Component__r.Needed_for_Re_enrollment__c,
                            Enrollment_Component__r.RecordTypeId
                    FROM    Enrollment_Component_Affiliation__c 
                    WHERE   
                        Program_Enrollment__c = :studPE.Id 
                        AND ( Enrollment_Component__r.Needed_for_Re_enrollment__c = true) // Only Stage-2 matters? 
                        AND 
                        ( 
                            (
                                ( 
                                    Status__c= 'Complete' 
                                    AND 
                                    Enrollment_Component__r.RecordType.Name 
                                        IN ('Section', 'Form', 'Question', 'Question Group', 'Document', 'Flag', 'Message', 'Text') 
                                )
                                OR 
                                ( 
                                    (  
                                        Status__c IN ('In Progress', 'Complete')
                                        AND 
                                        (
                                            Enrollment_Component__r.RecordType.Name = 'Stage' 
                                            AND 
                                            Order__c != 1
                                        )
                                    )
                                )
                            )
                        )
                ]);

        System.debug('ecalist::' + JSON.serialize(ecaList));
    }
    
    //#US223531 Start (Jagadish Babu)
    //Below method will create ECAs for Migrated Students
    private void createECAsForMigratedStudent(){
        //Retrive PE record with External Id, academic program
        List<hed__Program_Enrollment__c> peRecord = [Select Id,Attended_other_school_since_withdrawing__c,Enrollment_Type__c,
                                                            hed__Account__c,hed__Contact__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Contact__r.AccountId,
                                                            V2_External_ID__c
                                                            from hed__Program_Enrollment__c Where id =: this.studPE.Id];
        //Check to Execute only for Migrated student
        if(String.isNotBlank(peRecord[0].V2_External_ID__c)){
            Set<Id> enrollmentComponentIds = new Set<Id>();
            //Retrive all ECAs if created already
            List<Enrollment_Component_Affiliation__c> allECAList= [Select Id,
                                                            Enrollment_Component__c,
                                                            Program_Enrollment__c
                                                            from Enrollment_Component_Affiliation__c
                                                            Where Program_Enrollment__c =:this.studPE.Id];
            //Add all EC ids to set to exclude while creation of ECA                                                            
            if(!allECAList.isEmpty()){
                for (Enrollment_Component_Affiliation__c eca : allECAList) {
                    enrollmentComponentIds.add(eca.Enrollment_Component__c);
                }
            }
            
            //Retrive process EC with academic program
            List<Enrollment_Component__c> processECRec = [Select Id,Name,
                                                                 RecordType.Name,
                                                                 Process_Academic_Program__c
                                                                 from Enrollment_Component__c where Process_Academic_Program__c=:peRecord[0].hed__Account__c and RecordType.Name =: NES_DashboardUtilities.PROCESS_RT]; 
            
             
            //Retrieve the ECR tree.
            NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
            NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processECRec[0].Id);
            List<Enrollment_Component_Affiliation__c> newAffiliations = new List<Enrollment_Component_Affiliation__c>();
           
            //Create Process ECA if not exist
            if(!enrollmentComponentIds.contains(processECRec[0].Id)){
                Enrollment_Component_Affiliation__c processECA = new Enrollment_Component_Affiliation__c();
                processECA.Enrollment_Component__c = processECRec[0].Id;
                processECA.Program_Enrollment__c = peRecord[0].Id;
                processECA.Status__c = 'Not Started';
                processECA.EC_Record_Type__c = NES_DashboardUtilities.PROCESS_RT;   
                newAffiliations.add(processECA);
            }
            
            //Add Stage ECA records if not exist
            for (Enrollment_Component_Relationship__c relationship : thisProcessData.stageRelationships) {  
                System.debug('Needed for Reenroll****'+relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c);             
                if(relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c == true && !enrollmentComponentIds.contains(relationship.Child_Enrollment_Component__c)  && String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = peRecord[0].Id;
                    affiliationRecord.Status__c = 'Not Started';
                    affiliationRecord.Order__c = relationship.Order__c;
                    affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                    newAffiliations.add(affiliationRecord);
                   
                }    
                
            }
            
            //Add form ECA records
            for (Enrollment_Component_Relationship__c relationship : thisProcessData.formRelationships) { 
                System.debug('Needed for Reenroll****'+relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c);              
                if(relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c == true && !enrollmentComponentIds.contains(relationship.Child_Enrollment_Component__c) && String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c))  {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = peRecord[0].Id;
                    affiliationRecord.Status__c = 'Not Started';
                    affiliationRecord.Order__c = relationship.Order__c;
                    affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                    newAffiliations.add(affiliationRecord);
                    
                } 
                
            }

            //Add Section ECA records
            for (Enrollment_Component_Relationship__c relationship : thisProcessData.sectionRelationships) {  
                System.debug('Needed for Reenroll****'+relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c);             
                if(relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c == true && !enrollmentComponentIds.contains(relationship.Child_Enrollment_Component__c) && String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) )  {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = peRecord[0].Id;
                    affiliationRecord.Status__c = 'Not Started';
                    affiliationRecord.Order__c = relationship.Order__c;
                    affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                    newAffiliations.add(affiliationRecord);
                
                }  
                
            }

             //Add Question Group ECA records
             for (Enrollment_Component_Relationship__c relationship : thisProcessData.questionGroupRelationships) {  
                System.debug('Needed for Reenroll****'+relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c);             
                 if(relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c == true && !enrollmentComponentIds.contains(relationship.Child_Enrollment_Component__c) && String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) )  {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = peRecord[0].Id;
                    affiliationRecord.Status__c = 'Not Started';
                    affiliationRecord.Order__c = relationship.Order__c;
                    affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                    newAffiliations.add(affiliationRecord);
                
                }    
                
            }

             //Add Question  ECA records
             for (Enrollment_Component_Relationship__c relationship : thisProcessData.questionRelationships) {             
                System.debug('Needed for Reenroll****'+relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c);
                 if(relationship.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c == true && !enrollmentComponentIds.contains(relationship.Child_Enrollment_Component__c) && String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) ) {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = peRecord[0].Id;
                    affiliationRecord.Status__c = 'Not Started';
                    affiliationRecord.Order__c = relationship.Order__c;
                    affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                    newAffiliations.add(affiliationRecord);                   
                }                    
            }
            System.debug('newAffiliations**********'+newAffiliations);
            if (newAffiliations.size() > 0) {
               insert newAffiliations; 
            }
            //Calling assignment logic to create ECAs to create schooling Info section
            NES_ECAEvaluation.runAssignment(peRecord[0].Id, null, peRecord[0],newAffiliations,processECRec[0].Id);
        }      
        else{
            List<Enrollment_Component_Affiliation__c> ecalist = [Select Id,Enrollment_Component__c,Program_Enrollment__c,Status__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c =: peRecord[0].Id];
            //Retrive process EC with academic program
            List<Enrollment_Component__c> processECRec = [Select Id,
                                                                 RecordType.Name,
                                                                 Process_Academic_Program__c
                                                                 from Enrollment_Component__c where Process_Academic_Program__c=:peRecord[0].hed__Account__c and RecordType.Name =: NES_DashboardUtilities.PROCESS_RT]; 
            NES_ECAEvaluation.runAssignment(peRecord[0].Id, null, peRecord[0],ecalist,processECRec[0].Id);
        }
    }
    //#US223531 End (Jagadish Babu)
    

}