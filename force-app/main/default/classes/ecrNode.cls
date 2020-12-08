/**
 *  @TODO: 
 *      1. rename to ecrNode 
 */
public class ecrNode { // rename to ecrNode

    /** 
	* 	@ALIKM 20/apr/2020- commenting out changes
        public Id parentId {get; private set;} // parent.ec.ID
        public Id nodeId {get; private set;} // ecr.ID / ec.ID
        // public Id ecrId {get; private set;} // ecr.ID
        public Id ecId {get; private set;} // ec.ID
    
        public List<ecrNode> children {get; private set;}
    
        // public String kind {get; private set;} // ec.rectype.Name
        // public String name {get; private set;} // ec.ID
        // public Integer order {get; private set;} // ecr.Order__c
    
        public Enrollment_Component_Relationship__c ecrRec {get; private set;} // experimental
    
    
        public ecrNode(ecrNode srcNode) {
    
            this.parentId = srcNode.parentId;
            this.nodeId = srcNode.nodeId;
            // this.ecrId = srcNode.ecrId;
            this.ecId = srcNode.ecId;
    
            this.children = new List<ecrNode>();
    
            // this.kind = srcNode.kind;
            // this.name = srcNode.name;
            // this.order = srcNode.order;
            
            this.ecrRec = srcNode.ecrRec; // experimental
    
        }
    
        public ecrNode(Enrollment_Component__c ec) {
    
            this.nodeId = ec.Id;
            this.ecId = ec.Id;
    
            this.children = new List<ecrNode>();
    
            // this.kind = ec.RecordType.Name;
            // this.name = ec.name;
    
        }
    
        public ecrNode(Enrollment_Component_Relationship__c ecr) {
    
            // this.parentId = ecr.Parent_Enrollment_Component__c;
            // this.nodeId = ecr.Child_Enrollment_Component__c;
            this.nodeId = ecr.Id;
            // this.ecrId = ecr.Id;
            this.ecId = ecr.Child_Enrollment_Component__c;
    
            this.children = new List<ecrNode>();
            
            // this.kind = ecr.Child_Enrollment_Component__r.RecordType.Name;
            // this.name = ecr.Child_Enrollment_Component__r.Name;
            // this.order = (Integer) ecr.Order__c;
            this.ecrRec = ecr; // experimental
        }
    
    
        public void setParent(Id nodeId) {
            this.parentId = nodeId;
        }
    
    
        public void addChildren(ecrNode child) {
            addChildren(new List<ecrNode>{child});
        }
    
    
        public void addChildren(List<ecrNode> children) {
    
            for (ecrNode child: children) {
                child.setParent(this.nodeId);
            }
            this.children.addAll(children);
            
        }
    
    
        public Map<Id, ecrNode> getChildrenAsMap() { 
    
            Map<Id, ecrNode> dataToECNodeMap = new Map<Id, ecrNode>();
            for (ecrNode child : this.children) {
                dataToECNodeMap.put(child.nodeId, child);
            }
            return dataToECNodeMap;
    
        }
    
        // // Deprecated
        // public void removeChildren() {
        //     this.children.clear();
        // }
	*/
    
}