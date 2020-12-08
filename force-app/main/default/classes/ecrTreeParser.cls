/**
 * 
 *  
    SELECT  Id, Name, CreatedDate, isActive__c, ParentID__c, Type__c, Version__c, ecTreeHeight__c, ecCount__c, ecTypes__c, ParentExtID__c
    FROM    ecrTree__c 
    WHERE isActive__c = true 
    ORDER BY CreatedDate DESC   
    
    @FUTURE IMPROVEMENTS: 
        Add more functionality to ecrTreeParser.cls, like:
            -> find element & return path to parent
            -> find sub-tree in the tree & return sub-tree (ex: Stage & its subTree)

    @Usage: 
        String  ecParentID= 'a0f0n000001IAQ2AAO';
        ecrTreeParser parser = new ecrTreeParser(ecParentID);
        ecrConsumerFormat result = parser.parse();
        System.debug('>>result>>' + JSON.serialize(result));

*/
public class ecrTreeParser {

    private Id ecParentID;
    private ecrTree__c ecrTreeRec; 

    public ecNode rootNode {get; private set;}
    public ecrConsumerFormat ecrImportFormat {get; private set;}

    // constructor
    public ecrTreeParser(String ecParentID) {

        try {

            this.ecParentID = Id.valueOf(ecParentID);

            if (!ecrTreeUtils.doesECRecordExist(this.ecParentID)) {
                throw new ecrTreeImportException('No ecrTree__c records found for EC parentID: ' + this.ecParentID);
            }

            this.ecrTreeRec = ecrTreeUtils.getECRTreeByParentIDs(ecParentID);
            this.ecrImportFormat = new ecrConsumerFormat(this.ecParentID, Integer.valueOf(this.ecrTreeRec.Version__c));
            this.deserialize();
                
        } catch (Exception ex ) {

            throw new ecrTreeIllegalArgumentException('invalid ecrTree__c parentId:' + ecParentID  + '; Exception:' + ex.getMessage());

        }
          
    }

    
    /**
     *  Parse ecrTree using bfs.
     */
    public ecrConsumerFormat parse() {

        ecrConsumerFormat ecrImport = this.ecrImportFormat;
        ecNode root = this.rootNode;
        
        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(new Map<Id, ecNode>{root.nodeId => root});

        Integer level = 0;
        // ecrImport.ecrIDsByLevel

        Map<Id, ecNode> ecNodeTemp; // temp loop variable
        while (!q.isEmpty()) { 
            
            ecNodeTemp = q.dequeue(); 
            // this is all parentIDs
            // ecrImport.ecrIDsByLevel.put(level++, new List<Id>(ecNodeTemp.keySet()));

            for (Id ndID : ecNodeTemp.keySet()) {
                
                ecNode curr = ecNodeTemp.get(ndID); 
                q.enqueue(curr.getChildrenAsMap());

                // collect level -> ecrIDs Map
                ecrImport.setEcrIDsByLevel(curr.level, curr.nodeId);

                // collect all ECRs
                ecrImport.ecrNodesMap.put(curr.nodeId, ecrTreeUtils.ecrNodeClone(curr)); // use ecrNodeClone() to avoid deep copy of children.

                // collect all ECRs => ECs
                ecrImport.ecrECMap.put(curr.nodeId, curr.ecId);
                
                // // build ecrImport.ecrTypesMap => NOT NEEDED
                // List<Id> tmpTypeRecs;
                // if ((tmpTypeRecs = ecrImport.ecrTypesMap.get(curr.kind)) == null) {
                //     ecrImport.ecrTypesMap.put(curr.kind, tmpTypeRecs = new List<Id>());
                // }
                // tmpTypeRecs.add(curr.nodeId);
                
                
                // // build ecrImport.ecrParentChildMap => NOT NEEDED                
                // if (curr.parentId==null) {continue;} // if curr.parent is null don't execute below code
                // List<Id> tmpChildren;
                // if ((tmpChildren = ecrImport.ecrParentChildMap.get(curr.parentId)) == null) {
                //     ecrImport.ecrParentChildMap.put(curr.parentId, tmpChildren= new List<Id>());
                // }
                // tmpChildren.add(curr.nodeId);
                
            }
            
        }
        
        // System.debug('ecrImport.ecrParentChildMap.size>>>' + 
        // ecrImport.ecrParentChildMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrParentChildMap));
        
        // System.debug('ecrImport.ecrTypesMap.size>>>' + 
        // ecrImport.ecrTypesMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrTypesMap));
        
        // System.debug('ecrImport.ecrNodesMap.size>>>' + 
        // ecrImport.ecrNodesMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrNodesMap));

        // System.debug('ecrImport.ecrECMap>>>' + ecrImport.ecrECMap.size() + '>>>values>>' + ecrImport.ecrECMap.values());        
        
        // System.debug('this.ecrImportFormat>>>' + this.ecrImportFormat);
        return this.ecrImportFormat;
        
    }
    

    /**
     * 
     */
    private void deserialize() {
        
        String payload = this.ecrTreeRec.Payload__c;
        ecNode pak; 

        try {        

            pak = (ecNode) JSON.deserializeStrict( payload, ecNode.class );

        } 
        catch (Exception ex) {
            throw new ecrTreeImportException('ecrTreeParser Exception, unable to deserialize payload. Exception:' + ex.getMessage());
        }

        this.rootNode = pak;

    }


    // exception classes...
    public class ecrTreeImportException extends Exception {}
    public class ecrTreeIllegalArgumentException extends Exception {}

}