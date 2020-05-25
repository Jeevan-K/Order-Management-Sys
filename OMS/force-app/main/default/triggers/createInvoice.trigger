trigger createInvoice on Order (after update) {
         //Create new Invoice Record when order is confirmed and approved.
        for(Order ord:Trigger.new) {
        if(ord.Order_Confirmed__c==true && ord.Status == 'In Process'){
            try{
            Invoice__c inv = new Invoice__c(Order_Reference__c = ord.Id,Account_Reference__c = ord.AccountId);
            inv.Invoice_Quantity__c = ord.Order_Quantity__c;
            inv.Transactional_Net_Value__c = ord.TotalAmount;
        
            insert inv;
            }catch(DmlException e){
                ord.Status.addError('Error 1 while creating Invoice Object contact your admin'+e.getMessage());
            }
                
        }
       }
}