trigger statusCannotChange2PreviousVal on Order (before update) {
	//Trigger.isInsert
	//Trigger.isUpdate
	//Trigger.isBefore
    for(Order ord:Trigger.new) {
        //Access the "old" record by its ID in Trigger.oldMapp
        Order oldOrd = Trigger.oldMap.get(ord.Id);
        
        //Trigger.new records are the "new" version
        String oldOrdStage = oldOrd.Status;
        String newOrdStage = ord.Status;
        
        //Create an array to find the status names
        String[] statusName = new String[]{'Created','Saved','In Process','Invoice Generated','Payment Received','Delivery in Plan','Delivered','Cancelled'};
        Integer oldOrdNo = statusName.indexOf(oldOrdStage);
        Integer newOrdNo = statusName.indexOf(newOrdStage);
        if(oldOrdNo > newOrdNo) {
            ord.Status.addError('Stage cannot be changed to Previous '+oldOrdNo+' New Stage '+newOrdNo);
        }
    }
}