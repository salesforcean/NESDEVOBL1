/**
 * Usage:
Id processID = 'a0f0n000001IAQ2AAO';
ECParser ecParse = new ECParser(Id.valueOf(processId));
ecParse.process();

    // Select Id, Process_JSON__c
    // FROM processOutput__mdt
    // ORDER BY SystemModstamp DESC							
 */
public without sharing class ECParser {
    
    /**
	 * 	@ALIKM 20/apr/2020- commenting out changes

        public enum Type {STUDENT,PROCESS,STAGE,MESSAGE,FORM,FLAG,SECTION,DOCUMENT,QUESTION,TEXT,QUESTIONGROUP}
    
    
        public Id processId {get; private set;}
    
        public ECParser(Id processId) {
            this.processId = processId;
        }
    
        public void process() {
            
            // get the ECs tied to the process
            // ECRs: parent -> children
            Map<Id, List<Id>> parentToChildren = new Map<Id, List<id>>();
    
            // ECRs: children -> parent
            Map<Id, Id> childToParent = new Map<Id, Id>();
    
            // dup children
            List<Id> duplicateChildren = new List<Id>();
    
            // fetch the root/process record
            Enrollment_Component__c processRec = [SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Id = : this.processId];
            ECNode root = new ECNode(null, processRec.Id, Type.PROCESS);
    
            // fetch the stage records
            for (Enrollment_Component_Relationship__c ecr : [
                SELECT Child_Enrollment_Component__c, Child_Enrollment_Component__r.Id, Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.Assignment_Logic__c, Id, Order__c, Parent_Enrollment_Component__c,
                    Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Id, Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = : processRec.Id
                AND Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT ORDER BY Order__c 
            ]) {
    
                root.addChild(new ECNode(ecr.Parent_Enrollment_Component__r.Id, ecr.Child_Enrollment_Component__c, Type.STAGE));
                
                // add to child2Parent Map
                if (childToParent.get(ecr.Child_Enrollment_Component__c)==null){
                    childToParent.put(ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);
                } else {
                    duplicateChildren.add(ecr.Child_Enrollment_Component__c);
                }
    
                // add to parent2Children Map
                if (parentToChildren.get(ecr.Parent_Enrollment_Component__c)==null) {
                    parentToChildren.put(ecr.Parent_Enrollment_Component__c, new List<Id>{ecr.Child_Enrollment_Component__c});
                } else {
                    parentToChildren.get(ecr.Parent_Enrollment_Component__c).add(ecr.Child_Enrollment_Component__c);
                }
            }
    
            // String op = JSON.serialize(parentToChildren) + JSON.serialize(childToParent) + JSON.serialize(duplicateChildren);
            // prettyPrint(op); // Failing with STRING_TOO_LONG error.
            System.debug('nodes:' + JSON.serialize(root));
            // System.debug('parentToChildren:' + JSON.serialize(parentToChildren));
            // System.debug('childToParent:' + JSON.serialize(childToParent));
            // System.debug('duplicateChildren:' + JSON.serialize(duplicateChildren));
    
        }
    
        // wrapper class.
        public class ECNode {
            
            public String parentId {get; private set;}
            public String ecId {get; private set;}
            public Type type {get; private set;}
            public Enrollment_Component__c ecRec {get; private set;}
            public Set<ECNode> children;
    
            // public ECNode(String parentId, String ecId, Enrollment_Component__c ecRec) { // , Set<ECNode> children
                // public ECNode(String parentId, Enrollment_Component__c ecRec) { // , Set<ECNode> children String ecId, 
                public ECNode(String parentId, String ecId, Type type) { // , Set<ECNode> children String ecId,                 
                this.parentId = parentId;
                this.ecId = ecId;
                this.type = type;
                // this.ecRec = ecRec;
                // this.children = children;
            }
    
            public void addChild(ECNode child) {
                
                if (this.children == null) 
                    this.children = new Set<ECNode>();
    
                // child.parentId = this.ecId;
                this.children.add(child);
    
            }
    
            public void addChildren(Set<ECNode> children) {
    
                if (this.children == null) 
                    this.children = new Set<ECNode>();
                
                // for (ECNode child : children)
                //     child.parentId = this.ecId;
    
                this.children.addAll(children);
    
            }
    
            public List<String> getChildrenIds() {
    
                List<String> children = new List<String>();
                
                for (ECNode node : this.children)
                    children.add(node.ecId);
                
                return children;
                
            }
    
            public Set<ECNode> getChildren() {
    
                return this.children;
    
            }
        }
    
        public void prettyPrint(String strObj) {
            
            Peak_Apex_Log__c apxLog = new Peak_Apex_Log__c();
            apxLog.Content__c = strObj;
            apxLog.Class__c = 'ECParser';
            apxLog.Log_Level__c = 'INFO';
            apxLog.Method__c = 'prettyPrint';
            insert apxLog;
    
        }
	*/	
}



// Queries for reference

// SELECT Child_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Id, Order__c, Parent_Enrollment_Component__c,
//     Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
// FROM Enrollment_Component_Relationship__c
// WHERE Parent_Enrollment_Component__c = :
// AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT ORDER BY Order__c