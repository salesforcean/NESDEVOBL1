public class executeBatchToDeleteRecords{
    
    public static void executeBatch(set<string> objNames){
    //boolean IsSandbox= [SELECT Id, IsSandbox FROM Organization].IsSandbox;
         if(returnSandboxType() && DataDeletion__c.getValues(userinfo.getUserId())!=null){
        for(String objname: objNames ){
        if(objName=='User'){
            DeleteSelectedRecords shn = new DeleteSelectedRecords(objname); 
          database.executeBatch(shn,10 ); 
        }
        else{ DeleteSelectedRecords shn = new DeleteSelectedRecords(objname); 
          database.executeBatch(shn ); 
          }
            }
        }
    }
    public static Boolean returnSandboxType(){
        return [SELECT Id, IsSandbox FROM Organization].IsSandbox;
    }
    
}