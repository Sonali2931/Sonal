//Created By : Sunil Korada
//This is implemented for Book A Tour from Account.
//Modified By : Dhananjay Darane
//Enhancement: Add the Source campaign to Account last campaign.
public class CreateTourOnAccountController {
     public class premiumWrapper{
        public Integer quantity;
        public String product;
        public string productId;
        public string inventoryId;
        public string locationId;
    }
    
    @AuraEnabled
    public static string createTours(String listOfTourDetails,string accountId,string accId,string productId){
        Id gatewayId;
        system.debug('listOfTourDetails'+listOfTourDetails);
        system.debug('accId'+accId);
         system.debug('accountId'+accountId);
         system.debug('productId'+productId);
        case cs = new case();
        List<premiumWrapper> lstProducts = (List<premiumWrapper>)JSON.deserialize(productId, premiumWrapper[].class); 
        system.debug('lstProducts'+lstProducts);
        map<String, Object> mapOfTourObj= (Map<String, Object>)JSON.deserializeUntyped(listOfTourDetails);
        Savepoint sp = Database.setSavepoint();
        try{
            GatewayId = [Select Id from ChargentBase__Gateway__c where name='Stripe Test' limit 1].Id;
            Opportunity opp = new Opportunity();
            opp.Name=String.valueOf(mapOfTourObj.get('fname')) +''+ String.valueOf(mapOfTourObj.get('lname'));
            opp.AccountId = accountId;
            opp.StageName='Open';
            opp.CloseDate=system.today();
            opp.TourLocation__c=accId;          
            if(string.valueof(mapOfTourObj.get('tourwave')) != ''){
            opp.TourWave__c=(ID) (mapOfTourObj.get('tourwave') != null ? ((map<string,Object>)mapOfTourObj.get('tourwave')).get('Id') : null);
            }
            opp.Tour_Date__c=getDateValue(mapOfTourObj.get('tourDate'));
            opp.TourDepositAmount__c = mapOfTourObj.get('amount') != null && String.isNotBlank(''+mapOfTourObj.get('amount')) ? Decimal.valueOf(''+mapOfTourObj.get('amount')) : null;
            opp.TourType__c=String.valueOf(mapOfTourObj.get('tourType'));
            Account acc = [Select id,SalesPriceBook__c from Account where id =: accId ];
            Account acc1 = [Select id,personcontactid,Relationship_Type__c from Account where id =: accountId ];
            opp.Pricebook2Id =acc.SalesPriceBook__c;
           
            insert opp;
            If(opp != null){
             opportunitycontactrole pcr = new opportunitycontactrole();
             pcr.contactid= acc1.PersonContactId;
             pcr.OpportunityId= opp.id;
            // pcr.Role = acc1.Relationship_Type__c;
             pcr.IsPrimary = True ;
             insert pcr;
            }
            cs.Payment_Method__c=String.valueOf(mapOfTourObj.get('ChargeType'));
            cs.TourType__c=String.valueOf(mapOfTourObj.get('tourType'));
            cs.TourLocation__c=accId;
            cs.Guest_First_Name__c = String.valueOf(mapOfTourObj.get('fname'));
            cs.Guest_last_Name__c=String.valueOf(mapOfTourObj.get('lname'));
            cs.Second_Guest_First_Name__c = String.valueOf(mapOfTourObj.get('gFname'));
            cs.Second_Guest_Last_Name__c=String.valueOf(mapOfTourObj.get('gLname'));
            cs.Additional_Guest__c = cs.Second_Guest_First_Name__c + ' ' + cs.Second_Guest_Last_Name__c;
            cs.Relationship__c=String.valueOf(mapOfTourObj.get('relation'));
            cs.SuppliedPhone=String.valueOf(mapOfTourObj.get('phone'));
            cs.SuppliedEmail=String.valueOf(mapOfTourObj.get('email'));
            cs.Status=String.valueOf(mapOfTourObj.get('tourStatus'));
            cs.City__c = String.valueOf(mapOfTourObj.get('city'));
            cs.Street_Address__c = String.valueOf(mapOfTourObj.get('street'));
            cs.State__c = String.valueOf(mapOfTourObj.get('state'));
           // cs.Zip__c = mapOfTourObj.get('zip') != null ? Decimal.valueOf(''+mapOfTourObj.get('zip')) : null;
            cs.Zip__c = String.valueOf(mapOfTourObj.get('zip'));
            cs.DepositAmount__c = mapOfTourObj.get('amount') != null && String.isNotBlank(''+mapOfTourObj.get('amount')) ? Decimal.valueOf(''+mapOfTourObj.get('amount')) : null;
            cs.TourDate__c = getDateValue(mapOfTourObj.get('tourDate'));
            cs.Tour_Age_of_Children__c = String.valueOf(mapOfTourObj.get('tourage'));
            cs.Tour_No_of_Children__c = mapOfTourObj.get('noOfKids') != null ? Decimal.valueOf(''+mapOfTourObj.get('noOfKids')) : null;
            cs.Relationship_Status__c = String.valueOf(mapOfTourObj.get('relationshipStatus'));
            cs.Meets_Age_Minimum__c = String.valueOf(mapOfTourObj.get('meetsAgeMin'));
            cs.Meets_Income_Minimum__c = String.valueOf(mapOfTourObj.get('meetsIncomeMin'));
            cs.Owns_a_Credit_Card__c = String.valueOf(mapOfTourObj.get('ownsCreditCard'));
            cs.AccountId = accountId;
            cs.ContactId = acc1.personcontactid;
            cs.Opportunity__c=opp.id;
            if(string.valueof(mapOfTourObj.get('campaign')) != ''){
            cs.Source_To_Campaign__c=(ID) (mapOfTourObj.get('campaign') != null ? ((map<string,Object>)mapOfTourObj.get('campaign')).get('Id') : null);
            acc1.Last_Campaign__c = cs.Source_To_Campaign__c ;
            update acc1;    
            }
            system.debug('accomoMAP:::'+mapOfTourObj.get('accomodation'));
            system.debug('mapOfTourObj.get'+mapOfTourObj.get('tourage'));
            string accomId = (ID) (mapOfTourObj.get('accomodation') != null ? ((map<string,Object>)mapOfTourObj.get('accomodation')).get('Id') : null);
           
            system.debug('tourwave.....'+mapOfTourObj.get('tourwave'));
            if(string.valueof(mapOfTourObj.get('tourwave')) != ''){
                cs.TourWave__c = (ID) (mapOfTourObj.get('tourwave') != null ? ((map<string,Object>)mapOfTourObj.get('tourwave')).get('Id') : null);
            }
            if(gatewayId!=null){
                cs.Gateway__c= gatewayId;
            }
            insert cs;
            system.debug('insertcs'+cs);
            cs.TourDate__c = getDateValue(mapOfTourObj.get('tourDate'));
            update cs;
            opp.Case__c = cs.id;
            opp.CloseDate = system.today() + 40;
            update opp;
           If(CS != null){
             case tempcase = [select id,BookingAgent__c from case where id =: cs.id];
                System.debug('tempcase'+tempcase.BookingAgent__c);
                WelkTeamMember__c w = new WelkTeamMember__c();
                    w.Contact__c =tempcase.BookingAgent__c;                
                    w.Opportunity__c =opp.id; 
                   // w.OwnerId =cs.OwnerId;                       
                    w.User__c = UserInfo.getUserId();
                    w.Role__c ='Booking Agent (solicitor)'; 
                Insert w;
                
            }
            system.debug('opppppp'+opp.Pricebook2Id);
           list<Premium__c> lstPremiumsToInsert = new list<Premium__c>();
            
           List<product2> depositpr =[select id,name from product2 where name ='Tour Deposit' limit 1];
           
            for(premiumWrapper prod : lstProducts){
                Premium__c pr = new Premium__c();
                pr.Product__c= prod.productId;
                pr.Quantity__c=prod.quantity;
                pr.Notes__c = prod.product;
                pr.Tour__c=cs.id;
                pr.ProductInventory__c = prod.inventoryId;
                pr.Tour_Location__c = cs.TourLocation__c;//prod.locationId;
                system.debug('pr'+pr);
                lstPremiumsToInsert.add(pr);
                
                
            }
            if(!lstPremiumsToInsert.isEmpty()){
                insert lstPremiumsToInsert;
                system.debug('lstPremiumsToInsert'+lstPremiumsToInsert);
            }
            if('Minivac'.equalsIgnoreCase(cs.TourType__c)){
                case accomationReqCase = new case();
                accomationReqCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Accommodation Request').getRecordTypeId();
                accomationReqCase.CheckInDate__c = getDateValue(mapOfTourObj.get('checkindate'));
                accomationReqCase.Guest_First_Name__c = cs.Guest_First_Name__c;
                accomationReqCase.Guest_last_Name__c = cs.Guest_last_Name__c;
                accomationReqCase.NumberOfAdults__c = mapOfTourObj.get('adults') != '' ? Decimal.valueOf(''+mapOfTourObj.get('adults')): null;
                accomationReqCase.NumberOfNights__c = mapOfTourObj.get('nights') != '' ? Decimal.valueOf(''+mapOfTourObj.get('nights')): null;
                accomationReqCase.NumberOfChildren__c = mapOfTourObj.get('children') != '' ? Decimal.valueOf(''+mapOfTourObj.get('children')): null;
                accomationReqCase.AgeOfEachChild__c = String.valueOf(mapOfTourObj.get('age'));
                accomationReqCase.RoomType__c=String.valueOf(mapOfTourObj.get('RoomType'));
                //accomationReqCase.TourLocation__c = accId;
                //accomationReqCase.Second_Guest_First_Name__c = cs.Second_Guest_First_Name__c;
                //accomationReqCase.Second_Guest_Last_Name__c = cs.Second_Guest_Last_Name__c;
               accomationReqCase.Accommodation__c = accomId;
                accomationReqCase.Tour__c = cs.Id;
               if(string.valueof(mapOfTourObj.get('campaign')) != ''){ 
               accomationReqCase.Source_To_Campaign__c = cs.Source_To_Campaign__c ;  
               }    
                insert accomationReqCase;
            }
            
           List <OpportunityLineItem> olilist = new  list<OpportunityLineItem>();
            
                
            if('Day Drive'.equalsIgnoreCase(cs.TourType__c) || 'Minivac'.equalsIgnoreCase(cs.TourType__c)){
             OpportunityLineItem opplineitem1 = New OpportunityLineItem();
            //opplineitem1.Cost__c =cs.DepositAmount__c;
            opplineitem1.UnitPrice=cs.DepositAmount__c;      
            opplineitem1.Product2Id=depositpr[0].id;
            opplineitem1.OpportunityId=opp.id;
            opplineitem1.Quantity= 1;
            opplineitem1.Transaction_Type__c='Deposit';
            opplineitem1.PremiumStatus__c = 'N/A';    
            olilist.add(opplineitem1) ;  
            }
            
            insert olilist;
            
            
            
            system.debug('csupdate'+cs);
            return cs.id;
        }
        catch(exception ex){
            Database.rollback(sp);
        }
        
        return cs.id;     
    }
    private static Date getDateValue(Object strDate){
        if(strDate != null && String.isNotBlank(''+strDate)){
            try{
                return Date.valueof(''+strDate);
            }catch(Exception ex){
                system.debug('Date conversion exception::'+ex);
            }
        }
        return null;
    }
      @AuraEnabled
    public static List<String> getTypeOptions(){
        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = case.TourType__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> getChargeTypeOptions(){
        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = case.Payment_Method__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getStatusOptions(){
        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = case.status.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> getRoomTypeOptions(){
        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = case.RoomType__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String objectName) {
        String fieldsToReturn = 'Name,Id';
        return CreateTourOnLeadController.fetchExtendedLookUpValues(searchKeyWord, objectName, fieldsToReturn);
    }
    
    @AuraEnabled
    public static List<sObject> fetchExtendedLookUpValues(String searchKeyWord, String objectName,String fieldsToQuery) {
        return CreateTourOnLeadController.fetchFilterredLookUpValues(searchKeyWord, objectName, fieldsToQuery,'');
    }
    @AuraEnabled
    public static List<sObject> fetchFilterredLookUpValues(String searchKeyWord, String objectName,String fieldsToQuery,String filter) {    
        String realObjectName = String.escapeSingleQuotes(objectName);
        String realFieldsToQuery = String.escapeSingleQuotes(fieldsToQuery);
        String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List <sObject>();
        system.debug('----realObjectName'+realObjectName);
        system.debug('----realFieldsToQuery'+realFieldsToQuery);
        system.debug('----searchKey'+searchKey);
        system.debug('filterssss'+filter);
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery = 'select '+  realFieldsToQuery +' from ' + realObjectName + ' where Name LIKE :searchKey '+
                        (String.isNotBlank(filter) ? 'AND '+ filter : '') +' order by createdDate DESC limit 10';
        
        system.debug('----sQuery:: '+sQuery);
        try {
            List <sObject> lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            system.debug('----returnlist'+returnList);
        } catch (Exception e) {
            throw new AuraHandledException('That didn\'n work:'+sQuery+'\n'+e.getMessage());
        }
        return returnList;
    }
}