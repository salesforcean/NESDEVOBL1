/*
* Created by:  Sumanth B
* Created date: 2020-Apr-24
* User Story : 130549
* Purpose: Test class for 
            CS_AssignPermissionSetToCT_STDBatchJob,
            CS_AssignPermissionSetToCT_STDHandler & 

            CS_CTSTD_USERS_KM_BatchSchedule 

* Change Log: 
*/

@isTest
private class CS_AssignPermissionSetToCT_STDBatchTest {
  
     static testMethod void associatePermSetTest(){

        Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION).getRecordTypeId();
        Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();
        Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId(); 
        
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
        UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        User STDUsr;
        String orgId = UserInfo.getOrganizationId();
        User usr = factoryObj.createNewUser('BAdmn11'+orgId+'@pearson.com', usrRole.Id, 'bAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','BAdmn11'+orgId+'@pearson.com');
        insert usr;  

        System.debug('Print user Id::'+usr.Id);   
        System.runAs(usr)
        {
            Account HHAcc = factoryObj.createNewAccount('HouseHoldAcc',recordTypeIdHH,null,null,null) ; // Household
            insert HHAcc;

            Account TNCASchool = factoryObj.createNewAccount('TNCA',recordTypeIdEI,null,null,null);   //Educational Instituation
            insert TNCASchool;
            Account ACASchool = factoryObj.createNewAccount('Arizona Connections Academy',recordTypeIdEI,null,null,null);
            insert ACASchool;

            Account TNCAAcademicProgram = factoryObj.createNewAccount('TNCA 2019-2020',recordTypeIdAP,TNCASchool.id,system.today(),null);
            insert TNCAAcademicProgram;
            Account ACAAcademicProgram = factoryObj.createNewAccount('ACA 2019-2020',recordTypeIdAP,ACASchool.id,system.today(),null);
            insert ACAAcademicProgram;

            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
            Contact CTcon = factoryObj.createNewContact('CTContact',recordTypeIdCT,HHAcc.Id,null); 
            insert CTcon;
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            List<Contact> stdContList = factoryObj.createListOfContacts('StdContact',recordTypeIdSTD,HHAcc.Id,CTcon.id,3);
            insert stdContList;
            
            PermissionSet CT_PS = [Select id from permissionset Where name ='TNCA_CT'];
            PermissionSet STD_PS = [Select id from permissionset Where name ='TNCA_STD'];
        
            PermissionSet CT_PS2 = [Select id from permissionset Where name ='ACA_CT'];
            PermissionSet STD_PS2 = [Select id from permissionset Where name ='ACA_STD'];
            
            List<User> usrList = new List<User>();
            Profile CTProfile = [select id,name from profile where name='Caretaker Community User'];
            User CTUsr = factoryObj.createnewPortalUser('CTUser@pearson.com', 'CTUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', CTProfile.Id,'LastName','CTUser@pearson.com',CTcon.id);
            usrList.add(CTUsr);
            
            Profile STDProfile = [select id,name from profile where name='Student Community User'];
            STDUsr = factoryObj.createnewPortalUser('STDUser@pearson.com', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','STDUser@pearson.com',stdContList.get(0).id);
            usrList.add(STDUsr);
            insert usrList; 

            system.debug('Student User:'+STDUsr);

            stdContList.get(0).Caretaker_Id__c = CTCon.id;
            stdContList.get(0).Commuity_User__c = STDUsr.id;
            update stdContList.get(0);
            CTcon.Commuity_User__c = CTUsr.id;
            update CTcon;
             system.debug('CTcon-Commuity User-> : '+CTcon.Commuity_User__c +' Name: '+CTcon.Name);
            
            List<hed__Relationship__c> relList = new List<hed__Relationship__c>();
            hed__Relationship__c rel1 = factoryObj.createNewRelationship('Current', stdContList.get(0).id, CTcon.id, 'Parent');
            relList.add(rel1);
            hed__Relationship__c rel2 = factoryObj.createNewRelationship('Current', stdContList.get(1).id, CTcon.id, 'Parent');
            relList.add(rel2);
            hed__Relationship__c rel3 = factoryObj.createNewRelationship('Current', stdContList.get(2).id, CTcon.id, 'Parent');
            relList.add(rel3);
            insert relList;
            system.debug('RelationList:'+relList);
            
            List<hed__Program_Enrollment__c> peList = new List<hed__Program_Enrollment__c>();
            hed__Program_Enrollment__c pe1 = factoryObj.createNewProgramEnrollment(stdContList.get(0).id, TNCAAcademicProgram.id, 'Complete');
            peList.add(pe1);
            hed__Program_Enrollment__c pe2 = factoryObj.createNewProgramEnrollment(stdContList.get(1).id, TNCAAcademicProgram.id, 'In Progress');
            peList.add(pe2);
            hed__Program_Enrollment__c pe3 = factoryObj.createNewProgramEnrollment(stdContList.get(2).id, ACAAcademicProgram.id, 'Complete');
            peList.add(pe3);
            insert peList;
            system.debug('peList:'+peList);
        }
        
        
       //  User StdUser = [Select id,name,username,ContactId from User where username= 'STDUser@pearson.com'];
         CS_AssignPermissionSetToCT_STDBatchJob ctsch = new CS_AssignPermissionSetToCT_STDBatchJob();
         Test.startTest();
         Database.executeBatch(ctsch);
         Test.stopTest(); 
         system.debug('BatchExecuted');
      
         List<PermissionSetAssignment> stdUsrPsa = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: STDUsr.id];
         system.assertEquals(STDUsr.id, stdUsrPsa.get(0).AssigneeId);
    } 

    static testMethod void associatePermSetScheduleTest(){
            
        Test.startTest();
        String chron = '0 0 20 * * ?';
        CS_CTSTD_USERS_KM_BatchSchedule sch = new CS_CTSTD_USERS_KM_BatchSchedule();
        String jobDetails = system.schedule('Assign PermissionSets To CT_STD Users 2', chron, sch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id =: jobDetails Limit 1];
        System.assertEquals(chron, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}