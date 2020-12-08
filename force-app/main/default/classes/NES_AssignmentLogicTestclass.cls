@isTest(SeeAllData=true)
public class NES_AssignmentLogicTestclass {

    static testMethod void fieldUpdatedOnObject(){
        
        Test.starttest();
        hed__Program_Enrollment__c ProgramEnrollmentTest = [select id , waitlistflag__c from hed__Program_Enrollment__c where name = 'PE-0500'];
        ProgramEnrollmentTest.waitlistflag__c = 'Active';
        update ProgramEnrollmentTest;
        hed__Program_Enrollment__c ProgramEnrollment = [select id , waitlistflag__c from hed__Program_Enrollment__c where name = 'PE-0500'];
        system.debug('hh'+ProgramEnrollment.waitlistflag__c);
          
        boolean value = false;
       
        for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.Name,Enrollment_Component__r.RecordType.Name
																		FROM Enrollment_Component_Affiliation__c
																		WHERE Program_Enrollment__c =: ProgramEnrollmentTest.id and 
                                                                 Enrollment_Component__r.Name LIKE 'Waitlist%']){
                                                                      system.debug('hh'+affiliation.Enrollment_Component__r.Name);
                                                                     if ( affiliation.Enrollment_Component__r.RecordType.Name == 'Stage'){
                                                                         if(affiliation.Enrollment_Component__r.Name=='Waitlist'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                             
                                                                     }else if( affiliation.Enrollment_Component__r.RecordType.Name == 'Form'){

                                                                         if(affiliation.Enrollment_Component__r.Name =='Waitlist Form'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                            
                                                                     }else if( affiliation.Enrollment_Component__r.RecordType.Name == 'Section'){
                                                                         if(affiliation.Enrollment_Component__r.Name =='Waitlist Section'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                     }
                        
                                                                 }
        
          
        Test.stopTest();
        System.assertequals(value,true); 
        System.assertequals(ProgramEnrollment.waitlistflag__c,'Active');
    }
     static testMethod void fieldUpdatedOnMultipleRecords(){
        Test.starttest();
          list<hed__Program_Enrollment__c> ProgramEnrollmentTest = new list<hed__Program_Enrollment__c>();
         set<id> peid = new set<id>();
         for (hed__Program_Enrollment__c pe : [select id , waitlistflag__c from hed__Program_Enrollment__c where waitlistflag__c = '' limit 10 ]){
              pe.waitlistflag__c = 'Active';
              ProgramEnrollmentTest.add(pe);
             peid.add(pe.id);
         }
         system.debug('ProgramEnrollmentTest'+ProgramEnrollmentTest.size());
         update ProgramEnrollmentTest;
         boolean flag = false;
         for( hed__Program_Enrollment__c pe: [select id , waitlistflag__c from hed__Program_Enrollment__c where id in : peid]){
             if (pe.waitlistflag__c == 'Active'){
                flag = true; 
               
             }  else{
                     flag = false;  
                 }
             }        
         
       
        
        boolean value = false;
       
        for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.Name,Enrollment_Component__r.RecordType.Name
																		FROM Enrollment_Component_Affiliation__c
																		WHERE Program_Enrollment__c IN : peid and 
                                                                 Enrollment_Component__r.Name LIKE 'Waitlist%']){
                                                                      system.debug('hh'+affiliation.Enrollment_Component__r.Name);
                                                                     if ( affiliation.Enrollment_Component__r.RecordType.Name == 'Stage'){
                                                                         if(affiliation.Enrollment_Component__r.Name=='Waitlist'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                             
                                                                     }else if( affiliation.Enrollment_Component__r.RecordType.Name == 'Form'){

                                                                         if(affiliation.Enrollment_Component__r.Name =='Waitlist Form'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                            
                                                                     }else if( affiliation.Enrollment_Component__r.RecordType.Name == 'Section'){
                                                                         if(affiliation.Enrollment_Component__r.Name =='Waitlist Section'){
                                                                            value = true;
                                                                         }else{
                                                                             value = false;
                                                                         }
                                                                     }
                        
                                                                 }
        
        
        Test.stopTest();
        System.assertequals(flag, true );  
          System.assertequals(value,true);  
    }
    
    /*static testMethod void addStudent(){
        User careTaker = [SELECT Id FROM User WHERE Username = 'anitha.pagadipala@ness.com.nesspoc1141'];
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
        WHERE RecordType.Name = 'Academic Program' LIMIT 1];

        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = '2019-2020'];
        Enrollment_Component__c ec = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Form' limit 1];

        System.runAs(careTaker) {
            Test.startTest();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Peak_Response response = NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
            System.debug('institutionalAccount.Id'+institutionalAccount.Id);
            System.debug('schoolYears[1].Id'+schoolYears[1].Id);
            List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYears[0].Id);

            
            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal23','Middle11','MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null);//added for US116612 
            newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
            String studentJSON = JSON.serialize(newStudentData);
            System.debug('studentJSON++'+studentJSON);

            Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Question' LIMIT 1];
            List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
            NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
            /*q1.order = 1;
            q1.componentType = 'Student';
            q1.questionGroup = false;
            q1.questionPrompt = 'Indicate the grade in which the student was first enrolled in a public or private school in the state where you currently reside:';
            q1.questionTarget = 'hed__Program_Enrollment__c.Grade_First_Enrolled_State_School__c';
            q1.questionType = 'Picklist';
            q1.required = true;
            q1.schoolYear = schoolYears[0].Id;
            q1.targetField = 'K';
            q1.componentType = 'false';
            q1.questionId = qComponent.Id;
            questionDataList.add(q1);
            String questionJSON = JSON.serialize(questionDataList);*/
            /*q1.order = questionsList[0].order;
            q1.componentType = questionsList[0].componentType;
            q1.questionGroup = questionsList[0].questionGroup;
            q1.questionPrompt = questionsList[0].questionPrompt;
            q1.questionTarget = questionsList[0].questionTarget;
            q1.questionType = questionsList[0].questionType;
            q1.required = questionsList[0].required;
            q1.schoolYear = schoolYears[0].Id;
            q1.targetField = questionsList[0].targetField;
            q1.componentType = 'false';
            q1.questionId = qComponent.Id;
            questionDataList.add(q1);
            String questionJSON = JSON.serialize(questionDataList);

            Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
            Test.stopTest();
        }
    } */

    }