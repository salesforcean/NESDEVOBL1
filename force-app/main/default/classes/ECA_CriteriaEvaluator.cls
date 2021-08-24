/**
    @class:         ECA_CriteriaEvaluator           
    @description:   Part of rewrite of the ECA assignment and completion logic, runs thru is_Dirty ECAs & setup ECA.Status__c based 
                    on EC.Assignment/Completion Logic & triggers parentStatusUpdate as well.
	@author: 		Mark Membrino
	@createdDate:   8/31/2020
*/
public class ECA_CriteriaEvaluator {

    // part of public API, needed for postCriteriaEvaluation, like: ECA Status for ECA_Hierarchy
    public static Map<Id, Enrollment_Component_Affiliation__c> processedECAs { get; private set; } 
    // public static Map<Id, Map<Integer, Id>> mapECtoECCriteria { get; private set; }
    public static Map<Id, Map<Integer, String>> mapECtoECCriteria { get; private set; }

    /**
     * Called by TriggerCode
     */
    public static void processDirtyECAs	(
        List<Enrollment_Component_Affiliation__c> newList, 
        Map<Id, Enrollment_Component_Affiliation__c> newMap, 
        Map<Id, Enrollment_Component_Affiliation__c> oldMap
    ) {
        system.debug('newList '+newList);
        system.debug('newMap key '+newMap.keyset());
        system.debug('newMap value '+newMap.values());
        system.debug('oldMap key '+oldMap.keyset());
        system.debug('oldMap value '+oldMap.values());
        dirtyECAs = new List<Enrollment_Component_Affiliation__c>();
        dirtyECs = new Map<Id, Enrollment_Component__c>();
        dirtyPEIds = new List<Id>();

        processedECAs = new Map<Id, Enrollment_Component_Affiliation__c>();

        Map<Id, Id> dirtyECtoECAsMap = new Map<Id, Id>();
        Map<Id, Id> dirtyECAtoECsMap = new Map<Id, Id>();
        
        for (Enrollment_Component_Affiliation__c eca : newList) 
        {
            if (
                (eca.is_Dirty__c) && (
                    oldMap == null || 
                    eca.is_Dirty__c != oldMap.get(eca.Id).is_Dirty__c
                )
            ) {
				system.debug('===> is_Dirty__c '+eca.is_Dirty__c);
                dirtyECAs.add(eca);
                dirtyPEIds.add(eca.Program_Enrollment__c);
                dirtyECs.put(eca.Enrollment_Component__c, null);
                
                dirtyECtoECAsMap.put(eca.Enrollment_Component__c, eca.Id);
                dirtyECAtoECsMap.put(eca.Id, eca.Enrollment_Component__c);
            }        
        }
        
        system.debug('dirtyECtoECAsMap key '+dirtyECtoECAsMap.keyset());
        system.debug('dirtyECtoECAsMap value '+dirtyECtoECAsMap.values());
        system.debug('dirtyECAtoECsMap key '+dirtyECAtoECsMap.keyset());
        system.debug('dirtyECAtoECsMap key '+dirtyECAtoECsMap.values());
        
        //Get ProgramEnrollment statuses
       // Map<Id, hed__Program_Enrollment__c> mapPEWithEnrollmentType = new Map<Id, hed__Program_Enrollment__c>([Select Id, Enrollment_Type__c from hed__Program_Enrollment__c where id IN:dirtyPEIds]);
        // added by maddileti for defect 430511
        //Set<id> allPEIds = new Set<id>(dirtyPEIds);
	    List<hed__Program_Enrollment__c> PEList = GenericSOQLQueries.programEnrollmentDetails(new Set<id>(dirtyPEIds));
       Map<Id, hed__Program_Enrollment__c> mapPEWithEnrollmentType = new Map<Id, hed__Program_Enrollment__c>(PEList);
        // End by maddileti for defect 430511
        if (dirtyECAs.size()==0)
            return;
        
        refreshAll = true;
        
        // * Fetch ECs & ECCs & Criteria for given ECAs
        dirtyECs = ECA_CriteriaEvaluatorHelper.getECsById(new List<Id>(dirtyECs.keySet()));

        system.debug('==> dirtyECs key '+dirtyECs.keyset());
        system.debug('==> dirtyECs value '+dirtyECs.values());
        // build map of EC => ECCs
        mapECtoECCriteria = getECtoECCriteriaMap(dirtyECs); //Change this to EC => Order => ECC.ID

        system.debug('==> mapECtoECCriteria key '+mapECtoECCriteria.keyset());
        system.debug('==> mapECtoECCriteria value '+mapECtoECCriteria.values());
        
        // mapPEIdtoPECriteria
        // mapECtoECCriteria
        
        // this is a shared Class & is needed to fetchECA children
        ECA_HierarchyStatusUpdate.initialize(newMap);

        // temp variables
        Enrollment_Component__c ec;
        Map<Integer, String> eccCriteria;

        System.debug('>>>mapPEIdtoPECriteria>>>' + JSON.serialize(mapPEIdtoPECriteria));

        for (Enrollment_Component_Affiliation__c eca : dirtyECAs) 
        {        
			system.debug('ECA form Id here*******'+eca.Id);
            
            ec = dirtyECs.get(eca.Enrollment_Component__c);
            eccCriteria = mapECtoECCriteria.get(ec.Id);

            system.debug('==> ec '+ec);
            system.debug('==> eccCriteria '+eccCriteria);
            
            Map<Object, Boolean> expressionData = new Map<Object, Boolean>();
            if (eccCriteria!=null) // populate the criteriaData result field
            {                 
                System.debug('>>>mapPEIdtoPECriteria.get(eca.Program_Enrollment__c)>>>' + mapPEIdtoPECriteria.get(eca.Program_Enrollment__c));
                System.debug('>>>eccCriteria.get(key>>>' + JSON.serialize(eccCriteria));
                system.debug('==>eccCriteria key '+eccCriteria.keyset());
                for (Integer key : eccCriteria.keySet()){ 
                    System.debug('>>>eccCriteria.get(key>>>' + eccCriteria.get(key));
                    Program_Enrollment_Criteria__c pecTmp = mapPEIdtoPECriteria.get(eca.Program_Enrollment__c).get(eccCriteria.get(key));
                    system.debug('==> pecTmp '+pecTmp);
                    system.debug('==> pecTmp Result__c '+pecTmp.Result__c);
                    system.debug('==> key '+key);
                    expressionData.put(key, pecTmp.Result__c);
                    // expressionData.put(key, mapPEIdtoPECriteria.get(eca.Program_Enrollment__c).get(eccCriteria.get(key)).Result__c);
                }
            }            
            Boolean assignmentLogic = (ec.Assignment_Logic__c==null?true:evaluate(ec.Assignment_Logic__c, expressionData));
            String incompleteChildrenStatus = null;
            Boolean completionLogic = false;
            // check if ECA qualifies for Completion logic run
            
            if (!COMPLETION_LOGIC_BLACK_LIST_TXT.containsIgnoreCase(eca.EC_Record_Type__c) && ECA_HierarchyStatusUpdate.isECAPartOfCurrentStage(eca))
            {   
                completionLogic = (ec.Completion_Logic__c==null?true:evaluate(ec.Completion_Logic__c, expressionData));
                incompleteChildrenStatus = ECA_HierarchyStatusUpdate.getChildrenStatus(eca, true);
                completionLogic = completionLogic && (incompleteChildrenStatus==null || incompleteChildrenStatus.equalsIgnoreCase('Complete'));
            }
            
            String newStatus;
            system.debug('Id*******'+eca.Id);
           system.debug('eca.Status__c*******'+eca.Status__c);
            system.debug('assignmentLogic*******'+assignmentLogic);
            //ADDED TESTING
            
           if((mapPEWithEnrollmentType.containskey(eca.Program_Enrollment__c) && mapPEWithEnrollmentType.get(eca.Program_Enrollment__c).Enrollment_Type__c == 'Returning Student' && assignmentLogic == false  && eca.Status__c == 'Complete')){
              
               eca.Status__c = 'Not Applicable';
                processedECAs.put(eca.Id, eca);
           }else{
               if (COMPLETION_LOGIC_BLACK_LIST_TXT.containsIgnoreCase(eca.EC_Record_Type__c) && (eca.Status__c == 'Complete' || eca.Status__c == 'Deferred'))             
                {
                    system.debug('Debug Log*****COMPLETION_LOGIC_BLACK_LIST_TXT '+ eca.Id);
                    processedECAs.put(eca.Id, eca); // do nothing if Section/Document is Complete/Doc-deferred, process its parents.
                }
                else if ((newStatus = getNewECAStatus(eca.Status__c, assignmentLogic, completionLogic)) !=null) {
                    system.debug('Debug Log**getNewECAStatus**'+eca.Id +'****'+ newStatus);
                    eca.Status__c = newStatus;
                    processedECAs.put(eca.Id, eca);
                } 
                else if (incompleteChildrenStatus!=null && incompleteChildrenStatus.equalsIgnoreCase('In Progress')) 
                {
                    system.debug('Debug Log ****In incompleteChildrenStatus');
                    eca.Status__c = 'In Progress';
                    processedECAs.put(eca.Id, eca);
                }
           }
       	   
            
            eca.is_Dirty__c = false;
        }
    }

    /** 
     * EC.Assignment_Logic__c & EC.Completion_Logic__c Expression Parser
     * Example: 
            String expression = '1 AND 2 AND (3 OR 4)';
            Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => True, 2 => True, 3 => False, 4 => True};
            ECA_CriteriaEvaluator.evaluate(expression, expressionData);
    */
    public static Boolean evaluate(String expression, Map<Object, Boolean> expressionData) 
    {
     
        // pull this from debugMode setting
        Boolean showTree =  isDebugMode;

        if (String.isEmpty(expression))
            return false;

        SyntaxTree syntaxTree = SyntaxTree.Parse(expression);

        if (showTree)
        {
            PrettyPrint(syntaxTree.Root, null, null);
            System.debug('::ppResults::' + '\n' + ppResults);
        }

        if (syntaxTree.Diagnostics.size()==0)
        {
            EvaluatorBoolean e = new EvaluatorBoolean(syntaxTree.Root, expressionData);
            Boolean result = e.Evaluate();
            // System.debug('result>>' + result);
            return result;
        }
        else
        {
            for (String diagnostic : syntaxTree.Diagnostics)
                System.debug('diagnostic>>' +diagnostic);
        }    
        return false;        
    
    }

    public static Boolean isDebugMode{
        get 
        {

            if (Test.isRunningTest())
                isDebugMode = true;
        
            if (isDebugMode==null)
                isDebugMode = mapECAEvaluationSettingsByType.get('System').get('DebugMode').DebugMode__c;
        
            return isDebugMode;

        }
        
        set;
    }

    public static Map<String, Map<String, ECA_Evaluation_Setting__mdt>> mapECAEvaluationSettingsByType 
    {
        get 
        {
            if (mapECAEvaluationSettingsByType==null) 
            {

                mapECAEvaluationSettingsByType = new Map<String, Map<String, ECA_Evaluation_Setting__mdt>>();

                for (ECA_Evaluation_Setting__mdt setting : ECA_CriteriaEvaluatorHelper.getAllECAEvaluationSettings())
                {
                
                    Map<String, ECA_Evaluation_Setting__mdt> rec = mapECAEvaluationSettingsByType.get(setting.Type__c);
                
                    if (rec==null) 
                    {
                        
                        rec = new Map<String, ECA_Evaluation_Setting__mdt>{ setting.DeveloperName => setting };
                        mapECAEvaluationSettingsByType.put(setting.Type__c, rec);
                        
                    } else 
                    {
                        rec.put(setting.DeveloperName, setting);
                    }
                }                
            }

            return mapECAEvaluationSettingsByType;

        }

        set;

    }

    public static void PrettyPrint(SyntaxNode node, string indent, Boolean isLast)
    {
        
        isLast = isLast==null ? true : isLast;
        indent = indent==null ? '' : indent;
        String marker = isLast ? '└──' : '├──';
        
        ppResults += indent + marker + node.Kind;
        if (node instanceof SyntaxToken)
        {
            SyntaxToken st = (SyntaxToken) node;
            if (st.Value !=null) { 
                ppResults += ' ' + st.Value;
            }
        }

        ppResults += '\n';
        indent += isLast ? '    ' : '│   ';

        List<SyntaxNode> children = node.GetChildren();
        SyntaxNode lastChild;
        if (children.size()>0) {
            lastChild = children[children.size()-1];
        }
        
        for (SyntaxNode child : children)
            PrettyPrint(child, indent, child == lastChild);
    }

    /**
     * 
     * INTERNAL CLASS COMPONENTS
     * 
     */
    
    // CONSTANTS...
    public static final String ECA_STATUS_DECISION_SETTING_TYPE = 'ECA Status Mapping';
    public static final String COMPLETION_LOGIC_BLACK_LIST_TXT = 'Section,Document'; // Section, Question, Flag
    
    @TestVisible
    private static String ppResults = '';
    @TestVisible
    private static List<Enrollment_Component_Affiliation__c> dirtyECAs { get; set; }
    @TestVisible
    private static List<Id> dirtyPEIds { get; set; }
    @TestVisible
    private static Boolean refreshAll { get; set; }
    @TestVisible
    private static Map<Id, Enrollment_Component__c> dirtyECs { get; set; }

    @TestVisible
    private static Map<Id, Map<String, Program_Enrollment_Criteria__c>> mapPEIdtoPECriteria
    {
        get 
        {
            if (refreshAll && dirtyPEIds!=null) {

                refreshAll = false;
                mapPEIdtoPECriteria = new Map<Id, Map<String, Program_Enrollment_Criteria__c>>();

                for (Program_Enrollment_Criteria__c pec : ECA_CriteriaEvaluatorHelper.getPECriteriaResultsByPEIds(dirtyPEIds))
                {
                    
                    String key = pec.Criteria__c + pec.Student_or_Household__c + pec.School_Year__c + pec.Question_Group__c;

                    if (mapPEIdtoPECriteria.get(pec.Program_Enrollment__c) == null)
                        // mapPEIdtoPECriteria.put(pec.Program_Enrollment__c, new Map<String, Program_Enrollment_Criteria__c>{pec.Criteria__c => pec});
                        mapPEIdtoPECriteria.put(pec.Program_Enrollment__c, new Map<String, Program_Enrollment_Criteria__c>{key => pec});
                    else
                        mapPEIdtoPECriteria.get(pec.Program_Enrollment__c).put(key, pec);

                }

            }

            return mapPEIdtoPECriteria;

        } 

        set;

    }
    
    public static Map<Id, Map<Integer, String>> getECtoECCriteriaMap(Map<Id, Enrollment_Component__c> dirtyECs)
    {
        Map<Id, Map<Integer, String>> mapECtoECCriteria = new Map<Id, Map<Integer, String>>();

        Map<String, Enrollment_Component__c> criteriaQuestionGroups = new Map<String, Enrollment_Component__c>();
        Map<String, School_Year__c> criteriaSchoolYears = new Map<String, School_Year__c>();
        for (Enrollment_Component__c ec : dirtyECs.values()) 
        {
            for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) 
            {
                if (!String.isBlank(ecc.School_Year__c))
                    criteriaSchoolYears.put(ecc.School_Year__c, null);
        
                if (!String.isBlank(ecc.Question_Group__c))
                    criteriaQuestionGroups.put(ecc.Question_Group__c, null);
                
            }
        }

        // query for the QuestionGroup & SchoolYear ExtIds & build a Map.
        if (criteriaSchoolYears.size() > 0 ) {
            criteriaSchoolYears = ECA_CriteriaEvaluatorHelper.getSchoolYearsByExternalId(criteriaSchoolYears.keySet());
        }
        if (criteriaQuestionGroups.size() > 0 ) {
            criteriaQuestionGroups = ECA_CriteriaEvaluatorHelper.getECsByExternalId(criteriaQuestionGroups.keySet());
        }

        for (Enrollment_Component__c ec : dirtyECs.values())
        {
            for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) 
            {
                School_Year__c schoolYear = criteriaSchoolYears.get(ecc.School_Year__c);
                Enrollment_Component__c questionGroupEC = criteriaQuestionGroups.get(ecc.Question_Group__c);
                String key = ecc.Criteria__c + ecc.Student_or_Household__c; 
                key += (schoolYear!=null?schoolYear.Id:null); 
                key += (questionGroupEC!=null?questionGroupEC.Id:null);
                
                Map<Integer, String> mapECCriteria = mapECtoECCriteria.get(ec.Id);
                
                if (mapECCriteria == null) 
                {
                    mapECCriteria = new Map<Integer, String>{ 
                        // (Integer) ecc.Criteria_Number__c => ecc.Criteria__c
                        (Integer) ecc.Criteria_Number__c => key
                    };
                    mapECtoECCriteria.put(
                        ec.Id, 
                        mapECCriteria
                    );
                } else 
                {
                    mapECCriteria.put((Integer) ecc.Criteria_Number__c, key);
                        // (Integer) ecc.Criteria_Number__c, 
                        
                    
                }
            }

        }
        return mapECtoECCriteria;
    }
    // 12/18/2020 | Mark Membrino | Backing up... | WIP... END

    @TestVisible
    private static Map<String, ECA_Evaluation_Setting__mdt> mapECAStatusDecision 
    {
        get 
        {
            if (mapECAStatusDecision==null) 
                mapECAStatusDecision = mapECAEvaluationSettingsByType.get(ECA_STATUS_DECISION_SETTING_TYPE);
             system.debug('Debug Log**'+mapECAStatusDecision ) ;  
            return mapECAStatusDecision;
        }

        set;
    }

    @TestVisible
    private static String getNewECAStatus(String ecaStatus, Boolean assignmentLogic, Boolean completionLogic) 
    {
        for (ECA_Evaluation_Setting__mdt rec : mapECAStatusDecision.values()) 
        {
            system.debug('Debug Log*****RecId'+rec.Id);
            system.debug('rec.Status__c.containsIgnoreCase(ecaStatus)*******'+rec.Status__c.containsIgnoreCase(ecaStatus));
            system.debug('assignmentLogic*******'+assignmentLogic);
            system.debug('completionLogic*******'+completionLogic);
            system.debug('rec.AssignmentLogic__c*******'+rec.AssignmentLogic__c);
            system.debug('rec.CompletionLogic__c*******'+rec.CompletionLogic__c);           
            if (
                rec.Status__c.containsIgnoreCase(ecaStatus) && 
                assignmentLogic == rec.AssignmentLogic__c && 
                completionLogic == rec.CompletionLogic__c
            ) {
                system.debug('Debug Log***'+ rec.NewStatus__c);
                return rec.NewStatus__c;
            }
        }

        // if no matches
        return null;
    }
}