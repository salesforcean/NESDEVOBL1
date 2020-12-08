/**
 *  @TODO: 10/Apr/2020 
 *      - BuilderCall to the Import (In-progress)
 *      - test classes
 *      - migrate classes & object to ORG (to all classes add prefix: ecrTree)
 *      - change ecrTree__c.Version__c from picklist to integer & name it version__c
 *      - toggle feature
 *      - Add Error handling here
 *          -> **MOVE ALL ERROR HANDLING TO CALLER CLASS => ecrTreeImportExport.cls
 *      - Export single / multi-processes (batch) via Button w/Page
 *      - profile access
 *      - change implementations to use Interfaces instead of directly referring classes
 * 
    @Questions: 
        - How many programs are there ? Currently we are processing only 1 pgm/process, we can batch it if needed. 
        - Need a process with most elaborate/largest configuration (to validate)
        - Noticed that there are duplicates (count: 33) in ECR -> child-EC Mapping, implying same EC can be repeated in AcademicProgram Configuration
        - Who (need profile) should have access to generate the config (via button)

    Issues: 
        - realized questions could be under sections & questionGroups both, need to update the generator to take care of this.

 */

public class ecrTreeImportExport {

    // public static integer CURRENTVERSION = 1;
    public static final String ROOT_EC = NES_DashboardUtilities.PROCESS_RT;

    /**
     *  
     * For Exporting/Producing Academic Program Configuration via buttonClick (TBD)
     * 
     *  @returns: 
     *      inserted active ecrTree__c recordID
     * 
     *  @Usage: 
            String ecrTreeRecId = ecrTreeImportExport.ExportTree('a0f0n000001IAQ2AAO'); // a0f0n000001IAQ2AAO // a0f0n000001IAQ2AZO
            System.debug(ecrTreeRecId);
     * 
     */
    @AuraEnabled
    public static String ExportTree(String ecId) {

        try {
            
            if (!ecrTreeUtils.doesECRecordExist(ecId, ROOT_EC)) {
                return 'No Enrollment Component record found of Type:' + ROOT_EC + ' for Id:' + ecId;
            }

            ecrTreeGenerator ecTree = new ecrTreeGenerator(ecId); //('a0f0n000001IAQ2AAO');
            ecTree.generate();
            Id newECTreeID = ecTree.save();
            System.debug('ecTree rec created>>>' + newECTreeID);

            return ('Successfully created new configuration, recordID:' + newECTreeID);

        } catch (Exception ex) {
            return 'Something went wrong with export, Please reach out support Admin.'; // @TODO: log the error messages.....
        }

    }

    /** 
     *  method to pass the config/ecrTree JSON over to the LWC
     * 
     *  @todo: 
     *      -> get the processID as param 
     *              => https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.apex
     */
    @AuraEnabled(cacheable=true)
    public static ecNode getProcessTree(String rootId) {

        // ecrTreeGenerator tree = new ecrTreeGenerator('a2921000000KsIHAA0'); // poc1-tnca-ID: a2921000000KsIHAA0 // obl1-ID: a0f0n000001IAQ2AAO
        ecrTreeGenerator tree = new ecrTreeGenerator(rootId);
        tree.generate();
        System.debug('ecrTree.config>>>>' + JSON.serialize(tree.config.root));
        return tree.config.root;
        
    }

    
    /**
     * 
     * For Importing/Consuming stored Academic Program Configuration (ecrTree__c)
     * returns: 
     *      return builderFormatData for the processTree
     * 
     *  @USAGE: 
            String ecParentID ='a0f0n000001IAQ2AAO'; // a0f0n000001IAQ2AAO
            ecrConsumerFormat importData = ecrTreeImportExport.ImportTree(ecParentID);
            System.debug('importData>>>' + JSON.serialize(importData));
     *
     */
    @AuraEnabled
    public static ecrConsumerFormat ImportTree(String ecParentID) {

        // try {
        
            ecrTreeParser parser = new ecrTreeParser(ecParentID);
            return parser.parse();

        // } catch (Exception ex) {
        //     return 'Something went wrong with export, Please reach out support Admin.'; // @TODO: log the error messages.....
        // }

    }
    
}