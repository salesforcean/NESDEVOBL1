public without sharing class ECA_HierarchyStatusUpdateWIP2 
{

    // Constants...
    public static final String VALID_ECA_STATUS = 'Stage, Document, Section, Flag, Form'; // Question

    public static Boolean shouldRunStatusUpdate = true;

    // class variables...
    private static ECA_HierarchyStatusUpdateWIP2 instance = null;
    private Map<Id, ecrProcessData> academicProgramData{ get; set; }
    // private static 	Map<Id, ecrProcessData> ecaData{ get; set; } // maybe introduce this later.


    private Map<Id, Id> mapPEToAcademicProgram { get; set; }
    private Map<Id, hed__Program_Enrollment__c> mapPEs { get; set; }
    private Map<Id, Enrollment_Component_Affiliation__c>  mapECAs { get; set; }
    private Map<Id, Map<Id, Id>> peToECToECAMap { get; set; }
    
    private Boolean initialized = false;
    private Boolean allNA { get; private set; }
    private Map<Id, Id> petoProcessECAId { get; set; }
    private Map<Id, Id> petoCurrentStage { get; set; }
    private Map<Id, Enrollment_Component_Affiliation__c> peLastStageMap { get; set; }
    private Map<Id, Enrollment_Component_Affiliation__c> transactionalECAs { get; set; }
    private Map<Id, Enrollment_Component_Affiliation__c> changedECAs { get; set; } //ECAs received for processing
    private Map<Id, Enrollment_Component_Affiliation__c> forUpdateECAs { get; set; } //ECAs Status__c to-be-updated 
    private List<sObject> sObjectsForUpdate { get; set; }

    // returns singleton instance...
    public static ECA_HierarchyStatusUpdateWIP2 getInstance() 
    {
        if (instance == null)
            instance = new ECA_HierarchyStatusUpdateWIP2();
        return instance;
    }

    // private constructor...
    private ECA_HierarchyStatusUpdateWIP2() 
    {
        this.allNA = true;
        this.petoProcessECAId = new Map<Id, Id>();
        this.peLastStageMap = new Map<Id, Enrollment_Component_Affiliation__c>();
        this.petoCurrentStage = new Map<Id, Id>();

        // NEW STUFF
        this.mapPEToAcademicProgram = new Map<Id, Id>();
        this.mapPEs = new Map<Id, hed__Program_Enrollment__c>();
        this.mapECAs = new Map<Id, Enrollment_Component_Affiliation__c>();
        this.peToECToECAMap = new Map<Id, Map<Id, Id>>();

        this.sObjectsForUpdate = new List<sObject>();
        this.forUpdateECAs = new Map<Id,Enrollment_Component_Affiliation__c>();
    }

    @TestVisible
    private Set<Id> peIDs 
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

    // kick-off here...
    public void initialize(Map<Id, Enrollment_Component_Affiliation__c> mapECAs)  // Transactional ECAs, EX: Trigger.newMap
    {
        
        if (!shouldRunStatusUpdate || this.initialized || mapECAs==null || mapECAs.size()==0)
            return;

        this.transactionalECAs = mapECAs;

        // build data maps/trees...
        this.initializeProgramEnrollmentData(); // gather PE/ECA related maps 
        // this.initializeAcademicProgramData(); // build AcademicProgram process trees

        this.initialized = true;
    }

    @TestVisible
    private void initializeProgramEnrollmentData() // Gather PE/ECA related maps
    {
        for (hed__Program_Enrollment__c pe : ECA_CriteriaEvaluatorHelper.getPEsWithECAs(peIDs))
        {
            mapPEs.put(pe.Id, pe); // pe map
            mapPEToAcademicProgram.put(pe.Id, pe.hed__Account__c);
            // peToECToECAMap.put(pe, null); // initialize it.
            for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
            {
                mapECAs.put(eca.Id, eca); // eca Map

                Map<Id, Id> mapECToECAtmp = peToECToECAMap.get(pe.Id);
                if (mapECToECAtmp==null)
                    mapECToECAtmp = new Map<Id, Id>();
                mapECToECAtmp.put(eca.Enrollment_Component__c, eca.Id);
                peToECToECAMap.put(pe.Id, mapECToECAtmp); // option 1
                // peToECToECAMap.get(pe).put(mapECToECAtmp); // alternate option 2

                //capture the pe->processId
                if (eca.Enrollment_Component__r.RecordType.Name == 'Process')
                    petoProcessECAId.put(eca.Program_Enrollment__c, eca.Id);

                // map PE => Stage (Status=In Progress)
                if(eca.Enrollment_Component__r.RecordType.Name == 'Stage') 
                {
                    Enrollment_Component_Affiliation__c lastStage = peLastStageMap.get(eca.Program_Enrollment__c);
                    if (lastStage.Status__c!='Not Applicable' && (lastStage==null || lastStage.Order__c < eca.Order__c))
                        peLastStageMap.put(eca.Program_Enrollment__c, eca);
                
                    if(eca.Status__c == 'In Progress') 
                    {
                        petoCurrentStage.put(eca.Program_Enrollment__c, eca.Id);
                    }
                }
            }
        }
    }

    @Testvisible
    private void initializeAcademicProgramData() // Build AcademicProgra/Process Tree
    {   
        if (mapPEToAcademicProgram.values().size()==0)
            // throw an exception ? 
            return;
        
        ecrTreeGeneratorWIP apTreeGenerator = new ecrTreeGeneratorWIP(mapPEToAcademicProgram.values());
        apTreeGenerator.generate();
        this.academicProgramData = apTreeGenerator.getData();

    }

    private Map<Id, Opportunity> mapPEToOppty
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