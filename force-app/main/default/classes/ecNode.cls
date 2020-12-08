/**
 *  @TODO: 
 *      1. rename to ecrNode 
 */
public class ecNode { // rename to ecrNode

    @AuraEnabled
    public Id parentId {get; private set;} // parent.ec.ID

    @AuraEnabled
    public Id nodeId {get; private set;} // ecr.ID

    @AuraEnabled
    public Id ecrId {get; private set;} // ecr.ID

    @AuraEnabled
    public Id ecId {get; private set;} // ec.ID

    @AuraEnabled
    public String ecrExtId {get; private set;} // externalID

    @AuraEnabled
    public String ecExtId {get; private set;} // externalID

    @AuraEnabled
    public String logicAssignment {get; private set;}

    @AuraEnabled
    public String logicCompletion {get; private set;}

    @AuraEnabled
    public List<ecNode> children {get; private set;}

    @AuraEnabled
    public String kind {get; private set;} // ec.rectype.Name

    @AuraEnabled
    public String name {get; private set;} // ec.ID

    @AuraEnabled
    public Integer order {get; private set;} // ecr.Order__c

    @AuraEnabled
    public Integer level {get; private set;}


    public ecNode(ecNode srcNode) {

        this.parentId = srcNode.parentId;
        this.nodeId = srcNode.nodeId;
        this.ecrId = srcNode.ecrId;
        this.ecId = srcNode.ecId;
        this.ecrExtId = srcNode.ecrExtId;
        this.ecExtId = srcNode.ecExtId;
        this.logicAssignment = srcNode.logicAssignment;
        this.logicCompletion = srcNode.logicCompletion;

        this.children = new List<ecNode>();

        this.kind = srcNode.kind;
        this.name = srcNode.name;
        this.order = srcNode.order;
        this.level = srcNode.level;

    }

    public ecNode(Enrollment_Component__c ec, Integer level) {

        this.nodeId = ec.Id;
        this.ecId = ec.Id;
        this.ecExtId = ec.External_Id__c;
        this.ecrId = ec.Id;
        this.ecrExtId = ec.External_Id__c;
        this.logicAssignment = ec.Assignment_Logic__c;
        this.logicCompletion = ec.Completion_Logic__c;

        this.children = new List<ecNode>();

        this.kind = ec.RecordType.Name;
        this.name = ec.name;
        this.level = level;

    }

    public ecNode(Enrollment_Component_Relationship__c ecr, Integer level) {

        this.nodeId = ecr.Id;
        this.ecrId = ecr.Id;
        this.ecId = ecr.Child_Enrollment_Component__c;
        this.ecrExtId = ecr.External_Id__c;
        this.ecExtId = ecr.Child_Enrollment_Component__r.External_Id__c;
        this.logicAssignment = ecr.Child_Enrollment_Component__r.Assignment_Logic__c;
        this.logicCompletion = ecr.Child_Enrollment_Component__r.Completion_Logic__c;
        
        this.children = new List<ecNode>();
        
        this.kind = ecr.Child_Enrollment_Component__r.RecordType.Name;
        this.name = ecr.Child_Enrollment_Component__r.Name;
        this.order = (Integer) ecr.Order__c;
        this.level = level;

    }


    public void setParent(Id parentNodeId) {
        this.parentId = parentNodeId;
    }


    public void addChildren(ecNode child) {
        addChildren(new List<ecNode>{child});
    }


    public void addChildren(List<ecNode> children) {

        for (ecNode child: children) {
            child.setParent(this.nodeId);
        }
        this.children.addAll(children);
        
    }


    public Map<Id, ecNode> getChildrenAsMap() { 

        Map<Id, ecNode> dataToECNodeMap = new Map<Id, ecNode>();
        for (ecNode child : this.children) {
            dataToECNodeMap.put(child.nodeId, child);
        }
        return dataToECNodeMap;

    }
    
}