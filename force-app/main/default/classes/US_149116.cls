public with sharing class US_149116 {
	/**
	 * 	@ALIKM 20/apr/2020- commenting out changes

    @AuraEnabled
    public static String getDocumentListByUser_Alt(String caretakerId) {

        if (String.isBlank(caretakerId))
            return null;
        
        // stuff we need
        Date today = System.today();

        // Query all qualifyingPEs
        Map<Id, hed__Program_Enrollment__c> validPEs = new Map<Id, hed__Program_Enrollment__c>(
            [SELECT Id, hed__Account__c, Status__c, hed__Contact__r.Name, hed__Account__r.Document_Start_Date__c, hed__Account__r.Document_End_Date__c, 
                (SELECT Id, Name, Status__c, Enrollment_component__r.Id, Enrollment_component__r.Name
                FROM  Enrollment_Component_Affiliation__r
                WHERE Enrollment_component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
                AND Enrollment_component__r.Status__c IN ('In Progress', 'Complete')) // @TBD: need to confirm if we need both or just In-progress ones.
            FROM hed__Program_Enrollment__c 
            WHERE hed__Contact__r.CreatedById = :caretakerId // '0050n000002xO3GAAU' 
            AND Status__c = 'In Progress'
            AND hed__Account__r.Document_Start_Date__c != null AND hed__Account__r.Document_End_Date__c != null
            AND hed__Account__r.Document_Start_Date__c <= :today AND hed__Account__r.Document_End_Date__c >= :today]);

        // Query all stageECAs
        // [Select Id, Name, Status__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Program_Enrollment__r.hed__Contact__r.Name
        // FROM  Enrollment_Component_Affiliation__c
        // WHERE Program_Enrollment__c IN :validPEs.keySet()
        // AND Enrollment_component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
        // AND Enrollment_component__r.Status__c IN ('In Progress', 'Complete') // @TBD: need to confirm if we need both or just In-progress ones.
        // RecordType.Name = :NES_DashboardUtilities.STAGE_RT]


        // Query all childDocumentECAs


        // Query all relevantDocuments (first query in current implementation)


        // populate the wrapper & return

        return '';
    
    }

	*/

}


// SELECT Id, Name, status__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Program_Enrollment__r.hed__Contact__r.Name
// FROM Enrollment_Component_Affiliation__c
// WHERE Program_Enrollment__c IN :programIdslist and Enrollment_Component__r.recordtype.name = 'Document' and(Status__c = 'Not started' or Status__c = 'Deferred')];