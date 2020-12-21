public class PECEvaluation {

    // MM 12/8/2020 | capturing all criteriaFields
    public static void evaluatePECs(List<Enrollment_Component_Criteria__c> eccs, id programEnrollment) {
        //Household or Student,  Object, Field list
        Map<String, Map<String, Set<String>>> criteriaObjectFieldsMapByPEType = new Map<String, Map<String, Set<String>>>();
        for (Enrollment_Component_Criteria__c ecc : eccs) 
        {
            if (String.isBlank(ecc.Criteria__r.Criteria_Field__c))
                continue;

            String[] fieldParts = ecc.Criteria__r.Criteria_Field__c.toLowerCase().split('\\.', 2); 
            if (fieldParts.size()!=2) {
                System.debug('>>>Invalid field parts for ECC>>>' + JSON.serialize(ecc));    
                continue;
            }

            Map<String, Set<String>> tmpCriteriaObjectFieldsMap = criteriaObjectFieldsMapByPEType.get(ecc.Student_or_Household__c);
            if (tmpCriteriaObjectFieldsMap==null) {
                tmpCriteriaObjectFieldsMap = new Map<String, Set<String>>();
                criteriaObjectFieldsMapByPEType.put(ecc.Student_or_Household__c, tmpCriteriaObjectFieldsMap);
            }
            
            Set<String> tmpObjectFields = tmpCriteriaObjectFieldsMap.get(fieldParts[0]);
            if (tmpObjectFields==null)
                tmpObjectFields = new Set<String>();
            tmpObjectFields.add(fieldParts[1]);
            tmpCriteriaObjectFieldsMap.put(fieldParts[0], tmpObjectFields);
        }
        System.debug('>>>criteriaObjectFieldsMapByPEType>>>' + JSON.serialize(criteriaObjectFieldsMapByPEType));        

        if(criteriaObjectFieldsMapByPEType.size()==0)
            return;

        // query studPE & HH details...
        hed__Program_Enrollment__c studPE = getStudPEById(programEnrollment);
        id caretakerEnrollmentId = studPE.Household_Program_Enrollment__c;
        Id caretakerContactId = studPE.Household_Program_Enrollment__r.hed__Contact__c;
        Id studentContactId = studPE.hed__Contact__c;
        Id accountId = studPE.hed__Contact__r.AccountId;

        // // query the records...
        //Household or Student, Object, list of records for that object.
        Map<String, Map<String, List<sObject>>> criteriaObjectRecordsMapByPEType = new Map<String, Map<String, List<sObject>>>();
        for (String k : criteriaObjectFieldsMapByPEType.keySet()) {
            Id enrollmentId = ( (k.endsWithIgnoreCase('Household'))? caretakerEnrollmentId : programEnrollment);
            Id contactId = ( (k.endsWithIgnoreCase('Household')) ? caretakerContactId : studentContactId );

            //  caretakerMap = getObjectDataList(objectMap, caretakerEnrollmentId, accountId, caretakerContactId);
            criteriaObjectRecordsMapByPEType.put(k, 
                queryRelatedRecords(criteriaObjectFieldsMapByPEType.get(k), enrollmentId, accountId, contactId));
        }
        System.debug('>>>criteriaObjectRecordsMapByPEType>>>' + JSON.serialize(criteriaObjectRecordsMapByPEType));

        // List of fieldUpdate...
        List<EvaluationUtils.fieldUpdate> fldUpdates = new List<EvaluationUtils.fieldUpdate>();
        for ( String k : criteriaObjectRecordsMapByPEType.keySet()) // Ex: Household / Student
        {
            for (String objName : criteriaObjectRecordsMapByPEType.get(k).keySet()) // Ex: ASI / EmergencyContact / PE / PriorSchool / SpecialEducation / ... 
            {
                for (sObject rec : criteriaObjectRecordsMapByPEType.get(k).get(objName)) // Ex: {annual_student_information__c=(Annual_Student_Information__c:{Id=a1t3C000000RWLYQA4, Grade_Level_Requested__c=7}, Annual_Student_Information__c:{Id=a1t3C000000RWLiQAO, Grade_Level_Completed__c=6}
                {
                    for (String field : criteriaObjectFieldsMapByPEType.get(k).get(objName)) // Ex: "waitlistflag__c","date_today__c","LastSchoolType__c","DisciplinaryFlagOverride__c","HomelessRiskFlag__c"
                    {
                        if (rec.get(field)==null)
                            continue;
                        EvaluationUtils.fieldUpdate fldUpdate = new EvaluationUtils.fieldUpdate();
                        fldUpdate.programEnrollmentId = programEnrollment;
                        fldUpdate.objectAndFieldName = objName + '.' + field; 
                        fldUpdate.newValue = rec.get(field);
                        try {
                            if (rec.get('School_Year__c')!=null)
                            fldUpdate.schoolYear = (String) rec.get('School_Year__c');
                        } catch (Exception ex) {
                            // Ignore this one.
                        }
                        
                        try {
                            if (rec.get('Question_Group__c')!=null)
                                fldUpdate.questionGroup = (String)  rec.get('Question_Group__c');
                        } catch (Exception ex) {
                            // Ignore this one.
                        }
                        fldUpdates.add(fldUpdate);
                    }
                }
            }
        }

        if (fldUpdates.size()>0) {
            System.debug ('>>>fldUpdates>>> size>>> ' + fldUpdates.size() + '>>>' + fldUpdates);
            EvaluationUtils.evaluateChangedFields(fldUpdates);
        }
    }

    public static hed__Program_Enrollment__c getStudPEById(Id studPEID)
    {
        return [
            SELECT  Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.AccountId, 
                    Household_Program_Enrollment__c, Household_Program_Enrollment__r.hed__Contact__c,
                    Household_Program_Enrollment__r.Name, Household_Program_Enrollment__r.hed__Contact__r.Name
            FROM    hed__Program_Enrollment__c
            WHERE   Id = :studPEID
        ];
    }





    public static Map<String, List<SObject>> queryRelatedRecords(Map <String, Set<String>> queryMap, Id enrollmentId, Id accountId, Id contactId) {
        Map<String, List<SObject>> newQueryMap = new Map<String, List<SObject>>();

        Map<String, Set<String>> objectFieldsMap = ECA_CriteriaEvaluatorHelper.objectFieldsMap;
        for (String mapKey : queryMap.keySet()) 
        {
            String objectName = mapKey.toLowerCase();
            String fieldStrings;
            List<SObject> childRecords = new List<SObject>();
            

            if (objectFieldsMap.get(objectName)==null) {
                // Make the describe call
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objectName});
                // For each returned result, get some info
                for(Schema.DescribeSobjectResult res : results) {
                    if (objectFieldsMap.get(res.getName())==null) {
                        objectFieldsMap.put(res.getName().toLowerCase(), res.fields.getMap().keySet());
                    }
                }
            }

            // Dynamially add SY & QuestionGroup if not part of the fieldList & object contains these fields.
            String syFieldName = 'School_Year__c';
            if( !(
                    queryMap.get(objectName).contains(syFieldName) || 
                    queryMap.get(objectName).contains(syFieldName.toLowerCase())
                ) && 
                (
                    objectFieldsMap.get(objectName).contains(syFieldName) ||
                    objectFieldsMap.get(objectName).contains(syFieldName.toLowerCase())
                ) 
            ){
                    queryMap.get(objectName).add(syFieldName);
            }
            String questionGroupFieldName = 'Question_Group__c';
            if( !(
                    queryMap.get(objectName).contains(questionGroupFieldName) || 
                    queryMap.get(objectName).contains(questionGroupFieldName.toLowerCase())
                )  && 
                (
                    objectFieldsMap.get(objectName).contains(questionGroupFieldName) ||
                    objectFieldsMap.get(objectName).contains(questionGroupFieldName.toLowerCase())
                    
                ) 
            ){
                    queryMap.get(objectName).add(questionGroupFieldName);
            }
            // END...
            List<String> fieldNames = new List<String>(queryMap.get(mapKey));
            
            String query;
            if (objectName == 'account') {
                query = 'SELECT Id, ' +  String.join(fieldNames, ',') + ' FROM Account WHERE Id = \'' + accountId + '\' '; // SELECT Id, different_billing_address__c,own_or_rent_home__c,referral_from_ca_parent__c,migratory_info__c,School_Year__c FROM Account WHERE Id = '0013C00000S0ZEoQAN'
            } else if (objectName == 'contact') {
                query = 'SELECT id, ' + String.join(fieldNames, ',') + ' FROM Contact WHERE Id = \'' + contactId + '\' ';
            } else if (objectName == 'hed__program_enrollment__c' && String.isNotBlank(enrollmentId)) {
                query = 'SELECT id, ' + String.join(fieldNames, ',') + ' FROM hed__program_enrollment__c WHERE id = \'' + enrollmentId + '\' ';
            } else if (String.isNotBlank(enrollmentId)) {
                query = 'SELECT id, ' + String.join(fieldNames, ',') + ' FROM ' + objectName + ' WHERE program_enrollment__c = \'' + enrollmentId + '\' ';
            } 
            System.debug('>>>query>>>' + JSON.serialize(query)); //SELECT id, child_custody__c,who_has_student_custody__c,country_of_birth__c,ever_in_us_schools_for_3_years__c,gender__c,School_Year__c FROM Contact WHERE Id = '0033C00000HGb3hQAD'
            if (String.isNotBlank(query)) {
                query.remove('(');
                query.remove(')');
                childRecords = Database.query(query);
            }

            if (childRecords.size() > 0) {
                newQueryMap.put(mapKey.toLowerCase(), childRecords);
            } else {
                newQueryMap.put(mapKey.toLowerCase(), new List<SObject>());
            }
            System.debug(newQueryMap);
        }
        return newQueryMap;
    }
}