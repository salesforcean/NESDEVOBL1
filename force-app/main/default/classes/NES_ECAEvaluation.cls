/**
* Created by triciaigoe on 12/30/18.
*/
public without sharing class NES_ECAEvaluation {
    private static Peak_ApexLog logger = new Peak_ApexLog('ECAEvaluation');
    
    public static List<Enrollment_Component_Affiliation__c> evalAssignment(Id studentId, Id caretakerContactId, Id accountId, 
                                                                           Id studentEnrollmentId, Id caretakerEnrollmentId, List<Enrollment_Component_Relationship__c> stageRelationships, 
          List<Enrollment_Component_Relationship__c> formFlagRelationships, 
          List<Enrollment_Component_Relationship__c> sectionDocRelationships, 
          List<Enrollment_Component_Relationship__c> questionGroupRelationships,
          List<Enrollment_Component_Relationship__c> questionRelationships,
          NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData,
           List<Id> impactedEnrollmentComponents, List<Enrollment_Component_Affiliation__c> progEnrollmentECAs) {
                                                                               
     Map<Id, Decimal> componentOrderMap = new Map<Id, Decimal>();
     List<Id> allIds = new List<Id>();
                                                                               
      // First grab all enrollment component children of the current process hierarchy
        /*Set<Id> stageIds = new Set<Id>();

for (Enrollment_Component_Relationship__c temp : stageRelationships) {
stageIds.add(temp.Child_Enrollment_Component__c);
componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
}

Set<Id> formFlagIds = new Set<Id>();

for (Enrollment_Component_Relationship__c temp : formFlagRelationships) {
formFlagIds.add(temp.Child_Enrollment_Component__c);
componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
}

Set<Id> sectionAndDocIds = new Set<Id>();

for (Enrollment_Component_Relationship__c temp : sectionDocRelationships) {
sectionAndDocIds.add(temp.Child_Enrollment_Component__c);
componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
}

Set<Id> questionGroupIds = new Set<Id>();

for (Enrollment_Component_Relationship__c temp : questionGroupRelationships) {
questionGroupIds.add(temp.Child_Enrollment_Component__c);
componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
}

// Combine the question groups and the sections
Set<Id> questionParentIds = new Set<Id>();
questionParentIds.addAll(sectionAndDocIds);
questionParentIds.addAll(questionGroupIds);

Set<Id> questionIds = new Set<Id>();

for (Enrollment_Component_Relationship__c temp : questionRelationships) {
questionIds.add(temp.Child_Enrollment_Component__c);
componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
}

//join them all together to return ALL enrollment components related to one process
List<Id> allIds = new List<Id>();
allIds.addAll(stageIds);
allIds.addAll(formFlagIds);
allIds.addAll(questionParentIds);
allIds.addAll(questionIds); */
                                                                               
                 //Mark Membrino 12/14/2019 This calculations was moved to the NES_EnrollmentCompentBuilder
                   allIds = thisProcessData.allIds;
                   componentOrderMap = thisProcessData.componentOrderMap;
                                                                               
                  System.debug('allIds.size() :: '+allIds.size());
                  System.debug('evalAssignment.allIds=' + JSON.serialize(allIds));
                                                                               
               List<Enrollment_Component_Affiliation__c> affiliationsForReturn = new List<Enrollment_Component_Affiliation__c>();
               Set<Enrollment_Component_Affiliation__c> affiliationsForInsert = new Set<Enrollment_Component_Affiliation__c>();
				//Set<Enrollment_Component_Affiliation__c> affiliationsToUpdate = new Set<Enrollment_Component_Affiliation__c>();
                                                                               
               	 //Add any impacted components to all the components.
                                                                               
                   if (impactedEnrollmentComponents!= null){ //added by anitha
                   allIds.addAll(impactedEnrollmentComponents);
                      }      
                   if (allIds.size() > 0) { 
                                                                                   
              /*Mark Membrino 12/23/2019  Moved this into the data class.
            List<Enrollment_Component__c> componentChildren = [
            SELECT Id, RecordType.Name, Assignment_Logic__c, (  //MM This query is hard to remove because of the impacted components part of the query.
            SELECT Id, Criteria_Type__c, Criteria_Number__c,
            Criteria__r.Comparison_Field__c, Criteria__r.Operator__c,
            Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c
            FROM Enrollment_Component_Criteria__r
            ), (SELECT Id, Group_Logic__c, Group_Number__c FROM Criteria_Groups__r)
            FROM Enrollment_Component__c
            WHERE Id IN:allIds
            ];
            
            Map<Id, Enrollment_Component__c> enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();
            
            for (Enrollment_Component__c enrollmentComponent : componentChildren) {
            System.debug(enrollmentComponent.Id);
            enrollmentComponentMap.put(enrollmentComponent.Id, enrollmentComponent);
            } */
                                                                                   
              //Build this from the data that we store in the Enrollment Compon data class
              NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
                                                                                   
             Map<Id, Enrollment_Component__c> enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();
                                                                                   
             for (id EC : allIds) {
             if ( allECData.enrollmentComponentMap.containsKey(EC) )
          enrollmentComponentMap.put(EC, allECData.enrollmentComponentMap.get(EC) );
                                                                                   }  
                                                                                   
                                                                                   
       List<Id> componentsForAssignment = getMoreComponents(studentEnrollmentId, caretakerEnrollmentId, studentId, caretakerContactId, accountId, 'Assignment', enrollmentComponentMap, true, impactedEnrollmentComponents, progEnrollmentECAs);
                                                                                   
          // Grab all affiliations already created for these program enrollments
          /*List<Enrollment_Component_Affiliation__c> affiliations = [
            SELECT Enrollment_Component__c, Status__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c = :studentEnrollmentId
            ]; */
              List<Id> affiliationCompIds = new List<Id>();
         		if (progEnrollmentECAs <> null) {
               for (Enrollment_Component_Affiliation__c affiliation : progEnrollmentECAs) {
                affiliationCompIds.add(affiliation.Enrollment_Component__c);
                   } 
                 }
                                                                                   
         /* Mark Membrino 12/16/2019 While trying to understand this code I found that the following 3 variables
            are never used below.
            Boolean goThroughStages = false;
            List<Enrollment_Component_Affiliation__c> assignedStages = new List<Enrollment_Component_Affiliation__c>();
            Set<Id> assignedStageIds = new Set<Id>(); */
                                                                                   
          for (Id enrollmentComponentId : componentsForAssignment) {
          System.debug('affiliationCompIds.contains(enrollmentComponentId)::'+affiliationCompIds.contains(enrollmentComponentId));
             if (!affiliationCompIds.contains(enrollmentComponentId)) {
            // Create an affiliation for this enrollment component
   		Enrollment_Component_Affiliation__c newAffiiliation = new Enrollment_Component_Affiliation__c();
         newAffiiliation.Enrollment_Component__c = enrollmentComponentId;
         newAffiiliation.Program_Enrollment__c = studentEnrollmentId;
                                                                                           
      Enrollment_Component__c newComponent = enrollmentComponentMap.get(enrollmentComponentId);
      newAffiiliation.Order__c = componentOrderMap.get(enrollmentComponentId);
                                                                                           
      if(newComponent.RecordType.Name == NES_DashboardUtilities.STAGE_RT && newAffiiliation.Order__c == 1) {
                //goThroughStages = true;
             	//assignedStages.add(newAffiiliation);
                //assignedStageIds.add(newAffiiliation.Enrollment_Component__c);
                 newAffiiliation.Status__c = 'In Progress';                        
                  } else {
                   newAffiiliation.Status__c = 'Not Started';
					 }
                   affiliationsForInsert.add(newAffiiliation);
                   system.debug ('newAffiiliation' + newAffiiliation);
                          }  
                      }
                                                                                   
       // Separate the sections
      // Mark Membrino 12/16/2019 While trying to understand this code I found that both sectionRelationships
       //		and formRelationships are not referenced anywhere else in this method.
      /*   List<Enrollment_Component_Relationship__c> sectionRelationships = new List<Enrollment_Component_Relationship__c>();
            for (Enrollment_Component_Relationship__c sectionDocRelationship : sectionDocRelationships) {
            Enrollment_Component__c tempEnrollmentComponent = enrollmentComponentMap.get(sectionDocRelationship.Child_Enrollment_Component__c);
            
            if (tempEnrollmentComponent != null) {
            if (tempEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.SECTION_RT) {
            sectionRelationships.add(sectionDocRelationship);
            }
            }
            } 
            
            // Separate the forms
            List<Enrollment_Component_Relationship__c> formRelationships = new List<Enrollment_Component_Relationship__c>();
            for (Enrollment_Component_Relationship__c formFlagRelationship : formFlagRelationships) {
            Enrollment_Component__c tempEnrollmentComponent = enrollmentComponentMap.get(formFlagRelationship.Child_Enrollment_Component__c);
            if (tempEnrollmentComponent != null) {
            if (tempEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.FORM_RT) {
            formRelationships.add(formFlagRelationship);
            }
            }
            }           */
                                                                                   
          //Mark Membrino  12/16/2019  This whole massive pile of code in the following if then else is just to add
            //		child components that have no criteria for any parent component we decided to add.
                    if(affiliationsForInsert.size() > 0){
                       for (Enrollment_Component_Affiliation__c newAffiliation : affiliationsForInsert) {
                                                                                           
                        Enrollment_Component__c newEnrollmentComponent = enrollmentComponentMap.get(newAffiliation.Enrollment_Component__c);
                        if (newEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.STAGE_RT) {
                                                                                               
                          // this creates the flag and form affiliations 
                        Set<Enrollment_Component_Affiliation__c> childrenOfStageAffiliations = NES_ECAEvaluation.createAffiliations(newEnrollmentComponent.Id, formFlagRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                         affiliationsForInsert.addAll(childrenOfStageAffiliations);
                                                                                               
                       for (Enrollment_Component_Affiliation__c childOfStageAffiliations : childrenOfStageAffiliations) {
                                                                                                   
                          // find only forms for analysis
                       Enrollment_Component__c childOfStageEnrollmentComponent = enrollmentComponentMap.get(childOfStageAffiliations.Enrollment_Component__c);
                        if (childOfStageEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.FORM_RT) {
                                                                                                       
                    // this creates the document and section affiliations 
                       Set<Enrollment_Component_Affiliation__c> childrenOfFormAffiliations = NES_ECAEvaluation.createAffiliations(childOfStageEnrollmentComponent.Id, sectionDocRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                        affiliationsForInsert.addAll(childrenOfFormAffiliations);
                                                                                                       
                      // loop through these new affiliations for the children of forms
                        for (Enrollment_Component_Affiliation__c childOfFormAffiliation : childrenOfFormAffiliations) {
                                                                                                           
                             // find only sections for analysis
                            Enrollment_Component__c childOfFormEnrollmentComponent = enrollmentComponentMap.get(childOfFormAffiliation.Enrollment_Component__c);
                            if (childOfFormEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.SECTION_RT) {
                                                                                                               
                            // Create list of all children relationships of sections
                     List<Enrollment_Component_Relationship__c> childrenOfSectionsRelationships = new List<Enrollment_Component_Relationship__c>();
                           childrenOfSectionsRelationships.addAll(questionRelationships);
                            childrenOfSectionsRelationships.addAll(questionGroupRelationships);
                                                                                                               
                               // Create all affiliations of these children and add to set for insert 
                                  Set<Enrollment_Component_Affiliation__c> childrenOfSectionAffiliations = NES_ECAEvaluation.createAffiliations(childOfFormEnrollmentComponent.Id, childrenOfSectionsRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                      affiliationsForInsert.addAll(childrenOfSectionAffiliations);
                                                                                                               
                                     for (Enrollment_Component_Affiliation__c childOfSectionAffiliation : childrenOfSectionAffiliations) {
                                                                                                                   
                                      // Only if this is a question group, analyze its children
                                        Enrollment_Component__c childOfSectionComponent = enrollmentComponentMap.get(childOfSectionAffiliation.Enrollment_Component__c);
                                        if (childOfSectionComponent.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                                                                                                       
                                        // Create affiliations for all the questions associated with this question group
                                         Set<Enrollment_Component_Affiliation__c> childrenOfQuestionGroupAffiliations = NES_ECAEvaluation.createAffiliations(childOfSectionComponent.Id, questionRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                         affiliationsForInsert.addAll(childrenOfQuestionGroupAffiliations);
                                                                 }
                                                              }
                                                           }
                                                      }
                                                                                                       
                                                   }
                                                                                                   
                                               }
                                                                                               
                                           }
                                                                                           
                            // Create affiliations for children sections, documents, question groups and questions
                               else if (newEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.FORM_RT) {
                                                                                               
                                     // this creates the document and section affiliations
                                       Set<Enrollment_Component_Affiliation__c> childrenOfFormAffiliations = NES_ECAEvaluation.createAffiliations(newEnrollmentComponent.Id, sectionDocRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                       affiliationsForInsert.addAll(childrenOfFormAffiliations);
                                                                                               
                                    // loop through these new affiliations for the children of forms
                                       for (Enrollment_Component_Affiliation__c childOfFormAffiliation : childrenOfFormAffiliations) {
                                                                                                   
                                     // find only sections for analysis
                                        Enrollment_Component__c childOfFormEnrollmentComponent = enrollmentComponentMap.get(childOfFormAffiliation.Enrollment_Component__c);
                                        if (childOfFormEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.SECTION_RT) {
                                                                                                       
                                       // Create list of all children relationships of sections
                                       List<Enrollment_Component_Relationship__c> childrenOfSectionsRelationships = new List<Enrollment_Component_Relationship__c>();
                                             childrenOfSectionsRelationships.addAll(questionRelationships);
                                             childrenOfSectionsRelationships.addAll(questionGroupRelationships);
                                                                                                       
                                           // Create all affiliations of these children and add to set for insert
                                             Set<Enrollment_Component_Affiliation__c> childrenOfSectionAffiliations = NES_ECAEvaluation.createAffiliations(childOfFormEnrollmentComponent.Id, childrenOfSectionsRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                            affiliationsForInsert.addAll(childrenOfSectionAffiliations);
                                                                                                       
                                          for (Enrollment_Component_Affiliation__c childOfSectionAffiliation : childrenOfSectionAffiliations) {
                                                                                                           
                                         // Only if this is a question group, analyze its children
                                         Enrollment_Component__c childOfSectionComponent = enrollmentComponentMap.get(childOfSectionAffiliation.Enrollment_Component__c);
                                         if (childOfSectionComponent.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                                                                                               
                                          // Create affiliations for all the questions associated with this question group
                                           Set<Enrollment_Component_Affiliation__c> childrenOfQuestionGroupAffiliations = NES_ECAEvaluation.createAffiliations(childOfSectionComponent.Id, questionRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                           affiliationsForInsert.addAll(childrenOfQuestionGroupAffiliations);
                                                       }
                                                    }
                                                 }
                                            }
                                                                                               
                                       }
                                                                                           
                        // Create question affiliations and question group affiliations - for the question groups, create affiliations for all of their children
                                     else if (newEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.SECTION_RT) {
                                                                                               
                           // Create list of all children relationships of sections
                                            List<Enrollment_Component_Relationship__c> childrenOfSectionsRelationships = new List<Enrollment_Component_Relationship__c>();
                                            childrenOfSectionsRelationships.addAll(questionRelationships);
                                           childrenOfSectionsRelationships.addAll(questionGroupRelationships);
                                                                                               
                                                  // Create all affiliations of these children and add to set for insert
                                           Set<Enrollment_Component_Affiliation__c> childrenOfSectionAffiliations = NES_ECAEvaluation.createAffiliations(newEnrollmentComponent.Id, childrenOfSectionsRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                            System.debug('over here');
                                            System.debug(childrenOfSectionAffiliations);
                                          affiliationsForInsert.addAll(childrenOfSectionAffiliations);
                                                                                               
                                         for (Enrollment_Component_Affiliation__c childOfSectionAffiliation : childrenOfSectionAffiliations) {
                                                                                                   
                                        // Only if this is a question group, analyze its children
                                             Enrollment_Component__c childOfSectionComponent = enrollmentComponentMap.get(childOfSectionAffiliation.Enrollment_Component__c);
                                             if (childOfSectionComponent.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                                                                                       
                                      // Create affiliations for all the questions associated with this question group
                                         Set<Enrollment_Component_Affiliation__c> childrenOfQuestionGroupAffiliations = NES_ECAEvaluation.createAffiliations(childOfSectionComponent.Id, questionRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                              System.debug(childrenOfQuestionGroupAffiliations);
                                              affiliationsForInsert.addAll(childrenOfQuestionGroupAffiliations);
                                                 }
                                             }
                                                                                               
                                         }
                                                                                           
                              // Create affiliations for all child questions of a question group
                                  else if (newEnrollmentComponent.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                                                                               
                               // Create affiliations for all the questions associated with this question group
                                   Set<Enrollment_Component_Affiliation__c> childrenOfQuestionGroupAffiliations = NES_ECAEvaluation.createAffiliations(newEnrollmentComponent.Id, questionRelationships, enrollmentComponentMap, studentEnrollmentId, caretakerEnrollmentId, affiliationCompIds);
                                  affiliationsForInsert.addAll(childrenOfQuestionGroupAffiliations);
                                          }
                                      }
                                        affiliationsForReturn.addAll(affiliationsForInsert);
                                 }                    
                             }
                                         return affiliationsForReturn;        
                        }
    //Run assignment on one program enrollment
    public static void runAssignment(Id programEnrollmentId, List<Id> impactedEnrollmentComponents, hed__Program_Enrollment__c studentEnrollment, List<Enrollment_Component_Affiliation__c> progEnrollmentECAs, Id processId) {
        
        System.debug('In runAssignment');
        
        //Mark Membrino 12/18/2019.  To reduce SOQLs in for loops, passing this now instead.
        // Grab records we need for evaluation and data updates
        //hed__Program_Enrollment__c studentEnrollment = [
        //         SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
        //         FROM hed__Program_Enrollment__c
        //         WHERE Id = :programEnrollmentId
        // ];
        
        // Create map for storing the Enrollment Component Id, assignment logic
        //Mark Membrino 12/21/2019  To eliminate a soql in a for loop, we are now passing this value.
        //Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);
        
        Map<Id, String> assignmentLogicMap = new Map<Id, String>();
        
        //Go get all the EC data for this process id.
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
        
        // Grab all enrollment component relationships for this process
        /* List<Enrollment_Component_Relationship__c> stageRelationships = [
SELECT Child_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Id, Order__c, Parent_Enrollment_Component__c,
Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
FROM Enrollment_Component_Relationship__c
WHERE Parent_Enrollment_Component__c = :processId
AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
]; */
        
        List<Enrollment_Component_Relationship__c> stageRelationships = thisProcessData.stageRelationships;
        
        /*        List<Id> stageIds = new List<Id>();

for (Enrollment_Component_Relationship__c stageRelationship : stageRelationships) {
stageIds.add(stageRelationship.Child_Enrollment_Component__c);
}

List<Enrollment_Component_Relationship__c> formRelationships = [
SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c,
Child_Enrollment_Component__r.Component_Type__c, Parent_Enrollment_Component__c
FROM Enrollment_Component_Relationship__c
WHERE Parent_Enrollment_Component__c IN :stageIds
AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FLAG_RT)
];  */
        
        List<Enrollment_Component_Relationship__c> formRelationships = thisProcessData.formRelationships;
        
        
        /*List<Id> formIds = new List<Id>();
for (Enrollment_Component_Relationship__c relationship : formRelationships) {
formIds.add(relationship.Child_Enrollment_Component__c);
}

List<Enrollment_Component_Relationship__c> sectionRelationships = [
SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
FROM Enrollment_Component_Relationship__c
WHERE Parent_Enrollment_Component__c IN :formIds
AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
];*/
        
        List<Enrollment_Component_Relationship__c> sectionRelationships = thisProcessData.sectionRelationships;
        
        /*
List<Id> sectionIds = new List<Id>();
for (Enrollment_Component_Relationship__c relationship : sectionRelationships) {
sectionIds.add(relationship.Child_Enrollment_Component__c);
}

List<Enrollment_Component_Relationship__c> questionGroupRelationships = [
SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
FROM Enrollment_Component_Relationship__c
WHERE Parent_Enrollment_Component__c IN :sectionIds
AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT
]; */
        
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = thisProcessData.questionGroupRelationships;
        
        /*
List<Id> groupIds = new List<Id>();
for (Enrollment_Component_Relationship__c relationship : questionGroupRelationships) {
groupIds.add(relationship.Child_Enrollment_Component__c);
}

List<Enrollment_Component_Relationship__c> questionRelationships = [
SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
FROM Enrollment_Component_Relationship__c
WHERE (Parent_Enrollment_Component__c IN :groupIds
OR Parent_Enrollment_Component__c IN :sectionIds)
AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.HIDDEN_INPUT
OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
];*/
        
        List<Enrollment_Component_Relationship__c> questionRelationships = thisProcessData.questionRelationships;
        
        
        //Get all the Questions records using the section Id
        List<Enrollment_Component_Affiliation__c> affiliations = evalAssignment(studentEnrollment.hed__Contact__c, 
                                                                                studentEnrollment.Household_Program_Enrollment__r.hed__Contact__c, studentEnrollment.hed__Contact__r.AccountId, 
                                                                                studentEnrollment.Id, studentEnrollment.Household_Program_Enrollment__c, stageRelationships, formRelationships, 
                                                                                sectionRelationships, questionGroupRelationships, questionRelationships, thisProcessData, impactedEnrollmentComponents, progEnrollmentECAs);
        
		
				
		
        if (affiliations.size() > 0) { 
            //Added  condition to exclude ECA insertion for Migrated students who will have external id DEF255843(Jagadish Babu) 
			if(studentEnrollment.Enrollment_Type__c == 'Re-enrolling student'){					
				Map<Id, Enrollment_Component__c> ecMap = allECData.enrollmentComponentMap;
				List<Enrollment_Component_Affiliation__c> lstAffiliations = new List<Enrollment_Component_Affiliation__c>();
				for(Enrollment_Component_Affiliation__c eca : affiliations){
					if(ecMap.get(eca.Enrollment_Component__c).Needed_For_Re_Enrollment__c){
						lstAffiliations.add(eca);
					}				
				}			
				integer i=0;
				do{
					try{
					   i++;
                       if(lstAffiliations.size() > 0)
					  	  insert lstAffiliations;                
					   break;//Breaking the loop as the DML executed and no exceptions
					}
					catch(Exception e){
						//logger.logException('runAssignment migarted students', e); 
                        logger.logException('runAssignment migarted students retry '+i, e); 
						logger.saveLogs();
					}
				}while(i<5);
			   //End:DEF255843 (Jagadish Babu)
			}
           else{
             //Start: Added the below lines to fix Lock errors for BUG217916 (Jagadish Babu) to make sure retry the DMLs for 5 times
            /*try {insert affiliations;                
                } catch (Exception e) { logger.logException('runAssignment', e); logger.saveLogs();   }*/
				integer i=0;
					do{
						try{
						   i++;
						   insert affiliations;                
						   break;//Breaking the loop as the DML executed and no exceptions
						}
						catch(Exception e){
							//logger.logException('runAssignment', e); 
							logger.logException('runAssignment retry '+i, e); 
							logger.saveLogs();
						}
					}while(i<5);
				   //End: BUG217916 (Jagadish Babu)
				}
						
			} 
        }
    
    // Evaluate the ECC
    public static List<Id> getMoreComponents(Id studentEnrollmentId, Id caretakerEnrollmentId, Id studentId, 
                                             Id caretakerContactId, Id AccountId, String criteriaType, 
                                             Map<Id, Enrollment_Component__c> enrollmentComponentMap, Boolean useAffiliations,
                                             List<Id> impactedEnrollmentComponents, List<Enrollment_Component_Affiliation__c> progEnrollmentECAs) { 
                                                 
                                                 // Mark Membrino 12/16/2019 While trying to understand this code I found that enrollmentIds is not used.
                                                 // Grab a list of all related program enrollment Ids
                                                 //List<Id> enrollmentIds = new List<Id>();
                                                 //enrollmentIds.add(studentEnrollmentId);
                                                 //enrollmentIds.add(caretakerEnrollmentId);
                                                 
                                                 // Grab all affiliations already created for these program enrollments 
                                                 Map<Id, String> affiliationStatusMap = new Map<Id, String>();
                                                 if (progEnrollmentECAs <> null) {
                                                     for (Enrollment_Component_Affiliation__c affiliation : progEnrollmentECAs) {
                                                         affiliationStatusMap.put(affiliation.Enrollment_Component__c, affiliation.Status__c);
                                                     }
                                                 }
                                                 
                                                 //MM 12/23/2019  Removed this SOQL in a for loop by passing the needed affiliations from the caller.
                                                 /*if ( (criteriaType == 'Completion' ) || (criteriaType == 'Assignment' && useAffiliations) ) {
List<Enrollment_Component_Affiliation__c> affiliations2 = [
SELECT Enrollment_Component__c, Status__c
FROM Enrollment_Component_Affiliation__c
WHERE Program_Enrollment__c = :studentEnrollmentId
];

for (Enrollment_Component_Affiliation__c affiliation : affiliations2) {
affiliationStatusMap.put(affiliation.Enrollment_Component__c, affiliation.Status__c);
}
} */
                                                 
               list<Id> allCriteriaIds = new list<Id>();
                                                 
          //IF this method is not being asked to look at specific enrollment components that is passed through
            //impactedEnrollmentComponent then use all the components that is passed in the map.
              set<Id>  ECsToQueryFor = new set<Id>();
              if (impactedEnrollmentComponents <> null && impactedEnrollmentComponents.size() > 0)
                                                     for (id i:impactedEnrollmentComponents)
                                                     ECsToQueryFor.add(i);
                                                 else
                                                     ECsToQueryFor = enrollmentComponentMap.keySet();
                                                 
        // Grab all component criteria in the system for components not already assigned
          // Mark Membrino 12/26/2019  Updating to use the data class instead of the soql query that is called in a loop.
                NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
               List<Enrollment_Component_Criteria__c> enrollmentComponentCriteria = new List<Enrollment_Component_Criteria__c>();
            //List<Enrollment_Component_Criteria__c> enrollmentComponentCriteria2 = new List<Enrollment_Component_Criteria__c>();
           if (criteriaType == 'Assignment' && !useAffiliations) {
                                                     /*enrollmentComponentCriteria = [
SELECT Enrollment_Component__c, Student_or_Household__c, Enrollment_Component__r.Completion_Logic__c,
Criteria__c, Enrollment_Component__r.Assignment_Logic__c, Criteria_Number__c
FROM Enrollment_Component_Criteria__c
WHERE Criteria_Type__c = :criteriaType
AND Enrollment_Component__c IN :ECsToQueryFor
];*/
                                                     
                                                     
      hed__Program_Enrollment__c progId = [select Id , hed__Account__c from hed__Program_Enrollment__c where id =:studentEnrollmentId];
      Enrollment_Component__c processComponent = [SELECT Id FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :progId.hed__Account__c LIMIT 1];
     NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processComponent.Id);
                                                     
               for (Enrollment_Component__c ec:allECData.enrollmentComponentMap.values()) {
                  if (ECsToQueryFor.contains(ec.id) ) {
                 for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) {
                       if (ecc.Criteria_Type__c == criteriaType) 
                    enrollmentComponentCriteria.add(ecc);
                      }
                     }
                   }
                 } else if (criteriaType == 'Completion') {
             /* enrollmentComponentCriteria = [
        SELECT Enrollment_Component__c, Student_or_Household__c, Enrollment_Component__r.Completion_Logic__c,
        Criteria__c, Enrollment_Component__r.Assignment_Logic__c, Criteria_Number__c
        FROM Enrollment_Component_Criteria__c
        WHERE Criteria_Type__c = :criteriaType
        AND Enrollment_Component__c IN :ECsToQueryFor
        AND Enrollment_Component__c IN :affiliationStatusMap.keySet()
        ]; */
                                                     
                     for (Enrollment_Component__c ec:allECData.enrollmentComponentMap.values()) {
                     if (ECsToQueryFor.contains(ec.id) && affiliationStatusMap.keySet().contains(ec.id) ) {
                    for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) {
                  if (ecc.Criteria_Type__c == criteriaType)
                       enrollmentComponentCriteria.add(ecc);
                       }
                     }
                 }
                                                     
         } else if(criteriaType == 'Assignment' && useAffiliations) {
                                                     /*enrollmentComponentCriteria = [
            SELECT Enrollment_Component__c, Student_or_Household__c, Enrollment_Component__r.Completion_Logic__c,
            Criteria__c, Enrollment_Component__r.Assignment_Logic__c, Criteria_Number__c
            FROM Enrollment_Component_Criteria__c
            WHERE Criteria_Type__c = :criteriaType
            //AND Enrollment_Component__c IN :enrollmentComponentMap.keySet()
            AND Enrollment_Component__c IN :ECsToQueryFor
            AND Enrollment_Component__c NOT IN : affiliationStatusMap.keySet()
            ];*/
                                                                 
           for (Enrollment_Component__c ec:allECData.enrollmentComponentMap.values()) {
               if (ECsToQueryFor.contains(ec.id) && !affiliationStatusMap.keySet().contains(ec.id) ) {
                   for (Enrollment_Component_Criteria__c ecc : ec.Enrollment_Component_Criteria__r) {
                      if (ecc.Criteria_Type__c == criteriaType)
                            enrollmentComponentCriteria.add(ecc);
                               }
                             }
                           }
                         }
                                                 
             System.debug('***enrollmentComponentCriteria' + enrollmentComponentCriteria);
                //System.debug('***enrollmentComponentCriteria2' + enrollmentComponentCriteria2);
                                                 
           // Grab map of criteria number and Boolean result of evaluation
                Map<String, Boolean> eccMap = new Map<String, Boolean>();
                 Map<Id, Map<String, Boolean>> criteriaResultMap = new Map<Id, Map<String, Boolean>>(); 
                 List<Id> componentsForAssignment = new List<Id>();
                     if (enrollmentComponentCriteria.size() > 0) {
                        // Map of ECC Id to Boolean result
                      eccMap = NES_EvaluateUtil.getCriteriaResultMap(enrollmentComponentCriteria, studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId);
                      System.debug(eccMap);
                                                     
                  // Map of number from ECC to Boolean result
              criteriaResultMap = NES_ECAEvaluation.getBooleansByStringsByIds(eccMap, enrollmentComponentCriteria);
               System.debug(criteriaResultMap);
               Set<Enrollment_Component__c> componentsForEval = new Set<Enrollment_Component__c>();
                   for (Enrollment_Component_Criteria__c enrollmentComponentCriterium : enrollmentComponentCriteria) {
                       Enrollment_Component__c enrollmentComponent = enrollmentComponentMap.get(enrollmentComponentCriterium.Enrollment_Component__c);
                        componentsForEval.add(enrollmentComponent);
                       }
                for (Enrollment_Component__c enrollmentComponent : componentsForEval) {
                 System.debug('enrollmentComponent.Id' + enrollmentComponent.Id);
                 List<Criteria_Group__c> criteriaGroups = enrollmentComponent.Criteria_Groups__r; 
                  Map<String, Boolean> resultMap = criteriaResultMap.get(enrollmentComponent.Id);
                  Boolean result;
                   if (criteriaType == 'Completion') {
               		  result = NES_EvaluateUtil.evaluateCriteriaGroups(criteriaGroups, resultMap, enrollmentComponent.Completion_Logic__c);
                                                             
                    } else if (criteriaType == 'Assignment') {
                     result = NES_EvaluateUtil.evaluateCriteriaGroups(criteriaGroups, resultMap, enrollmentComponent.Assignment_Logic__c);
                                                             
                     }
                     if (result) { 
                     componentsForAssignment.add(enrollmentComponent.Id);
                       }
                    }
                }
                                                 
         system.debug('componentsForAssignment' + componentsForAssignment);
		return componentsForAssignment;
          }
    
    
    //Add all remaining Affiliation records
    @future
    public static void createRemainingAffiliations(Id accountId, Id studentId, Id caretakerId, 
                                                   Id studentEnrollmentId, Id caretakerEnrollmentId, 
                                                   List<id> stageRelationshipsIds,
                                                   Id processId) {
       Set<Enrollment_Component_Affiliation__c> newAffiliations = new Set<Enrollment_Component_Affiliation__c>();
                                                       
      List<Enrollment_Component_Relationship__c> stageRelationships = [
                         SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c,
                         Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
                         FROM Enrollment_Component_Relationship__c
                         WHERE id IN :stageRelationshipsIds
                         ORDER BY Order__c ASC
                   ];
                                                       
        // Start: Map Added by Viswa for US 227192 on 2020/08/26                                               
      Map<id,Enrollment_Component_Relationship__c> MapstageRelationships = new Map<id,Enrollment_Component_Relationship__c>();
           for(Enrollment_Component_Relationship__c ecr : stageRelationships)    
                 {
                  if(ecr.Child_Enrollment_Component__c!=null)
                       {
                        MapstageRelationships.put(ecr.Child_Enrollment_Component__c,ecr);
                       }
                }  
                                                       
        // End: Added by Viswa for US 227192 on 2020/08/26                                                     
                                                       
           NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
           NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
                                                       
          // Map<Id, Enrollment_Component_Affiliation__c> stageAffiliations = new Map<Id, Enrollment_Component_Affiliation__c>();
             Set<Id> stageIds = new Set<Id>();
             List<Id> allStageIds = new List<Id>();
             for (Integer i = 1; i < stageRelationships.size(); i++) {
                if (stageRelationships[i].Child_Enrollment_Component__c <> null)
                   allStageIds.add(stageRelationships[i].Child_Enrollment_Component__c);
                                                           
                if (String.isBlank(stageRelationships[i].Child_Enrollment_Component__r.Assignment_Logic__c)) {                
                    stageIds.add(stageRelationships[i].Child_Enrollment_Component__c);
                     }
             } 
                                                       
          // ALIKM: 12/14/2019 This calculations was moved to the NES_EnrollmentCompentBuilder
           List<Enrollment_Component_Relationship__c> formRelationships = thisProcessData.formRelationships;
                                                       
          Set<Id> formIds = new Set<Id>();
          List<Id> allFormIds = new List<Id>();
           for (Enrollment_Component_Relationship__c relationship : formRelationships) {
               if (relationship.Child_Enrollment_Component__c <> null)
                   allFormIds.add(relationship.Child_Enrollment_Component__c);
               if (String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) && stageIds.contains(relationship.Parent_Enrollment_Component__c)) {
                   formIds.add(relationship.Child_Enrollment_Component__c);
                   Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                   affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                   affiliationRecord.Program_Enrollment__c = studentEnrollmentId;
                   affiliationRecord.Status__c = 'Not Started';
                   affiliationRecord.Order__c = relationship.Order__c;
                   affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;
                   newAffiliations.add(affiliationRecord);
                   }          
               }
                                                       
                                                       
                                                       
        // ALIKM: 12/14/2019 This calculations was moved to the NES_EnrollmentCompentBuilder
           List<Enrollment_Component_Relationship__c> sectionRelationships = thisProcessData.sectionRelationships;
                                                       
        // grab the household docs to include their status on this program enrollment
            List<Enrollment_Document__c> householdDocs = [
             SELECT Enrollment_Component_Affiliation__r.Status__c, Enrollment_Component_Affiliation__r.Enrollment_Component__c
              FROM Enrollment_Document__c
               WHERE Program_Enrollment__c = :caretakerEnrollmentId
                                                       ];
                                                       
       //Map between the EC and the ECA status for the related doc
            Map<Id, String> docStatusMap = new Map<Id, String>();
            for (Enrollment_Document__c householdDoc : householdDocs) {            
                if (householdDoc.Enrollment_Component_Affiliation__r.Status__c <> null)
                    docStatusMap.put(householdDoc.Enrollment_Component_Affiliation__r.Enrollment_Component__c, householdDoc.Enrollment_Component_Affiliation__r.Status__c);
            }
            System.debug('docstatusMap: ' + docStatusMap);

            List<Id> markedFormIds = new List<Id>();
            Set<Id> sectionIds = new Set<Id>();
            List<Id> allSectionIds = new List<Id>();
            for (Enrollment_Component_Relationship__c relationship : sectionRelationships) {
                   if (relationship != null) {
                       if (relationship.Child_Enrollment_Component__c <> null)
                           allSectionIds.add(relationship.Child_Enrollment_Component__c);
                                                               
                  if (String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) && formIds.contains(relationship.Parent_Enrollment_Component__c)) {
                      sectionIds.add(relationship.Child_Enrollment_Component__c);
               		   Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                       affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                       affiliationRecord.Program_Enrollment__c = studentEnrollmentId;
                       affiliationRecord.Status__c = 'Not Started';
                       affiliationRecord.Order__c = relationship.Order__c;
                       affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;
                       newAffiliations.add(affiliationRecord);
                    }
                                                               
                  if (docStatusMap.keySet().contains(relationship.Child_Enrollment_Component__c)) {
                      markedFormIds.add(relationship.Parent_Enrollment_Component__c);
                      }
                  }
              }
                                                       
          // ALI KM: 12/19/2019 :: unique query, NOT moving to dataclass.
              // Diff: Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT
              List<Enrollment_Component_Relationship__c> questionGroupRelationships = [
                     SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Is_Required__c,
                            Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c,
                            Child_Enrollment_Component__r.RecordType.Name
                            FROM Enrollment_Component_Relationship__c
                            WHERE Parent_Enrollment_Component__c IN :allSectionIds
                            AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT
                             OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
                    ];
                         Set<Id> groupIds = new Set<Id>();
                         List<Id> allGroupIds = new List<Id>();
                         for (Enrollment_Component_Relationship__c relationship : questionGroupRelationships) {
                          if (relationship.Child_Enrollment_Component__c <> null)
                              allGroupIds.add(relationship.Child_Enrollment_Component__c);
                          if (String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) && sectionIds.contains(relationship.Parent_Enrollment_Component__c)) {
                              groupIds.add(relationship.Child_Enrollment_Component__c);
                              Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                              affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                              affiliationRecord.Program_Enrollment__c = studentEnrollmentId;
                              affiliationRecord.Status__c = 'Not Started';
                              affiliationRecord.Order__c = relationship.Order__c;
                              affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;
                              newAffiliations.add(affiliationRecord);
                          }
                      }
                                                       
        // ALI KM: 12/19/2019 :: unique query, NOT moving to dataclass.
           // Diff: allGroupIds, NES_DashboardUtilities.QUESTION_RT, :NES_DashboardUtilities.TEXT_RT, :NES_DashboardUtilities.MESSAGE_RT
            List<Enrollment_Component_Relationship__c> questionRelationships = [
                   SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Is_Required__c,
                          Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c,
                          Child_Enrollment_Component__r.RecordType.Name
                   FROM Enrollment_Component_Relationship__c
                   WHERE (Parent_Enrollment_Component__c IN :allGroupIds
                  OR Parent_Enrollment_Component__c IN :allSectionIds)
                   AND Child_Enrollment_Component__r.RecordType.Name IN (:NES_DashboardUtilities.QUESTION_RT, :NES_DashboardUtilities.TEXT_RT, :NES_DashboardUtilities.MESSAGE_RT)
           ];
                                                       
       for (Enrollment_Component_Relationship__c relationship : questionRelationships) {
            if (String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c) && (groupIds.contains(relationship.Parent_Enrollment_Component__c) || sectionIds.contains(relationship.Parent_Enrollment_Component__c))) {
                Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                affiliationRecord.Program_Enrollment__c = studentEnrollmentId;
                affiliationRecord.Status__c = 'Not Started';
                affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;
                affiliationRecord.Order__c = relationship.Order__c;
                newAffiliations.add(affiliationRecord);
                logger.logInfo('createRemainingAffiliations', 'new affiliation (' + relationship.Child_Enrollment_Component__r.RecordType.Name + '): ' + String.valueOf(affiliationRecord));
          }            
      }
               Boolean updateFlag = false;
                                                       
            List<Enrollment_Component_Affiliation__c> affiliations = [
                        SELECT Enrollment_Component__c, Status__c
                        FROM Enrollment_Component_Affiliation__c
                        WHERE Program_Enrollment__c = :studentEnrollmentId
                   ]; 
                                                       
           List<Enrollment_Component_Affiliation__c> assignmentAffiliations = evalAssignment(studentId, caretakerId, accountId, 
                                                   studentEnrollmentId, caretakerEnrollmentId, stageRelationships, formRelationships, sectionRelationships, 
                                                    questionGroupRelationships, questionRelationships, thisProcessData, null, affiliations);
            newAffiliations.addAll(assignmentAffiliations);
                                                       
                 //create map of all affiliations thus far for use in analysis
          Map<Id, Enrollment_Component_Affiliation__c> studentAffiliationsMap = new Map<Id, Enrollment_Component_Affiliation__c>();
          for (Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
               studentAffiliationsMap.put(newAffiliation.Enrollment_Component__c, newAffiliation);
            }
                                                       
   //create a map of form to children to evaluate completion status
     Map<Id, List<Id>> markedFormChildrenIdsMap = new Map<Id, List<Id>>();
    for (Enrollment_Component_Relationship__c relationship : sectionRelationships) {
     if (markedFormIds.contains(relationship.Parent_Enrollment_Component__c)) {
        List<Id> childIds = new List<Id>();
     if (markedFormChildrenIdsMap.keySet().contains(relationship.Parent_Enrollment_Component__c)) {
           childIds = markedFormChildrenIdsMap.get(relationship.Parent_Enrollment_Component__c);
         }
        childIds.add(relationship.Child_Enrollment_Component__c);
         markedFormChildrenIdsMap.put(relationship.Parent_Enrollment_Component__c, childIds);
         
         Enrollment_Component_Affiliation__c studentAffiliation = studentAffiliationsMap.get(relationship.Child_Enrollment_Component__c);
           if (studentAffiliation <> null) {
               if (docStatusMap.containsKey(relationship.Child_Enrollment_Component__c)) {
                   if (relationship <> null && relationship.Child_Enrollment_Component__c <> null && docStatusMap.get(relationship.Child_Enrollment_Component__c) <> null)
                       studentAffiliation.Status__c = docStatusMap.get(relationship.Child_Enrollment_Component__c);
               }
               newAffiliations.add(studentAffiliation);
             }
         }
      }
      
              System.debug('newAffiliationsbefore:' + JSON.serialize(newAffiliations));
                                                 
          for (Id markedFormId : markedFormChildrenIdsMap.keySet()) {
                                                           
            // check to see if any other children are incomplete
         Boolean incomplete = NES_ECACompletion.grabIncompleteBoolean(markedFormChildrenIdsMap.get(markedFormId), studentAffiliationsMap);
         Enrollment_Component_Affiliation__c formAffiliation = studentAffiliationsMap.get(markedFormId);
               if (incomplete) { 
                   formAffiliation.Status__c = 'In Progress';
              } else
                   {
                   formAffiliation.Status__c = 'Complete';
                   formAffiliation.Date_Completed__c = System.today();
              }
                    newAffiliations.add(formAffiliation);
          }

       system.debug('newAffiliationsafter:' + JSON.serialize(newAffiliations));

                                                       
    // This for loop (Line No: 842 and Line No: 855)commented by viswa for US 227192 on 2020/08/26
      //for(Integer i = 1; i < stageRelationships.size(); i++) {
                                                       
           for(Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
            // if(newAffiliation.Enrollment_Component__c == stageRelationships[i].Child_Enrollment_Component__c) {
               if(MapstageRelationships.Containskey(newAffiliation.Enrollment_Component__c)){
                    newAffiliations.remove(newAffiliation);
                    newAffiliation.Status__c = 'In Progress';
                    newAffiliations.add(newAffiliation);
                    //i=1000;
                    break; 
                }
             }
      // }
                                                       
                                                       
   //  Start -- added the comments for below two lines by Viswa for US 227192 on 2020/08/26                                                     
                                                       
           /*logger.logInfo('createRemainingAffiliations', 'new affiliations: ' + newAffiliations);
             logger.saveLogs();*/
                                                       
   // End --viswa
                                                       
          //Mark Membrino 7/16/2020 Order the insert of the affiliations so:
         //  Questions, Messages and Text goes in first.
        //  Sections and Documents second
        //  Forms and Flags third
      //  Stages last.  This was added to prevent forms from being completed early because their children were not interted first.
     List<Enrollment_Component_Affiliation__c> group1 = new List<Enrollment_Component_Affiliation__c>();
     List<Enrollment_Component_Affiliation__c> group2 = new List<Enrollment_Component_Affiliation__c>();
     List<Enrollment_Component_Affiliation__c> group3 = new List<Enrollment_Component_Affiliation__c>();
     List<Enrollment_Component_Affiliation__c> group4 = new List<Enrollment_Component_Affiliation__c>();
     //The same enrollment component should never go in twice.
     Set<Id> ECsAlreadyAdded = new Set<Id>();
                                                       
      for (Enrollment_Component_Affiliation__c i : newAffiliations) {
          if(!ECsAlreadyAdded.contains(i.Enrollment_Component__c)) {
                ECsAlreadyAdded.add(i.Enrollment_Component__c);

                if (i.EC_Record_Type__c == NES_DashboardUtilities.QUESTION_RT || i.EC_Record_Type__c == NES_DashboardUtilities.TEXT_RT || i.EC_Record_Type__c == NES_DashboardUtilities.MESSAGE_RT)
                       group1.add(i);
                else if (i.EC_Record_Type__c == NES_DashboardUtilities.SECTION_RT || i.EC_Record_Type__c == NES_DashboardUtilities.DOCUMENT_RT)
                       group2.add(i);
                else if (i.EC_Record_Type__c == NES_DashboardUtilities.FORM_RT || i.EC_Record_Type__c == NES_DashboardUtilities.FLAG_RT)
                        group3.add(i);
                else
                        group4.add(i);
            }
     }
                                                       
     List<Enrollment_Component_Affiliation__c> affilsToInsert = new List<Enrollment_Component_Affiliation__c>();
             affilsToInsert.addAll(group1);
             affilsToInsert.addAll(group2);
             affilsToInsert.addAll(group3);
             affilsToInsert.addAll(group4);
              //Commented the below try catch and implemented retry logic to fix issue reported by Perf Team for BUG217916
              /*try{
                    insert affilsToInsert;
                }
                   catch (Exception ex){                                                       
         			System.debug('Exception Thrown:' + ex.getMessage()); logger.logException('execute', ex); logger.saveLogs();
                 }*/                                                       
            integer i=0;
            do{
                try{
                   i++;
                   insert affilsToInsert;                
                   break;//Breaking the loop as the DML executed and no exceptions
                }
                catch(Exception ex){
                    System.debug('Exception Thrown:' + ex.getMessage()); 
                    //logger.logException('execute', ex); 
                    logger.logException('createRemainingAffiliations retry '+i, ex); 
                    logger.saveLogs();
                }
            }while(i<5);
           //End: BUG217916
                                                       
        //Mark the PE as ready to be shown to the caretaker in the community.
            hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = studentEnrollmentId, Initial_ECA_Creation_Complete__c = true);
                     try{
                        update pe; 
                        }         
                   catch (Exception ex){
                   System.debug('Exception Thrown:' + ex.getMessage()); logger.logException('execute', ex); logger.saveLogs();
                        }
                   System.enqueueJob(new NES_AddStudentCBLQueueable(studentEnrollmentId));
                        return;
                                                       
                }
    
    // evaluate list of Ids to see which with assignment logic belong to initial questions
    public static List<Enrollment_Component__c> evaluateEligibilityComponents(Set<Id> componentIds, Id studentId, Id caretakerContactId, Id accountId, Id studentEnrollmentId, Id caretakerEnrollmentId) {
        
        // Grab all related enrollment components, enrollment component criteria and criteria groups
        List<Enrollment_Component__c> enrollmentComponents = [
            SELECT Id, Assignment_Logic__c, (
                SELECT Id, Criteria__c, Student_or_Household__c, Criteria_Number__c, Criteria__r.Criteria_Field__c,
                Criteria__r.Comparison_Field__c
                FROM Enrollment_Component_Criteria__r
            ), (SELECT Id, Group_Number__c, Group_Logic__c FROM Criteria_Groups__r)
            FROM Enrollment_Component__c
            WHERE Id IN :componentIds
        ];
        System.debug('enrollmentComponents>>>>>>>>>>>>>>' + enrollmentComponents);
        // Instantiate all needed variables
        Map<String, Boolean> componentCriteriaResultMap = new Map<String, Boolean>();
        List<Enrollment_Component_Criteria__c> allComponentCriteria = new List<Enrollment_Component_Criteria__c>();
        
        // Loop through the enrollment components to create collection of related component criteria
        for (Enrollment_Component__c enrollmentComponent : enrollmentComponents) {
            allComponentCriteria.addAll(enrollmentComponent.Enrollment_Component_Criteria__r);
        }
        
        System.debug('allComponentCriteria>>>>>>>>>>>>>>>>>>>' + allComponentCriteria);
        
        componentCriteriaResultMap = NES_EvaluateUtil.getCriteriaResultMap(allComponentCriteria, studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId);
        System.debug('componentCriteriaResultMap>>>>>>>>>>>>>' + componentCriteriaResultMap);
        
        // Loop through the enrollment components to create collection maps and all related criteria
        List<Enrollment_Component__c> enrollmentComponentsReturned = new List<Enrollment_Component__c>();
        for (Enrollment_Component__c enrollmentComponent : enrollmentComponents) {
            Map<String, Boolean> criteriaResultMap = getBooleansByNumber(componentCriteriaResultMap, enrollmentComponent.Enrollment_Component_Criteria__r);
            System.debug('criteriaResultMap>>>>>>>' + criteriaResultMap);
            System.debug('enrollmentComponent.Criteria_Groups__r+++' + enrollmentComponent.Criteria_Groups__r);
            Boolean validComponent = NES_EvaluateUtil.evaluateCriteriaGroups(enrollmentComponent.Criteria_Groups__r, criteriaResultMap, enrollmentComponent.Assignment_Logic__c);
            System.debug('validComponent>>>>>>>>>>>' + validComponent);
            if (validComponent) {
                enrollmentComponentsReturned.add(enrollmentComponent);
            }            
        }
        return enrollmentComponentsReturned;
    }
    
    // grab map of map of number to boolean based on the criteria given for several components
    public static Map<Id, Map<String, Boolean>> getBooleansByStringsByIds(Map<String, Boolean> componentIdMap, List<Enrollment_Component_Criteria__c> componentCriteria) {
        
        Map<Id, Map<String, Boolean>> returnMap = new Map<Id, Map<String, Boolean>>();
        for (Enrollment_Component_Criteria__c criterium : componentCriteria) {
            Map<String, Boolean> finalResultMap = new Map<String, Boolean>();
            Boolean result = componentIdMap.get(criterium.Id);
            String criteriumNumber = String.valueOf(criterium.Criteria_Number__c);
            finalResultMap.put(criteriumNumber, result);
            if (returnMap.keySet().contains(criterium.Enrollment_Component__c)) {
                finalResultMap = returnMap.get(criterium.Enrollment_Component__c);
            }
            finalResultMap.put(criteriumNumber, result);
            returnMap.put(criterium.Enrollment_Component__c, finalResultMap);
        }
        
        return returnMap;
    }
    
    // grab map of number to boolean based on enrollment component
    public static Map<String, Boolean> getBooleansByNumber(Map<String, Boolean> componentIdMap, List<Enrollment_Component_Criteria__c> componentCriteria) {
        
        Map<String, Boolean> finalResultMap = new Map<String, Boolean>();
        for (Enrollment_Component_Criteria__c criterium : componentCriteria) {
            Boolean result = componentIdMap.get(criterium.Id);
            String criteriumNumber = String.valueOf(criterium.Criteria_Number__c);
            finalResultMap.put(criteriumNumber, result);
        }
        
        return finalResultMap;
    }
    
    // Stage new affiliation records based on 
    public static Set<Enrollment_Component_Affiliation__c> createAffiliations(Id parentId, 
                                                                              List<Enrollment_Component_Relationship__c> relationships, 
                                                                              Map<Id, Enrollment_Component__c> componentMap, 
                                                                              Id studentEnrollment, Id caretakerEnrollment, 
                                                                              List<Id> affiliationIds) {
    Set<Enrollment_Component_Affiliation__c> affiliations = new Set<Enrollment_Component_Affiliation__c>();
                                                                                  
    for (Enrollment_Component_Relationship__c tempRelationship : relationships) {
         if (tempRelationship <> null && tempRelationship.Parent_Enrollment_Component__c <> null && tempRelationship.Parent_Enrollment_Component__c == parentId) {
            Enrollment_Component__c tempComponent = componentMap.get(tempRelationship.Child_Enrollment_Component__c);
        if (tempComponent!= null) {
           System.debug(tempComponent.Id);
            System.debug(!affiliationIds.contains(tempComponent.Id));
           System.debug(affiliationIds);
       if (String.isBlank(tempComponent.Assignment_Logic__c) && !affiliationIds.contains(tempComponent.Id)) {
           System.debug('creating affiliation: ' + tempRelationship.Child_Enrollment_Component__c);
           Enrollment_Component_Affiliation__c tempAffiliation = new Enrollment_Component_Affiliation__c();
           tempAffiliation.Program_Enrollment__c = studentEnrollment;
           tempAffiliation.Enrollment_Component__c = tempRelationship.Child_Enrollment_Component__c;
           tempAffiliation.Status__c = 'Not Started';
           tempAffiliation.Order__c = tempRelationship.Order__c;
           tempAffiliation.EC_Record_Type__c = tempComponent.RecordType.Name;
           affiliations.add(tempAffiliation);
                 }
              } else system.debug('tempRelationship.Child_Enrollment_Component__c' + tempRelationship.Child_Enrollment_Component__c);                               
           }
        }
                                                                                  
              return affiliations;
     }
    
    // Using list of all enrollment components, returns a set of fields that may cause characteristics to change
    public static Set<String> getCriteriaFieldList(List<Id> componentIds, String criteriaType) {
        
        List<Enrollment_Component_Criteria__c> componentCriteria = [
            SELECT Criteria__c, Criteria__r.Operator__c, Criteria__r.Comparison_Field__c, Criteria__r.Criteria_Field__c
            FROM Enrollment_Component_Criteria__c
            WHERE Enrollment_Component__c IN:componentIds
            AND Criteria_Type__c = :criteriaType
        ];
        
        Set<String> criteriaFields = new Set<String>();
        for (Enrollment_Component_Criteria__c criterium : componentCriteria) {
            criteriaFields.add(criterium.Criteria__r.Comparison_Field__c);
            criteriaFields.add(criterium.Criteria__r.Criteria_Field__c);
        }
        
        return criteriaFields;
    }
    
    
}