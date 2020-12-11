/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-26-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-24-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 * 
 * Usage: 
    String processId = 'a293C000000JV4CQAW'; // AcademicProgram: NES 2020-2021 => 0013C00000MX0PLQA1
    AcademicProgramMigrationToNewECAModel ecaDataMigrationTree = new AcademicProgramMigrationToNewECAModel(processId);
    ecaDataMigrationTree.run();
    System.debug('ecaDataMigrationTree.objectsToUpdate>>>' + JSON.serialize(ecaDataMigrationTree.objectsToUpdate));
    System.debug('>>>>config>>>>' + JSON.serialize(ecaDataMigrationTree.config));

* Usage :: FETCH ONLY ALL EC/ECC/Criteria IDs for given Process:
    String processId = 'a293C000000JV4CQAW'; // AcademicProgram: NES 2020-2021 => 0013C00000MX0PLQA1
    AcademicProgramMigrationToNewECAModel ecaDataMigrationTree = new AcademicProgramMigrationToNewECAModel(processId);
    ecaDataMigrationTree.generateTree();
    ecaDataMigrationTree.remapECs();
    
    // get EC IDs...
    // System.debug('>>>>config.ecIds>>>>size>>>' + ecaDataMigrationTree.config.ecMap.size() + '>>>Ids>>>' + JSON.serialize(ecaDataMigrationTree.config.ecMap.keySet()));

    // get ECC IDs...
    // System.debug('>>>>config.eccIds>>>>size>>>' + ecaDataMigrationTree.config.eccToCriteriaMap.size() + '>>>Ids>>>' + JSON.serialize(ecaDataMigrationTree.config.eccToCriteriaMap.keySet()));
    
    // get Criteria IDs...
    Set<Id> criteriaIDs = new Set<Id>(ecaDataMigrationTree.config.eccToCriteriaMap.values());
    System.debug('>>>>config.criteriaIds>>>>size>>>' + criteriaIDs.size() + '>>>Ids>>>' + JSON.serialize(criteriaIDs));

    // get flattened CriteriaRefinement values by ECC
    // ecaDataMigrationTree.remapECCs();
    // System.debug('>>>>config.eccToFlattenedCriteriaRefinementMap>>>>size>>>' + ecaDataMigrationTree.config.eccToFlattenedCriteriaRefinementMap.size() + '>>>Details>>>' + JSON.serialize(ecaDataMigrationTree.config.eccToFlattenedCriteriaRefinementMap));    

    // move CriteriaRefinement to Criteria
    ecaDataMigrationTree.moveRefinementValueToCriterias();
    System.debug('>>>>config.criteriasToUpdate>>>>size>>>' + ecaDataMigrationTree.criteriasToUpdate.size() + '>>>Details>>>' + JSON.serialize(ecaDataMigrationTree.criteriasToUpdate));    
    // update ecaDataMigrationTree.criteriasToUpdate;
**/
public class AcademicProgramMigrationToNewECAModel
{
    private final String EC_RECORD_TYPE_WHITE_LIST_TXT = 'Process,Stage,Form,Section,Document,Flag,Message'; // @Q: Can we skip: Flag & Message ECs ? 
    private final List<String> EC_RECORD_TYPE_WHITE_LIST = EC_RECORD_TYPE_WHITE_LIST_TXT.split(',');
    private Id rootID;
    private Enrollment_Component__c rootRec;

    public ecData config {get; private set;}
    public ecNode root {get; private set;}
    public List<SObject> objectsToUpdate {get; private set;}
    public List<Criteria__c> criteriasToUpdate {get; private set;}
    

    // constructor
    public AcademicProgramMigrationToNewECAModel(String rootId)
    {
        try 
        {
            this.rootID = Id.valueOf(rootID);
            this.rootRec = ecrTreeUtils.getECsByID(new List<Id>{rootID})[0];
            if (this.rootRec!=null) 
            {
                this.objectsToUpdate = new List<SObject>();
                this.criteriasToUpdate = new List<Criteria__c>();
                this.config = new ecData(this.rootID); // xtra
                this.root = new ecNode(this.rootRec, this.config.steps); // xtra
            }
        } 
        catch (Exception ex) 
        {
            throw new illegalArgumentECTreeGeneratorException('invalid Enrollment_Component__c rootID:' + rootID  + '; Exception:' + ex.getMessage());
        }
    }

    // run
    public void run() 
    {
        this.generateTree();
        this.remapECs();
        // this.remapECCs();
        this.moveRefinementValueToCriterias();
    }

    // remapECCs
    public void moveRefinementValueToCriterias()
    {
        if (this.config == null || this.config.eccToCriteriaMap.size()==0) {return;}
        
        ecData config = this.config;

        // Now copy over questionGroups / schoolYears over to ECCs.
        String SY_TXT = 'school_year__r.external_id__c';
        String CG_TXT = 'question_group__r.external_id__c';
        String MostRecent_TXT = 'most_recent__c';

        // loop over eccs and run thru refinements
        for (Criteria__c c : getCriteriaWithRefinementsByIds(config.eccToCriteriaMap.values()))
        {
            Boolean shouldUpdateRec = false;
            Criteria__c criteriaToUpdate = new Criteria__c(Id=c.Id);
            for (Criteria_Refinement__c cr : c.Criteria_Refinements__r)
            {
                if (!cr.Refinement_Type__c.equalsIgnoreCase('Left side'))
                {
                    System.debug('NOT LEFT SIDE REFINEMENT, ID:' + cr.Id);
                    continue;
                }

                if (SY_TXT.equalsIgnoreCase(cr.Refinement_Field_Left__c))
                {
                    criteriaToUpdate.School_Year__c = cr.Refinement_Value__c;
                    shouldUpdateRec = true;
                } 
                else if (CG_TXT.equalsIgnoreCase(cr.Refinement_Field_Left__c))
                {
                    criteriaToUpdate.Question_Group__c = cr.Refinement_Value__c; 
                    shouldUpdateRec = true;
                }
                else if (MostRecent_TXT.equalsIgnoreCase(cr.Refinement_Field_Left__c))
                {
                    criteriaToUpdate.Most_Recent__c = Boolean.valueOf(cr.Refinement_Value__c);
                    shouldUpdateRec = true;
                }
            }
            
            if (shouldUpdateRec)
            {   
                this.criteriasToUpdate.add(
                    criteriaToUpdate
                );
            }
        }
    }

    // remapECCs
    public void remapECCs()
    {
        if (this.config == null || this.config.eccToCriteriaMap.size()==0) {return;}
        
        ecData config = this.config;

        config.criteriaMap = new Map<Id, Criteria__c>(getCriteriaWithRefinementsByIds(config.eccToCriteriaMap.values()));
        // config.criteriaRefinementMap = getCriteriaByCriteriaIds(config.eccToCriteriaMap.values());
        // Map<Id, Map<String, String>> eccToRefinementsMap = new Map<Id, Map<String, String>>();

        // flattened CriteriaRefinement mapped to ECC
        // Map<Id, String> eccToFlattenedCriteriaRefinementMap = new Map<Id, String>();

        // loop over eccs and run thru refinements
        for (Id eccId : config.eccToCriteriaMap.keySet())
        {
            String flattenedCriteriaRefinement = ''; // flattened CriteriaRefinement mapped to ECC
            Enrollment_Component_Criteria__c ecc = config.eccMap.get(eccId);
            Criteria__c c = config.criteriaMap.get(config.eccToCriteriaMap.get(eccId)); // (ecc.Criteria__c);
            for (Criteria_Refinement__c cr : c.Criteria_Refinements__r)
            {
                flattenedCriteriaRefinement += cr.Refinement_Field_Left__c + '=' + cr.Refinement_Value__c + '::';

                if (!cr.Refinement_Type__c.equalsIgnoreCase('Left side'))
                {
                    System.debug('NOT LEFT SIDE REFINEMENT, ID:' + cr.Id);
                    continue;
                }

                Map<String, String> refinements = config.eccToRefinementsMap.get(eccId);
                if (refinements==null)
                    refinements = new Map<String, String>();
                refinements.put((cr.Refinement_Field_Left__c).toLowerCase(), cr.Refinement_Value__c);
                config.eccToRefinementsMap.put(eccId, refinements);
            }
            
            if (String.isNotBlank(flattenedCriteriaRefinement)) // flattened CriteriaRefinement mapped to ECC
                config.eccToFlattenedCriteriaRefinementMap.put(eccId, flattenedCriteriaRefinement);
        }

        // pretty print eccs w/criteriaRefinements
        List<Enrollment_Component_Criteria__c> ppECCs = new List<Enrollment_Component_Criteria__c>();

        // Now copy over questionGroups / schoolYears over to ECCs.
        String SY_SMALL_TXT = 'school_year__r.external_id__c';
        String CG_SMALL_TXT = 'question_group__r.external_id__c';
        for (Id eccId : config.eccToCriteriaMap.keySet())
        {
            Enrollment_Component_Criteria__c ecc = config.eccMap.get(eccId);
            Map<String, String> refinements = config.eccToRefinementsMap.get(eccId);
            Boolean shouldUpdateRec = false;

            // prettyPring ECCs...
            Enrollment_Component_Criteria__c ppECC = new Enrollment_Component_Criteria__c();
            ppECC.Id = ecc.Id;
            ppECC.External_Id__c = config.eccToFlattenedCriteriaRefinementMap.get(ecc.Id);
            ppECC.Criteria_Type__c = ecc.Criteria_Type__c;
            ppECC.Criteria_Number__c = ecc.Criteria_Number__c;
            ppECC.Most_Recent__c = ecc.Most_Recent__c;
            ppECC.Criteria__c = ecc.Criteria__c;
            ppECC.Student_or_Household__c = ecc.Student_or_Household__c;
            ppECC.Question_Group__c = ecc.Question_Group__c;
            ppECC.School_Year__c = ecc.School_Year__c;
            ppECC.Enrollment_Component__c = ecc.Enrollment_Component__c;
            // ppECC.Enrollment_Component__r.Completion_Logic__c = ecc.Enrollment_Component__r.Completion_Logic__c;
            // ppECC.Enrollment_Component__r.Assignment_Logic__c = ecc.Enrollment_Component__r.Assignment_Logic__c;
            ppECCs.add(ppECC);
            // prettyPring ECCs... END...

            if (refinements!=null && refinements.size()>0)
            {
                if (refinements.get(CG_SMALL_TXT)!=null) 
                {
                    ecc.Question_Group__c = refinements.get(CG_SMALL_TXT);
                    shouldUpdateRec = true;
                }

                if (refinements.get(SY_SMALL_TXT)!=null) 
                {
                    ecc.School_Year__c = refinements.get(SY_SMALL_TXT);
                    shouldUpdateRec = true;
                }

                if (shouldUpdateRec)
                {
                    this.objectsToUpdate.add(
                        new Enrollment_Component_Criteria__c
                        (
                            Id=ecc.Id, 
                            School_Year__c=ecc.School_Year__c,
                            Question_Group__c=ecc.Question_Group__c
                        )
                    );
                }
                
            }   
        }
        // PP ECCs with Flattened Criteria Refinements.
        System.debug('>>>eccsWithFlatRefinements' + ppECCs.size() + '>>>Details>>>' + JSON.serialize(ppECCs));
    }

    // remapECs
    public void remapECs()
    {
        if (this.config == null || this.config.ecMap.size()==0) {return;}
        
        ecData config = this.config;
        for (Enrollment_Component__c ec : getECWithECCsCGsByIds(config.ecMap.keySet()))
        {
            config.ecMap.put(ec.Id, ec);

            // map ec to cg
            for (Criteria_Group__c cg : ec.Criteria_Groups__r)
            {
                Map<String, String> cgNumberToLogicMap = config.ecToGroupNumberToLogicMap.get(ec.Id);
                if (cgNumberToLogicMap==null)
                    cgNumberToLogicMap = new Map<String, String>();
                cgNumberToLogicMap.put(String.valueOf(cg.Group_Number__c), cg.Group_Logic__c);
                config.ecToGroupNumberToLogicMap.put(ec.Id, cgNumberToLogicMap);
            }

            // map ec to ecc && ecc to criteria
            for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r)
            {
                config.eccToECidMap.put(ecc.Id, ec.Id);
                config.eccMap.put(ecc.Id, ecc);
                config.eccToCriteriaMap.put(ecc.Id, ecc.Criteria__c);
            }
        }

        // Now remap the EC.Assignment_Logic__c = EC.CG.Logic based on CG.groupNumber
        for (Id ecId : config.ecToGroupNumberToLogicMap.keySet())
        {
            Enrollment_Component__c ec = config.ecMap.get(ecId);
            Map<String, String> cgNumberToLogicMap = config.ecToGroupNumberToLogicMap.get(ecId);
            String cgAssignmentLogic = (String.isNotBlank(ec.Assignment_Logic__c) ? cgNumberToLogicMap.get(ec.Assignment_Logic__c) : null);
            String cgCompletionLogic = (String.isNotBlank(ec.Completion_Logic__c) ? cgNumberToLogicMap.get(ec.Completion_Logic__c) : null);
            Boolean shouldUpdateEC = false;
            
            if (
                cgAssignmentLogic != null && 
                !cgAssignmentLogic.equalsIgnoreCase(ec.Assignment_Logic__c)
            ) {
                ec.Assignment_Logic__c = cgAssignmentLogic;
                shouldUpdateEC = true;
            }

            if (
                cgCompletionLogic != null && 
                !cgCompletionLogic.equalsIgnoreCase(ec.Completion_Logic__c)
            ) {
                ec.Completion_Logic__c = cgCompletionLogic;
                shouldUpdateEC = true;
            }
            
            if (shouldUpdateEC)
            {
                this.objectsToUpdate.add(
                    new Enrollment_Component__c
                    (
                        Id=ec.Id, 
                        Assignment_Logic__c=ec.Assignment_Logic__c,
                        Completion_Logic__c=ec.Completion_Logic__c
                    )
                );
            }
        }
    }

    /**
     * 
     * Using BFS w/iteration to build the tree
     */
    public void generateTree() 
    {
        if (this.root==null) {return;}
        
        Map<Id, ecNode> ecNodeMapParent = new Map<Id, ecNode>{this.root.nodeId => this.root}; 
        ecData config = this.config;
        config.ecTypes.add(this.root.kind);
        // config.countECs += ecNodeMapParent.size();

        // addProcessECRec to ecMap
        config.ecMap.put(rootRec.Id, rootRec);
        
        // overloading a 'queue for list of strings' to handle 'any' type of List, in this case a list of deserialized map of ecNodes.
        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(ecNodeMapParent); 

        while (!q.isEmpty()) {
            
            ecNodeMapParent = q.dequeue();

            // gathering stats...
            config.countECs += ecNodeMapParent.size();
            config.steps++;

            // System.debug('::step>>>' + config.steps + '>>>ecNodeMapParent>>>' + JSON.serialize(ecNodeMapParent));

            // tmpMap, to gather the children
            Map<Id, ecNode> ecNodeMapChildrenTmp = new Map<Id, ecNode>();

            for (Enrollment_Component_Relationship__c ecr : ecrTreeUtils.queryECRs(ecNodeMapParent.keySet()))
            {
                // build ec -> ecRec Map
                config.ecMap.put(ecr.Child_Enrollment_Component__c, null);
                
                ecNode child = new ecNode(ecr, config.steps); // create a child Node
                config.ecTypes.add(child.kind); // collecting stats => ecTypes
                ecNodeMapParent.get(ecr.Parent_Enrollment_Component__c).addChildren(child);// add child to parentNode
                ecNodeMapChildrenTmp.put(ecr.Child_Enrollment_Component__c, child); // tmp map to hold child ec -> ecNode
            }

            if (ecNodeMapChildrenTmp.size()>0) {
                q.enqueue(ecNodeMapChildrenTmp);
            }

        }

        // System.debug('Queue Ended::FinalStepCount>>>' + config.steps + '>>>ecNodeMapParent>>>' + JSON.serialize(this.root));
        // System.debug('::config>>>' + JSON.serialize(this.config));

    }

    // query the ecWithECCsCGs rec.
    public static List<Enrollment_Component__c> getECWithECCsCGsByIds(Set<Id> ecIDs) {
        return 
            [
                SELECT  Id, Name, Assignment_Logic__c, RecordTypeId, RecordType.Name, Completion_Logic__c, Is_Required__c, External_Id__c,
                        (  
                            SELECT  Id, Criteria_Type__c, Criteria_Number__c, Criteria__r.Criteria_Field__c,
                                    Criteria__c, Student_or_Household__c, Question_Group__c, School_Year__c,
                                    Criteria__r.Comparison_Field__c, Criteria__r.Operator__c, Most_Recent__c,
                                    Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c,
                                    Enrollment_Component__c, Enrollment_Component__r.Completion_Logic__c,
                                    Enrollment_Component__r.Assignment_Logic__c
                            FROM    Enrollment_Component_Criteria__r
                        ),
                        (
                            SELECT  Id, Group_Logic__c, Group_Number__c FROM Criteria_Groups__r
                        )
                FROM    Enrollment_Component__c 
                WHERE   Id =: ecIDs
            ];
    }

    public static List<Criteria_Refinement__c> getCriteriaRefinementsByCriteriaIds(List<Id> criteriaIds)
    {
        return 
            [
                SELECT  Id, Name, Criteria__c, Criteria__r.Criteria_Field__c, Criteria__r.Comparison_Field__c, 
                        Criteria__r.Operator__c, Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c,
                        External_Id__c, Operator__c, Refinement_Field_Left__c, Refinement_Field_Right__c, Refinement_Type__c, Refinement_Value__c
                FROM    Criteria_Refinement__c
                WHERE   Criteria__c = :criteriaIds
            ];
    }

    public static List<Criteria__c> getCriteriaWithRefinementsByIds(List<Id> criteriaIds)
    {
        return 
            [
                SELECT  Id, Name, Criteria_Field__c, Comparison_Field__c, Operator__c, Comparison_Data_Type__c, Comparison_Value__c, Most_Recent__c, Question_Group__c, School_Year__c,
                (
                    SELECT  Criteria__c, Id, Name, External_Id__c, Operator__c, Refinement_Field_Left__c, 
                            Refinement_Field_Right__c, Refinement_Type__c, Refinement_Value__c
                    FROM    Criteria_Refinements__r
                    ORDER BY Criteria__c
                )
                FROM    Criteria__c
                WHERE   Id = :criteriaIds
            ];
    }
    

    // inner data class...
    public class ecData 
    {
        // ecId -> ecRec
        // ecId -> order -> logic (QG)
        // eccId -> ecId
        // ecc.Id -> eccRec
        // ecc.Id -> Criteria.Id
        // criteriaId -> CriteriaRec w/CriteriaRefinement
        
        public Set<String> ecTypes;
        public Integer countECs;
        public Integer steps; 
        
        public Id processId;
        public Map<Id, Enrollment_Component__c> ecMap;
        public Map<Id, Map<String, String>> ecToGroupNumberToLogicMap;
        public Map<Id, Id> eccToECidMap; // its needed ? 
        public Map<Id, Enrollment_Component_Criteria__c> eccMap;
        public Map<Id, Id> eccToCriteriaMap;
        public Map<Id, Criteria__c> criteriaMap;
        public Map<Id, Map<String, String>> eccToRefinementsMap;
        public Map<Id, String> eccToFlattenedCriteriaRefinementMap;
        // public Map<Id, List<Id>> criteriaToRefinementsMap;
        // public Map<Id, Criteria_Refinement__c> criteriaRefinementMap;

        // constructor 1
        public ecData() 
        {
            this.countECs                   = 0;
            this.steps                      = 0;
            this.ecMap                      = new Map<Id, Enrollment_Component__c>();
            this.ecTypes                    = new Set<String>();
            this.ecToGroupNumberToLogicMap  = new Map<Id, Map<String, String>>();
            this.eccToECidMap               = new Map<Id, Id>(); // its needed ? 
            this.eccMap                     = new Map<Id, Enrollment_Component_Criteria__c>();
            this.eccToCriteriaMap           = new Map<Id, Id>();
            this.criteriaMap                = new Map<Id, Criteria__c>();
            this.eccToRefinementsMap        = new Map<Id, Map<String, String>>();
            this.eccToFlattenedCriteriaRefinementMap = new Map<Id, String>();
            // this.criteriaToRefinementsMap   = new Map<Id, List<Id>>();
            // this.criteriaRefinementMap      = new Map<Id, Criteria_Refinement__c>();
        }

        // constructor 2
        public ecData(Id processId) 
        {
            this();
            this.processId = processId;
        }

        // constructor 3
        public ecData(ecData interim) 
        {
            this.processId                  = interim.processId;
            this.ecTypes                    = interim.ecTypes;
            this.countECs                   = interim.countECs;
            this.steps                      = interim.steps;
            this.ecMap                      = interim.ecMap;
            this.ecToGroupNumberToLogicMap  = interim.ecToGroupNumberToLogicMap;
            this.eccToECidMap               = interim.eccToECidMap;
            this.eccMap                     = interim.eccMap;
            this.eccToCriteriaMap           = interim.eccToECidMap;
            this.criteriaMap                = interim.criteriaMap;
            this.eccToRefinementsMap        = interim.eccToRefinementsMap;
            this.eccToFlattenedCriteriaRefinementMap    = interim.eccToFlattenedCriteriaRefinementMap;
            // this.criteriaToRefinementsMap   = interim.criteriaToRefinementsMap;
            // this.criteriaRefinementMap      = interim.criteriaRefinementMap;
        }
    }

    // public void addToMap(Map<Id, List<Id>> addToMap, Id key, Id value)
    // {
    //     List<Id> values = addToMap.get(key);
    //     if (values==null)
    //         values = new List<Id>();
    //     values.add(value);
    //     addToMap.put(key, values);
    // }

    public class illegalArgumentECTreeGeneratorException extends Exception {}

}