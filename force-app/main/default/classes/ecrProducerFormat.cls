/**
 *  @author: Ali KM (Ness Tech)
 *  @Created on: 04/07/2020
 *  @User Story: 
    @Purpose: This class handles following 
        -> 
        -> 
    @Usage: 
        
 */
public class ecrProducerFormat {

    @AuraEnabled
    public Id sourceID {get; set;}

    @AuraEnabled
    public Integer version {get; set;}
    
    @AuraEnabled
    public ecNode root {get; set;}

    @AuraEnabled
    public Integer steps {get; set;}

    @AuraEnabled
    public Integer countECs {get; set;}

    @AuraEnabled
    public Set<String> ecTypes {get; set;} 

    public ecrProducerFormat() {
        this.steps = 0;
        this.countECs = 0;
        this.version = 0;
        this.ecTypes = new Set<String>();
    }

    // public ecrProducerFormat(ecNode root) {
    //     this();
    //     this.root = root;
    // }

    public void setRoot(ecNode root) {
        this.root = root;
    }

}