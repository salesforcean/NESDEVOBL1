/**
 * @author Ray Dehler <ray.dehler@7summitsinc.com> 2/7/19
 */
public with sharing class Peak_ApexLog {
    private static final Integer LOG_LEVEL_ERROR = 1;
    private static final String LOG_LEVEL_ERROR_STRING = 'Error';
    private static final Integer LOG_LEVEL_WARNING = 2;
    private static final String LOG_LEVEL_WARNING_STRING = 'Warning';
    private static final Integer LOG_LEVEL_INFO = 3;
    private static final String LOG_LEVEL_INFO_STRING = 'Info';
    private static final String LOG_MANAGER_INHERIT = 'Inherit from Persona';

    private static final String ERROR_NO_LOG_SETTINGS = 'The Apex Logger is not correctly configured, please see the setup guide.';
    private static final String ERROR_NO_LOG_SETTINGS_CLASS = 'The Apex Logger is not correctly configured for the class in question, please see the setup guide.';
    private static final String ERROR_CANNOT_LOG = 'Unable to insert logs, please see the setup guide.';
    private static final String INFO_NO_LOG = 'Skipping log (due to configuration).';
    
    private static final Integer MAX_STRING_LENGTH = Peak_Apex_Log__c.Content__c.getDescribe().getLength();
    	
    
    private Peak_Apex_Log_Persona_Manager__c personaManager;
    private Peak_Apex_Log_Manager__mdt logManager;
    private String className;
    private Integer userClassLogLevel;
    private Boolean isErrorState = false;

    private List<Peak_Apex_Log__c> logsToInsert;

    
    /*
     * Constructor with class specific logging
     */
    public Peak_ApexLog(String className) {
        this();
        this.className = className;
        this.calculateClassOverrides();
    }
    
    /*
     * Constructor without class specifics, keeping private for now
     */
    private Peak_ApexLog() {
        personaManager = Peak_Apex_Log_Persona_Manager__c.getInstance();
        // if there is not even an org-wide default persona manager, error
        if (personaManager == null || personaManager.Log_Level__c == null) {
            System.debug(ERROR_NO_LOG_SETTINGS);
            isErrorState = true;
        }
        logsToInsert = new List<Peak_Apex_Log__c>();
    }

    public void logInfo(String methodName, String message) {
        log(methodName, message, LOG_LEVEL_INFO);
    }    
    public void logWarning(String methodName, String message) {
        log(methodName, message, LOG_LEVEL_WARNING);
    }    
    public void logWarn(String methodName, String message) {
        logWarning(methodName, message);
    }    
    public void logError(String methodName, String message) {
        log(methodName, message, LOG_LEVEL_ERROR);
    }
    public void logException(String methodName, Exception e) {
        log(methodName, e.getMessage()+', '+e.getStackTraceString(), LOG_LEVEL_ERROR);
    }
    public void saveLogs() {
        if (logsToInsert.isEmpty()) {
            return;
        }
        insert logsToInsert;
        logsToInsert.clear();
    }
    
    /*
     * In order to save logs, there must be a metadata record for it
     * This metadata record also has the ability to override some user 
     * configuration.
     */
    private void calculateClassOverrides() {
        if (isErrorState) {
            return;
        }
        userClassLogLevel = Integer.valueOf(personaManager.Log_Level__c);
        
        //SOQL replaced by a call to GenericSOQLQueries for 430196 on 2021-08-10 by Krishna Peddanagammol
        /*List<Peak_Apex_Log_Manager__mdt> mgrRecords = [
            select QualifiedApiName, Log_Level__c
            from Peak_Apex_Log_Manager__mdt 
            where QualifiedApiName = :className];*/
        List<Peak_Apex_Log_Manager__mdt> mgrRecords = GenericSOQLQueries.apexLogDetails(className);
        
        if (!mgrRecords.isEmpty()) {
            logManager = mgrRecords.get(0);
            if (logManager.Log_Level__c != LOG_MANAGER_INHERIT) {
                userClassLogLevel = getLogLevelFromString(logManager.Log_Level__c);
            }
        } else {
            System.debug(ERROR_NO_LOG_SETTINGS_CLASS);
            isErrorState = true;
        }
    }

    /*
     * Method to save logs, if appropriate as designated by logLevel, 
     * class settings, and persona settings
     */
    private void log(String methodName, String message, Integer logLevel) {
        if (isErrorState) {
            return;
        }
        // if the message we're attempting to log is not configured to log
        // for our persona, ignore it
        if (this.userClassLogLevel < logLevel) {
            System.debug(INFO_NO_LOG);
            return;
        }
        
        // still allow for a "null" message, don't let it break our validations
        if (message == null) {
            message = '';
        }

		// only log first MAX_STRING_LENGTH characters        
        if (message.length() > MAX_STRING_LENGTH) {
            message = message.left(MAX_STRING_LENGTH);
        }

		logsToInsert.add(new Peak_Apex_Log__c(
            Class__c = this.className,
            Content__c = message,
            Log_Level__c = getLogLevelFromNumber(logLevel),
        	Method__c = methodName));
    }
    
    /*
     * Because sadly we cannot have a picklist in a custom setting, we
     * manage the log levels as both number and string
     */
    private String getLogLevelFromNumber(Integer logLevelNumber) {
        if (logLevelNumber == LOG_LEVEL_ERROR) {
            return LOG_LEVEL_ERROR_STRING;
        } else if (logLevelNumber == LOG_LEVEL_WARNING) {
            return LOG_LEVEL_WARNING_STRING;
        } else {
            return LOG_LEVEL_INFO_STRING;
        }
    } 
    
    /*
     * Because sadly we cannot have a picklist in a custom setting, we
     * manage the log levels as both number and string
     */
    private Integer getLogLevelFromString(String logLevelString) {
        if (logLevelString == LOG_LEVEL_ERROR_STRING) {
            return LOG_LEVEL_ERROR;
        } else if (logLevelString == LOG_LEVEL_WARNING_STRING) {
            return LOG_LEVEL_WARNING;
        } else {
            return LOG_LEVEL_INFO;
        }
    }     


    public class Peak_ApexLogException extends Exception {}
}