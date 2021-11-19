/**
    @Author: ALI KM 
    @Purpose:  Created this class to fetch all the ECAs based on ECRs for a given ProcessID
    @Usage: see run() method 

 */

public class eca_test {
    
    /**
     *  @ALIKM 20/apr/2020- commenting out changes
    // programExportFormat
    // root
    // version
    // depthCon
    // countECRs
    // countECs
    // ecTypes

    // public class ecNode {
    //     public Map<Id, ecNode> ecNodeMap {get; set;}
    //     public mapData() {
    //         ecNodeMap = new Map<Id, ecNode>();
    //     }
    // }

    public static String serializeNodesMap(Map<Id, ecNode> ecNodeMap) {
        return JSON.serialize(ecNodeMap);
    }

    public static Map<Id, ecNode> deserializeNodesMap(String ecNodeMapSerialized) {
        return (Map<Id, ecNode>) JSON.deserialize(ecNodeMapSerialized,Map<Id, ecNode>.class);
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
                    Child_Enrollment_Component__r.Is_Required__c,
                    Child_Enrollment_Component__r.External_Id__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Parent_Enrollment_Component__c =: parentIDs
            //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
            ORDER BY Order__c ASC];
    }

    // query the ProcessRecord
    public static List<Enrollment_Component__c> getECsByID(List<Id> ecIDs) {
        return [SELECT  Id, 
                        Name, 
                        Assignment_Logic__c, 
                        RecordTypeId, 
                        RecordType.Name, 
                        Completion_Logic__c,
                        Is_Required__c,
                        External_Id__c
                FROM    Enrollment_Component__c 
                WHERE   Id =: ecIDs];
    }
 
    /**
     * @Usage: 
        Enrollment_Component__c rootRec = eca_test.getECsByID(new List<Id>{Id.valueOf('a0f0n000001IAQ2AAO')})[0];
        programExportFormat pgmExportFormat = new programExportFormat();
        pgmExportFormat.root = new ecNode(rootRec);
        eca_test.generateECTree(pgmExportFormat);
     * 
     * 

    public static void generateECTree(programExportFormat pgmExport) { // return programExportFormat

        
        ecNode root = pgmExport.root;
        Map<Id, ecNode> ecNodeMapParent = new Map<Id, ecNode>{root.nodeId => root}; // holds the parent EC => ecNode mapping
        // ecNodeMapParent.put(root.nodeId, root);

        ecNodeQueue q = new ecNodeQueue();
        q.enqueue(ecNodeMapParent); // overloading a 'queue for list of strings' to handle 'any' type of List, in this case a list of deserialized map of ecNodes.
        Integer step = 0;
        while (!q.isEmpty()) {

            step++;
            ecNodeMapParent = q.dequeue();
            System.debug('::step>>>' + step + '>>>ecNodeMapParent>>>' + JSON.serialize(ecNodeMapParent));

            // tmpMap, to gather the children
            Map<Id, ecNode> ecNodeMapChildrenTmp = new Map<Id, ecNode>();

            for (Enrollment_Component_Relationship__c ecr : queryECRs(ecNodeMapParent.keySet()))
                // [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Id, Child_Enrollment_Component__r.RecordTypeId,
                //     Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Order__c
                // FROM Enrollment_Component_Relationship__c
                // WHERE Parent_Enrollment_Component__c IN : ecNodeMapParent.keySet()]) 
            {
                // create a child Node
                ecNode child = new ecNode(ecr);

                // add child to parentNode
                ecNodeMapParent.get(ecr.Parent_Enrollment_Component__c).addChildren(child);
                
                // tmp map to hold child ec -> ecNode
                ecNodeMapChildrenTmp.put(ecr.Child_Enrollment_Component__c, child);
            }

            if (ecNodeMapChildrenTmp.size()>0) {
                q.enqueue(ecNodeMapChildrenTmp);
            }

        }

        System.debug('Queue Ended::FinalStepCount>>>' + step + '>>>ecNodeMapParent>>>' + JSON.serialize(pgmExport.root));
    }


     public static List<Enrollment_Component__c> getChildren(List<Enrollment_Component__c> parentECs, EC_Parser_Data data) {
        
        // get an instance of dataObject
        // EC_Parser_Data data = EC_Parser_Data.getInstance(); 
        // set depthCon
        data.depthCon++;
        List<Enrollment_Component__c> newChildECs = new List<Enrollment_Component__c>();

        System.debug(':: parentECs ::' + JSON.serialize(parentECs.size())); // 'depthCon::' + depthCon + 
        System.debug(':: DATA :: depthCon ::' + data.depthCon + '::allECs count::' + data.allECs.size()+ ':: allECRs count::' + data.allECRs.size());

        if ([SELECT count() FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :parentECs]<1) {
            return parentECs;
        } else {
            for (Enrollment_Component_Relationship__c ecr : 
                [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Id, Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Order__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN : parentECs]) 
            {
                Enrollment_Component__c tmpEC = new Enrollment_Component__c (
                    id=ecr.Child_Enrollment_Component__c,
                    recordtypeId = ecr.Child_Enrollment_Component__r.RecordTypeId,
                    Name = ecr.Child_Enrollment_Component__r.RecordType.Name + ':: Order=>' + ecr.Child_Enrollment_Component__r.Order__c, // showing the REC_TYPE as NAME fld.
                    Completion_Logic__c = ecr.Child_Enrollment_Component__r.Completion_Logic__c,
                    Assignment_Logic__c = ecr.Child_Enrollment_Component__r.Assignment_Logic__c);

                newChildECs.add(tmpEC);
                data.addEC(tmpEC);
                data.addECR(ecr);
            } 
            
            
            
            // fetch children recursively
            List<Enrollment_Component__c> tmpECRs = getChildren(newChildECs, data);
            if (tmpECRs!=null && tmpECRs.size()>0)
                parentECs.addAll(tmpECRs);

            return parentECs;
        }

    }

     public static void run() {

        EC_Parser_Data data = new EC_Parser_Data(); 
        System.debug(':: data before ::' + JSON.serialize(data));
        List<Enrollment_Component__c> parentECs = new List<Enrollment_Component__c>{new Enrollment_Component__c(id='a0f0n0000003dhAAAQ')}; // 'a0f0n0000003dhAAAQ', 'a0f0n000001IAQ2AAO'
        List<Enrollment_Component__c> allChildECs = eca_test.getChildren(parentECs, data);
        System.debug('allchildECs with parent size:' + allChildECs.size());
        System.debug(':: data after ::' + JSON.serialize(data));
        System.debug(JSON.serialize(allChildECs));

    }

    // public static void run() {

    //     EC_Parser_Data data = EC_Parser_Data.getInstance(); 
    //     System.debug(':: data before ::' + JSON.serialize(data));
    //     List<Enrollment_Component__c> parentECs = new List<Enrollment_Component__c>{new Enrollment_Component__c(id='a0f0n0000003dhAAAQ')}; // 'a0f0n0000003dhAAAQ', 'a0f0n000001IAQ2AAO'
    //     List<Enrollment_Component__c> allChildECs = eca_test.getChildren(parentECs, 0);
    //     System.debug('allchildECs with parent size:' + allChildECs.size());
    //     System.debug(':: data after ::' + JSON.serialize(data));
    //     System.debug(JSON.serialize(allChildECs));

    // }
    
    */
    
    
}

// base condition

// public eca_test(List<Enrollment_Component__c> parentECs) {
//     this.parentECs = parentECs;
// }

//     // ProcessID => Stages => FORM => Questions / Sections ...

//     public List<Enrollment_Component__c> buildTopDownTree(List<Enrollment_Component__c> parentECs) {

//         // List<Enrollment_Component__c> allChildECs = new List<Enrollment_Component__c>();    
//         List<Enrollment_Component__c> newECs = new List<Enrollment_Component__c>();

//         for (Enrollment_Component_Relationship__c ecrs : 
//             [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Id, 
//                 Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Assignment_Logic__c
//             FROM Enrollment_Component_Relationship__c
//             WHERE Parent_Enrollment_Component__c IN : parentECs]) 
//         {
//             newECs.add(Child_Enrollment_Component__c);
//         }

//         // if (newECs.size()==0) {
//         //     return;
//         // }
//         // else {
//         //     childECs.add(newECs)
//         // }
        
//         if (newECs.size()==0) {
//             return;
//         }
//         else {
//             childECs.add(newECs);
//             buildTopDownTree(newECs);
//         }

//         reutrn childECs;
//         l1'=-

//     }
// }

// // Child_Enrollment_Component__c

// SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Id, Child_Enrollment_Component__r.RecordType.Name, 
//     Child_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Assignment_Logic__c
// FROM Enrollment_Component_Relationship__c
// WHERE Parent_Enrollment_Component__c IN 

// // ('a0f0n000001IBz5AAG', 'a0f0n000001IBz6AAG', 'a0f0n000001IBzAAAW', 'a0f0n000001IAOyAAO', 'a0f0n000001IAP1AAO', 'a0f0n000001IAP2AAO', 'a0f0n000001IAP4AAO', 'a0f0n000001IBfUAAW')


// List<Enrollment_Component__c>> allECs = new List<Enrollment_Component__c>();


// zero statment: 
//     if query.count() = 0
//         return;

// recursive stmnt: 
//     if (getChildren)
//     return (newQueriedRecs + getChildren(newQueriedRecs));

//     return ( + getChildren(newQueriedRecs));

//     allECs.add(newQueriedRecs)
//     tmpRecs = getChildren(newQueriedRecs)
//     if tmpRecs.size()>0
//         allECs.add(tmpRecs);
//     return allECs;