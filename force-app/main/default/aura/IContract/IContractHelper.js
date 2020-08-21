({	getCustomSetting: function(component,event,helper){
    var getSettingsAction = component.get("c.getCustomSetting");
    
    getSettingsAction.setCallback(this, function(response) {
        var title = '';
        var type = '' ;
        var message = '';
        if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
            var customsetting = response.getReturnValue();
            component.set("v.customSetting", customsetting.iContract_URL__c);
        } 
        else if (response.getState() === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    title = 'Error';
                    type = 'error';
                    message =  errors[0].message;
                    helper.showToast(component, event,title,type,message);
                }
            } else {
                title = 'Error';
                type = 'error';
                message = 'Unknown error';
                 helper.showToast(component, event,title,type,message);
            }
        }
    });
    $A.enqueueAction(getSettingsAction);
    helper.getOpportunity(component,event,helper);
},
  getOpportunity : function(component, event, helper) {
      var action = component.get("c.getOpportunityStageName");
      action.setParams({
          'oppId' : component.get('v.recordId')
      });
      action.setCallback(this, function(response){
          var state = response.getState();
          console.log('state: ',state);
          var title = '';
          var type = '' ;
          var message = '';
          console.log('stage>>>',response.getReturnValue());
          if (state === "SUCCESS") {
              var StageName = response.getReturnValue();
              if(StageName == "Awareness"){
                      title = 'Information';
                      type = 'info';
                      message =  "The Stage is past Awareness before using iContract";
                  helper.showToast(component, event,title,type,message);
              }else if(StageName == ''){
                     title = 'Information';
                      type = 'info';
                      message =  "Please ensure that the Opportunity has products";
                  helper.showToast(component, event,title,type,message);
              }else{
                  var urlEvent = $A.get("e.force:navigateToURL");
                  urlEvent.setParams({
                      "url": 'https://'+component.get('v.customSetting')+'/index.html?opp=' + component.get('v.recordId')
                  });
                  urlEvent.fire(); 
                  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                  dismissActionPanel.fire();
              }
          }
          else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      title = 'Error';
                      type = 'error';
                      message =  errors[0].message;
                      helper.showToast(component, event,title,type,message);
                  }
              } else {
                  title = 'Error';
                  type = 'error';
                  message = 'Unknown error';
                   helper.showToast(component, event,title,type,message);
              }
          }
      })
      $A.enqueueAction(action);
  },
  
  showToast : function(component, event,title,type,message) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          "title": title,
          "type" : type,
          "message": message
      });
      toastEvent.fire();
      var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();
  }
 })