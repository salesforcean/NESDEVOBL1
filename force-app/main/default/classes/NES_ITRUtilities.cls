public class NES_ITRUtilities {
   
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ITRUtilities');
    public static ITRResults createReturningStudentPE(Id studentId, Id previousYrPEId){
        Peak_Response peakResponse = new Peak_Response();
        try{
            NES_ECACompletion.shouldRunCompletion = false;
            NES_Constants.runAssignment = false;
            NES_LTSUtility.runLTSFlag = false;
            NES_ProgramEnrollmentHandler.runCBL = false;
            List<Contact> studentContact = [Select Id, FirstName,AccountId, LastName from contact where Id =: studentId];
            hed__Program_Enrollment__c previousYrPERecord = [Select Id,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c, OwnerId from hed__Program_Enrollment__c where Id=:previousYrPEId];
            List<Account> NextYearAcademicProgram  = [Select Id,OwnerId,ParentId,Confirmation_End_Date__c,School_Year__c,Registration_Start_Date__c,Registration_End_Date__c from Account where ParentId =:previousYrPERecord.hed__Account__r.ParentId and Id !=:previousYrPERecord.hed__Account__c and Registration_Start_Date__c <= TODAY AND Registration_End_Date__c >= TODAY] ;
            
            // Naveen -- Addded below Code as a part of DEFECT 448995
            // Get the list of Verified and Non Learning Coach CT contacts under the Students PE Account
            //Student Record Type Id
            Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();
            List <Contact> ctList = [Select Id, Recordtype.name from Contact where AccountId =: studentContact[0].AccountId and RecordtypeId !=: studentRecordTypeId 
                                     and Unverified__c =: false and V2_Role__c != : 'Learning Coach'];
            List <Id> ctIdList = new List <Id> ();
            for(Contact c: ctList){
                ctIdList.add(c.Id);
            }
            
            List <hed__Program_Enrollment__c> newCareTakerEnrollmentList = new List <hed__Program_Enrollment__c> ();
            
            List <Id> ctPeExistsIdList = new List <Id> ();
            Map <Id, Boolean> ctIdTOPeMap = new Map <Id, Boolean> ();
            
            if(NextYearAcademicProgram.size()>0){
                
                hed__Program_Enrollment__c newCareTakerEnrollment = new hed__Program_Enrollment__c();
                
                //List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :previousYrPERecord.Household_Program_Enrollment__r.hed__Contact__c AND hed__Account__c = :NextYearAcademicProgram[0].Id];
                List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c In : ctIdList  AND hed__Account__c = :NextYearAcademicProgram[0].Id];
                
                for(hed__Program_Enrollment__c pe: caretakerEnrollment){
                    ctPeExistsIdList.add(pe.hed__Contact__c);                    
                }
                
                for(Id ctId: ctIdList){
                    if(!ctPeExistsIdList.contains(ctId)){
                        newCareTakerEnrollment = new hed__Program_Enrollment__c();
                        Id caretakerEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
                        newCareTakerEnrollment.hed__Contact__c = ctId;
                        newCareTakerEnrollment.RecordTypeId = caretakerEnrollmentTypeId;
                        newCareTakerEnrollment.OwnerId = NextYearAcademicProgram[0].OwnerId;
                        newCareTakerEnrollment.Enrollment_Type__c = '';
                        if (NextYearAcademicProgram != null) {
                            newCareTakerEnrollment.hed__Account__c = NextYearAcademicProgram[0].Id;
                        }
                        newCareTakerEnrollmentList.add(newCareTakerEnrollment);                        
                    }
                }
                Id caretakerEnrollmentId;
                    
                if(newCareTakerEnrollmentList != null && newCareTakerEnrollmentList.size() >0){
                    Insert newCareTakerEnrollmentList;
                    caretakerEnrollmentId = newCareTakerEnrollmentList[0].Id;
                }
                else{
                    newCareTakerEnrollment = caretakerEnrollment[0];
                    caretakerEnrollmentId = caretakerEnrollment[0].Id;
                }
                
                //Program Enrollment for student
                hed__Program_Enrollment__c newStudentEnrollment = new hed__Program_Enrollment__c();
                Id studentEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                newStudentEnrollment.hed__Contact__c = studentId;
                newStudentEnrollment.RecordTypeId = studentEnrollmentTypeId;
                newStudentEnrollment.Household_Program_Enrollment__c = caretakerEnrollmentId;
                newStudentEnrollment.hed__Account__c = NextYearAcademicProgram[0].Id;
                newStudentEnrollment.Start_Year__c = NextYearAcademicProgram[0].School_Year__c;
                newStudentEnrollment.OwnerId = NextYearAcademicProgram[0].OwnerId;
                newStudentEnrollment.Enrollment_Type__c = 'Returning Student';
                newStudentEnrollment.Program_Enrollment_Previous_Yr__c = previousYrPEId;               
                newStudentEnrollment.Has_Open_Opportunity__c = true;
                insert newStudentEnrollment;
                
                //Insert opportunity
                Opportunity oppToInsert = new Opportunity(
                    Name = studentContact[0].FirstName + ' ' + studentContact[0].LastName + ' Opportunity',
                    OwnerId = NextYearAcademicProgram[0].OwnerId,
                    Caretaker_Id__c = previousYrPERecord.Household_Program_Enrollment__r.hed__Contact__c,
                    Student_Id__c = studentId,
                    AccountId = studentContact[0].AccountId,
                    Program_Enrollment__c = newStudentEnrollment.Id,
                    StageName = 'Open',
                    CloseDate = NextYearAcademicProgram[0].Confirmation_End_Date__c == null ? Date.today() : NextYearAcademicProgram[0].Confirmation_End_Date__c.date()
                );
                insert oppToInsert;
                
                
                String peGradeLevel = previousYrPERecord?.Program_Grade_Level__r?.Grade_Level__r?.Name;
                String nextGrade ='';
                if(peGradeLevel != null){
                   if(peGradeLevel == Label.NES_KG_Grade)
                       nextGrade =Label.NES_First_Grade;
                    else if(peGradeLevel == Label.NES_Twelth_Grade)
                        nextGrade = Label.NES_Twelth_Grade;
                    else
                        nextGrade = String.ValueOf(integer.valueOf(peGradeLevel) + 1); 
                }
                else{
                   Annual_Student_Information__c previousYrASI = [Select Id, School_year__c,Program_Enrollment__c, Final_Grade_Level__c from Annual_Student_Information__c where School_Year__c =:previousYrPERecord.start_year__c and Program_Enrollment__c =: previousYrPERecord.Id];
                   if(previousYrASI.Final_Grade_Level__c == Label.NES_KG_Grade)
                       nextGrade = Label.NES_First_Grade;
                    else if(previousYrASI.Final_Grade_Level__c == Label.NES_Twelth_Grade)
                        nextGrade = Label.NES_Twelth_Grade;
                    else
                        nextGrade = String.ValueOf(integer.valueOf(previousYrASI.Final_Grade_Level__c) + 1); 
                }
                
                
                //Insert ASI record
                Annual_Student_Information__c asiRecord = new Annual_Student_Information__c();                
                asiRecord.Program_Enrollment__c=newStudentEnrollment.id;
                asiRecord.School_Year__c=NextYearAcademicProgram[0].School_Year__c;
                asiRecord.Grade_Level_Requested__c=nextGrade;
                insert asiRecord;
                
                
                //get process Id
                List<Enrollment_Component__c> processComponent = [
                    SELECT Id, Assignment_Logic__c
                    FROM Enrollment_Component__c
                    WHERE Process_Academic_Program__c = :NextYearAcademicProgram
                    AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                    LIMIT 1
                ];
                
                
                
                //Retrieve the ECR tree.
                NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
                NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processComponent[0].Id);
                List<Enrollment_Component_Affiliation__c> newAffiliations = new List<Enrollment_Component_Affiliation__c>();
                
                //Create Process ECA          
                Enrollment_Component_Affiliation__c processECA = new Enrollment_Component_Affiliation__c();
                processECA.Enrollment_Component__c = processComponent[0].Id;
                processECA.Program_Enrollment__c = newStudentEnrollment.id;
                processECA.Status__c = 'In Progress';
                processECA.EC_Record_Type__c = NES_DashboardUtilities.PROCESS_RT;   
                newAffiliations.add(processECA);  
                
                //Add Stage ECA records
                for (Enrollment_Component_Relationship__c relationship : thisProcessData.stageRelationships) {  
                     if(relationship.Child_Enrollment_Component__r.Needed_for_ITR__c == true) {
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                        affiliationRecord.Program_Enrollment__c = newStudentEnrollment.id;   
                        affiliationRecord.Status__c = 'In Progress';                  
                        affiliationRecord.Order__c = relationship.Order__c;
                        affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                        newAffiliations.add(affiliationRecord);                   
                    }                    
                }
                
                //Add form ECA records
                for (Enrollment_Component_Relationship__c relationship : thisProcessData.formRelationships) { 
                    if(relationship.Child_Enrollment_Component__r.Needed_for_ITR__c == true &&  String.isBlank(relationship.Child_Enrollment_Component__r.Assignment_Logic__c))  {
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = relationship.Child_Enrollment_Component__c;
                        affiliationRecord.Program_Enrollment__c = newStudentEnrollment.id;                                         
                        affiliationRecord.Status__c = 'Not Started';
                        affiliationRecord.Order__c = relationship.Order__c;
                        affiliationRecord.EC_Record_Type__c = relationship.Child_Enrollment_Component__r.RecordType.Name;   
                        newAffiliations.add(affiliationRecord);
                        
                    } 
                    
                }
                
                
                insert newAffiliations;
                hed__Program_Enrollment__c previousPERec = new hed__Program_Enrollment__c(Id = previousYrPEId, Program_Enrollment_NY__c =newStudentEnrollment.id);
                update previousPERec;
                String gradelevel = NES_DashboardHelper.getGradeLevel(nextGrade);
                EvaluationUtils.PerformAsyncNewStudentSteps(newStudentEnrollment.id,processComponent[0].Id,caretakerEnrollmentId, 'Returning Student' ); 
                ITRResults result = new ITRResults(newStudentEnrollment.id , processComponent[0].Id, gradelevel);
                return result;
            }
        }catch(Exception e){
            peakResponse.success = false;
            peakResponse.messages.add('Could not create ITR process');
            system.debug('exception*************'+e.getMessage());
            logger.logException('There is some issue with the ITR creation'+previousYrPEId, e);
            logger.saveLogs();
            return null;
        }
        
        
        
        return null;
        
    }
    
    public class ITRResults{
        @AuraEnabled public Id programEnrollmentId{get;set;}
        @AuraEnabled public Id processId{get;set;}
        @AuraEnabled public String gradeLevel{get;set;}
        public ITRResults(Id programEnrollmentId, Id processId, String gradeLevel){
            this.programEnrollmentId = programEnrollmentId;
            this.processId = processId;
            this.gradeLevel = gradeLevel;
        }
    }
    
  
    
   
}