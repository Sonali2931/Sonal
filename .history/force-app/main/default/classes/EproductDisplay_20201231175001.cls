public with sharing class EproductDisplay {
    public EproductDisplay() {
        @AuraEnabled (cacheable=true)
    public static list<Product2> getproduct(){
        system.debug([select id,name from Product2 limit 1] +'*');
        return[select id,name from Product2 limit 10];
    }
}

    
