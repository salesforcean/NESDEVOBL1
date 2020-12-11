public class CS_Guid {
      public static string ramdomNum()
      {
        integer len=18;
        final string chars='0123456789';
        string randamStr='';
        while(randamStr.length()<len){
        integer idx=Math.mod(Math.abs(Crypto.getRandomInteger()),chars.length());
           randamStr+=chars.substring(idx,idx+1);
      }
        system.debug('randamStr-------->'+randamStr);
        return randamStr;
      }
}