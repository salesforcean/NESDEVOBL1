public without sharing class NES_ECAEvaluationQueueable1 implements Queueable{
  private Id programEnrollmentId;

    public void execute(QueueableContext context) {

            
    }

    public NES_ECAEvaluationQueueable1(Id enrollmentId) {

        this.programEnrollmentId = enrollmentId;
    }

}