({
    doInit: function(component, event, helper) {
		// Find the component whose aura:id is "flowData"
        //var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        //flow.startFlow("Create_Contact");
        //component.get("v.falseValue")
        var gotID = component.get("v.recordId");
        component.set("v.editID",gotID);
        console.log("Record ID of edit is");
        console.log(gotID);
        if(gotID)
            component.set("v.cardTtl","Edit Record");
        
    },
    
    handleSuccess: function(component, event, helper) {
        var newOrder = event.getParams().response;
        var navId = newOrder.id;
        var tstMessage = "The Order has been created successfully.";
        console.log(navId);
            if(component.get("v.recordId")){
                tstMessage = "Changes saved";
            }
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"success",
                "title": "Saved",
                "mode":"pester",
                "message": tstMessage
            });
            toastEvent.fire();
            
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": navId 
            });
            navEvt.fire();
   
    },
    
    handleCancel : function(component,event,helper){
        var rcdID = component.get("v.editID");
 		
        //alert("inside cancel"+rcdID);
        
        if(component.get("v.editID")){
            //alert("inside if");
            var gotID = component.get("v.editID");
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId":gotID 
            });
            navEvt.fire();
        }
        else{
        var homeEvent = $A.get("e.force:navigateToObjectHome");
    homeEvent.setParams({
        "scope": "Order"
    });
    homeEvent.fire();
            }
    },
    
    handleError: function(component, event) {
        var errors = event.getParams();
        console.log("response 1", JSON.stringify(errors));
    }
})