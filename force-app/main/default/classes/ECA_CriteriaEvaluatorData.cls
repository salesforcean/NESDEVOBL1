/**
 *  @author:
 *  @Created on: 
 *  @User Story: 
    @Purpose: This class handles following 
        -> 
        -> 
    @Usage: 
        
 */
public class ECA_CriteriaEvaluatorData { // ecrProcessData
    
    public Id processId {get; set;} // process
    public Id activeStage {get; set;}
    public Id lastStage {get; set;}
    public List<Id> stages {get; set;}
    public Map<Id, List<Id>> parentToChildrenECMap {get; set;}
    public Map<Id, List<Id>> childToParentsECMap {get; set;}
    public Map<Id, List<Id>> stageToChildrenECMap {get; set;}
    public Map<Id, Enrollment_Component_Relationship__c> childECToECRMap {get; set;}

    public ECA_CriteriaEvaluatorData() {
        this.stages = new List<Id>();
        this.parentToChildrenECMap = new Map<Id, List<Id>>();
        this.childToParentsECMap = new Map<Id, List<Id>>();
        this.stageToChildrenECMap = new Map<Id, List<Id>>();
        this.childECToECRMap = new Map<Id, Enrollment_Component_Relationship__c>();
    }

    public void setRoot(Id root) {
        this.processId = root;
    }

}