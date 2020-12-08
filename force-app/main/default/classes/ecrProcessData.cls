/**
    @class:         ecrProcessData           
	@description:   Data Class to hold Academic Program related data based on ECRs.
	@author: 		Mark Membrino
	@createdDate:   9/10/2020
*/
public class ecrProcessData 
{   
    public Id processId {get; set;} // process
    public Id academicProgramId {get; set;} // academicProgram
    public ecNode root {get; set;}
    public Integer version {get; set;}
    public Id activeStage {get; set;}
    public Id lastStage {get; set;}
    public Integer steps {get; set;}
    public Set<String> ecTypes {get; set;} 
    public Integer countECs {get; set;}
    public List<Id> stages {get; set;}
    public Map<Id, List<Id>> ecParentToChildrenMap {get; set;}
    public Map<Id, List<Id>> ecChildToParentsMap {get; set;}
    public Map<Id, List<Id>> stageToChildrenECMap {get; set;}
    public Map<Id, Enrollment_Component_Relationship__c> childECToECRMap {get; set;}

    public ecrProcessData() 
    {
        this.version = 0;
        this.steps = 0;
        this.countECs = 0;
        this.ecTypes = new Set<String>();
        this.stages = new List<Id>();
        this.ecParentToChildrenMap = new Map<Id, List<Id>>();
        this.ecChildToParentsMap = new Map<Id, List<Id>>();
        this.stageToChildrenECMap = new Map<Id, List<Id>>();
        this.childECToECRMap = new Map<Id, Enrollment_Component_Relationship__c>();
    }

    public ecrProcessData(Id processId) 
    {
        this();
        this.processId = processId;
    }

    public ecrProcessData(Id processId, Id acaPgmId) 
    {
        this(processId);
        this.academicProgramId = acaPgmId;
    }

    public void setRoot(ecNode root) {
        this.root = root;
    }
}