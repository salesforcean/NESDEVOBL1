/**
 * Created by ajith on 04/12/18.
 * Purpose : This is the helper controller for the NES_RelationShipViewController
 */

public with sharing class NES_RelationshipViewerHelper {
    //Grab the map of Record types by Name and Id
    public static Map<String, Id> recordTypeByNameMap = Peak_Utils.getRecordTypesByObject('Enrollment_Component__c');
    //Grab the Required Ids of RT's
    public static final Id sectionEnrollmentRecordTypeId = recordTypeByNameMap.get('Section');
    public static final Id formEnrollmentRecordTypeId = recordTypeByNameMap.get('Form');
    public static final Id stageEnrollmentRecordTypeId = recordTypeByNameMap.get('Stage');
    public static final Id processEnrollmentRecordTypeId = recordTypeByNameMap.get('Process');
    public static final Id questionEnrollmentRecordId = recordTypeByNameMap.get('Question');
    public static final Id documentEnrollmentRecordId = recordTypeByNameMap.get('Document');
    public static final Id groupEnrollmentRecordId = recordTypeByNameMap.get('Question Group');

    /**
     * Created by ajith on 04/12/18.
     * Purpose : This method returns the Peak Response with the property relationShipViewResults of type Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>
     *           for the passed in Question Enrollment Component Id. We would be start looking into the ECR object where child is Question and it's parent records and
     *           it's parent records and so on as for the record types mentioned in the task.
     * Param : Question Enrollment Component Id
     */
    public static Peak_Response getRelatedECComponents_Question(Id questionEcId){
        Peak_Response peakResponse = new Peak_Response();

        //Return Wrapper Map
        Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>  componentDataMap = new Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>();

        //Check the Passed in Id's Record type and then add it to the List
        List<Id> questionIds = new List<Id>();
        for(Enrollment_Component__c ec : [SELECT Id, RecordTypeId FROM Enrollment_Component__c WHERE Id =:questionEcId]){
            if(ec.RecordTypeId == questionEnrollmentRecordId){
                questionIds.add(ec.Id);
            }
        }

        if(questionIds.size() > 0){

            List<Id> groupECIds = new List<Id>();
            NES_RelationShipUtils.ECDataList questionGroupECData = NES_RelationShipUtils.getRelatedECInfo(questionIds, groupEnrollmentRecordId);
            groupECIds = questionGroupECData.parentECIds;
            if(groupECIds.size() > 0) {
                componentDataMap.put('Question Group', questionGroupECData.enrollmentComponentDataSet);
            }
            List<Id> sectionChildIds = new List<Id>();
            sectionChildIds.addAll(questionIds);
            sectionChildIds.addAll(groupECIds);

            //Get the Sections EC's Related to the Question EC Passed as the Parameter via ECR's
            List<Id> sectionECIds = new List<Id>();
            NES_RelationShipUtils.ECDataList questionECData = NES_RelationShipUtils.getRelatedECInfo(sectionChildIds, sectionEnrollmentRecordTypeId);
            sectionECIds = questionECData.parentECIds;
            //Add the values to the main map If the records in map exists
            if(sectionECIds.size() > 0){
                componentDataMap.put('Section', questionECData.enrollmentComponentDataSet);
                //Get the Form EC's Related to the Sections EC's Ids obtained in the above loop
                List<Id> formECIds = new List<Id>();
                NES_RelationShipUtils.ECDataList formECData = NES_RelationShipUtils.getRelatedECInfo(sectionECIds, formEnrollmentRecordTypeId);
                formECIds = formECData.parentECIds;
                //Add the values to the main map If the records in map exists
                if(formECIds.size() > 0){
                    componentDataMap.put('Form', formECData.enrollmentComponentDataSet);
                    //Get the Stage EC's Related to the Sections EC's Ids obtained in the above loop
                    List<Id> stageECIds = new List<Id>();
                    NES_RelationShipUtils.ECDataList stageECData = NES_RelationShipUtils.getRelatedECInfo(formECIds, stageEnrollmentRecordTypeId);
                    stageECIds = stageECData.parentECIds;
                    //Add the values to the main map If the records in map exists
                    if(stageECIds.size() > 0){
                        componentDataMap.put('Stage', stageECData.enrollmentComponentDataSet);
                        //Get the Process EC's Related to the Sections EC's Ids obtained in the above loop
                        List<Id> processECIds = new List<Id>();
                        NES_RelationShipUtils.ECDataList processECData = NES_RelationShipUtils.getRelatedECInfo(stageECIds, processEnrollmentRecordTypeId);
                        processECIds = processECData.parentECIds;
                        if(processECIds.size() > 0){
                            componentDataMap.put('Process', processECData.enrollmentComponentDataSet);
                        }
                    }
                }
                peakResponse.relationShipViewResults = sortComponentDataMap(componentDataMap);
                peakResponse.success = true;
                peakResponse.messages.add('Success');
            }else{
                peakResponse.success = false;
                peakResponse.messages.add('There are no related Enrollment Components for the Question');
            }

        }else{
            peakResponse.success = false;
            peakResponse.messages.add('There Passed in Component is not of Question Record Type');
        }

        return peakResponse;
    }

    /**
     * Created by ajith on 05/12/18.
     * Purpose : This method returns the Peak Response with the property relationShipViewResults of type Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>
     *           for the passed in Form Enrollment Component Id. We would look in to the ECR object where (Form is the parent and it's related child's and child of child also)
     *           and (Form is the child and it's related parent's and parent of the parent also) for the mentioned record types in the task.
     * Param : Form Enrollment Component Id           Documents, Questions, Sections
     */

     public static Peak_Response getRelatedECComponents_Form(Id formEcId){
         Peak_Response peakResponse = new Peak_Response();

         //Return Wrapper Map
         Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>  componentDataMap = new Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>();

         //Check the Passed in Id's Record type and then add it to the List
         List<Id> formIds = new List<Id>();
         for(Enrollment_Component__c ec : [SELECT Id, RecordTypeId FROM Enrollment_Component__c WHERE Id =:formEcId]){
             if(ec.RecordTypeId == formEnrollmentRecordTypeId){
                 formIds.add(ec.Id);
             }
         }

         if(formIds.size() > 0){
             //Get the Stage EC's Related to the Form EC Passed as the Parameter via ECR's
             List<Id> stageECIds = new List<Id>();
             NES_RelationShipUtils.ECDataList formECData = NES_RelationShipUtils.getRelatedECInfo(formIds, stageEnrollmentRecordTypeId);
             stageECIds = formECData.parentECIds;
             //Add the values to the main map If the records in map exists
             if(stageECIds.size() > 0){
                 componentDataMap.put('Stage', formECData.enrollmentComponentDataSet);
                 //Get the Process EC's Related to the Stages EC's Ids obtained in the above loop
                 List<Id> processECIds = new List<Id>();
                 NES_RelationShipUtils.ECDataList stageData = NES_RelationShipUtils.getRelatedECInfo(stageECIds, processEnrollmentRecordTypeId);
                 processECIds = stageData.parentECIds;
                 //Add the values to the main map If the records in map exists
                 if(processECIds.size() > 0){
                   componentDataMap.put('Process', stageData.enrollmentComponentDataSet);
                 }
             }

             //Get the Section EC's Related to the Form EC Passed as Parameter via ECR's
             //Note we need to look for the ECR Records where Form is the Parent and it's child Sections
             List<Id> sectionsIds = new List<Id>();
             NES_RelationShipUtils.ECDataList sectionECData = NES_RelationShipUtils.getRelatedChildECInfo(formIds, sectionEnrollmentRecordTypeId);
             System.debug(sectionECData);
             //Add the values to the main map If the records in map exists
             sectionsIds = sectionECData.childECIds;
             if(sectionsIds.size() > 0){
                 componentDataMap.put('Section', sectionECData.enrollmentComponentDataSet);
             }


             List<Id> docIds = new List<Id>();
             NES_RelationShipUtils.ECDataList docECData = NES_RelationShipUtils.getRelatedChildECInfo(formIds, documentEnrollmentRecordId);
             //Add the values to the main map If the records in map exists
             docIds = docECData.childECIds;
             if(docIds.size() > 0){
                 componentDataMap.put('Document', docECData.enrollmentComponentDataSet);
             }

             List<Id> questionGroupIds = new List<Id>();
             NES_RelationShipUtils.ECDataList questionGroupECData = NES_RelationShipUtils.getRelatedChildECInfo(sectionsIds, groupEnrollmentRecordId);
             questionGroupIds = questionGroupECData.childECIds;
             if(questionGroupIds.size() > 0){
                 componentDataMap.put('Question Group', questionGroupECData.enrollmentComponentDataSet);
             }

             //Get the Questions EC's Related to the Form EC Passed as Parameter via ECR's
             //Note we need to look for the ECR Records where Form is the Parent and it's child Questions
             List<Id> questionIds = new List<Id>();
             List<Id> questionParentIds = new List<Id>();
             questionParentIds.addAll(sectionsIds);
             questionParentIds.addAll(questionGroupIds);
             System.debug(questionParentIds);
             NES_RelationShipUtils.ECDataList questionECData = NES_RelationShipUtils.getRelatedChildECInfo(questionParentIds, questionEnrollmentRecordId);
             //Add the values to the main map If the records in map exists
             questionIds = questionECData.childECIds;
             if(questionIds.size() > 0){
                 componentDataMap.put('Question', questionECData.enrollmentComponentDataSet);
             }

             //Check Whether the map is empty or not then add peak messages accordingly
             if(!componentDataMap.isEmpty()){
                 peakResponse.relationShipViewResults = sortComponentDataMap(componentDataMap);
                 peakResponse.success = true;
                 peakResponse.messages.add('Success');
             }else{
                 peakResponse.success = false;
                 peakResponse.messages.add('There are no related Enrollment Components for the Form');
             }
         }else{
             peakResponse.success = false;
             peakResponse.messages.add('There Passed in Component is not of Form Record Type');
         }
         return peakResponse;
     }

    //Sorting the map
    public static Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>  sortComponentDataMap(Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>> oldMap) {

        Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>> newMap = new Map<String, Set<NES_RelationShipUtils.EnrollmentComponentData>>();

        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Process') {
                newMap.put('Process(es)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Stage') {
                newMap.put('Stage(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Flag') {
                newMap.put('Flag(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Form') {
                newMap.put('Form(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Document') {
                newMap.put('Document(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Section') {
                newMap.put('Section(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Question Group') {
                newMap.put('Question Group(s)', oldMap.get(mapKey));
            }
        }
        for(String mapKey : oldMap.keySet()) {
            if(mapKey == 'Question') {
                newMap.put('Question(s)', oldMap.get(mapKey));
            }
        }
        return newMap;
    }
}