trigger AddOneFreeQuantity on OrderItem (before insert) {
    for(OrderItem ordItem:Trigger.new){
        if(ordItem.Quantity>10){
            ordItem.UnitPrice = ((ordItem.UnitPrice*ordItem.Quantity)/(ordItem.Quantity+1)).setScale(2);
            ordItem.Quantity = ordItem.Quantity+1;
        }
    }
}