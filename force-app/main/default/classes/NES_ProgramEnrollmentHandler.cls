/**
 * Created by Anushka on 22-11-2018.
 * Purpose : Handler class for ProgramEnrollmentTrigger.
 **Change Log:
 * Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-06
 * Added code by Anitha P for Bug 122740 on 2020-01-09 
 * Added code by Sumanth/Rakesh to capture the old PE status value into Concatenated Status field as per US # 186957 (Task# 195460, 195459). Changes added on 2020-06-23.
 */


public class NES_ProgramEnrollmentHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('ProgramEnrollmentHandler');

    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('ProgramEnrollmentTrigger');
    static final Boolean entranceAgeEligibiltyOverrideSwitch = NES_TriggerUtility.BusinessLogicSwitch('Entrance Age Eligibility Override');
    static final Boolean highSchoolLTSScoreSwitch = NES_TriggerUtility.BusinessLogicSwitch('High School LTS Score');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');
    static final Boolean whyFlaggedLogicSwitch = NES_TriggerUtility.BusinessLogicSwitch('Why Flagged');
    static final String COMPLETE_STATUS = 'Complete';
    public static Boolean runCBL = true;
    public static Boolean runPlacement = true;
    static Boolean isFirstTime = true;//added
    public static Boolean isReenrollment = false; // added by maddileti




   


    public static void handleBeforeInsert(List<hed__Program_Enrollment__c> newList,List<hed__Program_Enrollment__c> actList) {
        //Mark Membrino 11/5/2019  Per 114797, we are changing the way the age elig overview works and making it a formula.  We no
        //longer need this override method to be called.
        //if (entranceAgeEligibiltyOverrideSwitch && runCBL)
        //      NES_ProgramEnrollmentBusinessLogic.calculateEntranceAgeEligibilityOverride(actList, null); //Swapna:Changed to active list
          //  NES_ProgramEnrollmentBusinessLogic.calculateEntranceAgeEligibilityOverride(newList, null);

        List<SObject> validRecords = new List<SObject>();

      //  for (hed__Program_Enrollment__c programEnrollment : newList) {
          for (hed__Program_Enrollment__c programEnrollment : actList) { //Swapna:Changed to active list
            if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch && runCBL) {
                if (programEnrollment.Start_Year__c != null || programEnrollment.Final_Grade_Level__c != null)  //See not on 114797 above programEnrollment.EntranceAgeEligibilityOverride__c != null ||
                         {
                    validRecords.add(programEnrollment);
                }
            }
            //80196 Bug Changes Ajith
            //if(programEnrollment.EntranceAgeEligibilityOverride__c != null){
            //    programEnrollment.EntAgeEliOvrDate__c = system.today();
            //}
        }

		//Mark Membrino 3/19/2020 (1540590)  Removing all these calls because we do all these steps in NES_AddStudentCBLQueueable

        //if (validRecords.size() > 0) {
        //    NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
        //}

        //All new records should have the address validation run and the technolgy flag set.
        //NES_BusinessLogicUtils.calculateAddressEligibility(newList);
        //NES_BusinessLogicUtils.flagTechnologyAction(newList);
    }

    public static void handleBeforeUpdate(Map<Id, hed__Program_Enrollment__c> newMap, Map<Id, hed__Program_Enrollment__c> oldMap,Map<Id, hed__Program_Enrollment__c> actlstnewMap, Map<Id, hed__Program_Enrollment__c> actlstoldMap) { 
        Boolean origCompletion = NES_ECACompletion.shouldRunCompletion;
        Boolean origAssignment = NES_Constants.runAssignment;
        Boolean origRunAssignment = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;       

        // Changes added on 2020-06-23.
        // Sumanth/Rakesh: Added the below 2 Maps for US # 186957 (Task# 195460, 195459)
        Map<Id,hed__Program_Enrollment__c> csNewMap = new Map<Id,hed__Program_Enrollment__c>();
        Map<Id,hed__Program_Enrollment__c> csOldMap = new Map<Id,hed__Program_Enrollment__c>();

        //Mark Membrino 11/5/2019  Per 114797, we are changing the way the age elig overview works and making it a formula.  We no
        //longer need this override method to be called.
        //if (entranceAgeEligibiltyOverrideSwitch && runCBL)
        //     NES_ProgramEnrollmentBusinessLogic.calculateEntranceAgeEligibilityOverride(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
           // NES_ProgramEnrollmentBusinessLogic.calculateEntranceAgeEligibilityOverride(newMap.values(), oldMap);              
        
        List<SObject> validRecords = new List<SObject>();
        list<hed__Program_Enrollment__c> disciplinaryActionUpdates  = new list <hed__Program_Enrollment__c> ();

        // Changes added on 2020-06-23.
        // Sumanth/Rakesh: Added the below 2 Maps for US # 186957 (Task# 195460, 195459)
        for (hed__Program_Enrollment__c pe : newMap.values()){
            if(pe.Status__c <> oldMap.get(pe.id).Status__c){
                csNewMap.put(pe.id,newMap.get(pe.id));
                csOldMap.put(pe.id,oldMap.get(pe.id));
            } 
         }

        // Logic added on 2020-06-23. Logic to process Updates PEs and stamp Old and New PE Status Values into the Concatenated Status field.
        // Sumanth/Rakesh: Added the below 2 Maps for US # 186957 (Task# 195460, 195459)
     	for (hed__Program_Enrollment__c progEnroll : csNewMap.values()){
            progEnroll.Concatenated_Status__c = csOldMap.get(progEnroll.Id).Status__c+'-'+progEnroll.Status__c;
        }

      //  for (hed__Program_Enrollment__c programEnrollment : newMap.values()) { //Swapna:Changed for active list
          for (hed__Program_Enrollment__c programEnrollment : actlstnewMap.values()) {
            if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch && runCBL) {
                if ((programEnrollment.Start_Year__c != actlstoldMap.get(programEnrollment.Id).Start_Year__c) ||
                        // See notes on 114797 (programEnrollment.EntranceAgeEligibilityOverride__c != actlstoldMap.get(programEnrollment.Id).EntranceAgeEligibilityOverride__c) ||
                        (programEnrollment.Final_Grade_Level__c != actlstoldMap.get(programEnrollment.Id).Final_Grade_Level__c)) {

                    validRecords.add(programEnrollment);
                }
            }

            if(programEnrollment.EntranceAgeEligibilityOverride__c != null &&
                    actlstoldMap.get(programEnrollment.Id).EntranceAgeEligibilityOverride__c != programEnrollment.EntranceAgeEligibilityOverride__c){
                programEnrollment.EntAgeEliOvrDate__c = system.today();
            }

            //We only calculate the disciplinary flag when the past actions are first set and if the PE is 'In Progress'
            //added logic for the bug 127334
              //if ( String.isBlank(oldMap.get(programEnrollment.Id).DisciplinaryPastActions__c) && !String.isBlank(programEnrollment.DisciplinaryPastActions__c) && programEnrollment.Status__c == 'In Progress')
              if ((oldMap.get(programEnrollment.Id).End_Date_of_Disciplinary_Action__c != programEnrollment.End_Date_of_Disciplinary_Action__c ||(String.isBlank(oldMap.get(programEnrollment.Id).DisciplinaryPastActions__c) && !String.isBlank(programEnrollment.DisciplinaryPastActions__c)))&& programEnrollment.Status__c == 'In Progress')  
              disciplinaryActionUpdates.add(programEnrollment);
        }

        if (validRecords.size() > 0 && runCBL) {
            NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
        }
        if (disciplinaryActionUpdates.size() > 0 ) {
            NES_BusinessLogicUtils.flagDisciplinaryAction(disciplinaryActionUpdates);
        }

        NES_ECACompletion.shouldRunCompletion = origCompletion;
        NES_Constants.runAssignment = origAssignment;

    }
    
    
    public static void handleAfterUpdate(Map<Id, hed__Program_Enrollment__c> newMap, Map<Id, hed__Program_Enrollment__c> oldMap,Map<Id, hed__Program_Enrollment__c> actlstnewMap, Map<Id, hed__Program_Enrollment__c> actlstoldMap) {
        Boolean origRunPlacement = runPlacement;
        runPlacement = false;
        Boolean origCompletion = NES_ECACompletion.shouldRunCompletion;
        Boolean origAssignment = NES_Constants.runAssignment;
        Boolean origRunAssignment = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;
		
        if (!logicSwitch) {
            return;
        }
        if (runCBL) {
            runCBL = false;
           
            NES_ProgramEnrollmentBusinessLogic.updateFinalConfirmationDate(newMap, oldMap);
            //  NES_ProgramEnrollmentBusinessLogic.calculateELLFlag(null, newMap, oldMap);
            NES_ProgramEnrollmentBusinessLogic.calculateELLFlag(null, actlstnewMap, actlstoldMap); //Swapna:Changed to active list
            //Swapna:Changed order of execution LTS and HSLTS
             if (likelihoodToTransitionScore) {
                //NES_ProgramEnrollmentBusinessLogic.calculateLTS(oldMap, newMap.values());
                NES_ProgramEnrollmentBusinessLogic.calculateLTS(actlstoldMap, actlstnewMap.values());//Swapna:Changed to active list
            }
            if (highSchoolLTSScoreSwitch) {
               // NES_ProgramEnrollmentBusinessLogic.populatecalculateHighSchoolLTS(oldMap, newMap.values());
                NES_ProgramEnrollmentBusinessLogic.populatecalculateHighSchoolLTS(actlstoldMap, actlstnewMap.values());//Swapna:Changed to active list
            }

           

            if (whyFlaggedLogicSwitch) {
               // NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newMap.values(), oldMap);
                NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
            }
        }

        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> pEsForCompleteAssignmentIds = new Set<Id>();
        //137647 -Swapna For ReActivation Case
		Set<Id> ReactivatedPEIds = new Set<Id>();
        Set<Id> allPEIds = new Set<Id>();
        NES_ProgramEnrollmentBusinessLogic.updateEnrollmentCapacity(oldMap, newMap.values());

        for (hed__Program_Enrollment__c programEnrollment : newMap.values()) {
            System.debug(programEnrollment.SIS_Integration_Status__c);
            if (programEnrollment.Status__c == COMPLETE_STATUS && oldMap.get(programEnrollment.Id).Status__c != COMPLETE_STATUS) {
                programEnrollmentIds.add(programEnrollment.Id);
            }

            if (programEnrollment.Status__c == 'In Progress' && oldMap.get(programEnrollment.Id).Status__c != 'In Progress') {
                pEsForCompleteAssignmentIds.add(programEnrollment.Id);
            }
            
            //137647 -Swapna For ReActivation Case
            if (programEnrollment.Status__c == 'In Progress' && oldMap.get(programEnrollment.Id).Status__c != 'In Progress' && (oldMap.get(programEnrollment.Id).Status__c == 'Inactive' || oldMap.get(programEnrollment.Id).Status__c == 'Ineligible' || oldMap.get(programEnrollment.Id).Status__c == 'Time Expired' || oldMap.get(programEnrollment.Id).Status__c == 'Withdrawn')) {
                ReactivatedPEIds.add(programEnrollment.Id);
       		}

            allPEIds.add(programEnrollment.Id);
        }
       
        if (programEnrollmentIds.size() > 0 && !System.isBatch() && !Test.isRunningTest()) {
            System.debug('push to SIS');
            NES_IdamUtilities.pushToSIS(programEnrollmentIds);
			System.debug('updateHHPEOrderHold====='+programEnrollmentIds);
			//If there is a Alt Shipping Address on the Account, we should set the Ordering Hold Flag
			//and date on the Household PE.  We also need to create a case.
			//Added code by viswa for #167639 User Story (Alternative Shipping Address Case Workflow) on 2020-04-24
            NES_ProgramEnrollmentBusinessLogic.updateHHPEOrderHold(programEnrollmentIds);
            NES_ProgramEnrollmentBusinessLogic.updateASIForCompletedPEs(programEnrollmentIds);//Added code by Maddileti Boya for #194222 User Story on 2020-06-15
            System.debug('updateHHPEOrderHold=====After'+programEnrollmentIds);
        }

        if (pEsForCompleteAssignmentIds.size() > 0 && !System.isBatch() && !Test.isRunningTest()) {
            for (id i:pEsForCompleteAssignmentIds) {
                
                 System.enqueueJob(new NES_AddStudentCBLQueueable(i));
            }
        }
        //137647 -Swapna For ReActivation Case
        if (ReactivatedPEIds.size() > 0) {
      
            NES_BusinessLogicUtils.reActivationCase(ReactivatedPEIds);
        }

        /****** Placement Updates ****************/
        runPlacement = origRunPlacement;
        system.debug('runPlacement:' + runPlacement);
        if(runPlacement) {
            // NES_ProgramEnrollmentBusinessLogic.calculatePlacement(newMap.values(), oldMap);
            list<ID> runPlacementPEs = new list<ID>();
            list<ID> runBucketPEs = new list<ID>();
            /* Add students to the list for placement execution if they are ready for placement, they have not been placed, they need 
            ** at least one of their components of placement updated, and at least one of the status indicators for placement changed values in the
            ** transaction. This will make sure the queueable only fires when there is a state change that triggers placement and will not fire for
            ** any transactions that execute between the queueable being fired and it running and commiting the changes back to the PE */
            for(hed__program_enrollment__c runPlacementPE : actlstnewMap.values()){
                if(
                	(runPlacementPE.HowStudentPlacementCompleted__c == null || newmap.get(runPlacementPE.ID).HowStudentPlacementCompleted__c == 'Standard Manual Process')
                    && runPlacementPE.isPlacementReady__c == true  && (runPlacementPE.EvaluatePlacementScore__c == true || runPlacementPE.EvaluatePlacementExclude__c == true || runPlacementPE.EvaluatePlacementBucket__c == true)
                    && (oldmap.get(runPlacementPE.ID).EvaluatePlacementScore__c != newmap.get(runPlacementPE.ID).EvaluatePlacementScore__c || oldmap.get(runPlacementPE.ID).EvaluatePlacementExclude__c != newmap.get(runPlacementPE.ID).EvaluatePlacementExclude__c || oldmap.get(runPlacementPE.ID).isPlacementReady__c != newmap.get(runPlacementPE.ID).isPlacementReady__c || oldmap.get(runPlacementPE.ID).EvaluatePlacementBucket__c != newmap.get(runPlacementPE.ID).EvaluatePlacementBucket__c )
           		){runPlacementPEs.add(runPlacementPE.ID);}
                
                /* If the student is placeable, isn't being evaluated for full placement, and is either marked as EvalPlacementBucket true or has had an update
                ** changing their placement flag or how student placement completed value, add them to the bucket eval list *
                }else if(runPlacementPE.isPlacementReady__c == true 
                	&& (runPlacementPE.EvaluatePlacementBucket__c == true
                	|| oldmap.get(runPlacementPE.ID).PlacementFlag__c != newmap.get(runPlacementPE.ID).PlacementFlag__c
                	|| oldmap.get(runPlacementPE.ID).HowStudentPlacementCompleted__c != newmap.get(runPlacementPE.ID).HowStudentPlacementCompleted__c)){ //added for 127565/127795
                    runBucketPEs.add(runPlacementPE.ID);    
                }*/
   
            /* Fire the full placement job for students needing evaluation */
            if(runPlacementPEs.size()>0){
                //NES_ProgramEnrollmentBusinessLogic.calculatePlacement(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
                System.enqueueJob(new NES_PlacementQueueable(runPlacementPEs)); 
                //runPlacement = false;
            }/*else{
             //Fire the bucket job for bucket-only evaluations 
            if(runBucketPEs.size()>0){
               System.enqueueJob(new PlacementBucketQueueable(runBucketPEs));  
            }*/
            }
            //runPlacement = false;
        }
        /********* End Placement Updates *************/
		/****Moved over to line number 143 ****/
       NES_Constants.runAssignment = origAssignment;
       NES_ECACompletion.shouldRunCompletion = origCompletion;
       

       //MM 11/18/2020 Removed for only running for when origRunAssignment is true because in the new ECA model, we always need it to run.         
     //   if (origRunAssignment) {  
            //As part of the ECA reWrite, we need to know which ECA process to use and what type of PE is being updated.
            Map<Id, hed__Program_Enrollment__c> PEMap = new Map<Id, hed__Program_Enrollment__c> ();

        	List<hed__Program_Enrollment__c> PEList = GenericSOQLQueries.programEnrollmentDetails(allPEIds);
        	for (hed__Program_Enrollment__c pe:PEList) {
                PEMap.put(pe.Id, pe);
            }
            /*for (hed__Program_Enrollment__c pe:[select id, hed__Account__r.Use_Updated_ECA_Process__c, recordtype.name from hed__Program_Enrollment__c where id in :allPEIds]) {
                PEMap.put(pe.Id, pe);
            }*/
            
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.hed__Program_Enrollment__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

            /*for (hed__Program_Enrollment__c programEnrollment :newMap.values()) {
                hed__Program_Enrollment__c oldPE = oldMap.get(programEnrollment.Id);*/
                //Swapna:Changed to active list
             for (hed__Program_Enrollment__c newPERec : actlstnewMap.values()) {
                hed__Program_Enrollment__c oldPE = actlstoldMap.get(newPERec.Id); 
                hed__Program_Enrollment__c thisPEWithDetail = PEMap.get(newPERec.Id); 
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newPERec.get(str) != oldPE.get(str)) {
                            System.debug('changed field: ' + str);

                            if ((thisPEWithDetail != null) && (thisPEWithDetail.hed__Account__c != null) && thisPEWithDetail.hed__Account__r.Use_Updated_ECA_Process__c) {  //New ECA method.

                                EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
                                newFieldUpdate.programEnrollmentId = newPERec.Id;
                                newFieldUpdate.objectAndFieldName = 'hed__Program_Enrollment__c.' + str;
                                if (thisPEWithDetail.RecordType.Name == 'Student' )  newFieldUpdate.studentOrHousehold = 'Student';
                                else newFieldUpdate.studentOrHousehold = 'Household';

                                newFieldUpdate.newValue = newPERec.get(str);
                                fieldUpdateList.add(newFieldUpdate);
                             } else

                             {//JB/SM:Included defensive coding-374966
                                 if ((thisPEWithDetail != null) && (thisPEWithDetail.hed__Account__c != null) && !(thisPEWithDetail.hed__Account__r.Use_Updated_ECA_Process__c))

                                changedFields.add(str);
                        }
                        }
                    } catch (Exception e) {System.debug('Error: ' + e); logger.logException('handleAfterUpdate', e);logger.saveLogs();
                    }
                }
                if (changedFields.size() > 0)
                    changedFieldsMap.put(newPERec.Id, changedFields);
            }

            System.debug('fieldUpdateList: ' + fieldUpdateList);
    

            if (changedFieldsMap.size() > 0)  //Must be at least one PE in the old ECA model that has changed field so call the old ECA stuff.
            {
                //NES_ECACompletion.shouldRunCompletion = true;
                NES_Constants.runAssignment = true;
                NES_ECACompletion.programEnrollmentCompletion(changedFieldsMap, 'hed__Program_Enrollment__c');
                
            }


            if (fieldUpdateList.size() > 0)  //Must be at least one PE in the NEW ECA model that has a changed field so call the new ECA stuff.
                EvaluationUtils.evaluateChangedFields  (fieldUpdateList);

       // }
   
        //Start-added for #107180 User Story (Task 108660) on 2019-09-06
           // NES_ProgramEnrollmentBusinessLogic.updateAnnualStudStatus(newMap.values());
          //NES_ProgramEnrollmentBusinessLogic.updateAnnualStudStatus(actlstnewMap.values());//Swapna:Changed to active list
        //End-added for #107180 User Story (Task 108660) on 2019-09-06

        //Start: US #226654 (Krishna Peddanagammol) on 28-Aug-2020
        try{
            if(newMap.size()>0){
                List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>();
                
                ecaList = [SELECT Id, Name, Order__c, Enrollment_Component__r.Name, Enrollment_Component__r.RecordType.Name, 
                Enrollment_Component__r.Order__c, Status__c, Program_Enrollment__r.waitlistflag__c, Program_Enrollment__r.Stage__c
                FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c IN :newMap.values() 

                AND ((Program_Enrollment__r.waitlistflag__c = 'Active') OR (Program_Enrollment__r.waitlistflag__c = 'Released') OR (Program_Enrollment__r.waitlistflag__c = '')) AND Enrollment_Component__r.RecordType.Name = 'Stage'];

                System.debug('ecaList.size() = '+ecaList.size());
                List<Enrollment_Component_Affiliation__c> ecaUpdateList = new List<Enrollment_Component_Affiliation__c>();
                Double waitlistOrder = 0;
                String WaitlistStageUpdate = 'Y';
                if(ecaList.size()>0){
                    for(Enrollment_Component_Affiliation__c eca: ecaList){
                        if((eca.Program_Enrollment__r.waitlistflag__c == 'Active') && (eca.Enrollment_Component__r.RecordType.Name == 'Stage') && (eca.Enrollment_Component__r.Name == 'Waitlist')) {
                            waitlistOrder = eca.Order__c;
                            break;                     
                        }
                    }
                    if(waitlistOrder >= 3){
                        System.debug('waitlistOrder = '+waitlistOrder);
                        for(Enrollment_Component_Affiliation__c eca: ecaList){
                            if((eca.Program_Enrollment__r.waitlistflag__c == 'Active') && 
                            (eca.Enrollment_Component__r.RecordType.Name == 'Stage') && 
                            (eca.Order__c > waitlistOrder) && (eca.Status__c <> 'Not Started')){
                                eca.Status__c = 'Not Started';
                                ecaUpdateList.add(eca);
                            }
                            //Defect-473087
                            else if((eca.Program_Enrollment__r.waitlistflag__c == 'Active') && 
                            (eca.Enrollment_Component__r.RecordType.Name == 'Stage') && 
                                    (eca.Order__c < waitlistOrder) && (eca.Status__c <> 'Complete')){
                                        WaitlistStageUpdate = 'N';
                                    }
                            else if((eca.Program_Enrollment__r.waitlistflag__c == 'Active') && 
                            (eca.Enrollment_Component__r.RecordType.Name == 'Stage') && 
                            (eca.Order__c == waitlistOrder) && 
                            (eca.Program_Enrollment__r.Stage__c == 'Waitlist' || 
                            eca.Program_Enrollment__r.Stage__c == 'Confirmation of Enrollment' || 
                            eca.Program_Enrollment__r.Stage__c == 'Final Confirmation' ||
                            eca.Program_Enrollment__r.Stage__c == 'Intent To Attend') && WaitlistStageUpdate == 'Y'){
                               eca.Status__c = 'In Progress';
                               ecaUpdateList.add(eca);
                            }

                            // Code below else-if ladder logic for addressing Bug #. 280977
							else if(
                                ((eca.Program_Enrollment__r.waitlistflag__c == 'Released') || 
                                (eca.Program_Enrollment__r.waitlistflag__c == '')) &&
                                (eca.Enrollment_Component__r.RecordType.Name == 'Stage') && 
                                (eca.Order__c >= waitlistOrder) &&
                                (eca.Program_Enrollment__r.Stage__c == 'Waitlist') && WaitlistStageUpdate == 'Y'
                               ) {
                                   eca.Status__c = 'Not Applicable';
                                   ecaUpdateList.add(eca);
                            }

                        }
                        update ecaUpdateList;
                    }
                    else{
                        System.debug('waitlistOrder is less than 3 = '+waitlistOrder);
                    }                                                                     
                }             
            }            
        }
        catch(Exception ex) { 
            System.debug('Exception Thrown:' + ex.getMessage()); logger.logException('execute', ex); logger.saveLogs(); 
        }
        //End: US #226654    
    }

    public static void handleAfterInsert(List<hed__Program_Enrollment__c> newList,List<hed__Program_Enrollment__c> actList) {
      
        if (!logicSwitch) return;

        if (runCBL) {
            //NES_ProgramEnrollmentBusinessLogic.calculateELLFlag(newList, null, null);
            NES_ProgramEnrollmentBusinessLogic.calculateELLFlag(actList, null, null);//Swapna:Changed to active list
            
            //Swapna:Changed the Order of execution of LTS and HSLTS
              if (likelihoodToTransitionScore) {
                //NES_ProgramEnrollmentBusinessLogic.calculateLTS(null, newList);
                NES_ProgramEnrollmentBusinessLogic.calculateLTS(null, actList);//Swapna:Changed to active list
            }
            if (highSchoolLTSScoreSwitch) {
              //  NES_ProgramEnrollmentBusinessLogic.populatecalculateHighSchoolLTS(null, newList);
                NES_ProgramEnrollmentBusinessLogic.populatecalculateHighSchoolLTS(null, actList);//Swapna:Changed to active list
            }


            if (whyFlaggedLogicSwitch) {
              // NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newList, null);
                NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actList, null);//Swapna:Changed to active list
            }

          

        }
         
        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<string> activePEIds = new Set<string>();

        for (hed__Program_Enrollment__c programEnrollment : newList) {
            if (String.isBlank(programEnrollment.SIS_Integration_Status__c) && programEnrollment.Status__c == COMPLETE_STATUS) {

                programEnrollmentIds.add(programEnrollment.Id);
            }
            activePEIds.add(programEnrollment.Id);
        }

        if (programEnrollmentIds.size() > 0) {
            NES_IdamUtilities.pushToSIS(programEnrollmentIds);
        }

        //for (hed__Program_Enrollment__c programEnrollment : actList)
        //  activePEIds.add(programEnrollment.id);
		//Mark Membrino 2/24/20 Removed and moved logic from this trigger to NES_AddStudentCBLQueueable
        //NES_BusinessLogicUtils.updateContactStartYear(activePEIds);
        
        //Start-added for #107180 User Story (Task 108660) on 2019-09-06
       // NES_ProgramEnrollmentBusinessLogic.updateAnnualStudStatus(newList);
          //NES_ProgramEnrollmentBusinessLogic.updateAnnualStudStatus(actList);//Swapna:Changed to active list
        //End-added for #107180 User Story (Task 108660) on 2019-09-06     
    }

}