/***
* 
@author: Rakesh Ramaswamy (Ness Technologies)
* Created this test class on 07/29/2020 for [US 164369 / Pi-01 (Sprint-07) & Pi-02 (Sprint-01) identified.]
* Test coverage for Batch Apex Job for Learning Coach Community User access to School based Knowledge Articles.
=> CS_LCUserCTPermSetsAccessRelnshipBth_v2.cls
=> CS_LCUserCTPermSetsAccessProgEnrBth_v2.cls
=> CS_LCUserAccessToSchoolCTKBAsHandler.cls
=> CS_CTSTDLC_PE_RLTN_KM_BatchSchedule.cls (Scheduler Apex)
*/
@isTest
public class CS_ProvCTPermSetToLCUsrBthTest_v2 {

    @TestSetup
    public static void createTestData(){
        Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION).getRecordTypeId();
        Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();
        Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId();                              
        CS_TestDataFactory dataFactoryObj = new CS_TestDataFactory();                                               
            
        UserRole r = dataFactoryObj.fetchUserRole('Pearson Community Role');
        User u = dataFactoryObj.createNewUser('teste123@pearson.com.admin', r.Id, 'adminn', 'America/Los_Angeles', 
                                              'en_US', 'en_US', 'UTF-8', 'United States', UserInfo.getProfileId(), 
                                              'admin', 'test123@pearson.com.admin');
        
        insert u;
        System.runAs(u) 
        {  
            list<School_Year__c> schoolYearList = new list<School_Year__c>();
            School_Year__c schoolYearObj = dataFactoryObj.createSchoolYear(false, system.today()+10, system.today()-10, 'ABCDEFG');
            schoolYearList.add(schoolYearObj);
            insert schoolYearList;
            
            list<Account> tempAcctList = new list<Account>();
            list<Account> school1List = dataFactoryObj.createListOfAccounts('Arizona Connections Academy', recordTypeIdEI, null, null, schoolYearList.get(0).Id, 1) ; // School            
            list<Account> school2List = dataFactoryObj.createListOfAccounts('California Connections Academy Central', recordTypeIdEI, null, null, schoolYearList.get(0).Id, 1) ; // School
            school1List.get(0).Name = 'Arizona Connections Academy';
            school2List.get(0).Name = 'California Connections Academy Central';
            tempAcctList.addAll(school1List);  
            tempAcctList.addAll(school2List);
            insert tempAcctList;
            
            list<Account> academicProgTNCAList = dataFactoryObj.createListOfAccounts('TNCA 2019-2020', recordTypeIdAP, school2List.get(0).Id, system.today(), schoolYearList.get(0).Id, 3) ; // Program            
            list<Account> academicProgACAList = dataFactoryObj.createListOfAccounts('ACA 2019-2020', recordTypeIdAP, school1List.get(0).Id, system.today(), schoolYearList.get(0).Id, 2) ; // Program                        
            list<Account> householdAccList = dataFactoryObj.createListOfAccounts('HouseHoldAcc', recordTypeIdHH, null, null, schoolYearList.get(0).Id, 3) ; // Household
            
            list<Account> finalAcctList = new list<Account>();            
            finalAcctList.addAll(academicProgTNCAList);
            finalAcctList.addAll(academicProgACAList);
            finalAcctList.addAll(householdAccList);            
            insert finalAcctList;            
            
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            Id recordTypeIdLC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_LEARNING_COACH).getRecordTypeId();
            
            list<Contact> CTHouseHold1ConList =  dataFactoryObj.createListOfContacts('CTContact', recordTypeIdCT, householdAccList.get(0).Id, null, 2);                                 
            list<Contact> CTHouseHold2ConList =  dataFactoryObj.createListOfContacts('CTContact', recordTypeIdCT, householdAccList.get(1).Id, null, 2);            
            // Learning Coach - Sai Ram at 0 and Joe Maya at 1.
            list<Contact> LCHouseHold1ConList =  dataFactoryObj.createListOfContacts('LCContact0', recordTypeIdLC, householdAccList.get(1).Id, null, 2);            
            // Learning Coach - Bharat Thakur
            list<Contact> LCHouseHold2ConList =  dataFactoryObj.createListOfContacts('LCContact1', recordTypeIdLC, householdAccList.get(2).Id, null, 1);            
            // Student - Rakesh Ramaswamy
            list<Contact> STDHouseHold1conList =  dataFactoryObj.createListOfContacts('StdContact', recordTypeIdSTD, householdAccList.get(0).Id, CTHouseHold1ConList.get(1).Id, 1);                 
            // Student - Shreejit Swain 
            list<Contact> STDHouseHold2con1List =  dataFactoryObj.createListOfContacts('StdContact1', recordTypeIdSTD, householdAccList.get(1).Id, CTHouseHold2ConList.get(0).Id, 1);                 
            // Student - Student 103 Sr.
            list<Contact> STDHouseHold2con2List = dataFactoryObj.createListOfContacts('StdContact2', recordTypeIdSTD, householdAccList.get(1).Id, CTHouseHold1ConList.get(0).Id, 1);            
            // Student - Rocky Ramsey
            list<Contact> STDHouseHold4conList =  dataFactoryObj.createListOfContacts('StdContact3', recordTypeIdSTD, householdAccList.get(2).Id, CTHouseHold2ConList.get(0).Id, 1);            
            list<Contact> finalContactsList = new list<Contact>();
            finalContactsList.addAll(CTHouseHold1ConList);
            finalContactsList.addAll(CTHouseHold2ConList);
            finalContactsList.addAll(LCHouseHold1ConList);
            finalContactsList.addAll(LCHouseHold2ConList);
            finalContactsList.addAll(STDHouseHold1conList);
            finalContactsList.addAll(STDHouseHold2con1List);
            finalContactsList.addAll(STDHouseHold2con2List);
            finalContactsList.addAll(STDHouseHold4conList);                     
            
            insert finalContactsList;            
            
            list<hed__Relationship__c> relationshipsList = new list<hed__Relationship__c>();            
            // Creating instances for all the Former Relationships here.
            hed__Relationship__c formerRelationship1ForACA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_FORMER_STATUS, STDHouseHold1conList.get(0).Id, LCHouseHold1ConList.get(0).Id, CS_Constants.LEARNING_COACH_TYPE);
            hed__Relationship__c formerRelationship2ForACA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_FORMER_STATUS, STDHouseHold2con1List.get(0).Id, LCHouseHold1ConList.get(1).Id, CS_Constants.LEARNING_COACH_TYPE);            
            hed__Relationship__c formerRelationship3ForACA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_FORMER_STATUS, STDHouseHold1conList.get(0).Id, LCHouseHold2ConList.get(0).Id, CS_Constants.LEARNING_COACH_TYPE);
            hed__Relationship__c formerRelationship4ForTNCA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_FORMER_STATUS, STDHouseHold4conList.get(0).Id, LCHouseHold1ConList.get(1).Id, CS_Constants.LEARNING_COACH_TYPE);
            relationshipsList.add(formerRelationship1ForACA);
            relationshipsList.add(formerRelationship2ForACA);
            relationshipsList.add(formerRelationship3ForACA);
            relationshipsList.add(formerRelationship4ForTNCA);
            
            // Creating instances for all the Current Relationships here.
            hed__Relationship__c currentRelationship1ForACA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_CURRENT_STATUS, STDHouseHold2con1List.get(0).Id, LCHouseHold1ConList.get(0).Id, CS_Constants.LEARNING_COACH_TYPE);
            hed__Relationship__c currentRelationship2ForACA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_CURRENT_STATUS, STDHouseHold1conList.get(0).Id, LCHouseHold1ConList.get(1).Id, CS_Constants.LEARNING_COACH_TYPE);         
            hed__Relationship__c currentRelationship3ForTNCA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_CURRENT_STATUS, STDHouseHold2con2List.get(0).Id, LCHouseHold1ConList.get(1).Id, CS_Constants.LEARNING_COACH_TYPE);           
            hed__Relationship__c currentRelationship4ForTNCA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_CURRENT_STATUS, STDHouseHold2con2List.get(0).Id, LCHouseHold2ConList.get(0).Id, CS_Constants.LEARNING_COACH_TYPE);           
            hed__Relationship__c currentRelationship5ForTNCA = dataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_CURRENT_STATUS, STDHouseHold4conList.get(0).Id, LCHouseHold2ConList.get(0).Id, CS_Constants.LEARNING_COACH_TYPE);            
            relationshipsList.add(currentRelationship1ForACA);
            relationshipsList.add(currentRelationship2ForACA);
            relationshipsList.add(currentRelationship3ForTNCA);
            relationshipsList.add(currentRelationship4ForTNCA);
            relationshipsList.add(currentRelationship5ForTNCA);
            
            insert relationshipsList; 
            
            list<hed__Program_Enrollment__c> programEnrollList = new list<hed__Program_Enrollment__c>();
            // Withdrawn Program Enrollments.
            list<hed__Program_Enrollment__c> withdrawnPE1ForSTDHH2ACA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold2con1List.get(0).Id, academicProgACAList.get(0).Id, CS_Constants.PE_WITHDRAWN_STATUS, 1);
            list<hed__Program_Enrollment__c> withdrawnPE1ForSTDHH2TNCA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold2con2List.get(0).Id, academicProgTNCAList.get(0).Id, CS_Constants.PE_WITHDRAWN_STATUS, 1);
            list<hed__Program_Enrollment__c> withdrawnPE1ForSTDHH3ACA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold1conList.get(0).Id, academicProgACAList.get(0).Id, CS_Constants.PE_WITHDRAWN_STATUS, 1);
            // Complete Program Enrollments.
            list<hed__Program_Enrollment__c> completePE1ForSTDHH4TNCA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold4conList.get(0).Id, academicProgTNCAList.get(1).Id, CS_Constants.PE_COMPLETE_STATUS, 1);
            list<hed__Program_Enrollment__c> completePE1ForSTDHH1ACA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold1conList.get(0).Id, academicProgACAList.get(1).Id, CS_Constants.PE_COMPLETE_STATUS, 1);
            list<hed__Program_Enrollment__c> completePE1ForSTDHH2TNCA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold2con2List.get(0).Id, academicProgTNCAList.get(2).Id, CS_Constants.PE_COMPLETE_STATUS, 1);
            list<hed__Program_Enrollment__c> completePE1ForSTDHH3ACA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold2con1List.get(0).Id, academicProgACAList.get(1).Id, CS_Constants.PE_COMPLETE_STATUS, 1);            
            list<hed__Program_Enrollment__c> completePE1ForSTDHH12ACA = dataFactoryObj.createListOfProgramEnrolls(STDHouseHold1conList.get(0).Id, academicProgACAList.get(1).Id, CS_Constants.PE_COMPLETE_STATUS, 1);
            programEnrollList.addAll(withdrawnPE1ForSTDHH2ACA);
            programEnrollList.addAll(withdrawnPE1ForSTDHH2TNCA);
            programEnrollList.addAll(completePE1ForSTDHH4TNCA);
            programEnrollList.addAll(completePE1ForSTDHH1ACA);
            programEnrollList.addAll(completePE1ForSTDHH2TNCA);
            programEnrollList.addAll(completePE1ForSTDHH3ACA);
            programEnrollList.addAll(withdrawnPE1ForSTDHH3ACA);
            programEnrollList.addAll(completePE1ForSTDHH12ACA);
            insert programEnrollList; 
                       
            Profile LCCommunityProfile = [SELECT Id, Name from Profile WHERE Name='Learning Coach Community User'];
            list<User> LCCommunityUsersList = new list<User>();
            User LCUser1 = dataFactoryObj.createnewPortalUser('lcportalUser1@abc.com', 'lcpu1', 'America/Los_Angeles', 'en_US', 'en_US','UTF-8','United States', LCCommunityProfile.Id,'LCU1LastName','LCUser1@pearson.com',LCHouseHold1ConList.get(0).Id);
            User LCUser2 = dataFactoryObj.createnewPortalUser('lcportalUser2@xyz.com', 'lcpu2', 'America/Los_Angeles', 'en_US', 'en_US','UTF-8','United States', LCCommunityProfile.Id,'LCU2LastName','LCUser2@pearson.com',LCHouseHold1ConList.get(1).Id);
            User LCUser3 = dataFactoryObj.createnewPortalUser('lcportalUser3@xba.com', 'lcpu3', 'America/Los_Angeles', 'en_US', 'en_US','UTF-8','United States', LCCommunityProfile.Id,'LCU3LastName','LCUser3@pearson.com',LCHouseHold2ConList.get(0).Id);
            LCCommunityUsersList.add(LCUser1);
            LCCommunityUsersList.add(LCUser2);
            LCCommunityUsersList.add(LCUser3);            
            insert LCCommunityUsersList;
        }
    }
        
    public static testMethod void assocCTPermSetToLCUsersProgEnrollBatchTest(){
             Test.startTest();
             CS_LCUserCTPermSetsAccessProgEnrBth_v2 programEnrollbatchJob = new CS_LCUserCTPermSetsAccessProgEnrBth_v2();
             Database.executeBatch(programEnrollbatchJob, 50);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 1', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered); 
             Test.stopTest();
     }
    
     public static testMethod void associateCTPermSetToLCUsersScenario11Test(){
             Test.startTest();
             set<Id> studRecsIdSet = new set<Id>();
             Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
             for(Contact contactRecObj : [SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdSTD]){
                 studRecsIdSet.add(contactRecObj.Id);
             }
             
             CS_LCUserCTPermSetsAccessRelnshipBth_v2 batchJob = new CS_LCUserCTPermSetsAccessRelnshipBth_v2(studRecsIdSet);
             Database.executeBatch(batchJob, 50);             
             Test.stopTest();
     }
         
     public static testMethod void associateCTPermSetToLCUserScenario10Test(){
             // Update test data added in the Test-Setup above.
            list<Contact> STDHouseHold1conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact1'];
            system.assertNotEquals(STDHouseHold1conList, null);
            system.assertEquals(STDHouseHold1conList.size() > 0, true);
            list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];  
            system.assertNotEquals(STDHouseHold2con2List, null);
            system.assertEquals(STDHouseHold2con2List.size() > 0, true);
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
            system.assertNotEquals(STDHouseHold4conList, null);
            system.assertEquals(STDHouseHold4conList.size() > 0, true);
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];
            system.assertNotEquals(LCHouseHold2ConList, null);
            system.assertEquals(LCHouseHold2ConList.size() > 0, true);             
             list<hed__Relationship__c> relationshipList = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold1conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_FORMER_STATUS];
             system.assertNotEquals(relationshipList, null);
            system.assertEquals(relationshipList.size() > 0, true);            
             relationshipList.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_CURRENT_STATUS;
             update relationshipList;   
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE Name = 'TNCA 2019-20201' AND RecordTypeId = :recordTypeIdAP];
             system.assertNotEquals(academicProgTNCAList, null);
            system.assertEquals(academicProgTNCAList.size() > 0, true);
            list<hed__Program_Enrollment__c> programEnrollList3 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123'];
             system.assertNotEquals(programEnrollList3, null);
            system.assertEquals(programEnrollList3.size() > 0, false);
             update programEnrollList3;
             list<hed__Program_Enrollment__c> programEnrollList2 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold4conList.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123'];
             system.assertNotEquals(programEnrollList2, null);            
             update programEnrollList2;          
             list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND School_Name__c = 'TNCA123' AND Status__c = :CS_Constants.PE_WITHDRAWN_STATUS];
             system.assertNotEquals(programEnrollList1, null);
            system.assertEquals(programEnrollList1.size() > 0, false); 
            update programEnrollList1;
             Test.startTest();
             set<Id> studRecsIdSet = new set<Id>();
             Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
             for(Contact contactRecObj : [SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdSTD]){
                 studRecsIdSet.add(contactRecObj.Id);
             }
             CS_LCUserCTPermSetsAccessRelnshipBth_v2 batchJob = new CS_LCUserCTPermSetsAccessRelnshipBth_v2(studRecsIdSet);
             Database.executeBatch(batchJob, 50);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 1', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered);             
             Test.stopTest();
     }
         
     public static testMethod void associateCTPermSetToLCUserScenario09Test(){
             // Update test data added in the Test-Setup above.
             Test.startTest();
             list<Contact> STDHouseHold2con1List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact11'];
            system.assertNotEquals(STDHouseHold2con1List, null);
            system.assertEquals(STDHouseHold2con1List.size() > 0, true);
             list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];
            system.assertNotEquals(STDHouseHold2con2List, null);
            system.assertEquals(STDHouseHold2con2List.size() > 0, true);
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
             system.assertNotEquals(STDHouseHold4conList, null);
            system.assertEquals(STDHouseHold4conList.size() > 0, true);
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];  
             system.assertNotEquals(LCHouseHold2ConList, null);
            system.assertEquals(LCHouseHold2ConList.size() > 0, true);
             list<hed__Relationship__c> relationshipDeleteList = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS];           
             system.assertNotEquals(relationshipDeleteList, null);
            system.assertEquals(relationshipDeleteList.size() > 0, true);
             delete relationshipDeleteList;
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE Name = 'TNCA 2019-20201' AND RecordTypeId = :recordTypeIdAP];
             system.assertNotEquals(academicProgTNCAList, null);
            system.assertEquals(academicProgTNCAList.size() > 0, true);
             list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND School_Name__c = 'TNCA123' AND Status__c = :CS_Constants.PE_WITHDRAWN_STATUS];
             system.assertNotEquals(programEnrollList1, null);
            system.assertEquals(programEnrollList1.size() > 0, false);
             update programEnrollList1; 
             CS_LCUserCTPermSetsAccessProgEnrBth_v2 programEnrollbatchJob = new CS_LCUserCTPermSetsAccessProgEnrBth_v2();
             Database.executeBatch(programEnrollbatchJob, 200);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 4', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered); 
            Test.stopTest();
     }
         
     public static testMethod void associateCTPermSetToLCUserScenario08Test(){
             // Update test data added in the Test-Setup above.
             Test.startTest();
             list<Contact> STDHouseHold2con1List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact11'];
            system.assertNotEquals(STDHouseHold2con1List, null);
            system.assertEquals(STDHouseHold2con1List.size() > 0, true);
             list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];
             system.assertNotEquals(STDHouseHold2con2List, null);
            system.assertEquals(STDHouseHold2con2List.size() > 0, true);
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
             system.assertNotEquals(STDHouseHold4conList, null);
            system.assertEquals(STDHouseHold4conList.size() > 0, true);
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];
             system.assertNotEquals(LCHouseHold2ConList, null);
            system.assertEquals(LCHouseHold2ConList.size() > 0, true);
            list<hed__Relationship__c> relationshipUpdtList = new list<hed__Relationship__c>();
            for(hed__Relationship__c relationshipRecObj : [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS]){           
                relationshipRecObj.hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
                relationshipUpdtList.add(relationshipRecObj);
            }
            system.assertNotEquals(relationshipUpdtList, null);
            system.assertEquals(relationshipUpdtList.size() > 0, true);
            update relationshipUpdtList;
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE Name = 'TNCA 2019-20201' AND RecordTypeId = :recordTypeIdAP];            
             system.assertNotEquals(academicProgTNCAList, null);
             system.assertEquals(academicProgTNCAList.size() > 0, true);
             list<hed__Program_Enrollment__c> programEnrollList3 = new list<hed__Program_Enrollment__c>();
             for(hed__Program_Enrollment__c programEnrollObj : [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123']){
                 programEnrollObj.Status__c = CS_Constants.PE_WITHDRAWN_STATUS;
                 programEnrollList3.add(programEnrollObj);
             }
            system.assertNotEquals(programEnrollList3, null);
            system.assertEquals(programEnrollList3.size() > 0, false);
             update programEnrollList3;
             list<hed__Program_Enrollment__c> programEnrollList2 = new list<hed__Program_Enrollment__c>();
            for(hed__Program_Enrollment__c programEnrollObj : [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold4conList.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123']){
                programEnrollObj.Status__c = CS_Constants.PE_WITHDRAWN_STATUS;
                programEnrollList2.add(programEnrollObj);
            }
             system.assertNotEquals(programEnrollList2, null);            
            update programEnrollList2; 
             list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND School_Name__c = 'TNCA123' AND Status__c= :CS_Constants.PE_WITHDRAWN_STATUS];
             system.assertNotEquals(programEnrollList1, null);
            system.assertEquals(programEnrollList1.size() > 0, false);
             update programEnrollList1;
            CS_LCUserCTPermSetsAccessProgEnrBth_v2 programEnrollbatchJob = new CS_LCUserCTPermSetsAccessProgEnrBth_v2();
             Database.executeBatch(programEnrollbatchJob, 100);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 5', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered); 
            Test.stopTest();
     }
         
     public static testMethod void associateCTPermSetToLCUserScenario07Test(){
             // Update test data added in the Test-Setup above.
             list<Contact> STDHouseHold2con1List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact11'];
             list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];  
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];
             list<Contact> LCHouseHold1ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact02']; 
             list<hed__Relationship__c> relationshipUpdt1List = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS];
             relationshipUpdt1List.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
             system.assertNotEquals(relationshipUpdt1List, null);
           system.assertEquals(relationshipUpdt1List.size() > 0, true);
            update relationshipUpdt1List;
             list<hed__Relationship__c> relationshipUpdt2List = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_FORMER_STATUS];
             relationshipUpdt2List.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_CURRENT_STATUS;            
             system.assertNotEquals(relationshipUpdt2List, null);
           system.assertEquals(relationshipUpdt2List.size() > 0, true);
            update relationshipUpdt2List;
             list<hed__Relationship__c> relationshipUpdtList = new list<hed__Relationship__c>();
             for(hed__Relationship__c relationTempObj : [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS]){
                 relationTempObj.hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
                 relationshipUpdtList.add(relationTempObj);
             }             
             system.assertNotEquals(relationshipUpdtList, null);
           system.assertEquals(relationshipUpdtList.size() > 0, true);
            update relationshipUpdtList;
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE Name = 'TNCA 2019-20201' AND RecordTypeId = :recordTypeIdAP];
            system.assertNotEquals(academicProgTNCAList, null);
           system.assertEquals(academicProgTNCAList.size() > 0, true);
             list<hed__Program_Enrollment__c> programEnrollList3 = new list<hed__Program_Enrollment__c>();
            for(hed__Program_Enrollment__c programEnrollObj : [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123']){
                programEnrollObj.Status__c = CS_Constants.PE_WITHDRAWN_STATUS;
                programEnrollList3.add(programEnrollObj);
            }
            system.assertNotEquals(programEnrollList3, null);
            system.assertEquals(programEnrollList3.size() > 0, false);
            update programEnrollList3;
             list<hed__Program_Enrollment__c> programEnrollList2 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold4conList.get(0).Id AND Status__c = :CS_Constants.PE_COMPLETE_STATUS AND School_Name__c = 'TNCA123'];
            system.assertNotEquals(programEnrollList2, null);           
             update programEnrollList2; 
             list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgTNCAList.get(0).Id AND hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND School_Name__c = 'TNCA123' AND Status__c = :CS_Constants.PE_WITHDRAWN_STATUS];
             system.assertNotEquals(programEnrollList1, null);
           system.assertEquals(programEnrollList1.size() > 0, false);
            update programEnrollList1;     
         
            Test.startTest();
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            set<Id> studRecsIdSet = new set<Id>();
            for(Contact contactRecObj : [SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdSTD]){
                 studRecsIdSet.add(contactRecObj.Id);
             }
             CS_LCUserCTPermSetsAccessRelnshipBth_v2 batchJobHandlerObj = new CS_LCUserCTPermSetsAccessRelnshipBth_v2(studRecsIdSet);
             database.executeBatch(batchJobHandlerObj);             
            Test.stopTest();
     }
    
    public static testMethod void associateCTPermSetToLCUserScenario06Test(){
             // Update test data added in the Test-Setup above.
             list<Contact> STDHouseHold1conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact1'];
             list<Contact> STDHouseHold2con1List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact11'];
             list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];  
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];
             list<Contact> LCHouseHold1ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact02']; 
             list<hed__Relationship__c> relationshipUpdt1List = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS];
             relationshipUpdt1List.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
           system.assertNotEquals(relationshipUpdt1List, null);
           system.assertEquals(relationshipUpdt1List.size() > 0, true);
             update relationshipUpdt1List;           
             list<hed__Relationship__c> relationshipUpdt2List = new list<hed__Relationship__c>();
            for(hed__Relationship__c relationTempObj : [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_FORMER_STATUS]){
                relationTempObj.hed__Status__c = CS_Constants.RELATIONSHIP_CURRENT_STATUS;
                relationshipUpdt2List.add(relationTempObj);
            }
           
            system.assertNotEquals(relationshipUpdt2List, null);
            system.assertEquals(relationshipUpdt2List.size() > 0, true);
             update relationshipUpdt2List;
             list<hed__Relationship__c> relationshipUpdtList = new list<hed__Relationship__c>();
            for(hed__Relationship__c relationTempObj : [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS]){
                relationTempObj.hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
                relationshipUpdtList.add(relationTempObj);
            }
             system.assertNotEquals(relationshipUpdtList, null);
             system.assertEquals(relationshipUpdtList.size() > 0, true);
             update relationshipUpdtList;
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             
             list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE ((Name = 'TNCA 2019-20201') OR (Name = 'TNCA 2019-20202') OR (Name = 'TNCA 2019-20203'))  AND RecordTypeId = :recordTypeIdAP];
           system.assertNotEquals(academicProgTNCAList, null);
           system.assertEquals(academicProgTNCAList.size() > 0, true);
           list<Account> academicProgACAList = [SELECT Id, Name FROM Account WHERE ((Name = 'ACA 2019-20201') OR (Name = 'ACA 2019-20202'))  AND RecordTypeId = :recordTypeIdAP];
           system.assertNotEquals(academicProgACAList, null);
           system.assertEquals(academicProgACAList.size() > 0, true);
           Test.startTest();
            list<hed__Program_Enrollment__c> programEnrollList3 = new list<hed__Program_Enrollment__c>();
            for(hed__Program_Enrollment__c progEnrollObj : [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE ((hed__Account__c = :academicProgTNCAList.get(0).Id) OR (hed__Account__c = :academicProgTNCAList.get(1).Id) OR (hed__Account__c = :academicProgTNCAList.get(2).Id)) AND ((hed__Contact__c = :STDHouseHold2con2List.get(0).Id) OR (hed__Contact__c = :STDHouseHold4conList.get(0).Id)) AND School_Name__c = 'TNCA123']){
                progEnrollObj.Status__c = CS_Constants.PE_COMPLETE_STATUS;
                programEnrollList3.add(progEnrollObj);
            }
           system.assertNotEquals(programEnrollList3, null);
           system.assertEquals(programEnrollList3.size() > 0, false);
           update programEnrollList3;
           list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgACAList.get(0).Id AND hed__Contact__c = :STDHouseHold1conList.get(0).Id AND School_Name__c = 'ACA32' AND Status__c = :CS_Constants.PE_COMPLETE_STATUS];
           system.assertNotEquals(programEnrollList1, null);           
             update programEnrollList1;     
             CS_LCUserCTPermSetsAccessProgEnrBth_v2 programEnrollbatchJob = new CS_LCUserCTPermSetsAccessProgEnrBth_v2();
             Database.executeBatch(programEnrollbatchJob, 50);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 7', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered); 
            Test.stopTest();
     }
    
    public static testMethod void associateCTPermSetToLCUserScenario05Test(){
             // Update test data added in the Test-Setup above.
             list<Contact> STDHouseHold1conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact1'];
             list<Contact> STDHouseHold2con1List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact11'];
             list<Contact> STDHouseHold2con2List = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact21'];  
             list<Contact> STDHouseHold4conList = [SELECT Id, LastName FROM Contact WHERE LastName = 'StdContact31'];
             list<Contact> LCHouseHold2ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact11'];
             list<Contact> LCHouseHold1ConList = [SELECT Id, LastName FROM Contact WHERE LastName = 'LCContact02']; 
             list<hed__Relationship__c> relationshipUpdt1List = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold2con2List.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS];
             relationshipUpdt1List.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_FORMER_STATUS;
             update relationshipUpdt1List;           
             list<hed__Relationship__c> relationshipUpdt2List = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold1ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_FORMER_STATUS];
             relationshipUpdt2List.get(0).hed__Status__c = CS_Constants.RELATIONSHIP_CURRENT_STATUS;
           system.assertNotEquals(relationshipUpdt2List, null);
           system.assertEquals(relationshipUpdt2List.size() > 0, true);
             update relationshipUpdt2List;
             list<hed__Relationship__c> relationshipUpdtList = [SELECT Id, Name, hed__Status__c, hed__Contact__c, hed__Type__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :STDHouseHold4conList.get(0).Id AND hed__RelatedContact__c = :LCHouseHold2ConList.get(0).Id AND hed__Status__c = :CS_Constants.RELATIONSHIP_CURRENT_STATUS];             
           system.assertNotEquals(relationshipUpdtList, null);
           system.assertEquals(relationshipUpdtList.size() > 0, true);
             update relationshipUpdtList;
             Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();         
             
           list<Account> academicProgTNCAList = [SELECT Id, Name FROM Account WHERE ((Name = 'TNCA 2019-20201') OR (Name = 'TNCA 2019-20202') OR (Name = 'TNCA 2019-20203'))  AND RecordTypeId = :recordTypeIdAP];
           system.assertNotEquals(academicProgTNCAList, null);
           system.assertEquals(academicProgTNCAList.size() > 0, true);
           list<Account> academicProgACAList = [SELECT Id, Name FROM Account WHERE ((Name = 'ACA 2019-20201') OR (Name = 'ACA 2019-20202'))  AND RecordTypeId = :recordTypeIdAP];
           system.assertNotEquals(academicProgACAList, null);
           system.assertEquals(academicProgACAList.size() > 0, true);
           Test.startTest();
             list<hed__Program_Enrollment__c> programEnrollList3 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE ((hed__Account__c = :academicProgTNCAList.get(0).Id) OR (hed__Account__c = :academicProgTNCAList.get(1).Id) OR (hed__Account__c = :academicProgTNCAList.get(2).Id)) AND ((hed__Contact__c = :STDHouseHold2con2List.get(0).Id) OR (hed__Contact__c = :STDHouseHold4conList.get(0).Id)) AND School_Name__c = 'TNCA123'];
             delete programEnrollList3;
           list<hed__Program_Enrollment__c> programEnrollList1 = [SELECT Id, Name, hed__Contact__c, hed__Account__c, Status__c FROM hed__Program_Enrollment__c WHERE hed__Account__c = :academicProgACAList.get(0).Id AND hed__Contact__c = :STDHouseHold1conList.get(0).Id AND School_Name__c = 'ACA32' AND Status__c = :CS_Constants.PE_COMPLETE_STATUS];
           list<hed__Program_Enrollment__c> finalProgramEnrollList1 = new list<hed__Program_Enrollment__c>();
           list<hed__Program_Enrollment__c> finalProgramEnrollList2 = new list<hed__Program_Enrollment__c>();
           for(hed__Program_Enrollment__c programEnrollObj : programEnrollList1){
              programEnrollObj.Status__c = CS_Constants.PE_IN_PROGRESS_STATUS;
              finalProgramEnrollList1.add(programEnrollObj);
           }
           system.assertNotEquals(finalProgramEnrollList1, null);
           update finalProgramEnrollList1;
           for(hed__Program_Enrollment__c programEnrollObj : finalProgramEnrollList1){
              programEnrollObj.Status__c = CS_Constants.PE_WITHDRAWN_STATUS;
                 finalProgramEnrollList2.add(programEnrollObj);
             }
             
           system.assertNotEquals(finalProgramEnrollList2, null);
           update finalProgramEnrollList2; 
           set<Id> studRecsIdSet = new set<Id>();
           Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
            for(Contact contactRecObj : [SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdSTD]){
                 studRecsIdSet.add(contactRecObj.Id);
             }
             CS_LCUserCTPermSetsAccessRelnshipBth_v2 batchJobHandlerObj = new CS_LCUserCTPermSetsAccessRelnshipBth_v2(studRecsIdSet);
             database.executeBatch(batchJobHandlerObj);
             String chron = '0 0 2 * * ?';        
             String jobDetails = system.schedule('Assign Perm-Sets To LC Users 6', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
             System.assertEquals(0, ct.TimesTriggered); 
            Test.stopTest();
     }        
    
     public static testMethod void associateCTPermSetToLCUserLCUserAccessToSchoolKBAsHandlerTest(){
         
         Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
         Id recordTypeIdLC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_LEARNING_COACH).getRecordTypeId();
         // Querying all the Student Contacts setup as test data.
         set<Id> studentIdSet = new set<Id>();
         // Querying all the Student Contacts setup as test data.
         map<Id, Contact> studentMap = new map<Id, Contact>([SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdSTD]);
         // Querying all the Learning Coach Contacts setup as test data.
         set<Id> learningCoachIdSet = new set<Id>();
         map<Id, Contact> learningCoachMap = new map<Id, Contact>([SELECT Id, LastName FROM Contact WHERE RecordTypeId = :recordTypeIdLC]);
         studentIdSet = studentMap.keySet();
         learningCoachIdSet = learningCoachMap.keySet();
         map<Id, set<Id>> studentIdWithSetOfLCRecIdSetMap = new map<Id, set<Id>>();
         map<String, hed__Relationship__c> studentIdAndLCRecIdWithRelationshipsMap = new map<String, hed__Relationship__c>();

         list<hed__Relationship__c> relationshipList = [SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__RelatedContact__c, hed__RelatedContact__r.Name, hed__Status__c FROM hed__Relationship__c WHERE (hed__Contact__c IN :studentIdSet) AND (hed__RelatedContact__c IN :learningCoachIdSet) AND hed__Type__c = :CS_Constants.LEARNING_COACH_TYPE];
         system.assertNotEquals(relationshipList, null);
         for(hed__Relationship__c relationshipRecObj : relationshipList){
             if(!studentIdWithSetOfLCRecIdSetMap.containsKey(relationshipRecObj.hed__Contact__c)){
                 set<Id> relatedLCRecIdSet = new set<Id>();
                 relatedLCRecIdSet.add(relationshipRecObj.hed__RelatedContact__c);
                 studentIdWithSetOfLCRecIdSetMap.put(relationshipRecObj.hed__Contact__c, relatedLCRecIdSet);
             }
             else {
                 set<Id> relatedLCRecIdSet = studentIdWithSetOfLCRecIdSetMap.get(relationshipRecObj.hed__Contact__c);
                 relatedLCRecIdSet.add(relationshipRecObj.hed__RelatedContact__c);
                 studentIdWithSetOfLCRecIdSetMap.put(relationshipRecObj.hed__Contact__c, relatedLCRecIdSet);                 
             }
             
             if(!studentIdAndLCRecIdWithRelationshipsMap.containsKey(String.valueOf(relationshipRecObj.hed__Contact__c)+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c))){
                 studentIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(relationshipRecObj.hed__Contact__c)+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c), relationshipRecObj);
             }
         }
         
         system.assertNotEquals(studentIdWithSetOfLCRecIdSetMap, null);
         system.assertNotEquals(studentIdAndLCRecIdWithRelationshipsMap, null);
         CS_LCUserAccessToSchoolCTKBAsHandler handlerObj = new CS_LCUserAccessToSchoolCTKBAsHandler();
         handlerObj.processRelationshipRecsForCTPermSetsAccess(studentIdWithSetOfLCRecIdSetMap, studentIdAndLCRecIdWithRelationshipsMap);         
     }           
     
     public static testMethod void scheduleProgramEnrollBatchForCTPermSetAccessForLCUsersTest(){
     
         Test.startTest();
         String chron = '0 0 2 * * ?';        
         String jobDetails = system.schedule('Test Prog Enroll Batch For Perm-set Access to LC Users', chron, new CS_CTSTDLC_PE_RLTN_KM_BatchSchedule());         
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobDetails];
         System.assertEquals(0, ct.TimesTriggered); 
         Test.stopTest();
     }  
}