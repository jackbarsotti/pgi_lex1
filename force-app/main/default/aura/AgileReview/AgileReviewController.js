({
    doInit : function(component, event, helper) {
        
        
    },
    openBacklog : function(component, event, helper) {
        component.set('v.isopenBacklog',true);
        component.set('v.isActiveSprint',false);
        component.set('v.isKanbanBoardView',false);
    },
    

    openActiveSprint : function(component, event, helper) {
        component.set('v.isActiveSprint',true);
        component.set('v.isopenBacklog',false);
        component.set('v.isKanbanBoardView',true);
    },

  /*  hideSideBar : function(component, event, helper) {
        var sideBar = component.find("sideBar"); 
        if(component.get("v.icon") == 'utility:chevronleft'){
            component.set("v.icon",'utility:chevronright');
            $A.util.addClass(sideBar , 'slds-hide');
            $A.util.removeClass(sideBar , 'slds-show');
        }
        else{
            component.set("v.icon",'utility:chevronleft');
            $A.util.addClass(sideBar , 'slds-show');
            $A.util.removeClass(sideBar , 'slds-hide');  
        }
        
    },  */
    
   collapseSidebar : function(component, event, helper) {

     //   document.getElementById("main").style.width = "250px";
      //  document.getElementById("secondid").style.width = "250px";
          var div1=document.getElementById("main");
          var div2=document.getElementById("sideBar");
       var mainDivStyle=div1.style.marginLeft;
         var sideBarDivStyle=div2.style.width;
     if(((mainDivStyle=='' || mainDivStyle=='-15px') && (sideBarDivStyle=='' || sideBarDivStyle=='250px')) && (component.get("v.icon") == 'utility:chevronleft')){
         component.set("v.icon",'utility:chevronright');
          div2.style.width="0px";
         
     }
        else{
            component.set("v.icon",'utility:chevronleft');
           //  doc1.style.marginLeft="-15px";
              div2.style.width="250px";
        }
  }
    

})