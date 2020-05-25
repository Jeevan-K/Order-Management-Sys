trigger createProductInvoice on Invoice__c (before insert,after insert,before update) {
        
    if(Trigger.isInsert){
    for(Invoice__c inv:Trigger.New){
        //prvent delivery status from changing back to previous stage/value
            
        List<OrderItem> itemList = [SELECT Id,UnitPrice,Product2.ProductCode,Product2.Name,Quantity FROM OrderItem WHERE OrderId=:inv.Order_Reference__c];
        List<Product_Invoice__c> prdct = new List<Product_Invoice__c>();
        Decimal disc = 0;
        Integer qty = 0;
        for(OrderItem oi:itemList){
            Product_Invoice__c pi = new Product_Invoice__c(
                Order_Line_Invoice_Number__c = oi.Id, Unit_Price__c = oi.UnitPrice,
                Product_Code__c = oi.Product2.ProductCode, Product__c = oi.Product2.Name,
                Invoice_Quantity__c = oi.Quantity );
            if(oi.Quantity>10){
                pi.Invoice_Quantity__c = oi.Quantity+1;
                pi.Price_Discount__c = oi.UnitPrice;
                disc = disc+pi.Price_Discount__c;
                qty = qty+1;
            }
            prdct.add(pi);
        }
        if(Trigger.isBefore){
        try{
            insert prdct;
            Order ord = [SELECT Id,Status FROM Order WHERE Id=:inv.Order_Reference__c];
            ord.Status = 'Invoice Generated';
            update ord;
        }catch(DmlException e){
            inv.addError('Error while updating status '+e.getMessage());
        }
        }
        if(Trigger.isAfter){
            List<Invoice__c> updInv = [ SELECT Price_Discount__c,Invoice_Quantity__c FROM Invoice__c WHERE Id=:inv.Id ];
            updInv[0].Price_Discount__c = disc;
            updInv[0].Invoice_Quantity__c = updInv[0].Invoice_Quantity__c + qty;
            update updInv;
        }
    }
    }
    else if(Trigger.isUpdate){
        for(Invoice__c inv:Trigger.New){
        //prvent delivery status from changing back to previous stage/value
        Invoice__c oldInv = Trigger.oldMap.get(inv.Id);
        String oldDlvry = oldInv.Delivery_Status__c;
        String newDlvry = inv.Delivery_Status__c;
        String[] statusName = new String[]{'Delivery in Plan','Delivered','Cancelled'};
            if(statusName.indexOf(oldDlvry) > statusName.indexOf(newDlvry)){
                inv.Delivery_Status__c.addError('Delivery Status cannot be changed back to previous stage');
            }   
        }
    }

}