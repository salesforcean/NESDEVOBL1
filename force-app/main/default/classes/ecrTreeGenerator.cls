/**    
    @Usage: 
        ecrTreeGenerator ecTree = new ecrTreeGenerator('a0f0n000001IAQ2AAO');
        ecTree.generate();
        System.debug(ecTree.save()); // returns newly created ecrTree__c recordID

    @Query: 
        SELECT  Id, Name, CreatedDate, isActive__c, ParentID__c, Type__c, Version__c, ecTreeHeight__c, ecCount__c, ecTypes__c, ParentExtID__c
        FROM    ecrTree__c 
        ORDER BY CreatedDate DESC

 */
public class ecrTreeGenerator {

    private Id rootID;
    private Enrollment_Component__c rootRec;
    
    public ecNode root {get; private set;}
    public ecrProducerFormat config {get; private set;}

    // constructor
    public ecrTreeGenerator(String rootID) {

        try {

            this.rootID = Id.valueOf(rootID);
            this.rootRec = ecrTreeUtils.getECsByID(new List<Id>{rootID})[0];
            if (this.rootRec!=null) {
                this.config = new ecrProducerFormat(); // xtra
                this.root = new ecNode(this.rootRec, config.steps); // xtra
                this.config.setRoot(root);
                // this.config = new ecrProducerFormat(this.root);
            }
                
        } catch (Exception ex ) {
            throw new illegalArgumentECTreeGeneratorException('invalid Enrollment_Component__c rootID:' + rootID  + '; Exception:' + ex.getMessage());
        }
          
    }


    /**
     * 
     * Using BFS w/iteration to build the tree
     */
    public void generate() {

        if (this.root==null) {return;}
        
        Map<Id, ecNode> ecNodeMapParent = new Map<Id, ecNode>{this.root.nodeId => this.root}; 
        ecrProducerFormat config = this.config;
        config.ecTypes.add(this.root.kind);
        // config.countECs += ecNodeMapParent.size();
        
        // overloading a 'queue for list of strings' to handle 'any' type of List, in this case a list of deserialized map of ecNodes.
        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(ecNodeMapParent); 

        while (!q.isEmpty()) {
            
            ecNodeMapParent = q.dequeue();

            // gathering stats...
            config.countECs += ecNodeMapParent.size();
            config.steps++;

            // System.debug('::step>>>' + config.steps + '>>>ecNodeMapParent>>>' + JSON.serialize(ecNodeMapParent));

            // tmpMap, to gather the children
            Map<Id, ecNode> ecNodeMapChildrenTmp = new Map<Id, ecNode>();

            for (Enrollment_Component_Relationship__c ecr : ecrTreeUtils.queryECRs(ecNodeMapParent.keySet()))
            {
                
                ecNode child = new ecNode(ecr, config.steps); // create a child Node
                config.ecTypes.add(child.kind); // collecting stats => ecTypes
                ecNodeMapParent.get(ecr.Parent_Enrollment_Component__c).addChildren(child);// add child to parentNode
                ecNodeMapChildrenTmp.put(ecr.Child_Enrollment_Component__c, child); // tmp map to hold child ec -> ecNode
            }

            if (ecNodeMapChildrenTmp.size()>0) {
                q.enqueue(ecNodeMapChildrenTmp);
            }

        }

        // System.debug('Queue Ended::FinalStepCount>>>' + config.steps + '>>>ecNodeMapParent>>>' + JSON.serialize(this.root));
        // System.debug('::config>>>' + JSON.serialize(this.config));

    }


    /**
     *  save ecrProducerFormat to the database object
     *  
     */
    public Id save() {

        // ecNode root = this.root;
        ecrProducerFormat config = this.config;
        
        // if no payload, exit
        if (config.root==null) {
            return null;
        }

        Integer version = 0;
        List<sObject> toUpdate = new List<sObject>();
        for (ecrTree__c rec : ecrTreeUtils.getECRTreeByParentIDs(new Set<Id>{config.root.nodeId})) { // query existing records for the same node.ID
            
            Integer configVersion = Integer.valueOf(rec.Version__c);
            if (configVersion > version){
                version = configVersion; // grab the latest version
            }
            
            rec.isActive__c = false; // set older configs to inActive
            toUpdate.add(rec);

        }
        config.version = ++version; // set the version
        
        ecrTree__c newConfig = ecrTreeUtils.createECRTreeRec(config); // create new record

        insert newConfig;
        update toUpdate; // update only after newConfig is save successfully

        return newConfig.Id;
        
    }


    public class illegalArgumentECTreeGeneratorException extends Exception {}
    

}