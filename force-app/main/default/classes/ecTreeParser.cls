/**
 * 
 *  @TODO [7/apr]: 
        - finish the parse() (DONE)
        - finish Builder format (DONE)
        - write test classes
        - **MOVE ALL ERROR HANDLING TO CALLER CLASSES -> programImportExport

    SELECT  Id, Name, CreatedDate, isActive__c, ParentID__c, Type__c, Version__c, ecTreeHeight__c, ecCount__c, ecTypes__c, ParentExtID__c
    FROM    ecrTree__c 
    WHERE isActive__c = true 
    ORDER BY CreatedDate DESC   
    
    @FUTURE IMPROVEMENTS: 
        Add more functionality to this class, like:
            -> find element & return path to parent
            -> find sub-tree in the tree & return sub-tree (ex: Stage & its subTree)

    @Usage: 
        String  ecParentID= 'a0f0n000001IAQ2AAO';
        ecTreeParser parser = new ecTreeParser(ecParentID);
        parser.parse();


*/
public class ecTreeParser {
    
    /**
    *   @ALIKM 20/apr/2020- commenting out changes

        private Id ecParentID;
        private ecrTree__c ecrTreeRec; 
    
        public ecNode rootNode {get; private set;}
        public ecrConsumerFormat ecrImportFormat {get; private set;}
    
        // constructor
        public ecTreeParser(String ecParentID) {
    
            try {
    
                this.ecParentID = Id.valueOf(ecParentID);
                this.ecrTreeRec = ecrTreeUtils.getECRTreeByParentIDs(ecParentID);
    
    
                if (this.ecrTreeRec!=null) {  // @TODO, need to clean this up.
    
                    this.ecrImportFormat = new ecrConsumerFormat();
                    // this.deserializeNode();
                    this.deserialize();
    
                }
                    
            } catch (Exception ex ) {
    
                throw new ecrTreeIllegalArgumentException('invalid ecrTree__c parentId:' + ecParentID  + '; Exception:' + ex.getMessage());
    
            }
              
        }
    
        
        /**
         *  Parse ecrTree using bfs.
    
        public ecrConsumerFormat parse() {
    
            ecrConsumerFormat ecrImport = this.ecrImportFormat;
            ecNode root = this.rootNode;
            
            ecNodeQueue q = new ecNodeQueue();
            q.enqueue(new Map<Id, ecNode>{root.nodeId => root});
    
            Map<Id, ecNode> ecNodeTemp; // temp loop variable
            while (!q.isEmpty()) { 
                
                ecNodeTemp = q.dequeue();
                for (Id ecID : ecNodeTemp.keySet()) {
                    
                    ecNode curr = ecNodeTemp.get(ecID);
                    q.enqueue(curr.getChildrenAsMap());
                    
                    // collect all ECRs
                    ecrImport.ecrNodesMap.put(curr.nodeId, curr);  
                    
                    // build ecrImport.ecrTypesMap
                    List<Id> tmpTypeRecs;
                    if ((tmpTypeRecs = ecrImport.ecrTypesMap.get(curr.kind)) == null) {
                        ecrImport.ecrTypesMap.put(curr.kind, tmpTypeRecs = new List<Id>());
                    }
                    tmpTypeRecs.add(curr.nodeId);
                    
                    if (curr.parentId==null) {continue;} // if curr.parent is null skip below code
                    // build ecrImport.ecrParentChildMap                
                    List<Id> tmpChildren;
                    if ((tmpChildren = ecrImport.ecrParentChildMap.get(curr.parentId)) == null) {
                        ecrImport.ecrParentChildMap.put(curr.parentId, tmpChildren= new List<Id>());
                    }
                    tmpChildren.add(curr.nodeId);
                    
                }
                
            }
            
            // System.debug('ecrImport.ecrParentChildMap.size>>>' + 
            // ecrImport.ecrParentChildMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrParentChildMap));
            
            // System.debug('ecrImport.ecrTypesMap.size>>>' + 
            // ecrImport.ecrTypesMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrTypesMap));
            
            // System.debug('ecrImport.ecrNodesMap.size>>>' + 
            // ecrImport.ecrNodesMap.size() + '>>> json >>>>' + JSON.serialize(ecrImport.ecrNodesMap));
            
            System.debug('this.ecrImportFormat>>>' + this.ecrImportFormat);
            return this.ecrImportFormat;
            
        }
        
    
        /**
         * 
    
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

    */

}

// // ONCE ALL IS WORKING, DELETE THIS...
//     public static void parse_WORKING_BACKUP(ecNode root) {
        
//         // { Kind : { Id: Rec } } // type traversal
//         // { parent : [children] } // parent 2 child traversal
//         // { ecId : ecRec + Parent } // allIDs
        
//         // { Kind : { Id: Rec } } // type traversal
//         // Map<String, Map<Id, Id>> ecTypeMap = new Map<String, Map<Id, Id>>();
//         Map<String, List<Id>> ecTypeMap = new Map<String, List<Id>>();
        
//         // { parent : [children] } // parent 2 child traversal
//         Map<Id,List<Id>> parentChildECMap = new Map<Id,List<Id>>();
        
//         // { ecId : ecRec + Parent } // allIDs
//         Map<Id, ecNode> ecNodeMapAll = new Map<Id, ecNode>();
        
//         // tmp for reuse in the loop
//         Map<Id, ecNode> ecNodeMap = new Map<Id, ecNode>{root.nodeId => root};        
//         ecNodeQueue q = new ecNodeQueue();
//         // q.enqueue(ecNodeMap); 
//         q.enqueue(new Map<Id, ecNode>{root.nodeId => root});
        
//         while (!q.isEmpty()) {
            
//             Map<Id, ecNode> ecNodeMapTmp = q.dequeue();
            
//             for (Id ecID :ecNodeMapTmp.keySet()) { // @parent
                
//                 ecNode curr = ecNodeMapTmp.get(ecID);
//                 q.enqueue(curr.getChildrenAsMap());
                
//                 // collect all ECs
//                 ecNodeMapAll.put(curr.nodeId, curr);  
                
//                 // build ecTypeMap
//                 List<Id> tmpTypeRecs;
//                 if ((tmpTypeRecs = ecTypeMap.get(curr.kind)) == null) {
//                     ecTypeMap.put(curr.kind, tmpTypeRecs = new List<Id>());
//                 }
//                 tmpTypeRecs.add(curr.nodeId);
                
//                 if (curr.parentId==null) {continue;}
//                 // build parentChildECMap                
//                 List<Id> tmpChildren;
//                 if ((tmpChildren = parentChildECMap.get(curr.parentId)) == null) {
//                     parentChildECMap.put(curr.parentId, tmpChildren= new List<Id>());
//                 }
//                 tmpChildren.add(curr.nodeId);
                
//             }
            
//         }
        
//         System.debug('parentChildECMap.size>>>' + 
//         parentChildECMap.size() + '>>> json >>>>' + JSON.serialize(parentChildECMap));
        
//         System.debug('ecTypeMap.size>>>' + 
//         ecTypeMap.size() + '>>> json >>>>' + JSON.serialize(ecTypeMap));
        
//         System.debug('ecNodeMapAll.size>>>' + 
//         ecNodeMapAll.size() + '>>> json >>>>' + JSON.serialize(ecNodeMapAll));
        
//         //@Usage
//         //  ecTreeParser.printTreeWIP();
//     }



//     /**
//      * @TODO: BUILD IT AT LAST...
//      */
//     public String getBuilderFormatData(){
//     //     Expected Output: 
//     //         EC.ID => ecrRec:
//     //                     Order, Kind 
//     //     Map<Stage -> all children>
//     //     Map<parent -> child>
//     //     Map<ec -> ecRec>
//         return '';
//     }

/**
     *  SELECT  Id, Name, CreatedDate, isActive__c, ParentID__c, Type__c, Version__c, ecTreeHeight__c, ecCount__c, ecTypes__c, ParentExtID__c
     FROM    ecrTree__c 
     WHERE isActive__c = true 
     ORDER BY CreatedDate DESC 
     
     @USAGE: 
     ecTreeParser.printTreeWIP();
     
     */
    // public static void printTreeWIP() {
        
    //     ecrTree__c acaPgmRec = [SELECT  Id, 
    //                                     Name, 
    //                                     CreatedDate, 
    //                                     isActive__c, 
    //                                     Payload__c,
    //                                     ParentID__c, 
    //                                     Type__c, 
    //                                     Version__c, 
    //                                     ecTreeHeight__c, 
    //                                     ecCount__c, 
    //                                     ecTypes__c, 
    //                                     ParentExtID__c
    //                             FROM    ecrTree__c 
    //                             WHERE   isActive__c = true 
    //                             ORDER BY CreatedDate DESC][0];

    //     System.debug('::ecrTreeRec>>' + JSON.serialize(acaPgmRec));

    //     ecNode importProgramTree = importProcessTree(acaPgmRec.Payload__c);
    //     // Set<Id> visitedNodes = nodeParser(importProgramTree, new Set<Id>());
    //     // System.debug('::visitedIds::count>>' + visitedNodes.size() + '>>nodes>>' + visitedNodes);

    //     // new parser run WIP
    //     parse(importProgramTree);

    // }