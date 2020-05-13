public virtual class LoggerUtil {
    public static List<Error_Log__c> errorLogs = new List<Error_Log__c>();
    public static void log(String message, Exception e) {
        Error_Log__c log = generateLog(e);
        log.Developer_Message__c = message;
        errorLogs.add(log);
    }
    public static void log(String message, DmlException e) {
        Error_Log__c log = generateLog(e);
        log.Developer_Message__c = message;
        errorLogs.add(log);
    }
    public static void log(Exception e) {
        errorLogs.add(new Error_Log__c( 
            Line_Number__c = e.getLineNumber(),
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Type_Name__c = e.getTypeName()
        ));
    }
    public static void log(DmlException e) {
        errorLogs.add(new Error_Log__c( 
            Line_Number__c = e.getLineNumber(),
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Type_Name__c = e.getTypeName()
        ));
    }
    
    public static void log(String msg, List<String> messageList){
        if(messageList!= null && messageList.size() > 0){
            for(String s : messageList){
                msg = msg  + s;
            }
        }
        errorLogs.add(new Error_Log__c(
            Error_Type__c = 'Exception',
            Message__c = msg  
        ));
    }
    
    private static Error_Log__c generateLog(Exception e) {
        return new Error_Log__c(
            Error_Type__c = 'Exception',
            Line_Number__c = e.getLineNumber(),
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Type_Name__c = e.getTypeName()
        );
    }
    private static Error_Log__c generateLog(DmlException e) {
        return new Error_Log__c(
            Error_Type__c = 'DmlException',
            Line_Number__c = e.getLineNumber(),
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Type_Name__c = e.getTypeName()
        );
    }

    public static void log(String message, HttpResponse response) {
        Error_Log__c log = generateLog(response);
        log.Developer_Message__c = message;
        errorLogs.add(log);
    }
    public static void log(HttpResponse response) {
        Error_Log__c log = generateLog(response);
        errorLogs.add(log);
    }
    private static Error_Log__c generateLog(HttpResponse response) {
        return new Error_Log__c(
            Error_Type__c = 'HttpResponse',
            Message__c = response.getBody(),
            Status__c = response.getStatus(),
            Status_Code__c = response.getStatusCode(),
            Header_Keys__c = String.valueOf(response.getHeaderKeys())
        );
    }
    public static void commitLogs() {
        try {
            insert errorLogs;
            errorLogs = new List<Error_Log__c>();
        } catch (Exception e) {
            System.debug('Failed to commit logs');
            System.debug(e);
            System.debug(e.getMessage());
        }
    }
    public static void handleSaveResults(Database.SaveResult sr) {
        if(!sr.isSuccess()) {
            log(sr);
        }
    }
    public static void handleSaveResults(String message, Database.SaveResult sr) {
        if(!sr.isSuccess()) {
            log(message, sr);
        }
    }
    public static void handleSaveResults(List<Database.SaveResult> srList) {
        for(Database.SaveResult sr: srList) {
            if(!sr.isSuccess()) {
                log(sr);
            }
        }
    }
    public static void handleSaveResults(String errorMessage, List<Database.SaveResult> srList) {
        for(Database.SaveResult sr: srList) {
            if(!sr.isSuccess()) {
                log(errorMessage, sr);
            }
        }
    }
    public static void handleSaveResults(Database.UpsertResult ur) {
        if(!ur.isSuccess()) {
            log(ur);
        }
    }
    public static void handleSaveResults(String message, Database.UpsertResult ur) {
        if(!ur.isSuccess()) {
            log(message, ur);
        }
    }
    public static void handleSaveResults(List<Database.UpsertResult> urList) {
        for(Database.UpsertResult ur: urList) {
            if(!ur.isSuccess()) {
                log(ur);
            }
        }
    }
    public static void handleSaveResults(String message, List<Database.UpsertResult> urList) {
        for(Database.UpsertResult ur: urList) {
            log(message, ur);
        }
    }
    public static void log(String message, List<Database.UpsertResult> urList) {
        for(Database.UpsertResult ur: urList) {
            if(!ur.isSuccess()) {
                Error_Log__c log = generateLog(ur);
                log.Message__c += ' Message: ' + message;
                errorLogs.add(log);
            }
        }
    }
    public static void log(Database.UpsertResult ur) {
        if(!ur.isSuccess()) {
            Error_Log__c log = generateLog(ur);
            errorLogs.add(log);
        }
    }
    public static void log(String message, Database.SaveResult sr) {
        if(!sr.isSuccess()) {
            Error_Log__c log = generateLog(sr);
            log.Message__c += ' Message: ' + message;
            errorLogs.add(log);
        }
    }
     public static void log(String message, Database.UpsertResult ur) {
        if(!ur.isSuccess()) {
            Error_Log__c log = generateLog(ur);
            log.Message__c += ' Message: ' + message;
            errorLogs.add(log);
        }
    }

    public static void log(Database.SaveResult sr) {
        Error_Log__c log = generateLog(sr);
        errorLogs.add(log);
    }
    private static Error_Log__c generateLog(Database.SaveResult sr) {
        Error_Log__c log = new Error_Log__c(Message__c = '', Error_Type__c = 'SaveResult');
        if(sr.getErrors() != null) {
            for(Database.Error err: sr.getErrors()) {
                log.Message__c += 'Id: ' + sr.getId() + '; ' + 'Message: ' + err.getMessage() + '; Fields: ' + err.getFields() + '; Status Code: ' + err.getStatusCode();
            }
        }
        return log;
    }
    private static Error_Log__c generateLog(Database.UpsertResult ur) {
        Error_Log__c log = new Error_Log__c(Message__c = '', Error_Type__c = 'SaveResult');
        if(ur.getErrors() != null) {
            for(Database.Error err: ur.getErrors()) {
                log.Message__c += 'Id: ' + ur.getId() + '; ' + 'Message: ' + err.getMessage() + '; Fields: ' + err.getFields() + '; Status Code: ' + err.getStatusCode();
            }
        }
        return log;
    }
    public static void handleDeleteResults(List<Database.DeleteResult> drList, String errorType, Boolean logAll) {
       Error_Log__c log = new Error_Log__c(Message__c = 'Summary of records to be deleted: ' + drList.size(), Error_Type__c = errorType);
       if(drList.size() == 0) {
            log.Message__c += ' no records matched';
       } else {
            for(Database.DeleteResult dr: drList) {
                if(dr.isSuccess() && logAll) {
                    log.Message__c += '  Id: ' + dr.getId();
                } else if(!dr.isSuccess()) {
                    errorLogs.add(generateLog(dr));
                }
            }
        }
        errorLogs.add(log);
    }
    private static Error_Log__c generateLog(Database.DeleteResult dr) {
        Error_Log__c log = new Error_Log__c(Message__c = '', Error_Type__c = 'Batch Delete Failure');
        log.Message__c += 'Id: ' + dr.getId();
        if(dr.getErrors() != null) {
            for(Database.Error err: dr.getErrors()) {
                log.Message__c += 'Message: ' + err.getMessage() + '; Fields: ' + err.getFields() + '; Status Code: ' + err.getStatusCode();
            }
        }
        return log;
    }
}