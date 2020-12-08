@IsTest
private with sharing class ExtensionCaller {

   @IsTest
   private static void givenConfiguredExtensionWhenCalledThenValidResult() {

      // Given
      String extensionClass = 'Extension'; // Typically set via configuration
      Decimal decimalTestValue = 10;

      // When
      Callable extension = 
         (Callable) Type.forName(extensionClass).newInstance();
      Decimal result = (Decimal) 
         extension.call('multiplyNumbers', new Map<String, Object> { 
            'decimalValue' => decimalTestValue
         });

      // Then
      System.assertEquals(100, result);
   }
}