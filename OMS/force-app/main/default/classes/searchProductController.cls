public with sharing class searchProductController {

    @AuraEnabled(cacheable=true)
     public static List < sObject > fetchProduct(String searchKeyWord,String option) {
          String searchKey;
          List < sObject > returnList = new List < sObject > ();
         List < sObject > lstOfProduct;
         if(option=='1'){
             searchKey = '%'+ searchKeyWord + '%';
         lstOfProduct = [SELECT Pricebook2Id,Product2.Name,ProductCode,UnitPrice,Product2.Stock_Quantity__c,Product2.Brand__c 
                                           FROM PricebookEntry WHERE (Product2.Name LIKE:searchKey OR ProductCode LIKE:searchKey)
                                           AND Product2.Stock_Quantity__c>0 LIMIT 500];
         system.debug('Inside product name/code');
         }
         else if(option=='2'){
             searchKey = '%'+ searchKeyWord + '%';
         lstOfProduct = [SELECT Pricebook2Id,Product2.Name,ProductCode,UnitPrice,Product2.Stock_Quantity__c,Product2.Brand__c 
                                           FROM PricebookEntry WHERE Product2.Brand__c LIKE:searchKey LIMIT 500];
             system.debug('Inside brand');
         }
         else if(option=='3'){
             searchKey = searchKeyWord;
             Integer MRP = Integer.valueOf(searchKey);
         lstOfProduct = [SELECT Pricebook2Id,Product2.Name,ProductCode,UnitPrice,Product2.Stock_Quantity__c,Product2.Brand__c 
                                           FROM PricebookEntry WHERE UnitPrice =:MRP LIMIT 500];
             system.debug('Inside brand'+lstOfProduct[0]);
         }
        system.debug('Recieved list is '+lstOfProduct);
          for (Integer i=0;i<lstOfProduct.size();i++) {  
           returnList.add(lstOfProduct[i]);
              i=i+1;
          }
         system.debug(lstOfProduct.size());
         system.debug(returnList.size());
          return returnList;
     }
    
    @AuraEnabled(cacheable=true)
    public static ID getPriceBookEntryID(String prdctCode,Id ordId){
        List <Order> orderPrice = [SELECT Pricebook2Id FROM Order WHERE Id =:ordId];
        ID orderPriceId = orderPrice[0].Pricebook2Id;
        List <PricebookEntry> pricebookID = [SELECT Pricebook2Id,Id FROM PricebookEntry WHERE Pricebook2Id=:orderPriceId and Product2Id=: prdctCode];
  
        System.debug('ID is '+pricebookID[0].Pricebook2Id+' '+pricebookID);
        return pricebookID[0].Id;
    }
    
    @AuraEnabled()
    public static List<OrderItem> getRelatedOrderItem(Id ordId){
    
        List<OrderItem> li = [SELECT Order.OrderNumber,order.Order_Quantity__c,
                              Order.TotalAmount,Product2.Name,Product2.ProductCode,
                              Product2.Brand__c,Quantity,UnitPrice,
                              TotalPrice,orderId FROM orderItem WHERE orderId=:ordId];
        return li;
    }
    
    @AuraEnabled
    public static String confirmOrder(Id ordId) {
        List<Order> getOrder= [SELECT Order_Confirmed__c FROM Order WHERE Id=:ordId];
        System.debug('Before update '+getOrder);
        for(Integer i=0;i< getOrder.size();i++)
        {
            getOrder[i].Order_Confirmed__c = true;
        }
        try{
            update getOrder;
        }catch(DmlException e) {
        
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return e.getMessage();
        }
        getOrder= [SELECT Order_Confirmed__c,OrderNumber FROM Order WHERE Order_Confirmed__c=true];
        System.debug('After update '+getOrder);
        return 'Success';
    }
 
}