({	getCustomSetting: function(component,event,helper){
        var getSettingsAction = component.get("c.getCustomSetting");
        
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                var customsetting = response.getReturnValue();
                component.set("v.customSetting", customsetting.iContract_URL__c);
            } 
        });
        $A.enqueueAction(getSettingsAction);
    	helper.getOpportunity(component,event,helper);
    },
  getOpportunity : function(component, event, helper) {
      var action = component.get("c.getOpportunityStageName");
      action.setParams({
          oppId : component.get('v.recordId')
      });
      action.setCallback(this, function(response){
          var state = response.getState();
          console.log('state: ',state);
          console.log('stage>>>',response.getReturnValue());
          if (state === "SUCCESS") {
              var StageName = response.getReturnValue();
              if(StageName == "Awareness"){
                  helper.showToast(component,event,"The Stage is past Awareness before using iContract");
              }else if(StageName == ''){
                  helper.showToast(component,event,"Please ensure that the Opportunity has products");
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
      })
      $A.enqueueAction(action);
  },
  showToast : function(component, event, message) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          "title": "Information !",
          "type" : 'info',
          "message": message
      });
      toastEvent.fire();
      var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();
  }
 })