/**

@class:         EvaluationUtils           
@description:   Part of rewrite of the ECA assignment and completion logic, Created to support the new method for ECA Evaluation and Completion
@author:        Mark Membrino
@createdDate:   7/27/2020
*/

public class EvaluationUtils  {
    private static Peak_ApexLog logger = new Peak_ApexLog('EvaluationUtils');
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
        //Added set to exclude the duplicate error
        Set<Id> PECIDs = new Set<Id>();
        for (criteriaItem i : impactedCriteria) {
            if(!PECIDs.Contains(i.criteriaId))
                if (i.currentResult <> i.newResult) {
                    Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c(Id=i.criteriaId, Result__c = i.newResult);
                    criteriaToUpdate.add(newPEC);
                    PECIDs.add(i.criteriaId);
                }
        }
        
        if (criteriaToUpdate != null && criteriaToUpdate.size() > 0  )
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
                
                // added by Maddileti for the defect 354588
                String newVal = '';
                // newVal = (string) this.newValue;
                if (this.comparisonDataType != 'Boolean'){
                    newVal = String.valueOf(this.newValue);
                } else{
                    newVal = (string) this.newValue;
                } 
                // End by Maddileti for the defect 354588
                
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
        
        PerformAsyncNewStudentSteps( id programEnrollment,  Id processId, id caretakerEnrollmentId, String EnrollmentType)
        
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
        List<Enrollment_Component_Affiliation__c> existEcas=new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : [select id,Status__c,Order__c,Enrollment_Component__c,Enrollment_Component__r.Assignment_Logic__c,Enrollment_Component__r.RecordType.Name,Enrollment_Component__r.Component_Type__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :programEnrollment]){
            ECsAlreadyAddedToPE.add(eca.Enrollment_Component__c);
            existEcas.add(eca);
        }
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
            
            //Started the loop by Jagadish Babu for ITR
            if(EnrollmentType == 'Returning Student' ){
                if (!ECsAlreadyAddedToPE.contains(ecr.Child_Enrollment_Component__c) && !ECANotNeededForThisRecType){ // && ecr.Child_Enrollment_Component__r.RecordType.Name != 'Stage') {
                    if(ecr.Child_Enrollment_Component__r.Needed_For_ITR__c == true){
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = ecr.Child_Enrollment_Component__c;
                        affiliationRecord.Program_Enrollment__c = programEnrollment;
                        affiliationRecord.Order__c = ecr.Order__c;
                        affiliationRecord.EC_Record_Type__c = ecr.Child_Enrollment_Component__r.RecordType.Name;
                        if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) {
                            affiliationRecord.Status__c = 'Not Started';                           
                        }                            
                        else{
                            affiliationRecord.Status__c = 'Not Applicable';                           
                        } 
                        newAffiliations.add(affiliationRecord);
                        system.debug('Affiliations*********'+affiliationRecord);
                    }  
                }
                
                
            }else{
                
                if (!ECsAlreadyAddedToPE.contains(ecr.Child_Enrollment_Component__c) && !ECANotNeededForThisRecType) {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = ecr.Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = programEnrollment;
                    affiliationRecord.Order__c = ecr.Order__c;
                    affiliationRecord.EC_Record_Type__c = ecr.Child_Enrollment_Component__r.RecordType.Name;
                    //Sravani: Added for Reinstatement
                    if(ecr.Child_Enrollment_Component__r.RecordType.Name == 'Stage' && ecr.Child_Enrollment_Component__r.Name == 'Eligibility' && (EnrollmentType == 'InitReActivation' || EnrollmentType == 'InitReEnrollment' || EnrollmentType == 'SYReEnroll'))
                        affiliationRecord.Status__c = 'Complete';
                    //End code                  
                    else if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) 
                    {
                        if(EnrollmentType == 'SYReEnroll' && ecr.Child_Enrollment_Component__r.Needed_for_Re_enrollment__c != true)
                            affiliationRecord.Status__c = 'Not Applicable';
                        else
                            affiliationRecord.Status__c = 'Not Started';
                    }   
                    else
                        affiliationRecord.Status__c = 'Not Applicable';
                    
                    newAffiliations.add(affiliationRecord);
                }
                
            }//Ended loop Jagadish Babu
            
            //While we are looping over the ECRs, collect all the ECs for this process so we can retrieve all the required criteria.
            allECs.add(ecr.Child_Enrollment_Component__c);
            
            
            if (ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT)
                allQuestionECs.add(ecr.Child_Enrollment_Component__c);
        }
        //Details: Code fix for UNABLE_TO_LOCK_ROW issue faced by Performance Team during performance testing
        //by <Krishna Peddanagammol> On <2021-10-12> 
        integer i=0;
        do{
            try
            {
                i++;
                if (newAffiliations.size() > 0){
                    upsert newAffiliations;
                    break;//Breaking the loop as the DML executed and no exceptions
                }
            }
            catch(DMLException e) {
                //if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) {
                logger.logException('Retrying a timed out insert', e);
                logger.saveLogs();         
                //}
            }
        }while(i<5);
        
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
        // added by maddileti
        Set<String> ExistingPECs  = new Set<String> (); //The combination of criteriaid, questiongroup, school year and student or house
        
        
        for (Program_Enrollment_Criteria__c pec : [
            SELECT  Criteria__c, Criteria__r.Criteria_Field__c, Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c   
            FROM    Program_Enrollment_Criteria__c 
            WHERE   Program_Enrollment__c =: programEnrollment ]) 
        {
            ExistingPECs .add(pec.Criteria__c + pec.Student_or_Household__c + pec.Question_Group__c + pec.School_Year__c);
        }
        // End by Maddileti 
        Set<String> pecAlreadyIncluded = new Set<String> (); //The combination of criteriaid, questiongroup, school year and student or house
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
        }
        
        
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
        List<Program_Enrollment_Criteria__c> finalPECS=new List<Program_Enrollment_Criteria__c>(); 
        for(Program_Enrollment_Criteria__c pec : pecsToInsert){
            if(!ExistingPECs.contains(pec.Criteria__c + pec.Student_or_Household__c + pec.Question_Group__c + pec.School_Year__c))
                finalPECS.add(pec);
            
        }
        //if (pecsToInsert.size() > 0)
        //insert pecsToInsert;
        if (finalPECS.size() > 0)
            insert finalPECS;
        //Call a method that will set the initial values for PE Criteria based on current data.
        if (eccs.size()>0) 
            evaluatePECs(eccs, programEnrollment);
        
        //Mark the PE as ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollment, Initial_ECA_Creation_Complete__c = true);
        update pe;
        
        //Added by Jagadish Babu for ITR
        if(EnrollmentType == 'Returning Student'){
            List<hed__Program_Enrollment__c> programEnrollments = [
                SELECT Id, hed__Contact__c, Start_Year__c, hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
                EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c,
                (SELECT Id, Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__c FROM Annual_Student_Information__r)
                FROM hed__Program_Enrollment__c
                WHERE Id = : programEnrollment];
            NES_AnnualStudentInfoBusinessLogic.populateProgramGradeLevel(programEnrollments[0].Annual_Student_Information__r, null);
        }
        else{
            //  if(EnrollmentType != 'InitReActivation' && EnrollmentType != 'InitReEnrollment' && EnrollmentType != 'SYReEnroll')
            System.enqueueJob(new NES_AddStudentCBLQueueable(programEnrollment)); 
        }
        //Ended by Jagadish Babu       
    }
    
    
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
                criteriaObjectFieldsMapByPEType.put(ecc.Student_or_Household__c, tmpCriteriaObjectFieldsMap); // ecc.Student_or_Household__c
            }
            
            Set<String> tmpObjectFields = tmpCriteriaObjectFieldsMap.get(fieldParts[0]);
            if (tmpObjectFields==null)
                tmpObjectFields = new Set<String>();
            tmpObjectFields.add(fieldParts[1]);
            tmpCriteriaObjectFieldsMap.put(fieldParts[0], tmpObjectFields);
        }
        // System.debug('>>>criteriaObjectFieldsMapByPEType>>>' + JSON.serialize(criteriaObjectFieldsMapByPEType));        
        
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
            Id enrollmentId = ( (k.equalsIgnoreCase('Household'))? caretakerEnrollmentId : programEnrollment);
            Id contactId = ( (k.equalsIgnoreCase('Household')) ? caretakerContactId : studentContactId );
            
            //  caretakerMap = getObjectDataList(objectMap, caretakerEnrollmentId, accountId, caretakerContactId);
            criteriaObjectRecordsMapByPEType.put(k, 
                                                 queryRelatedRecords(criteriaObjectFieldsMapByPEType.get(k), enrollmentId, accountId, contactId));
        }
        // System.debug('>>>criteriaObjectRecordsMapByPEType>>>' + JSON.serialize(criteriaObjectRecordsMapByPEType));
        
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
                        // if (rec.get(field)==null)
                        //     continue;
                        EvaluationUtils.fieldUpdate fldUpdate = new EvaluationUtils.fieldUpdate();
                        fldUpdate.programEnrollmentId = programEnrollment;
                        fldUpdate.objectAndFieldName = objName + '.' + field; 
                        fldUpdate.newValue = rec.get(field);
                        try {
                            fldUpdate.schoolYear = ((rec.get('School_Year__c')!=null) ? (String) rec.get('School_Year__c') : null);
                        } catch (Exception ex) {
                            // Ignore this one.
                        }
                        
                        try {
                            fldUpdate.questionGroup = ((rec.get('Question_Group__c')!=null) ? (String) rec.get('Question_Group__c') : null);
                        } catch (Exception ex) {
                            // Ignore this one.
                        }
                        fldUpdates.add(fldUpdate);
                    }
                }
            }
        }
        
        if (fldUpdates.size()>0) {
            // System.debug ('>>>fldUpdates>>> size>>> ' + fldUpdates.size() + '>>>' + fldUpdates);
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
        System.debug('>>>objectFieldsMap>>>DEFAULT>>>' + JSON.serialize(objectFieldsMap));
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
            String syFieldName = 'school_year__c';
            if (objectFieldsMap.get(objectName).contains(syFieldName))
                queryMap.get(objectName).add(syFieldName);
            String questionGroupFieldName = 'question_group__c';
            if (objectFieldsMap.get(objectName).contains(questionGroupFieldName))
                queryMap.get(objectName).add(questionGroupFieldName);                
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
            System.debug('>>>query>>>' + JSON.serialize(query));
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