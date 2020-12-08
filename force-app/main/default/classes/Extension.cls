/**
    https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_Callable.htm#apex_interface_System_Callable
 */

public class Extension implements Callable {

   // Actual method
   String concatStrings(String stringValue) {
     return stringValue + stringValue;
   }

   // Actual method
   Decimal multiplyNumbers(Decimal decimalValue) {
     return decimalValue * decimalValue;
   }

   // Dispatch actual methods
   public Object call(String action, Map<String, Object> args) {
     switch on action {
       when 'concatStrings' {
         return this.concatStrings((String)args.get('stringValue'));
       }
       when 'multiplyNumbers' {
         return this.multiplyNumbers((Decimal)args.get('decimalValue'));
       }
       when else {
        throw new ExtensionMalformedCallException('Method not implemented');
       }
     }
   }

   public class ExtensionMalformedCallException extends Exception {}
}