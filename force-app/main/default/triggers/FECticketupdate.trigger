trigger FECticketupdate on Case (before insert, before update) {

for(case caserecord : [Select id,RecordType.DeveloperName,account.Family_Enrollment_Counselor__c,Ownerid from case where id in:Trigger.new])
     {
        System.debug('caserecord&&&&'+caserecord);
        if(caserecord.RecordType.DeveloperName == 'FEC_Support' && caserecord.account.Family_Enrollment_Counselor__c!=null)
          {
        System.debug('beforecaserecord&&&&'+caserecord.Ownerid);
        System.debug('beforecaserecord&&&&'+caserecord.account.Family_Enrollment_Counselor__c);
        caserecord.Ownerid =caserecord.account.Family_Enrollment_Counselor__c;
        System.debug('Aftercaserecord&&&&'+caserecord.Ownerid);
        System.debug('Aftercaserecord&&&&'+caserecord.account.Family_Enrollment_Counselor__c);
         }
   }

}