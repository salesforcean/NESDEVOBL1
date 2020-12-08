global class academicProgram {

    /**
     * * 	@ALIKM 20/apr/2020- commenting out changes
     * ## NOTES ##
     * 
     * @todo [2/Apr/2020]
     *  -> Add Criteria Records
     *  -> Class needs to: 
*          -> Parse
*          -> Handle treeRefresh via button  / Button to kick-off
*          -> Return data in different formats
*              Ex:  a. Builder Data format
                    b. Raw
                    c. Search for an item in the tree & return path
                    d. 

*          -> toggle CustomSetting OR MDT
           -> See if we can plugin Ct/Student info to the tree
        Status Update 3/Apr: 
            Writing the processTree Parser (In-progress)
            code optimization & recursion (Not started)
            output builder data format (Not started)
            test serialization/deserialization of the complete processTree w/Process >> Stages >> Forms >> Sections >> QuestionGroups >> Questions (Not started)
            button callable code (Not started)
            test classes for the whole lot (Not started)
        ECA
        ||
        EC (ProcessID)
            \
             \ @TBD: New object w/lookup to Process.EC record. 
             This holds the json for each Stage (OR complete Process depending on the size)
             rec1: Stage-1 
             rec2: Stage-2
             rec3: Stage-3
             rec4: Stage-4

        Existing Structure
            \ 
            Process
            Stage
                Forms
                Sections
                    QuestionGroup
                    Questions
                    Messages
                    Hidden
                documents
        
        // public class acaPgm {

            //     String Name; // academicProgram Name
            //     Enrollment_Component__c process;
            //     Process -> Stages Map;
            //     Stages -> Forms Map;
            //     Forms -> Sections Map;
            //     Sections -> QuestionGroup
            //     QuestionGroup -> Questions
            //     QuestionParents -> QuestionGroup + Sections
            //      allIds
            //     ec.ID => EC.recs

        // }


    
    // Tree
    public class node {

        public id parent {get; private set;}
        public String kind {get; private set;} 
        public Enrollment_Component__c ec {get; private set;} // data
        public List<node> children {get; private set;}
        // kind ? 

        public node(Enrollment_Component__c ec) {
            this.ec = ec;
            this.children = new List<node>();
        }

        public void setParent(Id ecId) {
            this.parent = ecId;
        }

        public void addChild(node child) {
            child.setParent(this.ec.Id);
            children.add(child);
        }

        public void addChildren(List<node> children) {
            for (node child: children) {
                child.setParent(this.ec.Id);
            }
            children.addAll(children);
        }

        public Map<Id, node> getChildrenAsMap() { 
            Map<Id, node> dataToNodeMap = new Map<Id, node>();
            for (node child : this.children) {
                dataToNodeMap.put(child.ec.Id, child);
            }
            return dataToNodeMap;
        }
    }

    global enum Componentkind {
        Process,
        Stage,
        Form,
        Section,
        QuestionGroup,
        Question        
    }


    // // global class parserProcessTree {

        public static Set<Id> nodeParser (node nd, Set<Id> visitedIds) { // bfs => level Order; dfs => pre-order

            // start with the root node
            System.debug(JSON.serialize(nd));
            visitedIds.add(nd.ec.Id);

            Map<Id, node> children = nd.getChildrenAsMap();

            if (children.size()==0)
                return visitedIds;
            
            for (Id idx : children.keySet()) {
                visitedIds.addAll(nodeParser(children.get(idx), visitedIds));
            }
            return visitedIds;
        }
    
    // // }
    // academicProgram.printTree();
    public static void printTree() {

        Enrollment_Component__c acaPgmEC = [Select Id, ProcessTree__c, 
            Name from Enrollment_Component__c where id = 'a0f0n000001VAoJAAW'];
        node importProgramTree = importProcessTree(acaPgmEC.ProcessTree__c);
        Set<Id> visitedNodes = nodeParser(importProgramTree, new Set<Id>());
        System.debug('::visitedIds::count>>' + visitedNodes.size() + '>>nodes>>' + visitedNodes);

    }



    // global class Parser {

    //     private node _payload; 


    //     public Parser(node payload) {
    //         _payload = payload;
    //     }




        
    // }
    

    // query records: 
    public static List<Enrollment_Component_Relationship__c> queryECRs(Set<Id> parentIDs) {       
        return [SELECT  Id, Order__c, 
                        Parent_Enrollment_Component__c,
                        Child_Enrollment_Component__c, 
                        Child_Enrollment_Component__r.Id, 
                        Child_Enrollment_Component__r.Name, 
                        Child_Enrollment_Component__r.Assignment_Logic__c,  
                        Child_Enrollment_Component__r.RecordTypeId,
                        Child_Enrollment_Component__r.RecordType.Name, 
                        Parent_Enrollment_Component__r.Id, 
                        Parent_Enrollment_Component__r.Name, 
                        Parent_Enrollment_Component__r.Completion_Logic__c, 
                        Child_Enrollment_Component__r.Completion_Logic__c,
                        Child_Enrollment_Component__r.Is_Required__c
                FROM    Enrollment_Component_Relationship__c
                WHERE   Parent_Enrollment_Component__c =: parentIDs
                //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
                ORDER BY Order__c ASC];
    }


    // move the children up to Parent for the next iteration...
    public static Map<Id, node> getChildrenAsParent(Map<Id, node> parentNodes) { 
        Map<Id, node> parentNodeMapTmp = new Map<Id, node>();
        for (String id : parentNodes.keySet()) {
            parentNodeMapTmp.putAll(parentNodes.get(id).getChildrenAsMap());
        }
        return parentNodeMapTmp;
    }

    /**
     * @Usage: 
        academicProgram.createProcessTree('a0f0n000001IAQ2AAO');
        @todo: Make this recursive.

    public static void createProcessTree(String processID) {
        
        // process head >>> start flow
        Enrollment_Component__c processEC = new Enrollment_Component__c(id=processID);
        node root = new node(processEC);
        // root.setParent(null);

        // Stages
        // query stages...
        for (Enrollment_Component_Relationship__c ecr : queryECRs(new Set<Id>{processEC.Id})) {
            root.addChild(new node(
                new Enrollment_Component__c( 
                    id = ecr.Child_Enrollment_Component__c, 
                    Name = ecr.Child_Enrollment_Component__r.Name,
                    Description__c = ecr.Child_Enrollment_Component__r.RecordType.Name + '::' + ecr.Order__c,
                    Assignment_Logic__c = ecr.Child_Enrollment_Component__r.Assignment_Logic__c, 
                    Completion_Logic__c = ecr.Child_Enrollment_Component__r.Completion_Logic__c,
                    RecordTypeId = ecr.Child_Enrollment_Component__r.RecordTypeId
                )) // collect the parents here...
            );
            // System.debug(':: inbetween adding children to root >>> root ::' + JSON.serialize(root));
        }

        node tmpRoot = root;
        System.debug(':: inbetween stages >>> root ::' + JSON.serialize(root));

        // Build / LevelDown / ParentNodeMap
        Map<Id, node> parentNodes = new Map<Id, node>();
        parentNodes.put(root.ec.Id, root);
        parentNodes = getChildrenAsParent(parentNodes); // new parent nodes...
        System.debug(':: after stages >>> root ::' + JSON.serialize(root));
        System.debug(':: after stages >>> parentNodes ::' + JSON.serialize(parentNodes));
        // Stages end...
        

        // Forms
        // query Forms... w/parentNodeMap.keySet()
        for (Enrollment_Component_Relationship__c ecr : queryECRs(parentNodes.keySet())) {
            // create a childNode
            node tmpNode = new node(
                new Enrollment_Component__c(
                    id = ecr.Child_Enrollment_Component__c, 
                    Name = ecr.Child_Enrollment_Component__r.Name,
                    Description__c = ecr.Child_Enrollment_Component__r.RecordType.Name + '::' + ecr.Order__c,
                    Assignment_Logic__c = ecr.Child_Enrollment_Component__r.Assignment_Logic__c, 
                    Completion_Logic__c = ecr.Child_Enrollment_Component__r.Completion_Logic__c,
                    RecordTypeId = ecr.Child_Enrollment_Component__r.RecordTypeId
                ));
            // add to the parent
            parentNodes.get(ecr.Parent_Enrollment_Component__c).addChild(tmpNode);
        }
        // #2 alternatively, collect all childrent with same parent & the exit loop.
        // #2 now add to the parent after collecting parent -> childrentMap
        // parentMap.get(child.parentId).addChildren(children)

        // Build / LevelDown / ParentNodeMap
        parentNodes = getChildrenAsParent(parentNodes); // new parent nodes...
        System.debug(':: after Forms >>> root ::' + JSON.serialize(root));
        System.debug(':: after Forms >>> parentNodes ::' + JSON.serialize(parentNodes));
        // Forms end...

        // commit to a new EC record.
        // commitProcessTree(JSON.serialize(root));

        // Sections...
        // query sections... w/parentNodeMap.keySet()
    }

    public static void commitProcessTree(String acaPgmTree) {
        Enrollment_Component__c ecNew 
                = new Enrollment_Component__c(Name = 'AcademicProgramTree', ProcessTree__c = acaPgmTree);
        insert ecNew;
        System.debug('newEC::' + JSON.serialize(ecNew));      
    }

    public static node importProcessTree(String payload) {
        node pak; 
        try {        
            pak = (node)JSON.deserializeStrict(payload, academicProgram.node.class);
        } 
        catch (Exception ex) {
            system.debug(ex.getMessage());
            throw new ProcessTreeImportException('acaPgmImport:importProcessTree: Unable to parse payload.');
        }
        return pak;
    }

    // // Parser 
    //     Map<Kind ==> KindRecords>
    //     Stage => Stage
    //     Forms => Forms
    //     map.get(stages) > 

    public static void testImport() {
        Enrollment_Component__c acaPgmEC = [Select Id, ProcessTree__c, 
            Name from Enrollment_Component__c where id = 'a0f0n000001VAoJAAW'];
        node importProgramTree = importProcessTree(acaPgmEC.ProcessTree__c);
        System.debug(JSON.serialize(importProgramTree));
    }

    public static void testJSONParser() {

        Enrollment_Component__c acaPgmEC = [Select Id, ProcessTree__c, 
            Name from Enrollment_Component__c where id = 'a0f0n000001VAoJAAW'];

        node importProgramTree = importProcessTree(acaPgmEC.ProcessTree__c);

        JSONParser parser = JSON.createParser(acaPgmEC.ProcessTree__c);
        while (parser.nextToken() != null) {

            System.debug(parser.getText());
            parser.nextToken();

            // if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            //     (parser.getText() == 'totalPrice')) {
            //     // Get the value.
            //     parser.nextToken();
            //     // Compute the grand total price for all invoices.
            //     grandTotal += parser.getDoubleValue();
        }
    } 

    public static void testJSONParserWIP() {

        Enrollment_Component__c acaPgmEC = [Select Id, ProcessTree__c, 
            Name from Enrollment_Component__c where id = 'a0f0n000001VAoJAAW'];

        node importProgramTree = importProcessTree(acaPgmEC.ProcessTree__c);

        JSONParser parser = JSON.createParser(acaPgmEC.ProcessTree__c);
        while (parser.nextToken() != null) {

            if (parser.getText().containsIgnoreCase('Stage')) {
                System.debug('::stage token::' + parser.getText());
                parser.nextToken();
                System.debug('::nxtToken for Stage::' + parser.getText());
            }

            // if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            //     (parser.getText() == 'totalPrice')) {
            //     // Get the value.
            //     parser.nextToken();
            //     // Compute the grand total price for all invoices.
            //     grandTotal += parser.getDoubleValue();
        }
    }

    public class ProcessTreeImportException extends Exception {}

*/
}



/**
 * @todo: 
 *  a. parse the Tree
 *  b. Add Recursive bit inside
 * 
 */