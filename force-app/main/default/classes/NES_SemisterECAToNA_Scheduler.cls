public class NES_SemisterECAToNA_Scheduler implements Schedulable{

    public String acadamicProgram;
    public String recordTypeName;
    public Set<String> enrollmentComponentNames;
    
    public void execute(SchedulableContext SC) {        
        Database.executeBatch(new NES_Batch_SemisterECAsToNA(acadamicProgram, recordTypeName, enrollmentComponentNames), 200);
    }

    
    public NES_SemisterECAToNA_Scheduler ( String program, Set<String> ecName,  String rtName) {
        this.acadamicProgram = program;
        this.enrollmentComponentNames = ecName;
        this.recordTypeName = rtName;
    }

}