/*
* Created by:  Sumanth B
* Created date: 2020-May-04
* User Story : 130549
* Purpose: Test class for CS_PermissionSetsAccessUtility (which handles the assigning/removing of permission sets to/from an User)
		   

* Change Log: 

*/
@isTest
public class CS_PermissionSetsAccessUtilityTest {

    @TestSetup
    public static void createTestData(){
     

        Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId(); 
        
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
        UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');

        String orgId = UserInfo.getOrganizationId();
        User usr = factoryObj.createNewUser('BatchAdmin123'+orgId+'@pearson.com.org', usrRole.Id, 'bAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','BatchAdmin123'+orgId+'@pearson.com.org');
        insert usr;  
            
        System.runAs(usr) 
        {

            Account HHAcc = factoryObj.createNewAccount('HouseHoldAcc',recordTypeIdHH,null,null,null); // Household
            
            insert HHAcc;
            
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
            Contact CTcon = factoryObj.createNewContact('CTContact',recordTypeIdCT,HHAcc.Id,null); 
            insert CTcon;
       		system.debug('CTCon:--> '+CTCon.id);
            

            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            List<Contact> stdContList = factoryObj.createListOfContacts('StdContact',recordTypeIdSTD,HHAcc.Id,CTcon.id,3);
            insert stdContList;
            system.debug('stdContList:--> '+stdContList);
            
        	PermissionSet CT_PS = [Select id from permissionset Where name ='TNCA_CT'];
            PermissionSet STD_PS = [Select id from permissionset Where name ='TNCA_STD'];
        
        	PermissionSet CT_PS2 = [Select id from permissionset Where name ='ACA_CT'];
        	PermissionSet STD_PS2 = [Select id from permissionset Where name ='ACA_STD'];
            
            List<User> usrList = new List<User>();
            Profile CTProfile = [select id,name from profile where name='Caretaker Community User'];
            User CTUsr = factoryObj.createnewPortalUser('CTUser1@pearson.com', 'CTUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', CTProfile.Id,'LastName','CTUser1@pearson.com',CTcon.id);
        	usrList.add(CTUsr);
            CTcon.Commuity_User__c = CTUsr.id;
            update CTcon;
            
            Profile STDProfile = [select id,name from profile where name='Student Community User'];

            User STDUsr = factoryObj.createnewPortalUser('STDUser1@pearson.com.org', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','STDUser1@pearson.com.org',stdContList.get(0).id);
        	usrList.add(STDUsr);
          //  insert usrList; 
            system.debug('Student User:'+STDUsr);
            
          //  Profile STDProfile = [select id,name from profile where name='Student Community User'];

            User STDUsr2 = factoryObj.createnewPortalUser('STDUser2@pearson.com.org', 'STDUser', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', STDProfile.Id,'LastName','STDUser2@pearson.com.org',stdContList.get(1).id);
        	usrList.add(STDUsr2);
            insert usrList; 
            system.debug('Student User2:'+STDUsr2);
            

            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
           	PermissionSetAssignment psa1 = new PermissionSetAssignment();
            PermissionSetAssignment psa2 = new PermissionSetAssignment();
            psa1.AssigneeId = CTUsr.id;
            psa1.PermissionSetId = STD_PS.id;
            psaList.add(psa1);
            psa2.AssigneeId = CTUsr.id;
            psa2.PermissionSetId = CT_PS.id;
            psaList.add(psa2); 
            insert psaList;
        }
    }

    public static testMethod void PermSetTest(){
         	

         Set<Id> CTpermSetIds = new Set<Id>();
         Set<Id> STDpermSetIds = new Set<Id>();
         Map<Id,Set<id>> CTUserPermSetMap = new Map<Id,Set<Id>>();
         Map<Id,Set<id>> StdUserPermSetMap = new Map<Id,Set<Id>>();
         Map<Id,Set<id>> exceptionUserPermSetMap = new Map<Id,Set<Id>>();
         Map<Id,Set<id>> exceptionUserPermSetMap2Delete = new Map<Id,Set<Id>>();

         User CTUsr = [Select id,name from User where username = 'CTUser1@pearson.com'];
         System.debug('CTUser-->'+ CTUsr);
        

         User StdUsr = [Select id,name from User where username = 'STDUser1@pearson.com.org'];
         System.debug('StdUsr-->'+ StdUsr);
        
         User StdUsr2 = [Select id,name from User where username = 'STDUser2@pearson.com.org'];
         System.debug('StdUsr2-->'+ StdUsr2);
        
         for(PermissionSet ps : [Select id from permissionset Where name = 'TNCA_CT' or name = 'ACA_CT'])
         {
            CTpermSetIds.add(ps.id);
         }
         System.debug('CTpermSetIds-->'+ CTpermSetIds);
        
         for(PermissionSet ps : [Select id from permissionset Where name = 'TNCA_STD' or name = 'ACA_STD'])
         {
            STDpermSetIds.add(ps.id);
         }
         System.debug('STDpermSetIds-->'+ STDpermSetIds);
        
         CTUserPermSetMap.put(CTUsr.id,CTpermSetIds);
         StdUserPermSetMap.put(StdUsr.id,STDpermSetIds);
         exceptionUserPermSetMap.put(null,CTpermSetIds);
         exceptionUserPermSetMap2Delete.put(StdUsr2.id,CTpermSetIds);
         Test.startTest();
			 CS_PermissionSetsAccessUtility.assignPermissionSetToUser(CTUserPermSetMap);
       		 List<PermissionSetAssignment> ctUsrPsa = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: CTUsr.id];
             system.assertNotEquals(null, ctUsrPsa.size());
        
             CS_PermissionSetsAccessUtility.assignPermissionSetToUser(StdUserPermSetMap);
             List<PermissionSetAssignment> stdUsrPsa = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: StdUsr.id];
             system.assertNotEquals(null, stdUsrPsa.size());
        
	       	 CS_PermissionSetsAccessUtility.assignPermissionSetToUser(exceptionUserPermSetMap);
        	 List<PermissionSetAssignment> excepUsrPsa = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: null];
             system.assertEquals(0, excepUsrPsa.size());
        
       		 CS_PermissionSetsAccessUtility.removePermissionSetFromUser(CTUserPermSetMap);
        	 List<PermissionSetAssignment> ctUsrPsaRemove = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: CTUsr.id and PermissionSetId in (Select id from permissionset Where name = 'TNCA_CT' or name = 'ACA_CT')];
             system.assertEquals(0, ctUsrPsaRemove.size(),'There are some CT PermissonSets still associated and not removed from CT User');
        
        	 CS_PermissionSetsAccessUtility.removePermissionSetFromUser(StdUserPermSetMap);
        	 List<PermissionSetAssignment> stdUsrPsaRemove = [Select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId =: StdUsr.id and PermissionSetId in (Select id from permissionset Where name = 'TNCA_STD' or name = 'ACA_STD')];
             system.assertEquals(0, stdUsrPsaRemove.size(),'There are some Student PermissonSets still associated and not removed from Student User');
       		 
        	 CS_PermissionSetsAccessUtility.removePermissionSetFromUser(exceptionUserPermSetMap2Delete);
        
        Test.stopTest();
    }
}