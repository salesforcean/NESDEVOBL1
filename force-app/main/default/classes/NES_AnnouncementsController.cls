/**
 * Created by melindagrad on 12/17/18.
 */

public with sharing class NES_AnnouncementsController {

    /**
     * Created By Anand on 12/18/2018
     *purpose: To Retreive Announcements
     * @return
     */
    @AuraEnabled
    public static Peak_Response retrieveAnnouncements() {

        return NES_AnnouncementsHelper.getAnnouncements();
    }

    /**
     * Created By Anand on 12/18/2018
     *purpose: To Dissmiss Announcements
     * @return
     */
    @AuraEnabled
    public static Peak_Response dismissAnnouncement(Id contactAnnouncement) {
        return NES_AnnouncementsHelper.dismissAnnouncement(contactAnnouncement);
    }

}