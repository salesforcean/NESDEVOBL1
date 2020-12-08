public class programImportExport {
    
    // public static integer CURRENTVERSION = 1;
    public static final String ROOT_EC = 'Process';

    /**
     *  Steps for Export/Serialize process configuration: 
     *      ExportProgram(processId).ecrTreeGenerator(processId).serialize().save()
     *  @returns: 
     *      inserted active ecrTree__c recordID
     * 
     *  @Usage: 
     *      String ecrTreeRecId = programImportExport.ExportProgram('a0f0n000001IAQ2AAO');
     * 
     *  @TODO: 
     *      Add error logging
     *      Use a standard response structure
     *      Add Test classes

    @AuraEnabled
    public static String ExportProgram(String ecId) {

        try {

            if (!doesECRecordExist(ecId)) {
                return 'No Enrollment Component record found of Type:' + ROOT_EC + ' for Id:' + ecId;
            }

            ecrTreeGenerator ecTree = new ecrTreeGenerator(ecId); //('a0f0n000001IAQ2AAO');
            ecTree.generate();
            Id newECTreeID = ecTree.save();
            System.debug('ecTree rec created>>>' + newECTreeID);

            return ('Successfully created new configuration, recordID:' + ecId);

        } catch (Exception ex) {
            return 'Something went wrong with export, Please reach out support Admin.';
        }

    }

    
    /**
     * steps for Import/Deserialization: 
     *      ecTree.parse(processId).deserialize().getBuilderFormatData()
     * return: 
     *      return builderFormatData for the processTree

    @AuraEnabled
    public static String ImportProgram(String Id){
        // programExportFormat pgm = new programExportFormat();
        return null;

    }
    
    public static ecNode GetProcess(String payload){
        return null;
    }

    // UTILS...
    public static Boolean doesECRecordExist(String ecId) {
        
        // system.assertEquals(Schema.Enrollment_Component__c.SObjectType, ecId.getSobjectType());
        return (([SELECT count() FROM Enrollment_Component__c WHERE Id = :ecId AND RecordType.Name = :ROOT_EC])>0);

    }
     */
    
}