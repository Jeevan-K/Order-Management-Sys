trigger EmailAlertForOrderStatus on Order (before update) {

    for(Order ord:Trigger.New)
    {
        List<Account> acc = [Select Email_Opt_Out__c from Account where Id=:ord.AccountId];
        System.debug('email'+acc);
        Order oldOrd = Trigger.oldMap.get(ord.Id);
        if(acc[0].Email_Opt_Out__c == false && (oldOrd.Status != ord.Status))
        {
            List<Contact> con = [Select Email from Contact where AccountId=:ord.AccountId and Email_Opt_Out__c=:false];
            System.debug('email'+con);
            List<OrderItem> li = [select Product2.Name,Product2.ProductCode,Product2.Brand__c,Quantity,UnitPrice,TotalPrice from orderitem where orderId=:ord.Id];
            String msgtb='\n Order Line Items are \n\n';
            String msghtml='<br> Order Line Items are <br><br>';
            for(OrderItem oi:li)
            {
                msgtb+='Product Name : '+oi.Product2.Name;
                msgtb+='\nProduct Code : '+oi.Product2.ProductCode;
                msgtb+='\nQuantity : '+oi.Quantity;
                msgtb+='\nUnitPrice : '+oi.UnitPrice;
                msgtb+='\nTotalPrice : '+oi.TotalPrice;
                msgtb+='\n-----*-------\n';
                
                msghtml+='Product Name : '+oi.Product2.Name;
                msghtml+='<br>Product Code : '+oi.Product2.ProductCode;
                msghtml+='<br>Quantity : '+oi.Quantity;
                msghtml+='<br>UnitPrice : '+oi.UnitPrice;
                msghtml+='<br>TotalPrice : '+oi.TotalPrice;
                msghtml+='<br>-----*-------<br>';
                
            }
            for(Contact c:con)
            {
                	
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    String emailAddr = c.Email;
                    String newStageName = ord.Status;
                	String mes = 'Order Number : '+ String.valueOf(ord.OrderNumber);

                    String[] toAddresses = new String[] {emailAddr};
                    mail.setToAddresses(toAddresses);
            		
                    mail.setSubject('Order Status Change');
            
                    mail.setPlainTextBody(mes+'\nOrder Status has Changed to : ' + ord.Status+''+msgtb);
                    mail.setHtmlBody(mes+'<br>Order Status has Changed to : ' + ord.Status+''+msghtml);
            
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }
        }
    }

    /*
    for(Order ord:Trigger.New)
    {
    List<Account> acc = [Select Email_Opt_Out__c from Account where Id=:ord.AccountId];
        System.debug('email'+acc);
        if(acc[0].Email_Opt_Out__c == false)
        {
            List<Contact> con = [Select Email,Name from Contact where AccountId=:ord.AccountId and Email_Opt_Out__c=:false];
            System.debug('email'+con);
            for(Contact c:con)
            {
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    String emailAddr = c.Email;
                    String newStageName = ord.Status;
                    String mes = 'Order Number : '+ String.valueOf(ord.OrderNumber);

                    String[] toAddresses = new String[] {emailAddr};
                    mail.setToAddresses(toAddresses);
                    
                    mail.setSubject('Order Status Change');
            
                    mail.setPlainTextBody(mes+'\nOrder Status has Changed to : ' + ord.Status);
                    mail.setHtmlBody(mes+'<br>Order Status has Changed to : ' + ord.Status);
            
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }
        }
    }
	*/
}