/**
 * Created by ajith on 01/10/18.
 */

public with sharing class NES_Utilities2 {
    private static Peak_ApexLog logger = new Peak_ApexLog('Utilities');

    public static Id getCommunityNetworkId() {
        Id networkId = System.Network.getNetworkId();

        if (networkId == null) {
            try {
                networkId = [SELECT Id FROM Network WHERE Name = 'externalidentity'].Id;
            } catch (Exception ex) {
                System.debug('Error Message:::' + ex.getMessage());
                logger.logException('getCommunityNetworkId', ex);
                logger.saveLogs();
            }

        }

        return networkId;
    }

    public static String createDefaultNickname(String nickName) {
        String likeNickname = nickName + '%';
        List<User> users = new List<User>([
                SELECT Id, CommunityNickname
                FROM User
                WHERE
                        CommunityNickname LIKE :likeNickname
        ]);

        if (!users.isEmpty()) {
            nickName = nickName + String.valueOf(users.size() + 1);
        }

        return nickName;
    }

    public static String buildSOQL(String sObjectString, Boolean allFields, String fields, String whereString,
            String orderBy) {

        String returnString;
        if (allFields) {
            fields = selectAllFields(sObjectString);
        }

        returnString = 'SELECT ' + fields + ' FROM ' + sObjectString;

        if (whereString != null) {
            returnString = returnString + ' WHERE ' + whereString;
        }

        if (orderBy != null) {
            returnString = returnString + ' ORDER BY ' + orderBy;
        }

        return returnString;
    }

    public static String selectAllFields(String sObjectString) {
        String allFields;
        Boolean first = true;
        Map<String, Schema.SObjectField> objectFieldMap =
                Schema.getGlobalDescribe().get(sObjectString).getDescribe().fields.getMap();

        for (String fields : objectFieldMap.keySet()) {
            if (allFields == null) {
                allFields = fields;
            } else {
                allFields += ', ' + fields;
            }
        }

        return allFields;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

}