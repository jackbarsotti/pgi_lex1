@RestResource(urlMapping = '/Plan/*')
global with sharing class PlanRest {

  static Pkg packageRepo = new Pkg();

  //TODO: Method signature -> addPlan(String planJSON)
  @HttpPost
  global static void addPlan(String accountId, String packageName, String webFrequency, String webRate, String duration){
    try{
      Package__c p = packageRepo.findByName(packageName);      
      Integer durationDays = Integer.valueOf(duration);
      Date today = Date.today();
      Date endDate = null;

      //If the duration is < 1 then there is no end date for this plan, otherwise, add duration to today's date.
      if(durationDays==null || durationDays<1)
        endDate = null;    
      else
        endDate = today.addDays(durationDays);

      if(String.isBlank(webFrequency))
        webFrequency = null;

      if(String.isBlank(webRate))
        webRate = null;

      //Build Custom Schedules
      CustomSchedule customScheduleRepo = new CustomSchedule();
      customScheduleRepo.saveCustomSchedule('Audio - Standard', accountId, 'a1j38000003DIsv', 'Custom schedule based on Audio - Standard', true);
      customScheduleRepo.saveCustomSchedule('Web - Standard', accountId, 'a1j500000009OQl', 'Custom schedule based on Web - Standard', true);
      customScheduleRepo.saveCustomSchedule('Hosting - Standard', accountId, 'a1j500000009OQq', 'Custom schedule based on Hosting - Standard', true);

      //Build planProducts JSON
      String planProductsJSON = '{"products": [';      
      List<String> products = new List<String>();
      for(RT_Product__c product : p.RT_Products__r){
        Decimal recurringCharge = product.recurringCharge__c;
        String recurringChargeFrequency = product.recurringChargeFrequency__c;

        //TODO: Add other product types
        if(product.type__c == 'WEB') {
          //If a webRate was passed in, then convert it to a decimal, otherwise, use the product's recurring charge
          recurringCharge = webRate == null ? recurringCharge : Decimal.valueOf(webRate);

          //If a webFrequency was passed in, then use it, otherwise, use the product's recurring charge frequency
          recurringChargeFrequency = webFrequency == null ? recurringChargeFrequency : webFrequency;
        }

        String productJSON = '';
        productJSON += '{';
        productJSON += '"id":"'+product.id+'",';
        productJSON += '"productName":"'+product.name+'",';
        productJSON += '"schedule":"'+product.scheduleName__c+'",';
        productJSON += '"singleCharge":"",';
        productJSON += recurringCharge==null?'"recurringCharge":"",': '"recurringCharge":"'+recurringCharge+'",';
        productJSON += recurringChargeFrequency==null?'"recurringChargeFrequency":""': '"recurringChargeFrequency":"'+recurringChargeFrequency+'"';
        productJSON += '}';
        products.add(productJSON);
      }
      planProductsJSON += String.join(products, ',');
      planProductsJSON += ']}';

      boolean success = AddPlanController.addPlan(accountId, p.Id, p.Name, p.billableType__c, today.format(), endDate==null?null:endDate.format(), null, null, planProductsJSON);

      if(!success){
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error('Unknown error while adding plan.')})));      
      }
      else
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidResponse(new ValidResponse.Data(true))));
    }
    catch(Exception ex){
      //If the Plan already exists, then return true...hacky
      if(ex.getMessage().contains('Product names must be unique'))
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ValidResponse(new ValidResponse.Data(true))));
      else
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(new List<ErrorResponse.Error>{new ErrorResponse.Error(ex.getMessage())})));
    }
  }
}