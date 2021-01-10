public with sharing class AccountSearchController {
    public AccountSearchController() {
    }
    @AuraEnabled(chacheble = true)
    public static List <Account> getAccounts(string actName){
    List<Account> accountList = new List<Account>();
        if(actName!=''){
            String AccountName = '%' + actName + '%' ;
             accountList =[SELECT id,name from account where name like: accountName];
             return accountList;
        }
        return accountList;
         
    }
}
