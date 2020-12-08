public class ProgramEnrollmentHandler {
public void updateSchoolNameAndSchoolIDOnStudentContacts(list<hed__Program_Enrollment__c> progEnrollList){
		map<Id, String> studentIdSchoolNameMap = new map<Id, String>();
		map<Id, Id> studentIdSchoolIdMap = new map<Id, Id>();
		set<Id> studentIdSet = new set<Id>();
		list<Contact> studentListUpdt = new list<Contact>();
		
		for(hed__Program_Enrollment__c programEnrollObj : progEnrollList){
			if(!studentIdSchoolNameMap.containsKey(programEnrollObj.hed__Contact__c)){
				studentIdSchoolNameMap.put(programEnrollObj.hed__Contact__c, programEnrollObj.School_Name__c);
                System.debug('studentIdSchoolNameMap------>'+studentIdSchoolNameMap);
			}
			
			if(!studentIdSchoolIdMap.containsKey(programEnrollObj.hed__Contact__c)){
				studentIdSchoolIdMap.put(programEnrollObj.hed__Contact__c, programEnrollObj.School_Account_ID__c);
			}
			
			studentIdSet.add(programEnrollObj.hed__Contact__c);
		}
		
		for(Contact studentObj : [SELECT Id, School_Account_ID__c, School_Name__c FROM Contact WHERE Id IN: studentIdSet AND RecordType.DeveloperName = 'Students']){
			
			studentObj.School_Account_ID__c = studentIdSchoolIdMap.get(studentObj.Id);
			studentObj.School_Name__c = studentIdSchoolNameMap.get(studentObj.Id);
			studentListUpdt.add(studentObj);
		}
		
		if((studentListUpdt != null) && !studentListUpdt.isEmpty()){
			update studentListUpdt;
		}
	}
}