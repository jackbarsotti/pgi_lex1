/**
*    PGI_Utility class contains generic methods that can be reused across appliction
*
*    Modification Log
*
*    Deepthi        PGI    11/04/2014      contains generic methods that can be reused across appliction
**/
public class PGI_Utility{
    public static User currentUser { get{
        if(currentUser == null) {
            currentUser = [SELECT Override_Validation_Rules__c FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
        }
        return currentUser;
    } set;
    } 

    private static Integer currentHourInGMT {get {
        return System.now().hourGmt();
    }} 

    public static Integer hourInMT {get {
        Timezone tz = Timezone.getTimeZone('America/New_York');
        // Create a date before the 2007 shift of DST into November
        DateTime dtpre = DateTime.newInstanceGMT(System.today().year(), System.today().month(), System.today().day(), 0, 0, 0);
        
        Integer EtOffest = tz.getOffset(dtpre) / 3600 / 1000;   //-18000000 (= -5 hours = EST)
        Integer MtOffset = eTOffest - 2;

        Integer MTHour = currentHourInGMT + MtOffset;

        if(MTHour < 0) {
          MTHour = MTHour + 24;
        } else if(MTHour > 24) {
          MTHour = MTHour - 24;
        }
    return MTHour;
    } set;}
    public static Profile profile {get {
        if(profile == null) {
            List<Profile> pList = [SELECT Name FROM Profile where ID = :UserInfo.getProfileId()];
            if(pList.size() > 0) {
                profile = pList[0];
            } else {
                profile = new Profile();
            }
        }
        return profile;
    } set; }
    public static Map<Id, Profile> profileById {get {
        if(profileById == null) {
            profileById = new Map<Id, Profile>([SELECT Id, Name FROM Profile]);
        }
        return profileById;
    } set;}
    public static Set<String> pluckStrings(List<sObject> sobjects, String stringField) {
        Set<String> returnSet = new Set<String>();
        for(sObject sobj: sObjects) {
            try {
                returnSet.add((String)sobj.get(stringField));
            } catch (exception e) {
                system.debug('Ignoring record: ' + e);
            }
        }
        return returnSet;
    }
    public static List<sObject> removeFields(List<sObject> sObjList, Set<String> fieldsToRemove) {
        List<sObject> returnList = new List<sObject>();
        for(sObject sObj: sObjList) {
            returnList.add(removeFields(sObj, fieldsToRemove));
        }
        return returnList;
    }
    private static sObject removeFields(sObject sObj, Set<String> fieldsToRemove) {
        Map<String, Object> serializedObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
        for(String s: fieldsToRemove) {
            if(serializedObjectMap.keySet().contains(s)) {
                serializedObjectMap.remove(s);
            }
        }
        return (sObject)JSON.deserialize(JSON.serialize(serializedObjectMap), sObject.class);
    }
          
          
    public static Date findMinimumDate(List<sObject> sobjects, String dateField) {
        Date minimumDate = null;
        for(sObject sobj: sObjects) {
            try {
                if((Date)sobj.get(dateField) < minimumDate || minimumDate == null) {
                    minimumDate = (Date)sobj.get(dateField);
                }
            } catch (exception e) {
                system.debug('Ignoring record: ' + e);
            }
        }
        return minimumDate;
    }
    public static Date findMaximumDate(List<sObject> sobjects, String dateField) {
        Date maximumDate = null;
        for(sObject sobj: sObjects) {
            try {
                if((Date)sobj.get(dateField) > maximumDate || maximumDate == null) {
                    maximumDate = (Date)sobj.get(dateField);
                }
            } catch (exception e) {
                system.debug('Ignoring record: ' + e);
            }
        }
        return maximumDate;
    }
    public static Date startOfMonth(Date inputDate) {
        if(inputDate == null) {
            return null;
        }
        Date returnDate = inputDate;
        return Date.newInstance(returnDate.year(), returnDate.month(), 1);
    }
    public static Date startOfNextMonth(Date inputDate) {
        if(inputDate == null) {
            return null;
        }
        return startOfMonth(inputDate.addMonths(1));
    }
    public static Date endOfMonth(Date inputDate) {
        if(inputDate == null) {
            return null;
        }
        Integer daysInMonth = Date.daysInMonth(inputDate.year(), inputDate.month());
        return Date.newInstance(inputDate.year(), inputDate.month(), daysInMonth);
    }
  // get record type info:
    public static Map<String, Id> getRecordTypes(String objectAPIName){
        Map<String,Id> recordTypes = new Map<String,Id>();
        Id defaultRecordTypeId;
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String, Id> mapofOppRecordTypeNameandId = new Map<String, Id>();
        System.debug('here' + recordTypeInfo);
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.DefaultRecordTypeMapping) {
                defaultRecordTypeId = info.RecordTypeId;
                mapofOppRecordTypeNameandId.put('DefaultRecordType', defaultRecordTypeId);
            }
            mapofOppRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
        }

        recordTypes = mapofOppRecordTypeNameandId;
        system.debug('***mapofOppRecordTypeNameandId*'+mapofOppRecordTypeNameandId);
        return recordTypes;
    }


    /*
    *   Logic to lookup Lead LicenseSet records with Opportunity
    */
    public static list<LicenseSet__c> createOpporLicenseSet(map<id, id> ldOpporIdMap){
        list<Licenseset__c> licSetLst = new list<Licenseset__c>();
        //Retrieve Leads and LicenseSets associated with Leads
        for(Lead ld: [select id, Z_Source__c, (Select id, name, Opportunity__c, Enterprise_Name__c, Number_of_Licensed_Named_Users__c,Start_Date__c,End_Date__c, Z_Source__c from licensesets__r) 
                            from 
                                lead 
                            where 
                                id in :ldOpporIdMap.keyset()]){
            system.debug(' ld.licensesets__r: ' + ld.licensesets__r);
            for(Licenseset__c licSet : ld.licensesets__r){
                if(licSet.Opportunity__c == null){
                    //Mapping LicenseSet with Opportunity
                    licSet.Opportunity__c = ldOpporIdMap.get(ld.id);
                }
                licSetLst.add(licSet);
            }
        }
        system.debug(' licSetLst: ' + licSetLst);

        //Returning LicenseSet list for update
        return licSetLst;
    }

    /*
    *   Logic to create Opportunity Assets
    */
    public static list<Asset> createOpporAsset(list<LicenseSet__c> licSetLst){
        list<Asset> licLst     = new list<Asset>();
        //set<string> offeringIdSet   = new set<String>();
        set<string> opporIdSet      = new set<String>();

        //Collecting OpportnityIds from LicenseSet list
        for(LicenseSet__c licSet: licSetLst){
            //offeringIdSet.add(licSet.Enterprise_Name__c);
            opporIdSet.add(licSet.Opportunity__c);
        }
        //map<Id, Offerings__c > offeringsMap = new map<id, Offerings__c>([select id, name from offerings__c where id in :offeringIdSet]);

        // Querying for Opportunity Values and Storing in Map
        map<Id, Opportunity >   opporMap    = new map<id, Opportunity>([select id, name, AccountId, Z_Source__c,ECommerce_Account_Number__c from Opportunity where id in :opporIdSet]);
        system.debug('licSetLst : ' + licSetLst);
        
        // Creating Assets for LicenseSets
        for(Licenseset__c licSet:licSetLst){
            for(Integer i=0;i<licSet.Number_of_Licensed_Named_Users__c;i++){
                // Initializing assets
                Asset lic = new Asset(Name = licSet.name,
                                    Enterprise_Name__c = licSet.Enterprise_Name__c, 
                                    Client_ID__c = Label.Default_Asset_ClientId,
                                    accountid = opporMap.get(licSet.Opportunity__c).accountid,
                                    ECommerce_Account_Number__c = opporMap.get(licSet.Opportunity__c).ECommerce_Account_Number__c,
                                    Opportunity__c = licSet.Opportunity__c, 
                                    License_Name__c = licSet.id,
                                    Z_Source__c = licSet.Z_Source__c
                                );

                //Adding Assets to list
                licLst.add(lic);    
             }
        }
        system.debug('licLst : ' + licLst);
        //Returning Assets list for Update
        return licLst;
    }   

    /*
    *   Logic to create Contracts
    */
     
 }