/**    
    @Usage: 
        ecTreeGenerator ecTree = new ecTreeGenerator('a0f0n000001IAQ2AAO');
        ecTree.generate();
        System.debug(ecTree.save()); // returns newly created ecrTree__c recordID

    @Query: 
        SELECT  Id, Name, CreatedDate, isActive__c, ParentID__c, Type__c, Version__c, ecTreeHeight__c, ecCount__c, ecTypes__c, ParentExtID__c
        FROM    ecrTree__c 
        ORDER BY CreatedDate DESC

    testing purposes: 
        ecrNodeQueue
        ecTreeGenerator
        ecrNode
        programExportFormat
        ecTreeParser (not yet used)

 */
public class ecTreeGenerator {
    
    /**
    *   @ALIKM 20/apr/2020- commenting out changes

    private Id rootID;
    private Enrollment_Component__c rootRec;
    
    public ecrNode root {get; private set;}
    public programExportFormat config {get; private set;}

    // constructor
    public ecTreeGenerator(String rootID) {

        try {

            this.rootID = Id.valueOf(rootID);
            this.rootRec = ecrTreeUtils.getECsByID(new List<Id>{rootID})[0];
            if (this.rootRec!=null) {
                this.root = new ecrNode(this.rootRec);
                this.config = new programExportFormat(this.root);
            }
                
        } catch (Exception ex ) {
            throw new illegalArgumentECTreeGeneratorException('invalid Enrollment_Component__c rootID:' + rootID  + '; Exception:' + ex.getMessage());
        }
          
    }


    /**
     * 
     * Using BFS w/iteration to build the tree
     
    public void generate() {

        if (this.root==null) {return;}
        
        Map<Id, ecrNode> ecrNodeMapParent = new Map<Id, ecrNode>{this.root.nodeId => this.root}; 
        programExportFormat config = this.config;
        
        // WIP ALI 1
        // config.ecTypes.add(this.root.kind);
        
        // config.countECs += ecrNodeMapParent.size();
        
        // overloading a 'queue for list of strings' to handle 'any' type of List, in this case a list of deserialized map of ecrNodes.
        ecrNodeQueue q = new ecrNodeQueue();
        q.enqueue(ecrNodeMapParent); 

        while (!q.isEmpty()) {
            
            ecrNodeMapParent = q.dequeue();

            // gathering stats...
            config.countECs += ecrNodeMapParent.size();
            config.steps++;

            // System.debug('::step>>>' + config.steps + '>>>ecrNodeMapParent>>>' + JSON.serialize(ecrNodeMapParent));

            // tmpMap, to gather the children
            Map<Id, ecrNode> ecrNodeMapChildrenTmp = new Map<Id, ecrNode>();

            for (Enrollment_Component_Relationship__c ecr : ecrTreeUtils.queryECRs(ecrNodeMapParent.keySet()))
            {
                
                ecrNode child = new ecrNode(ecr); // create a child Node
                // WIP ALI 2
                // config.ecTypes.add(child.kind); // collecting stats => ecTypes
                ecrNodeMapParent.get(ecr.Parent_Enrollment_Component__c).addChildren(child);// add child to parentNode
                ecrNodeMapChildrenTmp.put(ecr.Child_Enrollment_Component__c, child); // tmp map to hold child ec -> ecrNode
            }

            if (ecrNodeMapChildrenTmp.size()>0) {
                q.enqueue(ecrNodeMapChildrenTmp);
            }

        }

        System.debug('Queue Ended::FinalStepCount>>>' + config.steps + '>>>ecrNodeMapParent>>>' + JSON.serialize(this.root));
        System.debug('::config>>>' + JSON.serialize(this.config));

    }


    /**
     *  save programExportFormat to the database object
     *  
     
    public Id save() {

        // ecrNode root = this.root;
        programExportFormat config = this.config;
        
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
        
        ecrTree__c newConfig = createECRTreeRec(config); // create new record

        insert newConfig;
        update toUpdate; // update only after newConfig is save successfully

        return newConfig.Id;
        
    }

    public static ecrTree__c createECRTreeRec(programExportFormat config) {
        
        List<String> ecTypesList = new List<String>();
        ecTypesList.addAll(config.ecTypes); // converting ecTypes from set to list

        ecrTree__c newConfig = new ecrTree__c(
            ParentID__c = config.root.nodeId,
            isActive__c = true,
            // WIP ALI 3
            Type__c =  'Process', //config.root.kind,
            ecTreeHeight__c = config.steps, 
            ecCount__c = config.countECs, 
            ecTypes__c = String.join(ecTypesList, ','),
            Payload__c = JSON.serialize(config.root),
            Version__c = String.valueOf(config.version)
        );

        return newConfig;

    }


    public class illegalArgumentECTreeGeneratorException extends Exception {}

    */
    

}