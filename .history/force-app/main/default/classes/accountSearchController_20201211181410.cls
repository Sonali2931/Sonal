public with sharing class AccountSearchController {
    public AccountSearchController() {
    }
    @AuraEnabled
    public static List <Account> getAccounts (string ActName){
    List<Account> accountList = new List<Account>();
        if(actName!=''){
            String AccountName = '%' + ActName + '%' ;
             accountList =[SELECT id,name from account where name like: accountName];
             return accountList;
        }
        return accountList;
         
    }
}
