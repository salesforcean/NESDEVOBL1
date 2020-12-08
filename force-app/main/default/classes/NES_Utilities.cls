/**
 * Created by ajith on 14/11/18.
 */

public without sharing class NES_Utilities {

    // Method to get the attachment body for a educational Institution
    @AuraEnabled
    public static String retrieveLogo(String instituteId) {

        System.debug(instituteId);
        String returnName;
        if(String.isNotBlank(instituteId)) {
            Account institute = [SELECT Name FROM Account WHERE Id = : instituteId];
            String schoolName = institute.Name.replace(' ', '_');
            returnName = 'logo' + schoolName;
        }
        
        return returnName;
    }

    @AuraEnabled
    public static void callBatchUpdateTimeConstraint(){
        NES_Batch_UpdateHardStopTimeConstraint bc = new NES_Batch_UpdateHardStopTimeConstraint();
        Database.executeBatch(bc);
    }
}