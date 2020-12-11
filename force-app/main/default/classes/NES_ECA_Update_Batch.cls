/**
* Created by Jagadishbabu on 10/23/20.
* Created for the task #328907. 
* Test Class : NES_ECA_Update_BatchTest
* Description : This class is used for updating ECAs status, This class utilizes NES_ECA_Update metadata.
* Check today's date and query corresponding records from metadata with academic program, grade and EC and update corresponding ECAs with status
*/

global class NES_ECA_Update_Batch  implements DataBase.Batchable<SObject>, Schedulable {
    public Map<String, List<NES_ECA_Update__mdt>> mapAcademicProgramWithGrade;//Holds Academic program|grade level key with list  of NES_ECA_Update__mdt
    public Set<String> enrollmentComponents; //Holds Set of Academic program|grade level keysets
    public static final String PE_STATUS = 'In Progress';   
    public static final String PE_RECORDTYPE = 'Student';  
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        Set<String> academicProgramWithGradeSet = new Set<String>();
        academicProgramWithGradeSet.addAll(mapAcademicProgramWithGrade.keySet());    
        //Query program enrollments with Academic program|grade level keys
        Id StudentrecTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        String queryString = 'SELECT Id,RecordType.Name,hed__Account__c,Status__c,Academic_Program_With_Grade__c FROM hed__Program_Enrollment__c WHERE Status__c =:PE_STATUS AND RecordTypeId= :StudentrecTypeId AND Academic_Program_With_Grade__c IN:academicProgramWithGradeSet';                
        system.debug('queryString************'+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> programEnrollmentIds = new Set<Id>();       
        for(hed__Program_Enrollment__c pe : (List<hed__Program_Enrollment__c>) scope) {            
            programEnrollmentIds.add(pe.Id);
        }
        
        Set<Enrollment_Component_Affiliation__c> ecas = new Set<Enrollment_Component_Affiliation__c> ();  
        for (Enrollment_Component_Affiliation__c affiliation :[SELECT Id, 
                                                               Enrollment_Component__r.RecordType.Name,
                                                               Program_Enrollment__c,Program_Enrollment__r.Academic_Program_With_Grade__c,
                                                               Enrollment_Component__r.Name
                                                               FROM Enrollment_Component_Affiliation__c
                                                               WHERE Program_Enrollment__c in :programEnrollmentIds AND Enrollment_Component__r.Name IN:enrollmentComponents]) 
        {
            if(mapAcademicProgramWithGrade.containsKey(affiliation.Program_Enrollment__r.Academic_Program_With_Grade__c)){
                for(NES_ECA_Update__mdt ecsToUpdate : mapAcademicProgramWithGrade.get(affiliation.Program_Enrollment__r.Academic_Program_With_Grade__c)){                    
                    if(affiliation.Enrollment_Component__r.RecordType.Name == ecsToUpdate.Type__c && affiliation.Enrollment_Component__r.Name == ecsToUpdate.Enrollment_Component__c){
                        Enrollment_Component_Affiliation__c n = new Enrollment_Component_Affiliation__c(id = affiliation.id, Status__c = ecsToUpdate.Status__c );
                        ecas.add(n);          
                    }                        
                }            	
            }            
        }
        if(ecas.size() > 0){
            List<Enrollment_Component_Affiliation__c> ecaListToUpdate = new List<Enrollment_Component_Affiliation__c>();
            ecaListToUpdate.addAll(ecas);
            system.debug('ecaListToUpdate*******'+ecaListToUpdate.size());
            Database.update(ecaListToUpdate, false);
        }       
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
	
	//Constructor which will prepare  mapAcademicProgramWithGrade map
    public NES_ECA_Update_Batch(){
        Date dT = Date.Today();
        Date todayDate;
        if(Test.isRunningTest()){
            NES_ECA_Update__mdt testRec= [Select Id, Date_to_be_Updated_On__c,Grade_level__c, Academic_Program__c, Enrollment_Component__c, Status__c,Type__c from NES_ECA_Update__mdt where Grade_level__c = 'All' limit 1];
            todayDate = testRec.Date_to_be_Updated_On__c;
        }
        else
        	todayDate = date.newinstance(dT.year(), dT.month(), dT.day()); 
        mapAcademicProgramWithGrade =  new Map<String, List<NES_ECA_Update__mdt>>(); 
        enrollmentComponents = new Set<String>();
        for(NES_ECA_Update__mdt  ref: [Select Id, Date_to_be_Updated_On__c,Grade_level__c, Academic_Program__c, Enrollment_Component__c, Status__c,Type__c from NES_ECA_Update__mdt where Date_to_be_Updated_On__c=:todayDate ORDER BY Grade_level__c DESC]){
            if(ref.Grade_level__c == 'All'){
                if(!mapAcademicProgramWithGrade.containsKey(ref.Academic_Program__c+'|'+'1')){
                    mapAcademicProgramWithGrade.put(ref.Academic_Program__c+'|'+'K', new List<NES_ECA_Update__mdt>{ref});                    
                    integer i = 0;
                    do{
                        i++;
                        mapAcademicProgramWithGrade.put(ref.Academic_Program__c+'|'+i, new List<NES_ECA_Update__mdt>{ref});                                            
                    }while(i<12);                     
                }
                else{
                    mapAcademicProgramWithGrade.get(ref.Academic_Program__c+'|'+'K').add(ref);     
                    integer j =0;
                    do{
                        j++;
                    	mapAcademicProgramWithGrade.get(ref.Academic_Program__c+'|'+j).add(ref);     
                    }while(j<12);                     
                }                
            }else{
                if(!mapAcademicProgramWithGrade.containsKey(ref.Academic_Program__c+'|'+ref.Grade_level__c)){
                    mapAcademicProgramWithGrade.put(ref.Academic_Program__c+'|'+ref.Grade_level__c, new List<NES_ECA_Update__mdt>{ref});                    
                }
                else{
                     mapAcademicProgramWithGrade.get(ref.Academic_Program__c+'|'+ref.Grade_level__c).add(ref);
                }
            }
            enrollmentComponents.add(ref.Enrollment_Component__c);    	
        } 
        system.debug('mapAcademicProgramWithGrade*******'+mapAcademicProgramWithGrade);
    }  
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_ECA_Update_Batch(), 200);
    }
    
}