public without sharing class CSVObject  {

    @AuraEnabled
    public List<CSVHeader> headers {get; set;}

    @AuraEnabled
    public List<List<String>> lines {get; set;}

    @AuraEnabled
    public Integer line_count {get; set;}

    public CSVObject() {}

    public CSVObject(List<CSVHeader> headers, List<List<String>> lines) {
        this.headers = headers;
        this.lines = lines;
        this.line_count = lines.size();
    }
    public class CSVField{        
        public String phone; 
        public String conFirstName;
        public String conLastName;   
        public String email ;
        public String username;
        public String password;
        public String phoneType;
        public String state;
        public String zip;
        public String accountId;
        public String contactId;
        public String studentId;
        public String programCode;
        public String gradeCode;
        public String yearCode;
        public String phoneTy;


    } 
    
    
    
}