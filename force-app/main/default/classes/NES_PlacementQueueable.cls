/**
 * Created by triciaigoe on 2019-04-10.
 * Updated by Alex Chisholm on 11/9/2019
 */

public without sharing class NES_PlacementQueueable implements Queueable {
    private List<Id> asiIds;
    private List<ID> peIds;

    public void execute(QueueableContext context) {
		
		/* Initiate the placement process for the list of PEs */
        PlacementUtilities.runPlacement(peIDs);
        //System.enqueueJob(new PlacementBucketQueueable(peIds)); --Removed by Alex 2020-01-23
    }

    public NES_PlacementQueueable(List<Id> runPlacementPEs) {
        this.peIDs = runPlacementPEs;
    }
}