public with sharing class ecNodeParser {
    
    /**
	* 	@ALIKM 20/apr/2020- commenting out changes

    public Id rootID {get; private set;}
    public Enrollment_Component__c rootRec {get; private set;}

    public ecNodeParser(String rootID) {
        try {
            this.rootID = Id.valueOf(rootID);
            this.rootRec = getECsByID(new List<Id>{rootID})[0];
        } catch (Exception ex ) {
            throw new illegalArgumentNodeParserException('invalid Enrollment_Component__c id:' + rootID  + '; Exception:' + ex.getMessage());
        }
    }

    /**
     * @Usage: 
        academicProgram.createProcessTree('a0f0n000001IAQ2AAO');
        @todo: Make this recursive.

        ecNodeParser parser = new ecNodeParser('a0f0n000001IAQ2AAO');
        parser.parse(); // returns payload
        parser.commit(); // return recId post commit



    // public String parse() {
    public void parse() {
       
        ecNode root = new ecNode(rootRec);
        

        // Stages
        // query stages...
        for (Enrollment_Component_Relationship__c ecr : queryECRs(new Set<Id>{rootID})) {
            root.addChild(new ecNode(ecr)); // collect the parents here...
            // System.debug(':: inbetween adding children to root >>> root ::' + JSON.serialize(root));
        }

        ecNode tmpRoot = root;
        System.debug(':: inbetween stages >>> root ::' + JSON.serialize(root));

        // Build / LevelDown / ParentNodeMap
        Map<Id, ecNode> parentNodes = new Map<Id, ecNode>();
        parentNodes.put(root.nodeId, root);
        parentNodes = getChildrenAsParent(parentNodes); // new parent nodes...
        System.debug(':: after stages >>> root ::' + JSON.serialize(root));
        System.debug(':: after stages >>> parentNodes ::' + JSON.serialize(parentNodes));
        // Stages end...
        

        // Forms
        // query Forms... w/parentNodeMap.keySet()
        for (Enrollment_Component_Relationship__c ecr : queryECRs(parentNodes.keySet())) {
            // create a childNode
            ecNode tmpNode = new ecNode(ecr);
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

    // query the ProcessRecord
    public static List<Enrollment_Component__c> getECsByID(List<Id> ecIDs) {
        return [SELECT  Id, 
                        Name, 
                        Assignment_Logic__c, 
                        RecordTypeId, 
                        RecordType.Name, 
                        Completion_Logic__c,
                        Is_Required__c
                FROM    Enrollment_Component__c 
                WHERE   Id =: ecIDs];
    }
    

    // query ECR records...
    private static List<Enrollment_Component_Relationship__c> queryECRs(Set<Id> parentIDs) {       
        return [SELECT  Id, Order__c, 
                    Parent_Enrollment_Component__c,
                    Parent_Enrollment_Component__r.Id, 
                    Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, 
                    Child_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Id, 
                    Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.Assignment_Logic__c,  
                    Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, 
                    Child_Enrollment_Component__r.Completion_Logic__c,
                    Child_Enrollment_Component__r.Is_Required__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Parent_Enrollment_Component__c =: parentIDs
            //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
            ORDER BY Order__c ASC];
    }

    // move the children up to Parent for the next iteration...
    private static Map<Id, ecNode> getChildrenAsParent(Map<Id, ecNode> parentNodes) { 
        Map<Id, ecNode> parentNodeMapTmp = new Map<Id, ecNode>();
        for (String id : parentNodes.keySet()) {
            parentNodeMapTmp.putAll(parentNodes.get(id).getChildrenAsMap());
        }
        return parentNodeMapTmp;
    }

    public class illegalArgumentNodeParserException extends Exception {}
	*/

}