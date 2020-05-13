/*
 * Author: Angel Robles (anyei)
 * Github: https://github.com/anyei/LayoutDescriberHelper
 * Created Date: 8/25/2015
 * Purpose: Utility class with some functions to allow describe layouts
 * Test Class: LayoutDescriberHelper_Test
 * History: 
 *      8/25/2015 - Angel Robles - Initial Code.
 * 
 * */

public class LayoutDescriberHelper {
    public LayoutDescriberHelper() {
        
    }
    public static string urlPrefixToUse {get;set;}
    
    public static List<LayoutSection> describeSectionWithFields(Id recordTypeId, string objectType){
        sobjectType = objectType;
        //system.debug('record type id ===>'+ recordTypeId);
        List<LayoutSection> layoutSections = new List<LayoutSection>();
        Map<string,List<LayoutField>> layoutFields;
        string theRespBody = GetLayoutSchema(recordTypeId, objectType);
        //system.debug('======>'+theRespbody);  
            //resp is a JSON string
           // JSONParser parser = JSON.createParser(theRespBody);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(theRespBody);
        //for(String s: m.keySet()) {
        //    //system.debug(s);
        //    //system.debug(m.get(s));
        //}
        if(m.containsKey('editLayoutSections')){
            List<object > targetLayout = (List<object>) m.get('editLayoutSections');
            for(object sectionObject: targetLayout){
               Map<String,object> section = (Map<String,object>) sectionObject;
                string sectionH = (string)section.get('heading');
                //system.debug('sectionH-->'+sectionH);
                boolean useH = (boolean)section.get('useHeading');
                integer columns = (integer)section.get('columns');
                boolean useCollapse = (boolean)section.get('useCollapsibleSection');
                
                LayoutSection ls = new LayoutSection();
                ls.Name = sectionH;// == 'Stage 0+' || useH == false ? '' : sectionH;
                ls.useHeader = useH;
                ls.columns = columns;
                ls.allowCollapse = useCollapse;
                ls.layoutFields = new List<LayoutField>();                
                layoutSections.add(ls);

                
                List<object> layoutRows = (List<object>)  section.get('layoutRows');
                List<object> layoutColumns = (List<object>) section.get('layoutColumns');
                if(layoutColumns != null) { 
                    for(object lc: layoutColumns) {
                        //System.debug(lc);
                        Map<String, object> mymap = (Map<String, object>)lc;
                        //System.debug(mymap.get('layoutItems'));
                    }
                }
                //system.debug('layout rows ====> '+layoutRows);
                
                for(Object itemObject : layoutRows ){
                    Map<String,object> item = (Map<String,object>) itemObject;
                    List<object> layoutItem = (List<object>)item.get('layoutItems');
                    boolean priorFieldLayoutAdded = true;//initially true
                    //system.debug(itemObject);
                    //system.debug(layoutItem);


                    for(object fieldItemObject : layoutItem){
                        Map<string, object> layoutitemmap = (map<string,object>)fieldItemObject;
                    //system.debug(layoutitemmap.get('behavior'));
                        Map<string, object> fields = (Map<string,object>) fieldItemObject;
                        //for(String field: fields.keySet()) {
                        //    //system.debug(field);
                        //    //system.debug(fields.get(field));
                        //}
                        List<object> layoutComponents = (List<object>) fields.get('layoutComponents');
                        string apiName = '';
                        string fieldType = '';
                        string label = '';
                        for(Object layoutComponent: layoutComponents){
                            Map<string, object> componentMap = (Map<string,object>)layoutComponent;
                            if(componentMap.get('details') != null) {
                                Map<string, object> detailMap = (Map<string, object>)componentMap.get('details');
                                //for(String s: detailMap.keySet()) {
                                //    //system.debug(s);
                                //    //system.debug(detailMap.get(s));
                                //}
                            }
                            
                            if(componentMap.containsKey('value')){
                                apiName = (string) componentMap.get('value');
                            }
                            if(componentMap.containsKey('type')){
                                fieldType = (string) componentMap.get('type');
                            }
                            /*
                            if(componentMap.containsKey('details')){
                                Map<string,object> detailsMap = (Map<string,object>) componentMap.get('details');
                                boolean calculatedField = (boolean)detailsMap.get('calculated');
                                boolean autoNumberField = (boolean)detailsMap.get('autoNumber');
                                if(calculatedField || autoNumberField)
                                    apiName = '';
                            }*/
                        }
                         /*Map<string, object> nameDetails = (Map<string,object>) layoutComponents.get('Name');
                       
//*/                     // for(String s: fields.keySet()) {
//                            System.debug(s);
//                            system.debug(fields.get(s));
//                        }
                        boolean placeholderF = (boolean) fields.get('placeholder'); 
                        boolean isEditable = (boolean) fields.get('editable');
                        if( (apiName != '' && fieldType =='Field' && apiName != 'OwnerId' && apiName != 'RecordTypeId') || (   placeholderF)){
                            //System.debug(fields);     
                            LayoutField lf = new LayoutField();
                            lf.required      = fields.get('required') != null ? (Boolean)fields.get('required') : false;
                            if(lf.required){
                                ls.isTabHaveFieldRequired = true;
                            }
                            //lf.label = (string)fields.get('label');
                            lf.editableForUpdate = (boolean)fields.get('editableForUpdate');
                            lf.editableForNew = (boolean)fields.get('editableForNew');
                            lf.isPlaceHolder = placeholderF;
                            lf.editableField = isEditable;
                            lf.ApiName = apiName;
                            if(ls.Name != '' || layoutSections.size() == 1)                                
                                ls.layoutFields.add(lf);
                            else if(layoutSections.size() - 2 >= 0)
                                layoutSections.get(layoutSections.size() - 2).layoutFields.add(lf);
                            priorFieldLayoutAdded = true;
                        }else
                            priorFieldLayoutAdded = false;
                       //system.debug(fields);
                    }/**/
                  
                }
              if(layoutSections.get(layoutSections.size() -1).layoutFields.size() <= 0)  
                  layoutSections.remove(layoutSections.size() - 1);
            }
        }
        //system.debug('-->  '+layoutSections);
        return layoutSections;
    }
    
    public static List<AssignmentModel> describeAssignment(Id recordTypeId, string objectType){
        sobjectType = objectType;
       // system.debug('record type id ===>'+ recordTypeId);
        List<AssignmentModel> assignmentSections = new List<AssignmentModel>();
        string theRespBody = GetLayoutSchema(recordTypeId, objectType);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(theRespBody);
        if(m.containsKey('saveOptions')){
           List<object > targetLayout = (List<object>) m.get('saveOptions');
            for(object sectionObject: targetLayout){
                
                Map<String,object> section = (Map<String,object>) sectionObject;
                
                AssignmentModel am = new AssignmentModel();
                am.isDisplayed = (boolean)section.get('isDisplayed');
                am.soapHeaderName = (string)section.get('soapHeaderName'); 
                am.label = (string)section.get('label'); 
                am.name = (string)section.get('name'); 
                am.defaultValue = (boolean)section.get('defaultValue'); 
                assignmentSections.add(am); 
            }
        }
         
        return assignmentSections;
    }
     
    static string getUrlPrefix(){
        
            string baseurl= System.URL.getSalesforceBaseUrl().toExternalForm();
            //system.debug('original prefix is ===>'+ baseurl);
            if(baseurl.contains('c.cs'))
                baseurl = baseurl.substring(baseurl.indexof('.cs') + 1,baseurl.indexof('.visual'));
            else if(baseurl.contains('.na'))
                baseurl = baseurl.substring(baseurl.indexof('.na') + 1,baseurl.indexof('.visual'));
            else if(baseurl.contains('.ap'))
                baseurl = baseurl.substring(baseurl.indexof('.ap') + 1,baseurl.indexof('.visual'));
            else
                baseurl = baseurl.substring(baseurl.indexof('/cs') + 1, baseurl.indexof('.salesforce'));
       
        
        return baseurl;
    }
    public static string GetLayoutSchema(id recordTypeId, string objectType){
        sobjectType = objectType;
        string allLayoutsRestUrl = 'https://'+getUrlPrefix()+'.salesforce.com/services/data/v40.0/sobjects/'+objectType+'/describe/layouts/';
        string urlToRequest = allLayoutsRestUrl +  recordtypeid;
        
        //system.debug('urlToRequest ===>'+ urlToRequest);
        
        HttpResponse resp = null;
         
            HttpRequest req = new HttpRequest();
         
            req.setMethod('GET');
            req.setEndpoint(urlToRequest);
            req.setHeader('Authorization', 'Bearer ' + userinfo.getsessionid());
            Http client = new Http();   
            resp = client.send(req);

            //system.debug('====================> get the response body ');
        return resp.getBody();
    }
    public static Map<String, Schema.sObjectType> gd {get {
        if(gd == null) {
            gd = Schema.getGlobalDescribe();
        }
        return gd;
    }set;}
    public static Schema.DescribeSObjectResult describeResult {get {
        if(describeResult == null) {
            describeResult = gd.get(sObjectType).getDescribe();
        } 
        return describeResult;
    } set;}
    public static Map<String, Schema.SObjectField> fieldMap {get {
       if(fieldMap == null) {
        fieldMap =  describeResult.fields.getMap();
        }
        return fieldMap;
    } set;}
    public static Id  getDefaultRecordType(SObject obj) {
    // in case it's null, the user has only one record type available.
            sObjectType = obj.getSobjectType().getDescribe().getName();

            List<Schema.RecordTypeInfo> rtInfos = describeResult.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            // walk through the map to determine the correct record type, this is done with the isAvailable() function
                if(rtInfo.DefaultRecordTypeMapping) {              
                    return  rtInfo.getRecordTypeId();
                       
                }
            }       
           
       
        return null;
     }
     public static String sobjectType;

   public class LayoutSection{
       public boolean useHeader {get;set;}
       public string name {get;set;}
       public boolean allowCollapse {get;set;}  
       public integer columns {get;set;}
       public Boolean isTabHaveFieldRequired{get;set;}
       public List<LayoutField> layoutFields {get;set;}
   }
    
    public class LayoutField{
        public String label {get; set;}
        public Boolean editableForUpdate {get; set;}
        public Boolean editableForNew {get; set;}
        public boolean required {get; set;}
        public boolean isPlaceHolder {get;set;}
        public String fieldType {get; set;}
        public Boolean richText {get; set;}
        public string ApiName {get; set {
            ApiName = value;
            if(!isPlaceHolder){
                try{
                    Schema.DescribeFieldResult fieldResult = fieldMap.get(value).getDescribe();
                    fieldType = String.valueOf(fieldResult.getType());
                    richText = fieldResult.getType() == Schema.DisplayType.TEXTAREA && fieldResult.isHtmlFormatted();
                    Label = fieldResult.getLabel();
                } catch (exception e) {

                }
            }
        }}
        public boolean editableField {get;set;}
    }
    
    public class AssignmentModel{
        public boolean isDisplayed {get; set;}
        public string soapHeaderName {get;set;}        
        public string label {get;set;}
        public string name {get;set;}
        public boolean defaultValue {get; set;}
    } 
}