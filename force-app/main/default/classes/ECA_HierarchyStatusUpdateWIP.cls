public class ECA_HierarchyStatusUpdateWIP
{   
    // APIs...
    public static Boolean shouldRunStatusUpdate = true;

    // Constants...
    private static final String VALID_ECA_STATUS = 'Stage, Document, Section, Flag, Form'; // Question
    private static Boolean initialized = false;
    private static boolean allNA { get; set; }
    private static Map<Id, Enrollment_Component_Affiliation__c> transactionalECAs { get; set; }
    private static Map<Id, Enrollment_Component_Affiliation__c> toProcessECAs { get; set; } //ECAs received for processing
    private static Map<Id, Enrollment_Component_Affiliation__c> forUpdateECAs { get; set; } //ECAs Status__c to-be-updated 
    private static List<sObject> forUpdateSobjects { get; private set; }
    private static Map<Id, ProgramEnrollmentDataClass> peDataMap { get; private set; }
    private static Map<Id, Enrollment_Component_Affiliation__c>  queriedECAs { get; private set; }
    private static Map<Id, Id> mapPEToAcademicProgram { get; private set; }

    public static Boolean isECAPartOfCurrentStage( Enrollment_Component_Affiliation__c eca )
    {
        return (peDataMap.get(eca.Program_Enrollment__c).currentStageChildECs.contains(eca.Enrollment_Component__c));
    }
    
    private static Set<Id> peIDs 
    {   
        get {
            if (peIDs==null && transactionalECAs!=null) {
                peIDs = new Set<Id>();
                for (Enrollment_Component_Affiliation__c eca : transactionalECAs.values()) 
                    peIDs.add(eca.Program_Enrollment__c);
            }
            return peIDs;
        }

        set;
    }

    private static void setDefaults() // initialize variables...
    {
        allNA = true;
        forUpdateECAs = new Map<Id,Enrollment_Component_Affiliation__c>();
        forUpdateSobjects = new List<sObject>();
        queriedECAs = new Map<Id, Enrollment_Component_Affiliation__c>();
        peDataMap = new Map<Id, ProgramEnrollmentDataClass>();
        mapPEToAcademicProgram = new Map<Id, Id>();
    }

    // kick-off here...
    public static void initialize(Map<Id, Enrollment_Component_Affiliation__c> mapTranECAs)  // Transactional ECAs, EX: Trigger.newMap
    {
        
        if (!shouldRunStatusUpdate || initialized || mapTranECAs==null || mapTranECAs.size()==0)
            return;

        // init variables...
        setDefaults();
        transactionalECAs = mapTranECAs;

        // build data maps/trees...
        initializeProgramEnrollmentData(); // gather PE/ECA related maps 
        initializeAcademicProgramData(); // build AcademicProgram process trees

        initialized = true;
    }

    // * kick-off here...
    public static void run(Map<Id, Enrollment_Component_Affiliation__c> ecas) 
    {
        if (ecas==null || !shouldRunStatusUpdate)
            return;

        if (!initialized) // if not run earlier, then only initialize data...
            initialize(ecas); // set-all-the-data-that-we-need

        // default variables...
        toProcessECAs = ecas;
        allNA = true;
        forUpdateECAs = new Map<Id,Enrollment_Component_Affiliation__c>();

        /* We now have maps describing all of the child and parent ECAs for our students. We can begin evaluating what impact our updated ECAs had on those */        
        for(Enrollment_Component_Affiliation__c toProcessECA : toProcessECAs.values())
        {
            if(VALID_ECA_STATUS.containsIgnoreCase(queriedECAs.get(toProcessECA.Id).enrollment_component__r.recordtype.name))
                updateParentStatus(toProcessECA);
    	}
    	
    	//Update the ECAs if there are any changed statuses
        if(forUpdateECAs.size()>0)
    		update forUpdateECAs.values();

        if(forUpdateSobjects.size()>0)
            update forUpdateSobjects;
    }
    
    public static String getChildrenStatus(Enrollment_Component_Affiliation__c parentECA, Boolean resetFlags)
    {
        Boolean allComplete = true;
        String updatedStatus = '';

        if (resetFlags)
            allNA = true;
        
        ProgramEnrollmentDataClass peData = peDataMap.get(parentECA.Program_Enrollment__c);
        ecrProcessData acaPgmData = peData.academicProgramData;
        list<Id> childrenECs = acaPgmData.ecParentToChildrenMap.get(parentECA.Enrollment_Component__c);

        if (childrenECs==null || childrenECs.size()==0)
            return null;
        
        //Evaluate the children's status
        for(Id childEC : childrenECs)
        {
            Enrollment_Component_Affiliation__c childECA = queriedECAs.get(peData.ecToECAMap.get(childEC)); // given EC.Id fetch PE.ECA
            string childStatus = ((toProcessECAs!=null && toProcessECAs.get(childECA.Id)!=null) ? toProcessECAs.get(childECA.Id).Status__c : childECA.Status__c);

            //Check that all required child ECAs are complete
            if( childECA.enrollment_component__r.is_Required__c == true && 
                childStatus != 'Complete' && 
                childStatus != 'Deferred' && 
                childStatus != 'Exempt' && 
                childStatus != 'Not Applicable')
            {
                allComplete = false;
            }
            
            if(childStatus != 'Not Started' && childStatus != 'Not Applicable') //Check that all ECAs regardless of whether they are required or not are not started
            {
                allNA = false; 
            } 
            // else if (childStatus == 'In Progress') {
            //     allNA = false; 
            //     allComplete = false;
            // }
        }
        
        //Determine the correct parent status   
        if(allComplete)
        {
            updatedStatus = 'Complete';
        } 
        else if(allNA)
        {
            updatedStatus = 'Not Started';
        } 
        else
        {
            updatedStatus = 'In Progress';
        }
            
        return updatedStatus;
    }

    
    /**
     * 
     * INTERNAL CLASS COMPONENTS
     * 
     */
    
    @TestVisible
    private static void initializeProgramEnrollmentData() // Gather PE/ECA related maps
    {
        ProgramEnrollmentDataClass peData; 
        for (hed__Program_Enrollment__c pe : ECA_CriteriaEvaluatorHelper.getPEsWithECAs(peIDs))
        {

            mapPEToAcademicProgram.put(pe.Id, pe.hed__Account__c); // pe -> academicProgram map

            peData = new ProgramEnrollmentDataClass();
            // peDataMap.put(pe.Id, peData);

            peData.peRecord = pe;
            peData.academicProgram = pe.hed__Account__c;
            for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
            {
                queriedECAs.put(eca.Id, eca);
                peData.ecToECAMap.put(eca.Enrollment_Component__c, eca.Id);

                // capture PE.Last Stage & In-Progress Stage
                if(eca.Enrollment_Component__r.RecordType.Name == 'Stage') 
                {
                    if (eca.Status__c != 'Not Applicable' && (peData.lastStageECA==null || peData.lastStageECA.Order__c < eca.Order__c))
                        peData.lastStageECA = eca;
                
                    if(eca.Status__c == 'In Progress') 
                        peData.currentStageECA = eca;
                }

                // * @todo: DO WE NEED THIS ? 
                //capture the pe->processId 
                // if (eca.Enrollment_Component__r.RecordType.Name == 'Process')
                //     petoProcessECAId.put(eca.Program_Enrollment__c, eca.Id);
            }

            peDataMap.put(pe.Id, peData);
            // System.assertEquals('expected', JSON.serialize(peData));
        }
    }

    @Testvisible
    private static void initializeAcademicProgramData() // Build AcademicProgra/Process Tree
    {   
        if (mapPEToAcademicProgram.values().size()==0) // throw an exception ? 
            return;
        
        ecrTreeGeneratorWIP apTreeGenerator = new ecrTreeGeneratorWIP(mapPEToAcademicProgram.values());
        apTreeGenerator.generate();
        Map<Id, ecrProcessData> academicPgmDataMap = apTreeGenerator.getData();
        // System.assertEquals('expected', JSON.serialize(academicPgmDataMap));
        
        for (Id peId : mapPEToAcademicProgram.keySet())
        {
            ProgramEnrollmentDataClass peData = peDataMap.get(peId);
            // peDataMap.get(peId).academicProgramData = academicPgmDataMap.get(mapPEToAcademicProgram.get(peId));
            System.debug('peDataWIP>>>' + JSON.serialize(peData.academicProgramData));
            peData.academicProgramData = academicPgmDataMap.get(mapPEToAcademicProgram.get(peId));
            System.debug('peDataWIP.root>>>' + JSON.serialize(peData.academicProgramData.root));

            // get the list of all children/grand-children under the currentStage ECA
            ecNode currentStageNode = ecrTreeGeneratorWIP.search(peDataMap.get(peId).academicProgramData.root, peDataMap.get(peId).currentStageECA.Enrollment_Component__c);
            System.debug('currentStgNchildren>>>' + ecrTreeGeneratorWIP.getNodeSubTreeAsList(currentStageNode));
            peDataMap.get(peId).currentStageChildECs = ecrTreeGeneratorWIP.getNodeSubTreeAsList(currentStageNode);
        }
    }

    private static void updateParentStatus(Enrollment_Component_Affiliation__c childECA)
    {	
        ProgramEnrollmentDataClass peData = peDataMap.get(childECA.Program_Enrollment__c);
        ecrProcessData acaPgmData = peData.academicProgramData;
        List<Id> parentECs = acaPgmData.ecChildToParentsMap.get(childECA.Enrollment_Component__c); //Grab the parent(s) of the updated record
        // System.assertEquals('peAcademicPgrmMap>>>', JSON.serialize(mapPEToAcademicProgram.values())); // test only
        // System.assertEquals('peData>>>', JSON.serialize(peData)); // test only
        // System.assertEquals('acaPgmData>>>', JSON.serialize(acaPgmData)); // test only
        
        // boolean allNA = true;
        Boolean allComplete = true;
        for(Id ecId : parentECs)
        {
            Id ecaId = peData.ecToECAMap.get(ecId);
            Enrollment_Component_Affiliation__c parent = queriedECAs.get(ecaId);
            Enrollment_Component_Affiliation__c inFlightParent = toProcessECAs.get(ecaId);

            String originalStatus = (inFlightParent!=null ? inFlightParent.Status__c : parent.status__c);
            String updatedStatus = getChildrenStatus(parent, false);
			
            if(updatedStatus!=null && updatedStatus != originalStatus) // parent.status__c)
            {
                parent.status__c = updatedStatus; //update the parent with the new status
                parent.Date_Completed__c = ( parent.status__c == 'Complete' ? System.today() : null );
                
                forUpdateECAs.put(parent.id, parent); //add the updated eca to our update list

                if(parent.enrollment_component__r.recordtype.name != 'Stage')
                {
                    updateParentStatus(parent); //recurse the function to update the next level parent as needed
				}
                else //Stages need special handling to move the student forward or backwards as needed
                {
                    // if (parent.Id != petoCurrentStage.get(parent.Program_Enrollment__c))
                    if (parent.Id != peData.currentStageECA.Id) // Don't Process Stage if its not current Stage.
                    {
                        parent.status__c = originalStatus;
                        parent.Date_Completed__c = null;
                        continue;
                    }
					
					//Determine the direction of the stage movement
                    Boolean isForward = ( (updatedStatus == 'In Progress' || updatedStatus == 'Not Started') ? false : true );
                    // boolean isForward = true;
					// if(updatedStatus == 'In Progress' || updatedStatus == 'Not Started')
                    //     isForward = false;
                        
                    Integer currentOrder = (Integer) parent.Order__c;
					Integer nextOrder = (isForward?currentOrder+1: currentOrder-1);
					
					// Get the parent process
					// list<Enrollment_Component_Affiliation__c> processParent = parentECAs.get(parent.ID);
					// System.debug('processParent>>' + JSON.serialize(processParent));
                    
                    // Get the other stages
                    // list<Enrollment_Component_Affiliation__c> stageChildren = childECAs.get(processParent[0].ID);
                    List<Id> stageECs =  acaPgmData.ecParentToChildrenMap.get(acaPgmData.processId);
                    // System.debug('stageChildren>>' + JSON.serialize(stageChildren));

                    String notApplicableStatuses = 'Not Applicable';
                    // Boolean isLastStage = (parent.Id == peLastStageMap.get(parent.Program_Enrollment__c).Id ? true : false); // is current stage the last Stage?
                    Boolean isLastStage = (parent.Id == peData.lastStageECA.Id ? true : false); // is current stage the last Stage?

                    List<Enrollment_Component_Affiliation__c> stageECAs = new List<Enrollment_Component_Affiliation__c>(); // collecting stages
                    // Update Next/Previous Stage
                    for(Id stageEC : stageECs)
                    {
                        Enrollment_Component_Affiliation__c stageECA = queriedECAs.get(peData.ecToECAMap.get(stageEC)); // given EC.Id fetch PE.ECA
                        stageECAs.add(stageECA);
                        if(isForward) //Find the next stage
                        {
                            if (isLastStage)
                                break;
                            if(stageECA.order__c == nextOrder)
                            {
                                if (notApplicableStatuses.containsIgnoreCase(stageECA.status__c)) {
                                    nextOrder++;
                                    continue;
                                }

                                stageECA.status__c = 'In Progress';
                                //stageECA.runRelatedUpdates__c = false;
                                forUpdateECAs.put(stageECA.id, stageECA);
                                break;
                            }
                        }
                        else
                        {
                            if(stageECA.Order__c > currentOrder && !notApplicableStatuses.containsIgnoreCase(stageECA.status__c))
                            {
                                stageECA.status__c = 'Not Started';
                                //stageECA.runRelatedUpdates__c = false;
                                forUpdateECAs.put(stageECA.id, stageECA);
                            }
                        }
                    }

                    String COMPLETE_STATUS = 'Complete';
                    Boolean allStagesComplete = isForward; // currentStage.Status equals 'Complete'
                    if (isForward && isLastStage)
                    {
                        
                        // ensure all other Stages are complete.
                        for(Enrollment_Component_Affiliation__c stageECA : stageECAs)
                        {
                            if (notApplicableStatuses.containsIgnoreCase(stageECA.Status__c)) // skip Not Applicable Stages
                                continue;

                            // stageLastOrder = ( stage.Order__c> stageLastOrder ? stage.Order__c : stageLastOrder );
                            if( stageECA.Id != parent.Id && !COMPLETE_STATUS.equalsIgnoreCase(stageECA.Status__c)) 
                            {
                                allStagesComplete=false;
                                // System.debug('STAGE NOT COMPLETE:' + JSON.serialize(stageECA));
                                break;
                            }
                        }

                        if (allStagesComplete)
                        {
                            Enrollment_Component_Affiliation__c processECA = queriedECAs.get(peData.ecToECAMap.get(acaPgmData.processId));
                            if (processECA!=null)
                            {
                                processECA.Status__c = 'Complete';
                                processECA.Date_Completed__c = System.today();
                                forUpdateECAs.put(processECA.id, processECA);

                                hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(
                                    id=parent.Program_Enrollment__c,
                                    Status__c = 'Complete'
                                );
                                forUpdateSobjects.add(pe);

                                
                                Opportunity studOppty = mapPEToOppty.get(parent.Program_Enrollment__c);
                                if (studOppty != null) 
                                {
                                    studOppty.StageName = 'Closed Won';
                                    forUpdateSobjects.add( new Opportunity(
                                        Id = studOppty.Id,
                                        StageName='Closed Won'
                                    ));
                                }
                            }
                        }
                    }
				}
			}
		}
    }

    @TestVisible
    private static Map<Id, Opportunity> mapPEToOppty
    {
        get
        {
            if (mapPEToOppty==null) 
            {
                mapPEToOppty = new Map<Id, Opportunity>();
                for (Opportunity opp : ECA_CriteriaEvaluatorHelper.getOpptyByStudPEIds(peIDs))
                {
                    mapPEToOppty.put(opp.Program_Enrollment__c, opp);
                }
            }
            return mapPEToOppty;
        } 
        
        set;
    }

    public class ECAEvaluationException extends Exception {}
}

/**
    In-progress Stage: 
    PE -> Stage Id
    Stage Id -> List of ECs
    stage its children > their children > their Children > their Children

    ecrTreeImport

                Process
                /	| 		\
            Stg1	Stg2	Stg3
        /	|		|		|		\
    form1	form2	form1	form1	form2
    |		|		|		|		|
    sec1	sec1	sec1	sec1	sec1
    sec2	sec2	sec2	sec2	sec2
    sec3	sec3

    Start from Stage, walk list of all children for the stage: BFS

    find a specific child in the tree ? DFS then track the path 

    I need a link of parent -> children
    child to parent
    stage -> children

    Referential Data: 
        Process => {
            stage => List<all its children>
            parent -> List<Child>
            child -> List<Parent>
        }
        
    Transactional Data: 
        Process => List<PEs>
        PE => Process
        PE => <ECs => ECAs>
        ECA.Id => ECAs

    // all ECAs by PE-ID
    // generate the PE-> ProcessID Map

    // Map<PE.ID, Map<EC.Id => ECA.ID>
    // Map<ECA.ID, ECA>

    // Map<Id, List<Id> ecChildToParentsMap = new Map<Id, List<Id>(); // replaces parentECs & parentECAs
    // Map<Id, List<Id>> ecParentToChildrenMap = new Map<Id, List<Id>>(); // replaces parentECs & parentECAs
    // Map<Id, List<Id>> stageToChildrenECMap = new Map<Id, List<Id>>(); // whitelist CurrentStage only
*/