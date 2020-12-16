/**
* Created by Jagadishbabu on 10/23/20.
* Created for the US343498. 
* Test Class : 
* Description : This class is used for updating Program Grade Level On Program Enrollment record as per the Annual Student Information Final Grade Level
* This will be used for Migrated students as Program grade level field in PE not updated from External System
*/
global class NES_ProgramGradeLevelUpdateOnPE  implements DataBase.Batchable<SObject>, Schedulable {
    public Map<String, Id> pglMap;//Key Academic Program with Grade Level Key and PGL Id as value
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id StudentrecTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        String queryString = 'SELECT Id,hed__Contact__r.CA_StartYear__r.Name,Program_Grade_Level__c,hed__Account__c,V2_External_ID__c,RecordType.Name,(Select Id, Final_Grade_Level__c from Annual_Student_Information__r order by Final_Grade_Level__c DESC NULLS LAST limit 1) FROM hed__Program_Enrollment__c WHERE RecordTypeId=:StudentrecTypeId AND Program_Grade_Level__c = null AND hed__Account__c !=null AND hed__Contact__r.CA_StartYear__r.Name<>\'2020-2021\'';
    	return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<hed__Program_Enrollment__c> lstProgramEnrollment = new List<hed__Program_Enrollment__c>();
        for(hed__Program_Enrollment__c peRec : (List<hed__Program_Enrollment__c>) scope){
            if(peRec.Annual_Student_Information__r.size() > 0){
                if(pglMap.containsKey(peRec.hed__Account__c+'|'+peRec.Annual_Student_Information__r[0].Final_Grade_Level__c))
                    lstProgramEnrollment.add(new hed__Program_Enrollment__c(Id=peRec.Id, Program_Grade_Level__c = pglMap.get(peRec.hed__Account__c+'|'+peRec.Annual_Student_Information__r[0].Final_Grade_Level__c))); 
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
    //This constructor is used to prepare the Map of Academic Programs with Grade Level as Key and Program grade level Id as value
    public NES_ProgramGradeLevelUpdateOnPE(){
        pglMap = new Map<String, Id>();
        for(Program_Grade_Level__c PGL : [Select Id, Academic_Program__c,Grade_Level__r.Name from Program_Grade_Level__c]){
            pglMap.put(PGL.Academic_Program__c+'|'+PGL.Grade_Level__r.Name, PGL.Id);
        }
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_ProgramGradeLevelUpdateOnPE(), 200);
    }
}