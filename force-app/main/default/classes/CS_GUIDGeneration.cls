public class CS_GUIDGeneration {
public static string CS_GUID()
      {
        Integer len=18;
        Final string chars='0123456789abdcef';
        String randamStr='';
         // System.debug('randamStr-------->'+randamStr.length());
        While(randamStr.length()<len){
            
        Integer idx=Math.mod(Math.abs(Crypto.getRandomInteger()),chars.length());
            //System.debug('IDx----->'+idx);
           randamStr+=chars.substring(idx,idx+1);
           // system.debug('randamStr-------->insideloop'+randamStr);
            //system.debug('randamStr-------->insideloop value:'+randamStr.length());
      }
       //System.debug('randamStr-------->'+randamStr);
       Return randamStr;
    }
}