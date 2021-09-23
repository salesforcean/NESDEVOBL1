/** 

    @author: Ali KM (Ness Tech)
    * Created this class on 04/15/2020 for [US 166761]
    * This class helps serialize / deserialize the NES_EnrollmentCompentBuilder.enrollmentComponentData 
        state in-order to reduce the number of soqls consumed in the eca reassignment/completion evaluation.

*/

public with sharing class NES_ECDataImportExport {

    // public static NES_EnrollmentCompentBuilderWIP.enrollmentComponentData {get; set;}
    public static final String EC_DATA_CLASS_TYPE = 'ecDataClass';

    
    /**
     *  @Autor: Ali KM 
     *  @Purpose: dataExport / serialize
     *  @Return: ecrTree__c.Id of inserted config record.
     *  @Usage: 
            String processId ='a2921000001pR9wAAE'; //  
            NES_EnrollmentCompentBuilder.enrollmentComponentData ecData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processId);
            System.debug('ecrTree RecID:' + NES_ECDataImportExport.ExportData(ecData));
     */
    public static Id ExportData(NES_EnrollmentCompentBuilder.enrollmentComponentData ecData) {
         
        if (ecData==null) {return null;}

        Decimal version = 0;
        List<sObject> toUpdate = new List<sObject>();

        // query older records if they exist & mark then inactive
        for (ecrTree__c config : getECRTreeByParentIDs(new Set<Id>{ecData.ProcessId}, EC_DATA_CLASS_TYPE)) {

            // Integer configVersion = config.version__c; //Integer.valueOf(config.version__c);
            if (config.version__c > version) { version = config.version__c;}

            toUpdate.add(new ecrTree__c(Id=config.Id, isActive__c = false));

        }

        // create a new backup record
        ecrTree__c newConfig = createECRTreeRec(buildECDataExportFormat(ecData));
        newConfig.version__c = ++version;String.valueOf(++version);

        // DMLs
        insert newConfig;
        update toUpdate;

        return newConfig.Id;

    }


    /**
     * 
     @Usage: 
        String processId ='a0f0n000001IAQ2AAO'; //  
        NES_EnrollmentCompentBuilder.enrollmentComponentData data = NES_ECDataImportExport.ImportData(processId);
        NES_ECDataImportExport.ppData(data);
     * 
     * OUTPUT:
        ecData.ProcessId>>>a0f0n000001IAQ2AAO>>>
        ecData.allIds.size>>>467>>>
        ecData.stageRelationships.size>>>5>>>
        ecData.formRelationships.size>>>23>>>
        ecData.sectionRelationships.size>>>54>>>
        ecData.questionGroupRelationships.size>>>33>>>
        ecData.questionRelationships.size>>>385>>>
        ecData.componentOrderMap.size>>>467>>>
        ecData.questionParentIds.size>>>86>>>
        >>>END>>>
     * 
     */
    // dataImport / deserialize
    public static NES_EnrollmentCompentBuilder.enrollmentComponentData ImportData(Id processId) { 
        
        try {
            
            // query the data
            ecrTree__c configRec = getECRTreeByParentIDs(processId, EC_DATA_CLASS_TYPE);
            // System.debug(JSON.serialize(configRec));
            
            if ((new ecrTree__c()) == configRec) {return null;}

            ecDataExportFormat configData = deserialize(configRec);

            return unpackConfigData(configData);

        } catch (Exception ex) {

            System.debug('Exception occured while importing configuration in NES_ECDataImportExport.ImportData(), exception:' + ex.getMessage());
            return null;

        }
    
    }

    public static NES_EnrollmentCompentBuilder.enrollmentComponentData unpackConfigData(ecDataExportFormat configData) {

        NES_EnrollmentCompentBuilder.enrollmentComponentData ecData = new NES_EnrollmentCompentBuilder.enrollmentComponentData();

        // run a query to get the ecr records.
        Map<Id, Enrollment_Component_Relationship__c> ecrMap = new Map<Id, Enrollment_Component_Relationship__c>();
        for (Enrollment_Component_Relationship__c ecr : queryECRById(configData.ecrToECMap.keySet())) {
            ecrMap.put(ecr.Id, ecr);
        }

        if (ecrMap.size()==0) {return null;}

        // copy data over to the enrollmentComponentData object...
        ecData.ProcessId = configData.processID;
        ecData.allIds.addAll(configData.componentOrderMap.keySet());
        ecData.stageRelationships = getECRRecordsByIds(ecrMap, configData.stageECRIds);
        ecData.formRelationships = getECRRecordsByIds(ecrMap, configData.formECRIds);
        ecData.sectionRelationships = getECRRecordsByIds(ecrMap, configData.sectionECRIds);
        ecData.questionGroupRelationships = getECRRecordsByIds(ecrMap, configData.questionGroupECRIds);
        ecData.questionRelationships = getECRRecordsByIds(ecrMap, configData.questionECRIds);
        ecData.componentOrderMap = configData.componentOrderMap;
        ecData.questionParentIds = configData.questionParentIds;

        return ecData;

    }

    public static void ppData(NES_EnrollmentCompentBuilder.enrollmentComponentData ecData) {

        String output = '\n>>>EC DATA SUMMARY>>';
        output += '\necData.ProcessId>>>' + ecData.ProcessId + '>>>';
        output += '\necData.allIds.size>>>' + ecData.allIds.size() + '>>>';
        output += '\necData.stageRelationships.size>>>' + ecData.stageRelationships.size() + '>>>';
        output += '\necData.formRelationships.size>>>' + ecData.formRelationships.size() + '>>>';
        output += '\necData.sectionRelationships.size>>>' + ecData.sectionRelationships.size() + '>>>';
        output += '\necData.questionGroupRelationships.size>>>' + ecData.questionGroupRelationships.size() + '>>>';
        output += '\necData.questionRelationships.size>>>' + ecData.questionRelationships.size() + '>>>';
        output += '\necData.componentOrderMap.size>>>' + ecData.componentOrderMap.size() + '>>>';
        output += '\necData.questionParentIds.size>>>' + ecData.questionParentIds.size() + '>>>';
        output += '\n>>>END>>>';

        System.debug(output);

    }

    public static List<Enrollment_Component_Relationship__c> getECRRecordsByIds(Map<Id, Enrollment_Component_Relationship__c> ecrMap, List<Id> ecrIds) {

        List<Enrollment_Component_Relationship__c> ecrList = new List<Enrollment_Component_Relationship__c>();
        for (Id ecrId: ecrIds) {
            ecrList.add(ecrMap.get(ecrId));
        }
        return ecrList;
    }


    public static ecDataExportFormat deserialize(ecrTree__c configRec) {

        String payload = configRec.Payload__c;
        ecDataExportFormat pak; 

        try {        
            pak = (ecDataExportFormat) JSON.deserializeStrict( payload, ecDataExportFormat.class );
        } 
        catch (Exception ex) {
            throw new ecDataImportException('EnrollmentConponentData Import Exception, unable to deserialize payload. Exception:' + ex.getMessage());
        }

        return pak;
        
    }


    // supporting methods start...
    public static ecrTree__c getECRTreeByParentIDs(Id ecrTreeParentID, String type) {
        return getECRTreeByParentIDs(new Set<Id>{ecrTreeParentID}, type)[0];
    }


    /**
     * // ideally this should return just 1 Active record
     */
    private static List<ecrTree__c> getECRTreeByParentIDs(Set<Id> ecTreeParentIDs, String type) {

        return [SELECT  Id, 
                        name, 
                        parentID__c, 
                        version__c, 
                        isActive__c, 
                        type__c,
                        payload__c
                FROM    ecrTree__c
                WHERE   parentID__c = : ecTreeParentIDs
                AND     isActive__c = true
                AND     Type__c =: type];

    }


    /**
     *  This class converts the enrollmentComponentData object to a leaner ecDataExportFormat object to serialize..
     */
    public static ecDataExportFormat buildECDataExportFormat( NES_EnrollmentCompentBuilder.enrollmentComponentData ecData ) {

        ecDataExportFormat dataFormat = new ecDataExportFormat();

        // copy data to exportFormat
        dataFormat.processID = ecData.ProcessId;
        dataFormat.stageECRIds = copyBuilderListToTargetMap(ecData.stageRelationships, dataFormat);
        dataFormat.formECRIds = copyBuilderListToTargetMap(ecData.formRelationships, dataFormat);
        dataFormat.sectionECRIds = copyBuilderListToTargetMap(ecData.sectionRelationships, dataFormat);
        dataFormat.questionGroupECRIds = copyBuilderListToTargetMap(ecData.questionGroupRelationships, dataFormat);
        dataFormat.questionECRIds = copyBuilderListToTargetMap(ecData.questionRelationships, dataFormat);
        dataFormat.componentOrderMap = ecData.componentOrderMap;
        dataFormat.questionParentIds = ecData.questionParentIds;

        return dataFormat;

    }


    private static List<Id> copyBuilderListToTargetMap(List<Enrollment_Component_Relationship__c> source, ecDataExportFormat target) {

        Map<Id, Id> ecrToECMap = target.ecrToECMap;
        List<Id> ecrIds = new List<Id>();
        for (Enrollment_Component_Relationship__c ecr : source) {
            ecrToECMap.put(ecr.Id, ecr.Child_Enrollment_Component__c);
            ecrIds.add(ecr.Id);
        }
        // System.debug('ecrToECMap.size()>>>' + ecrToECMap.size());
        return ecrIds;

    }


    // data class
    public class ecDataExportFormat {

        public Id processID {get; set;}
        public Map<Id, Id> ecrToECMap {get; set;}
        // public List<Id> allIds {get; set;}
        public List<Id> stageECRIds {get; set;}
        public List<Id> formECRIds {get; set;}
        public List<Id> sectionECRIds {get; set;}
        public List<Id> questionGroupECRIds {get; set;}
        public List<Id> questionECRIds {get; set;}
        public Map<Id, Decimal> componentOrderMap {get; set;}
        public Set<Id> questionParentIds {get; set;}

        public ecDataExportFormat() {
            
            ecrToECMap          = new Map<Id, Id>();
            // allIds              = new List<Id>(); this can be fetched from componentOrderMap or ecrToECMap
            stageECRIds         = new List<Id>();
            formECRIds          = new List<Id>();
            sectionECRIds       = new List<Id>();
            questionGroupECRIds = new List<Id>();
            questionECRIds      = new List<Id>();
            componentOrderMap   = new Map<Id, Decimal>();
            questionParentIds   = new Set<Id>();

        }
    }

    
    // @returns ecrTree record
    public static ecrTree__c createECRTreeRec(ecDataExportFormat config) {

        return (new ecrTree__c(
            parentID__c = config.ProcessId,
            isActive__c = true,
            type__c = EC_DATA_CLASS_TYPE,
            ecCount__c = config.componentOrderMap.size(), 
            payload__c = JSON.serialize(config)
            // Version__c = String.valueOf(config.version)
        ));

    }

     // query ECR records by IDs
    public static List<Enrollment_Component_Relationship__c> queryECRById(Set<Id> recIDs) {       
        return [SELECT  Id, Order__c, 
                    Parent_Enrollment_Component__c,
                    Parent_Enrollment_Component__r.Id, 
                    Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, 
                    Child_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Id, 
                    Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, 
                    Child_Enrollment_Component__r.Component_Type__c,
                    Child_Enrollment_Component__r.Completion_Logic__c,
                    Child_Enrollment_Component__r.Assignment_Logic__c,
                    Child_Enrollment_Component__r.Is_Required__c,
                    Child_Enrollment_Component__r.External_Id__c,
                Child_Enrollment_Component__r.Needed_for_Re_enrollment__c,
                Child_Enrollment_Component__r.Needed_for_ITR__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Id =: recIDs
            //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
            ORDER BY Order__c ASC];
    }

    public class ecDataImportException extends Exception {}
    
}