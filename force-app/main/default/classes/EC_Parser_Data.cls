public with sharing class EC_Parser_Data {
    /**
    *   @ALIKM 20/apr/2020- commenting out changes
        // Singleton
        // private static EC_Parser_Data instance = null;
        
        public List<Enrollment_Component__c>  allECs {get; private set;}
        public List<Enrollment_Component_Relationship__c>  allECRs {get; private set;}
        public List<String> parentECs {get; private set;}
        public Integer depthCon {get; set;}
    
        public EC_Parser_Data() { // private
            this.allECs = new List<Enrollment_Component__c>();
            this.allECRs = new List<Enrollment_Component_Relationship__c>();
            this.parentECs = new List<String>();
            this.depthCon = 0;
        }
    
        // public static EC_Parser_Data getInstance() {
        //     if (instance==null) instance = new EC_Parser_Data();
        //     return instance;
        // }
    
        public void addParentECs(List <String> parentECs) {
            this.parentECs.addAll(parentECs);
        }
    
        public void addECs(List<Enrollment_Component__c> ecs) {
            allECs.addAll(ecs);
        }
    
        public void addEC(Enrollment_Component__c ec) {
            allECs.add(ec);
        }
    
        public void addECRs(List<Enrollment_Component_Relationship__c> ecrs) {
            allECRs.addAll(ecrs);
            // depthCon++;
        }
    
        public void addECR(Enrollment_Component_Relationship__c ecr) {
            allECRs.add(ecr);
        }
    */
}