({
    doInit: function(cmp, event, helper){
  		// let TeamMembers = cmp.get('v.TeamMemberRow');
        // console.log('v TeamMembers>>onload>>>> ',JSON.parse(JSON.stringify(TeamMembers)));
    },

    getAddedTeamMember: function(cmp, evt, helper){
    	var Id = evt.getParam("Id");
        // var fieldApi = evt.getParam("fieldApi");
        var ObjLabel = evt.getParam("ObjLabel");

        // console.log('Id>>>>>>>>>> ',Id);
        // console.log('fieldApi>>>>>>>>>> ',fieldApi);
        // console.log('ObjLabel>>>>>>>>>> ',ObjLabel);

        var objUser = {'Id':'',
                    'Name':''};
        objUser.Id = Id;
        objUser.Name = ObjLabel;

        cmp.set("v.TeamMemberRow.User__c",Id);
        cmp.set("v.TeamMemberRow.User__r",objUser);

        // console.log('v TeamMemberRow>>>>>> ',JSON.parse(JSON.stringify(cmp.get('v.TeamMemberRow'))));
    },

    clearRow : function(cmp, evt, helper){
        // Store removed Row MR record Id
        var getRemovedrecordId = cmp.getEvent("getRemovedTeamMember_evt");
        getRemovedrecordId.setParams({ "removedMemberId" : cmp.get("v.TeamMemberRow.Id")});
        getRemovedrecordId.fire();

        var index = cmp.get("v.rowIndex");
        let member = cmp.get('v.TeamMembers');
       	member.splice(index,1);
        cmp.set('v.TeamMembers',member);
            
    },
  
})