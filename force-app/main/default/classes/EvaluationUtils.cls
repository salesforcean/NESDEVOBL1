/**
    @class:         EvaluationUtils           
    @description:   Part of rewrite of the ECA assignment and completion logic, Created to support the new method for ECA Evaluation and Completion
	@author: 		Mark Membrino
	@createdDate:   7/27/2020
*/

public class EvaluationUtils  {
    //This method is the main entry point from the triggers that have been written on the base objects.
    //It is handed a list of fields that have been updated and collected in a trigger.  
    //The changedFieldsMap parameter is a map between field names and the value that field was updated to.
    public static void evaluateChangedFields( List<fieldUpdate> fieldUpdateList)
    {
        Set<String> PESet = new Set<String>();
        Set<Id> hhPEs = new Set<Id>(); // collect household PEs
        Set<String> fieldSet = new Set<String>();
        Map<String, List<fieldUpdate>> peToFieldListMap = new Map<String, List<fieldUpdate>> ();
        //Build a set of unique Program Enrollments and impacted fields to use to query the PE Criteria object. Also build a map
        //between PE and a list of fields that have been changed so finding impacted criteria will be simpler.
        for (fieldUpdate f : fieldUpdateList) {
            PESet.add(f.programEnrollmentId);
            fieldSet.add(f.objectAndFieldName);
            if (f.studentOrHousehold!=null && f.studentOrHousehold.equalsIgnoreCase('Household'))
                hhPEs.add(f.programEnrollmentId); // collect household PEs

            List<fieldUpdate> thisPEsList;
            if (!peToFieldListMap.containsKey(f.programEnrollmentId))  {
                thisPEsList = new List<fieldUpdate> ();
                peToFieldListMap.put(f.programEnrollmentId, thisPEsList);
            } else
                thisPEsList = peToFieldListMap.get(f.programEnrollmentId);

            thisPEsList.add(f);
        }

        // fetch all studPEs which have HHPEs with changedFields...
        Map<Id, Id> studPEtoHHPE = new Map<Id, Id>(); // fetchAndMapStudPEs, tied to a HouseHold
        for (hed__Program_Enrollment__c studPE : 
            [   
                SELECT  Id, Household_Program_Enrollment__c // , hed__Account__c
                FROM    hed__Program_Enrollment__c
                WHERE   Household_Program_Enrollment__c 
                IN  : hhPEs
                AND Status__c  = 'In Progress'
            ]) 
        {
            studPEtoHHPE.put(studPE.Id, studPE.Household_Program_Enrollment__c);
        }
        

        //Retrieve all the PE criteria for the PEs and fields that were passed.
        List<Program_Enrollment_Criteria__c> allPECs
                    = new List<Program_Enrollment_Criteria__c> (
                        [
                            SELECT  Id, Result__c, Criteria__r.Comparison_Data_Type__c, Criteria__r.Operator__c, 
                                    Criteria__r.Comparison_Value__c, Criteria__r.Criteria_Field__c,
                                    Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c,
                                    Program_Enrollment__c
                            FROM    Program_Enrollment_Criteria__c 
                            WHERE   
                                (
                                    Program_Enrollment__c in :PESet 
                                    OR
                                    Program_Enrollment__c in :studPEtoHHPE.keySet()
                                ) 
                                AND 
                                Criteria__r.Criteria_Field__c in :fieldSet 
                        ]
                    );

        //Iterate over all the Criteria for this PE and see if any were impacted.
        list <criteriaItem> impactedCriteria = new list <criteriaItem>();
        for (Program_Enrollment_Criteria__c pec:allPECs) {

            //Get the list of field updates for the PE we are currently working on.
            //We need to confirm that the PE Criteria is the 'right' one that was updated.  We need to account for
            //filter criteria like is this a household or student or current school year.
            List<fieldUpdate> thisPEsList;
            if (peToFieldListMap.containsKey(pec.Program_Enrollment__c) 
                || ( studPEtoHHPE.size()>0 &&  peToFieldListMap.containsKey( studPEtoHHPE.get( pec.Program_Enrollment__c ))))
                {
                    if (((thisPEsList = peToFieldListMap.get(pec.Program_Enrollment__c)) == null) && studPEtoHHPE.size()>0)
                        thisPEsList = peToFieldListMap.get(studPEtoHHPE.get(pec.Program_Enrollment__c));
                }

            for ( fieldUpdate t: thisPEsList ) {
                if ((t.objectAndFieldName == pec.Criteria__r.Criteria_Field__c) &&
                    (t.mostRecent == null || t.mostRecent == false || t.mostRecent && pec.Most_Recent__c)  &&
                    (String.IsBlank(t.questionGroup) || pec.Question_Group__c == t.questionGroup) &&
                    (String.IsBlank(t.schoolYear) || pec.School_Year__c == t.schoolYear)
                    && (String.IsBlank(t.studentOrHousehold) || pec.Student_or_Household__c == t.studentOrHousehold) ) {
                    criteriaItem c = new criteriaItem(pec.Id, pec.Criteria__r.Criteria_Field__c, pec.Criteria__r.Operator__c,
                                        pec.Criteria__r.Comparison_Data_Type__c, pec.Criteria__r.Comparison_Value__c, 
                                        t.newValue, pec.Result__c); 

                    c.calculateNewResult();  //Call a method to force the calculation of newValue based on the passed data.
                    impactedCriteria.add(c);
                }
            }
        }

        //Now that we know which of the current criteria had fields that were updated, let's see which ones have a different result then they
        //currently have.
        List<Program_Enrollment_Criteria__c> criteriaToUpdate = new List<Program_Enrollment_Criteria__c> ();
        for (criteriaItem i : impactedCriteria) {
            if (i.currentResult <> i.newResult) {
               Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c(Id=i.criteriaId, Result__c = i.newResult);
               criteriaToUpdate.add(newPEC);
            }
        }
        
        if (criteriaToUpdate.size() > 0)
            update criteriaToUpdate;
    }

    public class fieldUpdate {
        public string programEnrollmentId {get; set;}
        public string objectAndFieldName {get; set;}
        public string studentOrHousehold {get; set;}  
        public string schoolYear {get; set;}
        public string questionGroup {get; set;}
        public boolean mostRecent {get; set;}
        public object newValue {get; set;}

        public fieldUpdate(string id, string updatedField, string studentOrHousehold, string schoolYear, string questionGroup, boolean mostRecent, string newValue) {
            this.programEnrollmentId = id;
            this.objectAndFieldName = updatedField;
            this.studentOrHousehold = studentOrHousehold;
            this.schoolYear = schoolYear;
            this.questionGroup = questionGroup;
            this.mostRecent = mostRecent;
            this.newValue = newValue;
        }

        public fieldUpdate() {

        }
    }


    public class criteriaItem {
        public string criteriaId {get; set;}
        public string objectAndFieldName {get; set;}
        public string operator {get; set;}
        public string comparisonDataType {get; set;}
        public string comparisonValueRight {get; set;}
        public object newValue {get; set;}
        public boolean currentResult {get; set;}
        public boolean newResult {get; set;}

        public criteriaItem(string id, string compField, string op, string compDataType, string compValright, object newVal, boolean curResult) {
            this.criteriaId = id;
            this.objectAndFieldName = compField;
            this.operator = op;
            this.comparisonDataType = compDataType;
            this.comparisonValueRight = compValright;
            this.newValue = newVal;
            this.currentResult = curResult;
        }
        
        public criteriaItem(){
            
        }

        public void calculateNewResult ()
        {
            this.newResult = false;
            
            if(this.comparisonDataType == 'number')
            {
            
                Decimal leftside =(decimal) this.newValue;
                Decimal rightside = decimal.valueOf(this.comparisonValueRight);
    			
                if (this.operator == '='){
                    if (leftside == rightside)
                        this.newResult = true;
                } else if (this.operator == '<'){
                    if (leftside < rightside)
                        this.newResult = true; 
                } else if (this.operator == '>'){
                    if (leftside > rightside)
                        this.newResult = true; 
                } else if (this.operator == '!='){
                    if (leftside != rightside)
                        this.newResult = true; 
                } else if (this.operator == '<='){
                    if (leftside <= rightside)
                        this.newResult = true;
                } else if (this.operator == '>='){
                    if (leftside >= rightside)
                        this.newResult = true;    
                }
                
            } else if (this.comparisonDataType == 'Date'){
                
                Date leftside = (Date) this.newValue;
                Date rightside = Date.parse(this.comparisonValueRight);
                
                if (this.operator == '='){
                    if (leftside == rightside)
                        this.newResult = true;
                } else if (this.operator == '<'){
                    if (leftside < rightside)
                        this.newResult = true; 
                } else if (this.operator == '>'){
                    if (leftside > rightside)
                        this.newResult = true; 
                } else if (this.operator == '!='){
                    if (leftside != rightside)
                        this.newResult = true; 
                } else if (this.operator == '<='){
                    if (leftside <= rightside)
                        this.newResult = true;
                } else if (this.operator == '>='){
                    if (leftside >= rightside)
                        this.newResult = true;    
                }
            } else {
                string newVal = (string) this.newValue;
                if(!String.isblank(newVal) && (this.operator == 'CONTAINS' || this.operator == 'DOES NOT CONTAIN')){
                    newVal = newVal.toLowerCase();
                    this.comparisonValueRight = this.comparisonValueRight.toLowerCase();
                    if (this.operator == 'CONTAINS') {
                        if (newVal.indexOf(comparisonValueRight) > -1) {
                            this.newResult = true;
                        }
                    }
                    if (this.operator == 'DOES NOT CONTAIN') {
                        if (newVal.indexOf(comparisonValueRight) == -1) {
                            this.newResult = true;
                        } 
                    }
                } else {
                    if (this.operator == '=') {
                        if (newVal == this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    } else if (this.operator == '<') {
                        if (newVal < this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    } else if (this.operator == '>') {
                        if (newVal > this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    } else if (this.operator == '!=') {
                        if (newVal != this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    } else if (this.operator == '<=') {
                        if (newVal <= this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    } else if (this.operator == '>=') {
                        if (newVal >= this.comparisonValueRight) {
                            this.newResult = true;
                        }
                    }
                } 
            }
            
        }
    }
    @future 
    public static void 
    PerformAsyncNewStudentSteps( id programEnrollment,  Id processId, id caretakerEnrollmentId)
    {
        //This method is called from Add a student process. Runs as a future method.  Will create the remaining ECAs and all the PE Criteria Records.

        //Retrieve the ECR tree.
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
		NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
        //Retrieve all the ECRs for this process
        List<Enrollment_Component_Relationship__c> allECRs = new list <Enrollment_Component_Relationship__c> ();
        allECRs.addAll(thisProcessData.stageRelationships);
        allECRs.addAll(thisProcessData.formRelationships);
        allECRs.addAll(thisProcessData.sectionRelationships);
        allECRs.addAll(thisProcessData.questionGroupRelationships);
        allECRs.addAll(thisProcessData.questionRelationships);

        //Get the ECs that have already been added to this PE
        Set<Id> ECsAlreadyAddedToPE = new Set<Id> ();
        for (Enrollment_Component_Affiliation__c eca : [select Enrollment_Component__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :programEnrollment])
            ECsAlreadyAddedToPE.add(eca.Enrollment_Component__c);

        //Add all ther remaining ECAs
        list<Enrollment_Component_Affiliation__c> newAffiliations = new list<Enrollment_Component_Affiliation__c>();
        Set<id> allECs = new set <Id>();  // Holds all the Enrollment Components for this Academic Program
        Set<id> allQuestionECs = new set <Id>();  // Holds all the Enrollment Components that are questions so we can use that list later to set initial values.

        //Add all the ECAs that have not already been added.  The ones with assignment criteria should be 'Not Started' the ones
        //with assignment criteria should be 'Not Applicable' for now.  If their assignment criteria is met, it will get switched to not started.
        //We also don't want to create ECAs for Questions, Question Groups, Messages and Text.  The community will retrieve
        //what should appear within a section based on the ECRs instead of the ECAs.
        for (Enrollment_Component_Relationship__c ecr : allECRs) {
            //Determine if it is one of the excluded record types.
            boolean ECANotNeededForThisRecType = false;
            if ( ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.HIDDEN_INPUT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.TEXT_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT )
                    ECANotNeededForThisRecType = true;

            if (!ECsAlreadyAddedToPE.contains(ecr.Child_Enrollment_Component__c) && !ECANotNeededForThisRecType) {
                Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                affiliationRecord.Enrollment_Component__c = ecr.Child_Enrollment_Component__c;
                affiliationRecord.Program_Enrollment__c = programEnrollment;
                affiliationRecord.Order__c = ecr.Order__c;
                affiliationRecord.EC_Record_Type__c = ecr.Child_Enrollment_Component__r.RecordType.Name;

                if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) 
                    affiliationRecord.Status__c = 'Not Started';
                else
                    affiliationRecord.Status__c = 'Not Applicable';

                newAffiliations.add(affiliationRecord);
            }

            //While we are looping over the ECRs, collect all the ECs for this process so we can retrieve all the required criteria.
            allECs.add(ecr.Child_Enrollment_Component__c);

            if (ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT)
                allQuestionECs.add(ecr.Child_Enrollment_Component__c);
        }

        if (newAffiliations.size() > 0)
            insert newAffiliations;

        
        // collect SchoolYears
        Map<String, School_Year__c> schoolYearByExternalId = new Map<String, School_Year__c>();
        // collect QuestionGroups        
        Map<String, Enrollment_Component__c> questionGroupByExternalId = new Map<String, Enrollment_Component__c>();
        // END ...

        // // collect 
        // Map<String, Map<String, List<String>>> criteriaObjectFieldsMapByPEType = new Map<String, Map<String, List<String>>>();
        List<Enrollment_Component_Criteria__c> eccs = new List<Enrollment_Component_Criteria__c>();

        //Now insert all the Program Enrollment Criteria records.
        list <Program_Enrollment_Criteria__c> pecsToInsert = new list <Program_Enrollment_Criteria__c> ();
        Set<string> pecAlreadyIncluded = new Set<string> (); //The combination of criteriaid, questiongroup, school year and student or household.
        for (Enrollment_Component_Criteria__c ecc : [
            SELECT  Criteria__c, Criteria__r.Criteria_Field__c, Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c   
            FROM    Enrollment_Component_Criteria__c 
            WHERE   Enrollment_Component__c in :allECs]) 
        {
            eccs.add(ecc);
            if (!pecAlreadyIncluded.contains(ecc.Criteria__c + ecc.Student_or_Household__c + ecc.Question_Group__c + ecc.School_Year__c)) {
                // collect schoolYearExtId && questionGroupExtId
                if (String.isNotEmpty(ecc.School_Year__c))
                    schoolYearByExternalId.put(ecc.School_Year__c,null);
                if (String.isNotEmpty(ecc.Question_Group__c))    
                    questionGroupByExternalId.put(ecc.Question_Group__c,null);
                // collect schoolYearExtId && questionGroupExtId END...

                pecAlreadyIncluded.add(ecc.Criteria__c + ecc.Student_or_Household__c + ecc.Question_Group__c + ecc.School_Year__c);
                Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c();
                newPEC.Program_Enrollment__c = programEnrollment;
                newPEC.Criteria__c = ecc.Criteria__c;
                newPEC.Student_or_Household__c = ecc.Student_or_Household__c;
                newPEC.Most_Recent__c = ecc.Most_Recent__c;
                newPEC.Question_Group__c = ecc.Question_Group__c;
                newPEC.School_Year__c = ecc.School_Year__c;
                pecsToInsert.add(newPEC);
            }

            // MM 12/8/2020 | capturing all criteriaFields START...
            // String[] fieldParts = ecc.Criteria__r.Criteria_Field__c.split('.', 2); 
            // Map<String, List<String>> tmpCriteriaObjectFieldsMap = criteriaObjectFieldsMapByPEType.get(ecc.Student_or_Household__c);
            // if (tmpCriteriaObjectFieldsMap==null) {
            //     tmpCriteriaObjectFieldsMap = new Map<String, List<String>>();
            //     criteriaObjectFieldsMapByPEType.put(ecc.Student_or_Household__c, tmpCriteriaObjectFieldsMap);
            // }
            
            // List<String> tmpObjectFields = tmpCriteriaObjectFieldsMap.get(fieldParts[0]);
            // if (tmpObjectFields==null)
            //     tmpObjectFields = new List<String>();
            // tmpObjectFields.add(fieldParts[1]);
            // tmpCriteriaObjectFieldsMap.put(fieldParts[0], tmpObjectFields);
            // MM 12/8/2020 | capturing all criteriaFields END...

        }

        // MM 12/8/2020 | capturing all criteriaFields START...
        // System.debug('>>>criteriaObjectFieldsMapByPEType>>>' + JSON.serialize(criteriaObjectFieldsMapByPEType));
        // MM 12/8/2020 | capturing all criteriaFields END...

        // Copying Rec.Id from ExternalId Map
        if (schoolYearByExternalId.size() > 0 ) {
            for (School_Year__c schYear : [ SELECT Id, External_Id__c, Name from School_Year__c where External_Id__c IN : schoolYearByExternalId.keySet()]) {
                schoolYearByExternalId.put(schYear.External_Id__c, schYear);
            }
            for (Program_Enrollment_Criteria__c newPEC : pecsToInsert) {
                School_Year__c tmpSY = schoolYearByExternalId.get(newPEC.School_Year__c);
                if (tmpSY!=null) {
                    newPEC.School_Year__c = tmpSY.Id;
                }
            }
        }
        if (questionGroupByExternalId.size() > 0 ) {
            for (Enrollment_Component__c questionGroupEC : [ SELECT Id, External_Id__c, Name from Enrollment_Component__c where External_Id__c IN : questionGroupByExternalId.keySet()]) {
                questionGroupByExternalId.put(questionGroupEC.External_Id__c, questionGroupEC);
            }

            for (Program_Enrollment_Criteria__c newPEC : pecsToInsert) {
                Enrollment_Component__c tmpEC = questionGroupByExternalId.get(newPEC.Question_Group__c);
                if (tmpEC!=null) {
                    newPEC.Question_Group__c = tmpEC.Id;
                }
            }
        }
        // Copying Rec.Id from ExternalId Map END...

        if (pecsToInsert.size() > 0)
            insert pecsToInsert;

        //Call a method that will set the initial values for PE Criteria based on current data.
        if (eccs.size()>0) 
            PECEvaluation.evaluatePECs(eccs, programEnrollment);

        //Mark the PE as ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollment, Initial_ECA_Creation_Complete__c = true);
        update pe;

        System.enqueueJob(new NES_AddStudentCBLQueueable(programEnrollment));
    }
}