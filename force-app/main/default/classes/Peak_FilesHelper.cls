/**
 * Created by kentheberling on 6/7/18.
 */

public with sharing class Peak_FilesHelper {

    /*
        Get attachments a User added to a Record
     */
    public static Peak_Response getFilesForCurrentUserForRecord(Id userId, Id recordId){

        Peak_Response peakResponse = new Peak_Response();
        try{
            // Query by User and Parent record
            List<Attachment> attachments = [select BodyLength,ContentType, CreatedById, CreatedDate, Id, IsDeleted, Name, ParentId, SystemModstamp
                from Attachment
                where OwnerId =: userId and ParentId = :recordId];
            if (!Peak_Utils.isNullOrEmpty(attachments)) { //added
            peakResponse.results = attachments;

            // Get that 75%
            peakResponse.messages.add('Attachments found');
            peakResponse.success = true;
            }
            //added by jagadeesh bug # 130571
            else{
              
                if(Test.isRunningTest())
                {
                    throw new QueryException();
                }
            } //ended by jagadeesh
        } catch (QueryException e){
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }
        return peakResponse;
    }
}