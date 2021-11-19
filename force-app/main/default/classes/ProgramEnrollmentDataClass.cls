/**
    @class:         ProgramEnrollmentDataClass           
    @description:   Data Class to hold PE related data
    @author:        Mark Membrino
    @createdDate:   9/10/2020
*/
public class ProgramEnrollmentDataClass 
{
    public Id academicProgram { get; set; }
    public hed__Program_Enrollment__c peRecord { get; set; }
    public ecrProcessData academicProgramData{ get; set; }
    public Map<Id, Id> ecToECAMap { get; set; }
    public Enrollment_Component_Affiliation__c currentStageECA { get; set; }
    public Enrollment_Component_Affiliation__c lastStageECA { get; set; }
    public Set<Id> currentStageChildECs { get; set; }

    public ProgramEnrollmentDataClass() 
    {
        this.ecToECAMap = new Map<Id, Id>();
        this.currentStageChildECs = new Set<Id>();
    }
}