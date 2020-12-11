trigger StudentCustodyTrigger on Student_Custody__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
        Student_Custody__c newObject = new  Student_Custody__c();
        Schema.SObjectType objType = newObject.getSObjectType();
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Student_Custody__c.fields.getMap();
            
        for(Student_Custody__c studCust:Trigger.new)
        {
            for (String str : mapFields.keySet()) {
                if (studCust.get(str) != null) {
                    //These are for the new ECA processing model.  
                    EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                    newFieldUpdate.programEnrollmentId = studCust.Program_Enrollment__c;
                    newFieldUpdate.objectAndFieldName = 'Student_Custody__c.' + str;
                    newFieldUpdate.newValue = studCust.get(str);
                    fieldUpdateList.add(newFieldUpdate);
                }           
           }
        }
        
        if (fieldUpdateList.size() > 0)
            EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
            
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
        Student_Custody__c newObject = new  Student_Custody__c();
        Schema.SObjectType objType = newObject.getSObjectType();
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Student_Custody__c.fields.getMap();
            
        for(Student_Custody__c studCust:Trigger.new)
        {
            for (String str : mapFields.keySet()) {
            
                if (studCust.get(str) != Trigger.oldMap.get(str) ) {
                    //These are for the new ECA processing model.  
                    EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                    newFieldUpdate.programEnrollmentId = studCust.Program_Enrollment__c;
                    newFieldUpdate.objectAndFieldName = 'Student_Custody__c.' + str;
                    newFieldUpdate.newValue = studCust.get(str);
                    fieldUpdateList.add(newFieldUpdate);
                }           
           }
        }
        
        system.debug ('StudentCustodyTrigger  fieldUpdateList:' + fieldUpdateList);
        
        if (fieldUpdateList.size() > 0)
            EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
    }
}