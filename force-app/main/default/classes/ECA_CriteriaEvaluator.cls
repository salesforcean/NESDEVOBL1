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
    public static Map<Id, Map<Integer, Id>> mapECtoECCriteria { get; private set; }

     /**
     * Called by TriggerCode
     */
    public static void processDirtyECAs(
        List<Enrollment_Component_Affiliation__c> newList, 
        Map<Id, Enrollment_Component_Affiliation__c> newMap, 
        Map<Id, Enrollment_Component_Affiliation__c> oldMap
    ) {
        
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

                dirtyECAs.add(eca);
                dirtyPEIds.add(eca.Program_Enrollment__c);
                dirtyECs.put(eca.Enrollment_Component__c, null);
                
                dirtyECtoECAsMap.put(eca.Enrollment_Component__c, eca.Id);
                dirtyECAtoECsMap.put(eca.Id, eca.Enrollment_Component__c);
            }        
        }
        
        if (dirtyECAs.size()==0)
            return;
            
        refreshAll = true;
        
        // * Fetch ECs & ECCs & Criteria for given ECAs
        dirtyECs = ECA_CriteriaEvaluatorHelper.getECsById(new List<Id>(dirtyECs.keySet()));

        // build map of EC => ECCs
        mapECtoECCriteria = getECtoECCriteriaMap(dirtyECs);
        
        // this is a shared Class & is needed to fetchECA children
        ECA_HierarchyStatusUpdate.initialize(newMap);

        // temp variables
        Enrollment_Component__c ec;
        Map<Integer, Id> eccCriteria;

        for (Enrollment_Component_Affiliation__c eca : dirtyECAs) 
        {

            // // if Status=Not Applicable, skip & process Parents.
            // if (eca.Status__c == 'Not Applicable') 
            // {
            //     eca.is_Dirty__c = false;
            //     processedECAs.put(eca.Id, eca);
            //     continue;
            // }

            ec = dirtyECs.get(eca.Enrollment_Component__c);
            eccCriteria = mapECtoECCriteria.get(ec.Id);

            Map<Object, Boolean> expressionData = new Map<Object, Boolean>();
            if (eccCriteria!=null) // populate the criteriaData result field
            { 
                for (Integer key : eccCriteria.keySet()){ 
                    Program_Enrollment_Criteria__c pecTmp = mapPEIdtoPECriteria.get(eca.Program_Enrollment__c).get(eccCriteria.get(key));
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
            
            String newStatus; // = getNewECAStatus(eca.Status__c, assignmentLogic, completionLogic);
            // if (eca.Status__c == 'Not Applicable' ) {
            //     // eca.Status__c = 'Not Applicable'
            //     processedECAs.put(eca.Id, eca);
            // }
            // else 
            if (COMPLETION_LOGIC_BLACK_LIST_TXT.containsIgnoreCase(eca.EC_Record_Type__c) && (eca.Status__c == 'Complete' || eca.Status__c == 'Deferred')) {
                processedECAs.put(eca.Id, eca); // do nothing if Section/Document is Complete/Doc-deferred, process its parents.
            }
            else if ((newStatus = getNewECAStatus(eca.Status__c, assignmentLogic, completionLogic)) !=null) {
                eca.Status__c = newStatus;
                processedECAs.put(eca.Id, eca);
            } 
            else if (incompleteChildrenStatus!=null && incompleteChildrenStatus.equalsIgnoreCase('In Progress')) 
            {
                eca.Status__c = 'In Progress';
                processedECAs.put(eca.Id, eca);
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
    private static Map<Id, Map<Id, Program_Enrollment_Criteria__c>> mapPEIdtoPECriteria 
    {
        get 
        {
            if (refreshAll && dirtyPEIds!=null) {

                refreshAll = false;
                mapPEIdtoPECriteria = new Map<Id, Map<Id, Program_Enrollment_Criteria__c>>();

                for (Program_Enrollment_Criteria__c result : ECA_CriteriaEvaluatorHelper.getPECriteriaResultsByPEIds(dirtyPEIds))
                {

                    if (mapPEIdtoPECriteria.get(result.Program_Enrollment__c) == null)
                        mapPEIdtoPECriteria.put(result.Program_Enrollment__c, new Map<Id, Program_Enrollment_Criteria__c>{result.Criteria__c => result});
                    else
                        mapPEIdtoPECriteria.get(result.Program_Enrollment__c).put(result.Criteria__c, result);

                }

            }

            return mapPEIdtoPECriteria;

        } 

        set;

    }

    // @TestVisible
    // private static Map<Id, Map<Integer, Id>> mapECtoECCriteria
    // {
    //     get 
    //     {
    //         if (mapECtoECCriteria==null) 
    //         {

    //             mapECtoECCriteria = new Map<Id, Map<Integer, Id>>();

    //             for (Enrollment_Component__c ec : dirtyECs.values()) 
    //             {
    //                 for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) 
    //                 {
                        
    //                     Map<Integer, Id> mapECCriteria = mapECtoECCriteria.get(ec.Id);
                        
    //                     if (mapECCriteria == null) 
    //                     {
    //                         mapECCriteria = new Map<Integer, Id>{ 
    //                             (Integer) ecc.Criteria_Number__c => ecc.Criteria__c
    //                         };
    //                         mapECtoECCriteria.put(
    //                             ec.Id, 
    //                             mapECCriteria
    //                         );
    //                     } else 
    //                     {
    //                         mapECCriteria.put(
    //                             (Integer) ecc.Criteria_Number__c, 
    //                             ecc.Criteria__c
    //                         );
    //                     }
    //                 }

    //             }

    //         }

    //         return mapECtoECCriteria;

    //     }

    //     set;

    // }
    
    public static Map<Id, Map<Integer, Id>> getECtoECCriteriaMap(Map<Id, Enrollment_Component__c> dirtyECs)
    {
        Map<Id, Map<Integer, Id>> mapECtoECCriteria = new Map<Id, Map<Integer, Id>>();
        for (Enrollment_Component__c ec : dirtyECs.values()) 
        {
            for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) 
            {
                
                Map<Integer, Id> mapECCriteria = mapECtoECCriteria.get(ec.Id);
                
                if (mapECCriteria == null) 
                {
                    mapECCriteria = new Map<Integer, Id>{ 
                        (Integer) ecc.Criteria_Number__c => ecc.Criteria__c
                    };
                    mapECtoECCriteria.put(
                        ec.Id, 
                        mapECCriteria
                    );
                } else 
                {
                    mapECCriteria.put(
                        (Integer) ecc.Criteria_Number__c, 
                        ecc.Criteria__c
                    );
                }
            }

        }
        return mapECtoECCriteria;
    }

    @TestVisible
    private static Map<String, ECA_Evaluation_Setting__mdt> mapECAStatusDecision 
    {
        get 
        {
            if (mapECAStatusDecision==null) 
                mapECAStatusDecision = mapECAEvaluationSettingsByType.get(ECA_STATUS_DECISION_SETTING_TYPE);
                
            return mapECAStatusDecision;
        }

        set;
    }

    @TestVisible
    private static String getNewECAStatus(String ecaStatus, Boolean assignmentLogic, Boolean completionLogic) 
    {
        for (ECA_Evaluation_Setting__mdt rec : mapECAStatusDecision.values()) 
        {
            if (
                rec.Status__c.containsIgnoreCase(ecaStatus) && 
                assignmentLogic == rec.AssignmentLogic__c && 
                completionLogic == rec.CompletionLogic__c
            ) {
                return rec.NewStatus__c;
            }
        }

        // if no matches
        return null;
    }

}



    // public static String getECAChildrenStatus(Enrollment_Component_Affiliation__c parentECA) 
    // {
    //     List<Id> childEC_Ids = new List<Id>();
    //     Id parentECA_EC_ID = parentECA.Enrollment_Component__c; 
    //     Id parentECA_PE_ID = parentECA.Program_Enrollment__c;

    //     // get children ECA.ECs from ECR
    //     for (Enrollment_Component_Relationship__c ecr : [SELECT Child_Enrollment_Component__c 
    //         FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c = :parentECA_EC_ID])
    //     {
    //         childEC_Ids.add(ecr.Child_Enrollment_Component__c);
    //     }

    //     if (childEC_Ids == null || childEC_Ids.size()==0)
    //         return 'Complete'; // no children found.

    //     Integer completedChildrenCount = 0;
    //     Integer inProgressChildrenCount = 0;
    //     Integer restChildrenCount = 0;
    //     Integer totalCount = 0;

    //     for (Enrollment_Component_Affiliation__c child : [
    //         SELECT 	Id, Status__c, Enrollment_Component__c
    //         FROM 	Enrollment_Component_Affiliation__c 
    //         WHERE 	Program_Enrollment__c = : parentECA.Program_Enrollment__c 
    //                 AND Status__c != 'Not Applicable'
    //                 AND Enrollment_Component__c IN :childEC_Ids
    //     ])
    //     {
    //         totalCount++; 

    //         if (child.status__c.equalsIgnoreCase('Complete')) { completedChildrenCount++; }
    //         else if (child.status__c.equalsIgnoreCase('In Progress')) { completedChildrenCount++; }
    //         else { restChildrenCount++; }
    //     }

    //     if (completedChildrenCount == totalCount) { return 'Complete'; } // no incomplete children found
    //     else if (completedChildrenCount>0 || inProgressChildrenCount>0) { return 'In Progress'; } // found in-progress children
        
    //     return 'rest'; // found 'Not Started'/others... children
    // }