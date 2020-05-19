({
    doInit:function(component, event, helper){
         var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "https://pgi--lex.my.salesforce.com/a0f/e?CF00Na000000AR5Dt=IST-074227&CF00Na000000AR5Dt_lkid=a0f29000002ngVb&retURL=%2Fa0f29000002ngVb&RecordType=0121B000001hgWr&ent=01Ia00000021fyK"
        });
        urlEvent.fire();
    },
    
  /*  handlerNavigate: function(component, event, helper) {
       
    } */


})