/**
 *  @author: Ali KM (Ness Tech)
 *  @Created On: 04/09/2020
 *  @User Story: 
    @Purpose: This class handles following 
        -> 
        -> 
    @Usage: 
        
 */
public class ecrConsumerFormat {

    public Id sourceID {get; set;}

    public Integer version {get; set;}

    // { Kind : [type_Id] } // Ex: {Stage => [ecrID], Form => [ecrID], ...}
    public Map<String, List<Id>> ecrTypesMap {get; set;}

    // { parent : [children_Id] } // Ex: {Process => [Stages.ecrID], Stage => [Forms.ecrID], ...}
    public Map<Id,List<Id>> ecrParentChildMap {get; set;}

    // { ecrID : ecr_Node } // Ex: { ecrStage.ID => ecrNodeStage, ...}
    public Map<Id, ecNode> ecrNodesMap {get; set;}

    // { ecrID : ecID } // Ex: { 'a0e0n00000BnGDaAAN' => 'a0f0n000001IAV2AAO', ... }
    public Map<Id, Id> ecrECMap {get; set;}

    // { level : ecrIDs } // E: { 1 => [All Stage IDs....], 2 => >[All Forms IDs...] }
    public Map<Integer, List<Id>> ecrIDsByLevel {get; set;}

    public ecrConsumerFormat(Id sourceID) {
        this.sourceID = sourceID;
        this.ecrTypesMap = new Map<String, List<Id>>();
        this.ecrParentChildMap = new Map<Id,List<Id>>();
        this.ecrNodesMap = new Map<Id, ecNode>();
        this.ecrECMap = new Map<Id, Id>(); // may-not be needed.
        this.ecrIDsByLevel = new Map<Integer, List<Id>>();
        
    }

    public ecrConsumerFormat(Id sourceID, Integer version) {
        this(sourceID);
        this.version = version;
    }

    public void setEcrIDsByLevel(Integer level, Id ecrID) {
        List<Id> placeHolder;
        if ((placeHolder = this.ecrIDsByLevel.get(level)) == null) {
            this.ecrIDsByLevel.put(level, placeHolder = new List<Id>());
        }
        placeHolder.add(ecrID);
    }
    

    // @TODO: 
    // getChildren()
    // getECRRec()
    // getECRed()

}