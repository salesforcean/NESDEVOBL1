global class NES_Schedule_ACASemisterECAsToNA implements Schedulable {
   global void execute(SchedulableContext SC) {
      Set<String> strECNames = new Set<String>();     
        strECNames.add('Alternative Shipping Address Information');
        strECNames.add('Parent/Legal Guardian (Caretaker) Acknowledgement');
        strECNames.add('Parent / Legal Guardian (Caretaker) Acknowledgement');       
        Database.executeBatch(new NES_Batch_SemisterECAsToNA('ACA 2020-2021', 'Section', strECNames), 200); 
   }
}