/**
* Created by triciaigoe on 12/18/18.
* Change log:
*         2019-08-02 add code by Maddileti for #101934 User Story
          2019-11-08 add code by AnithaP for #116612 User Story
          2019-12-03 add code by AnithaP for #116612 User Story    
*/

public without sharing class NES_EvaluateUtil {

    private static Peak_ApexLog logger = new Peak_ApexLog('EvaluateUtil');

    private static final String OPEN = '(';
    private static final String CLOSE = ')';

    private String expression;
    private Boolean[] values;
    private String finalExpression;

    // Grab Map of ECC Id to Boolean result
    public static Map<String, Boolean> getCriteriaResultMap(List<Enrollment_Component_Criteria__c> componentCriteria, Id newStudentId, Id caretakerId, Id accountId, Id studentEnrollmentId, Id caretakerEnrollmentId) {
        Map<String, Boolean > resultMap = new Map<String, Boolean >();
        List<Id> criteriaIds = new List<Id>();

        for (Enrollment_Component_Criteria__c componentCriterium : componentCriteria) {
            criteriaIds.add(componentCriterium.Criteria__c);
        }
        //Start : Updated some fields in query by Ritvik on 01/10/2019.
        List<Criteria__c> criteria = [
                SELECT Id, Operator__c, Criteria_Field__c, Comparison_Data_Type__c, Comparison_Value__c, Comparison_Field__c, (SELECT Criteria_Number__c, Enrollment_Component__r.Component_Type__c FROM Enrollment_Component_Criteria__r), (
                        SELECT Id, Refinement_Value__c, Refinement_Type__c, Operator__c,Refinement_Field_Left__c,Refinement_Field_Right__c
                        FROM Criteria_Refinements__r
                )
                FROM Criteria__c
                WHERE Id IN :criteriaIds
        ];

        Map<Enrollment_Component_Criteria__c, Criteria__c> componentCriteriaMap = grabCriteriaByEnrollmentComponentCriteria(componentCriteria, criteria);
        System.debug('componentCriteriaMap>>>>>>' + componentCriteriaMap);
        Map<String, Map <String, List<String>>> fieldsMap = getECCQueryMap(componentCriteriaMap);
        System.debug('fieldsMap>>>>>>>' + fieldsMap);
        Map<String, List<SObject>> studentMap = new Map<String, List<SObject>>();
        Map<String, List<SObject>> caretakerMap = new Map<String, List<SObject>>();
        for (String studentHousehold : fieldsMap.keySet()) {
            Map<String, List<String>> objectMap = fieldsMap.get(studentHousehold);
            if (studentHousehold == 'Student' && String.isNotBlank(newStudentId)) {
                studentMap = getObjectDataList(objectMap, studentEnrollmentId, accountId, newStudentId);
                System.debug('rctesting------------------->' + studentMap);
            } else {
                caretakerMap = getObjectDataList(objectMap, caretakerEnrollmentId, accountId, caretakerId);
                System.debug('Rctesting----------->'+caretakerMap);
            }
        }
        resultMap = grabCriteriaResultMap(componentCriteriaMap, studentMap, caretakerMap);
        System.debug('resultMap+++++' + resultMap);
        return resultMap;
    }

    //  Build the results map for each of the component criteria
    public static Map<String, Boolean> grabCriteriaResultMap(Map<Enrollment_Component_Criteria__c, Criteria__c> componentCriteriaMap, Map<String, List<SObject>> studentMap, Map<String, List<SObject>> caretakerMap) {

        Map<String, Boolean> resultingMap = new Map<String, Boolean>();
        for (Enrollment_Component_Criteria__c componentCriterium : componentCriteriaMap.keySet()) {

            System.debug(studentMap);
            Boolean calculateResult = evaluateComponentCriteria(componentCriterium, componentCriteriaMap.get(componentCriterium), studentMap, caretakerMap);
            resultingMap.put(componentCriterium.Id, calculateResult);
            System.debug('resultingMap+++++' + resultingMap);
        }
        return resultingMap;
    }

    // Grab map of ECC to Criteria
    public static Map<Enrollment_Component_Criteria__c, Criteria__c> grabCriteriaByEnrollmentComponentCriteria(List<Enrollment_Component_Criteria__c> componentCriteria, List<Criteria__c> criteria) {

        Map<Enrollment_Component_Criteria__c, Criteria__c> criteriaReturnMap = new Map<Enrollment_Component_Criteria__c, Criteria__c>();
        for (Enrollment_Component_Criteria__c componentCriterium : componentCriteria) {

            for (Criteria__c criterium : criteria) {
                // if this criteria is the one from the ECC, add to map and break from loop
                if (componentCriterium.Criteria__c == criterium.Id) {
                    criteriaReturnMap.put(componentCriterium, criterium);
                    break;
                }
            }
        }
        System.debug('criteriaReturnMap>>>>>>>>>>>' + criteriaReturnMap);
        return criteriaReturnMap;
    }

    public static Boolean evaluateComponentCriteria(Enrollment_Component_Criteria__c componentCriteria, Criteria__c criteria, Map<String, List<SObject>> studentQueryMap, Map<String, List<SObject>> caretakerQueryMap) {

        Boolean result;
        System.debug(studentQueryMap);
        // Send the evaluation the student or caretaker query map
        if (componentCriteria.Student_or_Household__c == 'Student') {
            if (studentQueryMap.size() == 0) {
                result = false;
            } else {
                result = evaluateCriteria(criteria, criteria.Criteria_Refinements__r, studentQueryMap);
            }
        } else {
            result = evaluateCriteria(criteria, criteria.Criteria_Refinements__r, caretakerQueryMap);
        }
        System.debug('result++++' + result);
        return result;
    }

    public static Boolean evaluateCriteriaGroups(List<Criteria_Group__c> criteriaGroups, Map<String, Boolean> criteriaResultMap, String logic) {
        System.debug('criteriaGroups++++++' + criteriaGroups);
        Map<String, Boolean> criteriaGroupMap = new Map<String, Boolean>();
        for (Criteria_Group__c criteriaGroup : criteriaGroups) {
            String newLogic = criteriaGroup.Group_Logic__c; System.debug('newLogic++' + newLogic);
            Boolean resultBoolean = NES_EvaluateUtil.evaluateFunction(newLogic, criteriaResultMap);
            if (resultBoolean != null) {
                criteriaGroupMap.put(String.valueOf(criteriaGroup.Group_Number__c), resultBoolean);
            }
        }
        System.debug('criteriaGroupMap>>>>>>'+criteriaGroupMap);
        Boolean finalResult = false;
        if (String.isNotBlank(logic)) {
            finalResult = NES_EvaluateUtil.evaluateFunction(logic, criteriaGroupMap);
        }
        System.debug('finalResult2: ' + finalResult);
        return finalResult;
    }


    // Using criteria and refinements if necessary, runs criteria against answer or other field
    public static Boolean evaluateCriteria(Criteria__c criteria, List<Criteria_Refinement__c> refinements, Map<String, List<SObject>> queryMap) {

        System.debug(criteria.Id);
        Boolean result = false;
        //Split the Target field to get the Object and Field API Names
        String fieldApiName = criteria.Criteria_Field__c.substring(criteria.Criteria_Field__c.indexOf('.') + 1, criteria.Criteria_Field__c.length()).toLowerCase();
        String objectApiName = criteria.Criteria_Field__c.substring(0, criteria.Criteria_Field__c.indexOf('.')).toLowerCase();

        List<SObject> records = new List<SObject>();
        System.debug(queryMap);
        System.debug(queryMap.keySet());
        System.debug(objectApiName);
        if (queryMap.keySet().contains(objectApiName)) {
            records = queryMap.get(objectApiName);
        }
        System.debug('records: ' + records);
        List<SObject> relatedRecords = new List<SObject>();
        List<SObject> tempRecords1 = new List<SObject>();
        List<SObject> tempRecords2 = new List<SObject>();

        List<SObject> refinementRightObjects = new List<SObject>();
        List<SObject> tempRecords3 = new List<SObject>();
        List<SObject> tempRecords4 = new List<SObject>();
        if (refinements.size() > 0) {

            List<SObject> tempObjects = queryMap.get(objectApiName);

            tempRecords1 = tempObjects.clone();
            tempRecords3 = tempObjects.clone();
            for (Criteria_Refinement__c refinement : refinements) {
                if (refinement.Refinement_Type__c == 'Right Side') {

                    // loop through the records to find those that fit every refinement
                    if (tempRecords3.size() > 0) {
                        tempRecords4 = grabRelatedSObjects(tempRecords3, criteria, refinement, queryMap);
                        tempRecords3.clear();
                    } else if (tempRecords4.size() > 0) {

                        tempRecords3 = grabRelatedSObjects(tempRecords4, criteria, refinement, queryMap);
                        tempRecords4.clear();

                    } else {
                        tempRecords3 = grabRelatedSObjects(records, criteria, refinement, queryMap);
                    }

                } else {

                    // loop through the records to find those that fit every refinement
                    if (tempRecords1.size() > 0) {
                        tempRecords2 = grabRelatedSObjects(tempRecords1, criteria, refinement, queryMap);
                        tempRecords1.clear();
                    } else if (tempRecords2.size() > 0) {

                        tempRecords1 = grabRelatedSObjects(tempRecords2, criteria, refinement, queryMap);
                        tempRecords2.clear();

                    } else {
                        tempRecords1 = grabRelatedSObjects(records, criteria, refinement, queryMap);
                    }

                }
            }
            if (tempRecords1.size() > 0) {
                relatedRecords.addAll(tempRecords1);
            } else if (tempRecords2.size() > 0) {
                relatedRecords.addAll(tempRecords2);
            }
            if (tempRecords3.size() > 0) {
                refinementRightObjects.addAll(tempRecords3);
            } else if (tempRecords4.size() > 0) {
                refinementRightObjects.addAll(tempRecords4);
            }

        } else {
            relatedRecords.addAll(records);
        }

        if (relatedRecords.size() > 0) {

            String evaluateMe = getStringForAll(criteria.Comparison_Data_Type__c, relatedRecords[0], fieldApiName);
            System.debug('eval: ' + evaluateMe);
            if (refinementRightObjects.size() > 0) {
                result = directEvaluate(criteria, evaluateMe, refinementRightObjects[0]);
            } else if(criteria.Comparison_Value__c == null && records.size() > 0){
                result = directEvaluate(criteria, evaluateMe, records[0]);
            } else {
                result = directEvaluate(criteria, evaluateMe, null);
            }
            System.debug('result: ' + result);
        }
        return result;
    }

    //return list of appropriate records based on that refinement
    public static List<SObject> grabRelatedSObjects(List<SObject> records, Criteria__c criteria, Criteria_Refinement__c refinement, Map<String, List<SObject>> queryMap) {

        System.debug('Records to grab related for: ' + records);
        System.debug('And criteria; ' + criteria);
        System.debug('And refinement: ' + refinement);
        List<SObject> tempRecords = new List<SObject>();
        for (SObject record : records) {
            List<SObject> refinementObjects = new List<SObject>();
            String refinementObjectName = criteria.Criteria_Field__c.substring(0, criteria.Criteria_Field__c.indexOf('.')).toLowerCase();
            String refinementFieldName = refinement.Refinement_Field_Left__c.toLowerCase();
            System.debug(refinementObjectName);

            if(refinementObjectName == 'prior_school__c') {
                System.debug('This is the one that caused issues before');
            }

            System.debug(queryMap);
            refinementObjects = queryMap.get(refinementObjectName);

            System.debug('Refinement Objects');
            System.debug(refinementObjects);

            for (SObject sObjectRecord : refinementObjects) {
                System.debug('This is the record');
                System.debug(sObjectRecord);
                System.debug('This is the refinementFieldName');
                System.debug(refinementFieldName);
                System.debug('This is the refinementObjectName');
                System.debug(refinementObjectName);
                if (refinementFieldName.indexOf('.') > -1) {

                    String fieldApiName = refinementFieldName.substring(refinementFieldName.indexOf('.') + 1, refinementFieldName.length()).toLowerCase();
                    String objectApiName = refinementFieldName.substring(0, refinementFieldName.indexOf('.')).toLowerCase();
                    System.debug(sObjectRecord);
                    SObject childObject = sObjectRecord.getSObject(objectApiName);
                    System.debug('Looking for null failure after assignment');
                    System.debug(childObject);
                    System.debug(refinementFieldName);
                    System.debug(fieldApiName);

                    String fieldValue;
                    if(childObject != null) {
                        fieldValue = getStringForAll('text', childObject, fieldApiName);
                    } else {
                        fieldValue = '';
                    }
                    System.debug(fieldApiName);
                    System.debug(fieldValue);
                    System.debug(refinement.Refinement_Field_Right__c);
                    if (refinement.Refinement_Field_Right__c != null) {
                        String fieldRightValue;
                        String refinementRightName = refinement.Refinement_Field_Right__c.toLowerCase();
                        String fieldRightApiName = refinementRightName.substring(refinementRightName.indexOf('.') + 1, refinementRightName.length()).toLowerCase();
                        if (refinementRightName.indexOf('.') > -1) {
                            SObject childRightObject = sObjectRecord.getSObject(objectApiName);
                            if(childRightObject != null) {
                                fieldRightValue = getStringForAll('text', childRightObject, fieldRightApiName);
                            } else {
                                fieldRightValue = '';
                            }
                        } else {
                            if(childObject != null) {
                                fieldRightValue = getStringForAll('text', childObject, fieldRightApiName);
                            } else {
                                fieldRightValue = '';
                            }
                        }

                        if (fieldValue == fieldRightValue) {
                            tempRecords.add(sObjectRecord);
                        }


                    } else {
                        if (fieldValue == refinement.Refinement_Value__c) {
                            tempRecords.add(sObjectRecord);
                            System.debug(tempRecords);
                        }
                    }
                } else {

                    String fieldApiName = refinementFieldName.substring(refinementFieldName.indexOf('.') + 1, refinementFieldName.length()).toLowerCase();
                    String fieldValue = getStringForAll(criteria.Comparison_Data_Type__c, sObjectRecord, refinementFieldName);

                    if (refinement.Refinement_Field_Right__c != null) {
                        String fieldRightValue;
                        String refinementRightName = refinement.Refinement_Field_Right__c.toLowerCase();
                        String fieldRightApiName = refinementRightName.substring(refinementRightName.indexOf('.') + 1, refinementRightName.length()).toLowerCase();
                        if (refinementRightName.indexOf('.') > -1) {
                            SObject childRightObject = sObjectRecord.getSObject(refinementObjectName);
                            fieldRightValue = getStringForAll('text', childRightObject, fieldRightApiName);
                        } else {
                            fieldRightValue = getStringForAll('text', sObjectRecord, fieldRightApiName);
                        }

                        if (fieldValue == fieldRightValue) {
                            tempRecords.add(sObjectRecord);
                        }
                    } else {

                        if (fieldValue == refinement.Refinement_Value__c) {
                            tempRecords.add(sObjectRecord);
                        }
                    }
                }

            }
        }
        return tempRecords;
    }

    // Directly evaluates value for this criteria
    public static Boolean directEvaluate(Criteria__c criteria, String answer, SObject rightCompare) {

        System.debug('answer: ' + answer + ' operator: ' + criteria.Operator__c);
        String compareValue;
        
        
        if (answer == null) {
            answer = '';
        }
          
        if (String.isNotBlank(criteria.Comparison_Field__c)) {

            String fieldName = criteria.Comparison_Field__c.substring(criteria.Comparison_Field__c.indexOf('.') + 1, criteria.Comparison_Field__c.length()).toLowerCase();
            String objectName = criteria.Comparison_Field__c.substring(0, criteria.Comparison_Field__c.indexOf('.')).toLowerCase();

            System.debug(rightCompare);
           

            if (rightCompare != null) {
                compareValue = getStringForAll(criteria.Comparison_Data_Type__c, rightCompare, fieldName);
                
            } else {
                compareValue = '';
            }
            
      } else if (criteria.Comparison_Value__c == null) {
            compareValue = '';
        } else {
            compareValue = criteria.Comparison_Value__c.toLowerCase();
        }
      
        if (criteria.Comparison_Data_Type__c == 'Date' && String.isNotBlank(answer) && String.isNotBlank(compareValue)) {

            Date compareDate;
            Date answerDate = Date.parse(answer);
            if(criteria.Comparison_Value__c == 'today()') {
                compareDate = System.today();
            } else {
                compareDate = Date.parse(compareValue);                     
            }
               
            if (criteria.Operator__c == '=') {
                if (answerDate == compareDate) {
                    return true;
                }
            } else if (criteria.Operator__c == '<') {
                if (answerDate < compareDate) {
                    return true;
                }
            } else if (criteria.Operator__c == '>') {
                if (answerDate > compareDate) {
                    return true;
                }
            } else if (criteria.Operator__c == '!=') {
                if (answerDate != compareDate) {
                    return true;
                }
            } else if (criteria.Operator__c == '<=') {
                if (answerDate <= compareDate) {
                    return true;
                }
            } else if (criteria.Operator__c == '>=') {
                if (answerDate >= compareDate) {
                    return true;
                }
            }
           
        } else if ((criteria.Comparison_Data_Type__c == 'Number' || criteria.Comparison_Data_Type__c == 'Date (Years Calculated)') && String.isNotBlank(answer) && String.isNotBlank(compareValue)) {

            Decimal compareDecimal = Decimal.valueOf(compareValue);
            Decimal answerDecimal = 0;
           System.debug(compareDecimal);
            System.debug(answerDecimal);
            if(criteria.Comparison_Data_Type__c == 'Number') {
                answerDecimal = Decimal.valueOf(answer);
            } else {
                Date answerDate = Date.parse(answer);
                Date todayDate = System.today();
                Integer numberOfMonths = todayDate.monthsBetween(answerDate);
                Decimal numberOfYears = numberOfMonths/12;
                answerDecimal = numberOfYears.round(System.RoundingMode.DOWN);

            }

            if (criteria.Operator__c == '=') {
                if (answerDecimal == compareDecimal) {
                    return true;
                }
            } else if (criteria.Operator__c == '<') {
                if (answerDecimal < compareDecimal) {
                    return true;
                }
            } else if (criteria.Operator__c == '>') {
                if (answerDecimal > compareDecimal) {
                    return true;
                }
            } else if (criteria.Operator__c == '!=') {
                if (answerDecimal != compareDecimal) {
                    return true;
                }
            } else if (criteria.Operator__c == '<=') {
                if (answerDecimal <= compareDecimal) {
                    return true;
                }
            } else if (criteria.Operator__c == '>=') {
                if (answerDecimal >= compareDecimal) {
                    return true;
                }
            }
            
        } else if (criteria.Comparison_Data_Type__c == 'Datetime' && String.isNotBlank(answer) && String.isNotBlank(compareValue)) { 

            Datetime compareDatetime;
            Datetime answerDatetime = Datetime.valueOf(answer);
           
            if(criteria.Comparison_Value__c == 'today()') {
                compareDatetime = System.now();
            } else {
                compareDatetime = Datetime.valueOf(compareValue);
            }

            if (criteria.Operator__c == '=') {
                if (answerDatetime == compareDatetime) {
                    return true;
                }
            } else if (criteria.Operator__c == '<') {
                if (answerDatetime < compareDatetime) {
                    return true;
                }
            } else if (criteria.Operator__c == '>') {
                if (answerDatetime > compareDatetime) {
                    return true;
                }
            } else if (criteria.Operator__c == '!=') {
                if (answerDatetime != compareDatetime) {
                    return true;
                }
            } else if (criteria.Operator__c == '<=') {
                if (answerDatetime <= compareDatetime) {
                    return true;
                }
            } else if (criteria.Operator__c == '>=') {
                if (answerDatetime >= compareDatetime) {
                    return true;
                } 
            }
        } else {
            if ((criteria.Operator__c == 'CONTAINS' || criteria.Operator__c == 'DOES NOT CONTAIN') && String.isNotBlank(answer)) { 
                answer = answer.toLowerCase();
                compareValue = compareValue.toLowerCase();
                if (criteria.Operator__c == 'CONTAINS') {
                    if (answer.indexOf(compareValue) > -1) {
                        return true;
                    } else {
                        return false;
                    }
                }
                if (criteria.Operator__c == 'DOES NOT CONTAIN') {
                    if (answer.indexOf(compareValue) == -1) {
                        return true;
                    } else {
                        return false;
                    }
                }
            } else {
                if (criteria.Operator__c == '=') {
                    if (answer == compareValue) {
                        return true;
                    }
                } else if (criteria.Operator__c == '<') {
                    if (answer < compareValue) {
                        return true;
                    }
                } else if (criteria.Operator__c == '>') {
                    if (answer > compareValue) {
                        return true;
                        
                    }
                    
                } else if (criteria.Operator__c == '!=') {
                    if (answer != compareValue) {
                        return true;
                    }
                } else if (criteria.Operator__c == '<=') {
                    if (answer <= compareValue) {
                        return true;
                    }
                } else if (criteria.Operator__c == '>=') {
                    if (answer >= compareValue) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    //Return string for different types
    public static String getStringForAll(String dataType, SObject record, String fieldName) {

        String stringForReturn;
        System.debug('In Get String For All');
        System.debug(record);
        System.debug(dataType);
        System.debug(fieldName);
        Map<String, Object> fieldMapping = record.getPopulatedFieldsAsMap();
        System.debug('fieldMapping: ' + fieldMapping);
        Map<String, Object> fieldMappingLowercase = new Map<String, Object>();
        for (String mapKey : fieldMapping.keySet()) {
            System.debug('Map key ' + mapKey);
            Object tempObject = fieldMapping.get(mapKey);
            System.debug('Temp obj: ' + tempObject);
            fieldMappingLowercase.put(mapKey.toLowerCase(), tempObject);
        }

        if (fieldMappingLowercase.containsKey(fieldName)) {
            System.debug(record.get(fieldName));
            System.debug('She is in here');
            
            if (dataType == 'Date'  || dataType == 'Date (Years Calculated)') {
                stringForReturn = ((Date) record.get(fieldName)).format();
                System.debug('date: ' + stringForReturn);
            } else if (dataType == 'Number') {
                stringForReturn = String.valueOf((Decimal) record.get(fieldName));
            } else if (dataType == 'Datetime') {
                stringForReturn = String.valueOf((Datetime) record.get(fieldName));
            } else if (dataType == 'Time') {
                stringForReturn = String.valueOf((Time) record.get(fieldName));
            } else if (dataType == 'Boolean') {
                System.debug('System value is below');
                System.debug(record.get(fieldName));
                stringForReturn = String.valueOf(Boolean.valueOf(record.get(fieldName)));
            } else {
                SObjectType r = record.getSObjectType();
                DescribeSObjectResult d = r.getDescribe();
                if (d.fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean) {
                    stringForReturn = String.valueOf((Boolean) record.get(fieldName));
                } else {
                    System.debug('Trying to get this one 1');
                    stringForReturn = String.valueOf((String) record.get(fieldName));
                }

            }
        } else if (fieldName.indexOf('.') > -1) {
            System.debug('No dot');
            String fieldApiName = fieldName.substring(fieldName.indexOf('.') + 1, fieldName.length()).toLowerCase();
            String objectApiName = fieldName.substring(0, fieldName.indexOf('.')).toLowerCase();
            SObject childObject = record.getSObject(objectApiName);

            if(childObject != null) {

                if (dataType == 'Date' || dataType == 'Date (Years Calculated)') {
                    stringForReturn = ((Date) childObject.get(fieldApiName)).format();
                    System.debug('date: ' + stringForReturn);
                } else if (dataType == 'Number') {
                    stringForReturn = String.valueOf((Decimal) childObject.get(fieldApiName));
                } else if (dataType == 'Datetime') {
                    stringForReturn = String.valueOf((Datetime) childObject.get(fieldApiName));
                } else if (dataType == 'Time') {
                    stringForReturn = String.valueOf((Time) childObject.get(fieldApiName));
                } else if (dataType == 'Boolean') {
                    stringForReturn = String.valueOf((Boolean) childObject.get(fieldApiName));
                } else {
                    System.debug('Trying to get this one');
                    stringForReturn = String.valueOf((String) childObject.get(fieldApiName));
                }
            }
        }
        if (stringForReturn != null) {
            if (stringForReturn.toLowerCase() == 'true' || stringForReturn.toLowerCase() == 'false') {
                stringForReturn = stringForReturn.toLowerCase();
            }
        }
        return stringForReturn;
    }

    //Evaluate the criteria group expression
    public static Boolean evaluateFunction(String expression, Map<String, Boolean> criteriaResultMap) {
        System.debug('expression>>>>>>' + expression);
        System.debug('criteriaResultMap>>>>>>' + criteriaResultMap);
        if (expression != null && expression != '' && criteriaResultMap.size() != 0) {
            expression = expression.replaceAll('\\|\\|', 'OR').replaceAll('&&', 'AND');
            System.debug('expression>>>>>>>>>>>' + expression);
            expression = formatExpression(expression, criteriaResultMap);
            System.debug('expression' + expression);
            Boolean result = evaluate(expression);
            return result;
        } else {
            return false;
        }
    }

    public static Boolean evaluate(String expression) {

        Boolean finalResult;

        if (!expression.contains('(')) {
            finalResult = evaluateExpression(expression);
            return finalResult;
        }

        Integer indexOfOpen = -1;
        Integer indexOfClose = -1;

        String[] chars = expression.split('');
        for (Integer i = 0; i < chars.size(); i++) {

            String singleChar = chars[i];

            if (singleChar == '(') {
                indexOfOpen = i;
                continue;
            }

            if (singleChar == ')') {
                indexOfClose = i;
                break;
            }
        }

        String replace = expression.substring(indexOfOpen + 1, indexOfClose);
        expression = expression.replace('(' + replace + ')', String.valueOf(evaluateExpression(replace)));
        System.debug(replace);
        System.debug(expression);
        System.debug('########');
        finalResult = evaluate(expression);
        return finalResult;
    }

    public static Boolean evaluateExpression(String expression) {

        Boolean result = false;
        for (String conj : expression.split(' OR ')) {

            Boolean b = true;
            for (String single : conj.split(' AND ')) {
                b &= Boolean.valueOf(single.trim());                
            }

            result |= b;
        }

        return result;

    }

    public static String formatExpression(String expression, Map<String, Boolean> criteriaResultMap) {

        String[] arguments = expression.splitByCharacterType();
        System.debug('arguments>>>>>>>>>' + arguments);
        for (String arg : arguments) {
            if(arg.length() > 1) {
                try {
                    String mapKey = String.valueOf(criteriaResultMap.get(arg));
                    expression = expression.replace(arg, mapKey);
                    System.debug('formatExpression expression>>>>>>>>>>' + expression);
                } catch (Exception e) {
                    continue;
                }
            }
        }
        for (String arg : arguments) {
            if(arg.length() == 1) {
                try {
                    String mapKey = String.valueOf(criteriaResultMap.get(arg));
                    expression = expression.replace(arg, mapKey);
                    System.debug('formatExpression expression>>>>>>>>>>' + expression);
                } catch (Exception e) {
                    continue;
                }
            }
        }
        System.debug('expression: ' + expression);
        return expression;
    }

    // verify if a field exists
    public static Boolean hasSObjectField(String fieldName, SObject so) {
        fieldName = fieldName.toLowerCase();
        return so.getSObjectType().getDescribe().fields.getMap().keySet().contains(fieldName);
    }

    // Send list of object.fields, return map of object, field list
    public static Map<String, List<String>> configureQueryMap(Set<String> fieldsForEval) {
        System.debug(fieldsForEval);
        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        Map<String, Set<String>> objectMap = new Map<String, Set<String>>();
        try {
            for (String fieldForEval : fieldsForEval) {
                if (!isValidField(fieldForEval)) {
                    throw new InvalidFieldException(fieldForEval);
                }
                System.debug(fieldForEval);
                if (fieldForEval != null) {
                    Set<String> currentFields = new Set<String>();
                    fieldForEval = fieldForEval.toLowerCase();
                    //Split the field to get the Object and Field API Names
                    String fieldApiName = getFieldNameFromTargetField(fieldForEval);
                    String objectApiName = getObjectNameFromTargetField(fieldForEval);

                    // if already in map, add to list
                    if (objectMap.keySet().contains(objectApiName)) {
                        currentFields = objectMap.get(objectApiName);
                        currentFields.add(fieldApiName);
                    } else {
                        currentFields.add(fieldApiName);
                    }
                    SObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
                    Boolean schoolYearExists = hasSObjectField('School_Year__c', sObj);
                    Boolean groupExists = hasSObjectField('Question_Group__c', sObj);
                    System.debug('school year: ' + schoolYearExists);
                    if (schoolYearExists) {
                        currentFields.add('school_year__c');
                    }
                    if (groupExists) {
                        currentFields.add('question_group__c');
                    }
                    objectMap.put(objectApiName, currentFields);
                }

            }
            System.debug(objectMap);

            // turn the set of fields into a list for return
            for (String objectName : objectMap.keySet()) {
                List<String> returnFields = new List<String>();
                Set<String> fieldStrings = objectMap.get(objectName);
                returnFields.addAll(fieldStrings);
                returnMap.put(objectName, returnFields);
            }

            return returnMap;
        } catch(Exception e) {
            logger.logException('configureQueryMap', e);
            logger.saveLogs();
            throw e;
        }
    }

    // Create queryMap for Object-field combos from List of ECCs and List of Criteria for each student and caretaker
    @AuraEnabled
    public static Map<String, Map <String, List<String>>> getECCQueryMap(Map<Enrollment_Component_Criteria__c, Criteria__c> componentCriteriaMap) {

        Set<String> studentTargets = new Set<String>();
        Set<String> caretakerTargets = new Set<String>();

        for (Enrollment_Component_Criteria__c enrollmentComponentCriteria : componentCriteriaMap.keySet()) {

            // Grab all the related fields for this specific component criterium
            Criteria__c specificCriteria = componentCriteriaMap.get(enrollmentComponentCriteria);
            Set<String> specificTargets = returnSetStringTargets(specificCriteria);

            if (enrollmentComponentCriteria.Student_or_Household__c == 'Student') {
                studentTargets.addAll(specificTargets);
            } else {
                caretakerTargets.addAll(specificTargets);
            }

        }

        Map<String, List<String>> studentQueryMap = configureQueryMap(studentTargets);
        Map<String, List<String>> caretakerQueryMap = configureQueryMap(caretakerTargets);
        Map<String, Map <String, List<String>>> newQueryMap = new Map<String, Map <String, List<String>>>();
        newQueryMap.put('Student', studentQueryMap);
        newQueryMap.put('Caretaker', caretakerQueryMap);

        return newQueryMap;

    }

    // Grab set of targets for student or household
    public static Set<String> returnSetStringTargets(Criteria__c criteria) {

        Set<String> targets = new Set<String>();
        targets.add(criteria.Criteria_Field__c);


        if (String.isNotBlank(criteria.Comparison_Field__c)) {
            targets.add(criteria.Comparison_Field__c);
        }

        for (Criteria_Refinement__c refinement : criteria.Criteria_Refinements__r) {
            String objectApiName = criteria.Criteria_Field__c.substring(0, criteria.Criteria_Field__c.indexOf('.')).toLowerCase();
            targets.add(objectApiName + '.' + refinement.Refinement_Field_Left__c);
            System.debug('right here');
            System.debug(objectApiName + '.' + refinement.Refinement_Field_Left__c);
            if (String.isNotBlank(refinement.Refinement_Field_Right__c)) {
                targets.add(objectApiName + '.' + refinement.Refinement_Field_Right__c);
            }

        }
        return targets;

    }

    // Return a question from an Enrollment Component for Add a Student
    public static NES_EvaluateUtil.Question configureQuestion(Enrollment_Component__c question, Map<Id, Option_Exclusion__c> optionExclusionMap, Map<String, List<SObject>> dataMap, Decimal orderNumber, Boolean groupQuestion, Id groupId, Set<String> targetsStrings) {

        //Initialize Wrapper Object
        List<Enrollment_Component_Picklist_Option__c> optionsList = new List<Enrollment_Component_Picklist_Option__c>();

        NES_EvaluateUtil.Question wrap = new NES_EvaluateUtil.Question();
        wrap.questionPrompt = question.Question_Prompt__c;
        // add code by Maddileti on 02/08/19 for #101934 User Story
        wrap.questionReadOnly = question.Question_Read_Only__c;
        wrap.tooltipText = question.Tooltip_Text__c;
        wrap.componentMessage = question.Component_Message__c;
        wrap.validation = question.Question_Validation__c;
        wrap.validationMessage = question.Question_Validation_Message__c != null ? question.Question_Validation_Message__c.replaceAll('<[^>]+>','') : '';
        wrap.questionType = question.Question_Type__c;
        wrap.questionId = question.Id;
        wrap.required = question.Is_Required__c;
        wrap.questionTarget = question.Answer_Target__c;
        wrap.componentType = question.Component_Type__c;
        wrap.schoolYear = question.Question_School_Year__c;
        wrap.apiMapping = question.API_Mapping__c;
        wrap.questionGroup = groupQuestion;
        wrap.order = orderNumber;

        if (String.isNotBlank(groupId)) {
            System.debug('We are setting a parent id. Parent trap');
            wrap.parentId = groupId;
        }

        if (question.RecordType.Name == NES_DashboardUtilities.TEXT_RT) {
            wrap.textComponent = true;
        } else {
            wrap.textComponent = false;
        }
        wrap.picklistValues = new List<NES_EvaluateUtil.PicklistOption>();
      	// wrap.exclPicklistValues = new List<NES_EvaluateUtil.PicklistOption>();

        System.debug(question.Question_Type__c);

        //Check the type of the record and check whether there any child records of type options
        if ((question.Question_Type__c == 'Radio' || question.Question_Type__c == 'Checkbox Group' || question.Question_Type__c == 'Picklist') && question.Enrollment_Component_Picklist_Options__r != null) {
            for (Enrollment_Component_Picklist_Option__c option : question.Enrollment_Component_Picklist_Options__r) {

                //Check Whether there is option exclusion record or not if there is none then only add the picklist options
                if (!optionExclusionMap.containsKey(option.Id)) {
                    NES_EvaluateUtil.PicklistOption optionValue = new NES_EvaluateUtil.PicklistOption();
                    if (option.Option_Value__c.toLowerCase() == 'true' || option.Option_Value__c.toLowerCase() == 'false') {
                        optionValue.value = option.Option_Value__c.toLowerCase();
                    } else {
                        optionValue.value = option.Option_Value__c;
                    }

                    optionValue.label = option.Option_Label__c;
                    optionValue.order = option.Order__c;

                    wrap.picklistValues.add(optionValue);
                }/*
                else{
					if(question.Question_Type__c == 'Picklist'&& ){
                    NES_EvaluateUtil.PicklistOption optionValue = new NES_EvaluateUtil.PicklistOption();
                    optionValue.label = option.Option_Label__c;
                    optionValue.value = option.Option_Value__c;
                    optionValue.order = option.Order__c;
                    wrap.exclPicklistValues.add(optionValue);
                }
            }*/
        }
        }

        System.debug(question.Answer_Target__c);

        if (String.isNotBlank(question.Answer_Target__c)) {

            if(targetsStrings.contains(question.Answer_Target__c)) {
                wrap.hasCriteria = true;
            } else {
                wrap.hasCriteria = false;
            }

            if(question.RecordType.Name == NES_DashboardUtilities.HIDDEN_INPUT) {
                wrap.targetField = question.Default_Value__c;
            } else {
                   wrap.targetField = getRecordString(question.Answer_Target__c.toLowerCase(), dataMap, question.Question_Type__c, question.Question_School_Year__c, groupId,question.id);
            }

            if(wrap.questionPrompt == '' || wrap.questionPrompt == null) {
                System.debug('This was a hidden input');
                System.debug('The value was set to: ' + wrap.targetField);
                System.debug('The question target is: ' + wrap.questionTarget);
            }
        }
        return wrap;
    }

    // Create queryMap for Object-field combos from the question target fields for caretaker only
    @AuraEnabled
    public static Map <String, List<String>> getQueryMap(List<NES_EvaluateUtil.Question> questionDataList, String componentType) {
        Map <String, List<String>> queryMap = new Map <String, List<String>>();
        Set<String> targetFields = new Set<String>();
        for (NES_EvaluateUtil.Question data : questionDataList) {
            System.debug(data.componentType);
            System.debug(componentType);
            System.debug(data.componentType == componentType);
            System.debug(data.questionTarget);
            if (data.componentType == componentType && data.questionTarget != null) {
                targetFields.add(data.questionTarget);
            }
        }
        System.debug(targetFields);
        queryMap = configureQueryMap(targetFields);

        return queryMap;
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Parameters: ID, String, Set<String>
     * Return Type: Set<Id>
     * Purpose : This method is used to retrieve and return all the child enrollment component Ids based on their record types
    */

    public static Set<Id> getChildComponentIds(Set<Id> parentIds, Set<String> parentRecordTypes, Set<String> childRecordTypes) {
        Set<Id> childIds = new Set<Id>();

        for (Enrollment_Component_Relationship__c temp : [
                SELECT Child_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :parentIds
                AND Child_Enrollment_Component__r.RecordType.Name IN:childRecordTypes
                AND Parent_Enrollment_Component__r.RecordType.Name IN:parentRecordTypes
        ]) {
            childIds.add(temp.Child_Enrollment_Component__c);
        }

        return childIds;
    }

    //Return value needed from dataMap
    public static String getRecordString(String target, Map<String, List<SObject>> dataMap, String dataTypeString, Id schoolYearId, Id groupId,Id record) {

        String returnString;
        if (String.isNotBlank(target)) {
            String fieldApiName = target.substring(target.indexOf('.') + 1, target.length()).toLowerCase();
            String objectApiName = target.substring(0, target.indexOf('.')).toLowerCase();
            System.debug('hello');
            System.debug(objectApiName); 
            System.debug(fieldApiName);
            if (dataMap.size() > 0) {
                System.debug(dataMap);
                System.debug(dataMap.keySet());
                System.debug(schoolYearId);
                System.debug(groupId);
                List<SObject> relatedSObjects = dataMap.get(objectApiName);
                List<SObject> relatedObjects = new List<SObject>();
                System.debug(relatedSObjects);
                if (relatedSObjects != null) {
                    if (String.isNotBlank(schoolYearId) || String.isNotBlank(groupId)) {
                       
                        for (SObject relatedSObject : relatedSObjects) {
                            System.debug(relatedSObject);
                            if (String.isNotBlank(schoolYearId) && String.isNotBlank(groupId)) {
                                String schoolYear = (String) relatedSObject.get('School_Year__c');
                                String questionGroup = (String) relatedSObject.get('Question_Group__c');
                                if (questionGroup == groupId && schoolYear == schoolYearId) {
                                    relatedObjects.add(relatedSObject);
                                }
                            } else if (String.isNotBlank(schoolYearId)) {
                                String schoolYear = (String) relatedSObject.get('School_Year__c');
                                if (schoolYear == schoolYearId) {
                                    //added logic for 113424 bug      
                                    if(objectApiName == 'prior_school__c')  {                           
                     Enrollment_Component_Relationship__c rel =[ SELECT Id, Parent_Enrollment_Component__c from Enrollment_Component_Relationship__c where Child_Enrollment_Component__c =:record];
                                    String questionGroup = (String) relatedSObject.get('Question_Group__c');
                                   if( questionGroup == rel.Parent_Enrollment_Component__c){                                    
                                    relatedObjects.add(relatedSObject);
                                    }
                                    }else{
                                       relatedObjects.add(relatedSObject);  
                                    }
                                //added logic for 113424 bug 
                                }
                                
                            } else if (String.isNotBlank(groupId)) {
                                String questionGroup = (String) relatedSObject.get('Question_Group__c');
                                if ( questionGroup == groupId) {
                                    relatedObjects.add(relatedSObject);
                                }
                            }
                        }
                    } else {
                        relatedObjects.addAll(relatedSObjects);
                    }

                    if (relatedObjects.size() > 0) {
                        System.debug('We are trying to get something at least');
                        System.debug(dataTypeString);
                        System.debug(relatedObjects[0]);
                        System.debug(fieldApiName);
                        returnString = getStringForAll(dataTypeString, relatedObjects[0], fieldApiName);
                    }
                }
            }
        }
        if (returnString == null) {
            returnString = ''; 
        }
        return returnString;
    }

    // Create query Map of object name and records in those fields related to the program enrollment entered
    @AuraEnabled
    public static Map<String, List<SObject>> getObjectDataList(Map <String, List<String>> queryMap, Id enrollmentId, Id accountId, Id contactId) {
        Map<String, List<SObject>> newQueryMap = new Map<String, List<SObject>>();
        for (String mapKey : queryMap.keySet()) {
            List<SObject> childRecords = new List<SObject>();
            String objectName = mapKey;
            List<String> fieldNames = queryMap.get(mapKey);
            String fieldStrings;
            for (Integer i = 0; i < fieldNames.size(); i++) {
                if (i == 0) {
                    fieldStrings = fieldNames[i].toLowerCase();
                } else {
                    fieldStrings = fieldStrings + ',' + fieldNames[i].toLowerCase();
                }
            }
            String query;
            if (objectName == 'account') {
                query = 'SELECT id, ' + fieldStrings + ' FROM Account WHERE Id = \'' + accountId + '\' ';
            } else if (objectName == 'contact') {
                query = 'SELECT id, ' + fieldStrings + ' FROM Contact WHERE Id = \'' + contactId + '\' ';
            } else if (objectName == 'hed__program_enrollment__c' && String.isNotBlank(enrollmentId)) {
                query = 'SELECT id, ' + fieldStrings + ' FROM hed__program_enrollment__c WHERE id = \'' + enrollmentId + '\' ';
            } else if (String.isNotBlank(enrollmentId)) {
                query = 'SELECT id, ' + fieldStrings + ' FROM ' + objectName + ' WHERE program_enrollment__c = \'' + enrollmentId + '\' ';
            }
				
            System.debug('testingrc-------->'+ query);
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

    // Grab Criteria Number to Boolean result Map for eligibility
    public static Map<String, Boolean> getResultMap(Id processId, Contact newStudent, User caretaker, Id studentEnrollmentId, Id caretakerEnrollmentId) {

        List<Enrollment_Component_Criteria__c> processComponentCriteria = [SELECT Criteria_Number__c, Criteria__c, Student_or_Household__c, Criteria_Type__c, Enrollment_Component__r.Component_Type__c FROM Enrollment_Component_Criteria__c WHERE Enrollment_Component__c = :processId];
        Map<Id, String> componentTypeMap = new Map<Id, String>();

        for (Enrollment_Component_Criteria__c enrollmentComponentCriteria : processComponentCriteria) {
            componentTypeMap.put(enrollmentComponentCriteria.Id, enrollmentComponentCriteria.Student_or_Household__c);
        }
        Map<String, Boolean > resultMap = NES_EvaluateUtil.getCriteriaResultMap(processComponentCriteria, newStudent.Id, caretaker.ContactId, newStudent.AccountId, studentEnrollmentId, caretakerEnrollmentId);
        Map<String, Boolean> criteriaResultMap = NES_ECAEvaluation.getBooleansByNumber(resultMap, processComponentCriteria);

        return criteriaResultMap;
    }

    //Enter data into field based on field type 
    public static SObject updateDataVoid(String dataType, String fieldData, String fieldName, SObject sObj) {

        System.debug('In updateDataVoid');
        System.debug(fieldData);
        System.debug(fieldName);
        if (fieldData == null || String.isBlank(fieldData)) {
            sObj.put(fieldName, null);
        } else if (dataType == 'Date') {
            Date myDate;
            try {
                myDate = Date.parse(fieldData);
            } catch (Exception e) {
                myDate = Date.valueOf(fieldData);
            }
            sObj.put(fieldName, myDate);
        } else if (dataType == 'Boolean') {
            System.debug('About to assign Boolean');
            System.debug(sObj);
            if(fieldData != null && String.isNotEmpty(fieldData)) {
                System.debug(fieldData);
                System.debug('Trying to assign anyway');
                sObj.put(fieldName, Boolean.valueOf(fieldData));
            }
        } else if (dataType == 'Number') {
            sObj.put(fieldName, Decimal.valueOf(fieldData));
        } else if (dataType == 'Date/Time') {
            sObj.put(fieldName, Datetime.valueOf(fieldData));
        } else {
            if (fieldData.equalsIgnoreCase('true') || fieldData.equalsIgnoreCase('false')) {
                Map<String, Schema.SObjectField> M = Schema.getGlobalDescribe().get(String.valueOf(sObj.getSObjectType())).getDescribe().fields.getMap();
                if(String.valueOf(M.get(fieldName).getDescribe().getType()).equalsIgnoreCase('Boolean')) {
                    sObj.put(fieldName, Boolean.valueOf(fieldData));
                } else {
                    sObj.put(fieldName, fieldData);
                }

            } else {
                sObj.put(fieldName, fieldData);
            }

        }
        System.debug('After updatedatavoid');
        return sObj;
    }

    // Determine whether a given field is a valid field
    public static Boolean isValidField(String fieldForEval) {
        // fields must be of the format {Object API Name}.{Field API Name}
        if (fieldForEval == null || fieldForEval.indexOf('.') == -1) {
            return false;
        } else {
            // either of these would throw an exception if not valid
            String fieldApiName = getFieldNameFromTargetField(fieldForEval);
            String objectApiName = getObjectNameFromTargetField(fieldForEval);

            return true;
        }
    }

    public static String getObjectNameFromTargetField(String targetField) {
        try {
            String fieldApiName = targetField.substring(targetField.indexOf('.') + 1, targetField.length());
            String objectApiName = targetField.substring(0, targetField.indexOf('.'));
            Sobject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
            return objectApiName;
        } catch (Exception e) {
            throw new InvalidFieldException(targetField);
        }
    }

    public static String getFieldNameFromTargetField(String targetField) {
        try {
            String fieldApiName = targetField.substring(targetField.indexOf('.') + 1, targetField.length());
            String objectApiName = targetField.substring(0, targetField.indexOf('.'));

            // if we want to validate the field exists, it looks something like this:
            // NOTE that it will not work with higher level fields, like prior_school__c.Question_Group__r.External_Id__c
            //Schema.SObjectField sobjField = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName);
            //if (sobjField != null) {
            //    return fieldApiName;
            //} else {
            //    throw new InvalidFieldException(targetField);
            //}

            return fieldApiName;
        } catch (Exception e) {
            throw new InvalidFieldException(targetField);
        }
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Question type enrollment component information
     * add Boolean questionReadOnly variable to Wrapper class by Maddileti on 02/08/19 for 101934 User Story
    */
    public class Question {
        @AuraEnabled
        public String questionPrompt { get; set; }
        @AuraEnabled
        public Boolean questionReadOnly { get; set; }
        @AuraEnabled
        public String tooltipText { get; set; }
        @AuraEnabled
        public String componentMessage { get; set; }
        @AuraEnabled
        public String questionType { get; set; }
        @AuraEnabled
        public String questionId { get; set; }
        @AuraEnabled
        public String parentId { get; set; }
        @AuraEnabled
        public String targetField { get; set; }
        @AuraEnabled
        public String componentType { get; set; }
        @AuraEnabled
        public String questionTarget { get; set; }
        @AuraEnabled
        public Boolean required { get; set; }
        @AuraEnabled
        public String validation { get; set; }
        @AuraEnabled
        public String validationMessage { get; set; }
        @AuraEnabled
        public Boolean hasCriteria { get; set; }
        @AuraEnabled
        public String defaultValue { get; set; }
        @AuraEnabled
        public Boolean questionGroup { get; set; }
        @AuraEnabled
        public String schoolYear { get; set; }
        @AuraEnabled
        public String apiMapping { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }
        @AuraEnabled
        public Boolean textComponent { get; set; }
        @AuraEnabled
        public List<PicklistOption> picklistValues { get; set; }
        @AuraEnabled
        public List<PicklistOption> exclPicklistValues { get; set; }
        

        public Question() {
            questionReadOnly = false;
        }
    }

    public class PicklistOption {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Decimal order { get; set; }

        public PicklistOption() {
        }
    }

    public class NewStudentData {
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String middleName { get; set; }//added for US116612  
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String suffix { get; set; }//added for US116612
        @AuraEnabled public String relationshipType { get; set; }
        @AuraEnabled public String SelectedSchoolId { get; set; }
        @AuraEnabled public String SelectedSchoolYear { get; set; }
        @AuraEnabled public String SelectedGradeLevelId { get; set; }
        @AuraEnabled public String SelectedGradeLevel { get; set; }
        @AuraEnabled public Account defaultAccount { get; set; }
        @AuraEnabled public List<School_Year__c> schoolYears { get; set; }
        @AuraEnabled public List<Account> activeSchools { get; set; }
        @AuraEnabled public List<Grade_Level__c> gradeLevels { get; set; }
       
        
            //added mName and suffix for US116612
        public NewStudentData(String fName,String mName, String lName,String suffix,String relationType, String schoolId, String gradeLevelId, String gradeLevel,
                Account defaultAcc, List<School_Year__c> years, List<Account> schools, List<Grade_Level__c> levels) {
            this.firstName = fName;
            this.lastName = lName; 
            this.middleName = mName; //added for US116612 
            this.suffix = suffix; //added for US116612 
            this.relationshipType = relationType;
            this.SelectedSchoolId = schoolId;
            this.SelectedGradeLevelId = gradeLevelId;
            this.SelectedGradeLevel = gradeLevel;
            this.defaultAccount = defaultAcc;
            this.schoolYears = years;
            this.activeSchools = schools;
            this.gradeLevels = levels;

        }
    }

    public class InvalidFieldException extends Exception {}
}