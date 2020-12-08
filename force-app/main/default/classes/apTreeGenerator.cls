/**
    @class:         apTreeGenerator           
	@description:   Walks over the Academic Program / Process ECRs & builds a tree hierarchy. Populates the ecrProcessData data class.
	@author: 		Mark Membrino
	@createdDate:   9/10/2020
*/
public class apTreeGenerator 
{
    private Map<Id, ecrProcessData> processData { get; private set; }
    private Map<Id, Enrollment_Component__c> processECs { get; private set; }
    private List<Id> processECsNotFound { get; private set; }
    private final Integer TREE_MAX_DEPTH = 3;
    private final String EC_RECORD_TYPE_WHITE_LIST_TXT = 'Process,Stage,Form,Section,Document,Flag,Message'; // @Q: Can we skip: Flag & Message ECs ? 
    private final List<String> EC_RECORD_TYPE_WHITE_LIST = EC_RECORD_TYPE_WHITE_LIST_TXT.split(',');

    public apTreeGenerator()
    {
        this.processECsNotFound = new List<Id>();
    }

    // public apTreeGenerator(List<Id> processIds) 
    // {
    //     this();
    //     try 
    //     {
    //         this.processECs = new Map<Id,Enrollment_Component__c>(ecrTreeUtils.getECsByID(processIds));
    //         if (this.processECs.size()==0)
    //              throw new illegalArgumentECTreeGeneratorException('No processEC records found.');
            
    //         this.processData = new Map<Id, ecrProcessData>();
    //         for (Id processId : processIds)
    //             this.processData.put(processId, new ecrProcessData(processId));
                
    //     } catch (Exception ex ) {
    //         throw new illegalArgumentECTreeGeneratorException('invalid processIds:' + processIds  + '; Exception:' + ex.getMessage());
    //     }
          
    // }

    // USE THIS ONE...
    public apTreeGenerator(List<Id> academicProgramIds) 
    {
        this();
        try 
        {
            this.processECs = new Map<Id,Enrollment_Component__c>(ECA_CriteriaEvaluatorHelper.getECsByAcademicPrograms(academicProgramIds));
            if (this.processECs.size()==0)
                 throw new illegalArgumentECTreeGeneratorException('No processEC records found.');
            
            this.processData = new Map<Id, ecrProcessData>();
            for (Enrollment_Component__c processEC : processECs.values())
                this.processData.put(processEC.Process_Academic_Program__c, new ecrProcessData(processEC.Id, processEC.Process_Academic_Program__c)); // Mapped to academicProgram -> processRecord
                
        } catch (Exception ex ) 
        {
            throw new illegalArgumentECTreeGeneratorException('invalid Academic Program IDs:' + academicProgramIds  + '; Exception:' + ex.getMessage());
        } 
    }
    
    public Map<Id, ecrProcessData> getData()
    {
        return this.processData;
    }

    /**
     * 
     * Using BFS w/iteration to build the tree
     */
    public void generate() {

        if ( this.processData==null || this.processData.size()==0 ) { return; }

        for (ecrProcessData pd : processData.values())
        {
            if (this.processECs.get(pd.processId)==null) 
            { 
                processECsNotFound.add(pd.processId); // @todo: something with this?
                continue; 
            }

            pd.root = new ecNode(this.processECs.get(pd.processId), pd.steps); // xtra
            pd.ecTypes.add(pd.root.kind);
            Map<Id, ecNode> ecNodeMapParent = new Map<Id, ecNode>{pd.root.nodeId => pd.root}; 

            // overloading a 'queue for list of strings' to handle 'any' type of List, in this case a list of deserialized map of ecNodes.
            ecNodeQueue q = new ecNodeQueue();
            q.enqueue(ecNodeMapParent); 

            while (!q.isEmpty()) { // && pd.steps <= TREE_MAX_DEPTH
                
                ecNodeMapParent = q.dequeue();

                // gathering stats...
                pd.countECs += ecNodeMapParent.size();
                pd.steps++;

                // System.debug('::step>>>' + pd.steps + '>>>ecNodeMapParent>>>' + JSON.serialize(ecNodeMapParent));

                // tmpMap, to gather the children
                Map<Id, ecNode> ecNodeMapChildrenTmp = new Map<Id, ecNode>();

                for (Enrollment_Component_Relationship__c ecr : queryECRs(ecNodeMapParent.keySet(), EC_RECORD_TYPE_WHITE_LIST))
                {   
                    // build EC-Parent => EC-Children Map
                    this.addToMap(pd.ecParentToChildrenMap, ecr.Parent_Enrollment_Component__c, ecr.Child_Enrollment_Component__c);
                    
                    // build EC-Child => EC-Parents Map
                    this.addToMap(pd.ecChildToParentsMap, ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);

                    ecNode child = new ecNode(ecr, pd.steps); // create a child Node
                    pd.ecTypes.add(child.kind); // gathering stats...
                    ecNodeMapParent.get(ecr.Parent_Enrollment_Component__c).addChildren(child);// add child to parentNode
                    ecNodeMapChildrenTmp.put(ecr.Child_Enrollment_Component__c, child); // tmp map to hold child ec -> ecNode
                }

                if (ecNodeMapChildrenTmp.size()>0) {
                    q.enqueue(ecNodeMapChildrenTmp);
                }

            }
        }
        System.debug('processData>>' + JSON.serialize(processData));
    }

    public void addToMap(Map<Id, List<Id>> addToMap, Id key, Id value)
    {
        List<Id> values = addToMap.get(key);
        if (values==null)
            values = new List<Id>();
        values.add(value);
        addToMap.put(key, values);
    }


    // /**
    //  *  save ecrProducerFormat to the database object
    //  *  
    //  */
    // // public List<ecrTree__c> save() 
    // public Set<Id> save()
    // {
    //     List<sObject> forUpdate = new List<sObject>();
    //     List<ecrTree__c> newConfigs = new List<ecrTree__c>();
    //     for ( ecrProcessData pdConfig : this.processData.values())
    //     {
            
    //         // if no payload, skip
    //         if (pdConfig.root==null) {
    //             continue;
    //         }

    //         Integer version = 0;
    //         for (ecrTree__c rec : ecrTreeUtils.getECRTreeByParentIDs(new Set<Id>{pdConfig.root.nodeId})) { // query existing records for the same node.ID
                
    //             Integer configVersion = Integer.valueOf(rec.Version__c);
    //             if (configVersion > version){
    //                 version = configVersion; // grab the latest version
    //             }
                
    //             rec.isActive__c = false; // set older configs to inActive
    //             forUpdate.add(rec);

    //         }
    //         pdConfig.version = ++version; // set the version
            
    //         // ecrTree__c newConfig = ecrTreeUtils.createECRTreeRec(config); // create new record
    //         ecrTree__c newConfig = createECRTreeRec(pdConfig); // create new record

    //         newConfigs.add(newConfig);
    //         // update forUpdate; // update only after newConfig is save successfully
    //         // return newConfig.Id;
    //     }
    //     if (newConfigs.size()>0)
    //         insert newConfigs;

    //     if (forUpdate.size()>0)
    //         update forUpdate;

    //     return (new Map<Id, ecrTree__c>(newConfigs).keySet());
    // }

    /**
     *  This method is used to find a specific node & its children in the processHierarch (rootNode)
     */
    public static ecNode search(ecNode rootNode, Id toFindECId)
    {
        // if (this.processData.get(pgmId)==null)
        //     return null;
    
        if (rootNode==null || toFindECId==null)
            return null;

        if (rootNode.ecId == toFindECId)
            return rootNode;
            
        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(new Map<Id, ecNode>{rootNode.nodeId => rootNode});
        
        // if  (q.peek().values()[0].ecId==toFindECId)
        //     return q.dequeue().values()[0];
        
        Integer level = 0;
        // ecrImport.ecrIDsByLevel

        Map<Id, ecNode> ecNodeTemp; // temp loop variable
        while (!q.isEmpty()) 
        {
            ecNodeTemp = q.dequeue();
            
            // if (toFindECId==ecNodeTemp.values()[0].ecId)
            for (Id ndID : ecNodeTemp.keySet()) 
            {
                ecNode curr = ecNodeTemp.get(ndID);
                // if (toFindECId==ecNodeTemp.values()[0].ecId)
                if (toFindECId==curr.ecId)
                    return curr;
                q.enqueue(curr.getChildrenAsMap());
            }
        }

        return null;

    }

    /**
     *  This method is flattens the given rootNode & its children & returns a Set of EC Ids
     */
    public static Set<Id> getNodeSubTreeAsList(ecNode rootNode)
    {
        Set<Id> subTree = new Set<Id>();

        if (rootNode==null)
            return null;

        // if (rootNode.getChildrenAsMap().size()==0)
        //     return children;
            
        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(new Map<Id, ecNode>{rootNode.nodeId => rootNode});
        
        // if  (q.peek().values()[0].ecId==toFindECId)
        //     return q.dequeue().values()[0];
        
        Integer level = 0;
        // ecrImport.ecrIDsByLevel
        Map<Id, ecNode> ecNodeTemp; // temp loop variable
        while (!q.isEmpty()) 
        {
            ecNodeTemp = q.dequeue();
            
            for (Id ndID : ecNodeTemp.keySet()) 
            {
                ecNode curr = ecNodeTemp.get(ndID);
                subTree.add(curr.ecId);

                Map<Id, ecNode> tmpChildren = curr.getChildrenAsMap();
                if (curr.getChildrenAsMap().size()>0)
                    q.enqueue(curr.getChildrenAsMap());
            }
        }

        return subTree;
    }


    // @returns ecrTree record
    public static ecrTree__c createECRTreeRec(ecrProcessData config) 
    {   
        List<String> ecTypesList = new List<String>();
        ecTypesList.addAll(config.ecTypes); // converting ecTypes from set to list

        ecrTree__c newConfig = new ecrTree__c(
            ParentID__c = config.root.nodeId,
            isActive__c = true, // false // true
            Type__c = config.root.kind,
            ecTreeHeight__c = config.steps, 
            ecCount__c = config.countECs, 
            ecTypes__c = String.join(ecTypesList, ','),
            // Payload__c = JSON.serialize(config.root),
            Payload__c = JSON.serialize(config),
            Version__c = config.version
        );

        return newConfig;
    }

    // query ECR records by ParentIDs
    public static List<Enrollment_Component_Relationship__c> queryECRs(Set<Id> parentIDs, List<String> recordTypeWhiteList) {       
        return [SELECT  Id, Order__c, External_Id__c,
                    Parent_Enrollment_Component__c,
                    Parent_Enrollment_Component__r.Id, 
                    Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, 
                    Child_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Id, 
                    Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, 
                    Child_Enrollment_Component__r.Component_Type__c,
                    Child_Enrollment_Component__r.Completion_Logic__c,
                    Child_Enrollment_Component__r.Assignment_Logic__c,
                    Child_Enrollment_Component__r.Is_Required__c,
                    Child_Enrollment_Component__r.External_Id__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Parent_Enrollment_Component__c =: parentIDs
            AND   Child_Enrollment_Component__r.RecordType.Name IN : recordTypeWhiteList
            ORDER BY Order__c ASC];
    }


    public class illegalArgumentECTreeGeneratorException extends Exception {}

}