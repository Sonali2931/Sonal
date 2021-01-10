public class CreateTourOnLeadController {
    
    public class premiumWrapper{
        public Integer quantity;
        public String product;
        public string productId;
        public string inventoryId;
        public string locationId;
    }
    
    @AuraEnabled
    public static string createTours(String listOfTourDetails,string leadId,string accId,string productId){
        ID recordID;
        ID prodId;
        Id gatewayId;
        try{
            gatewayId=[select Id from ChargentBase_Gateway__c where name='Stripe Test' limit 1].Id;
            system.debug('gatewayId----'+gatewayId);
            system.debug('hello1----'+listOfTourDetails);
            system.debug('hello2----'+leadId);
            system.debug('hello3----'+productId);
            system.debug(productId+'---hello4----'+accId);
            List<premiumWrapper> lstProducts = (List<premiumWrapper>)JSON.deserialize(productId, premiumWrapper[].class); //productId.split('},');
            system.debug('hello5----'+lstProducts);
            Integer a=lstProducts.size();
            system.debug('hello6----'+a);
            //  List<string> lstProducts= (List<String>)System.JSON.deserialize(productId, List<String>.class);
            //  system.debug('lstProducts'+lstProducts);
            string result;
            map<String, Object> mapOfTourObj= (Map<String, Object>)JSON.deserializeUntyped(listOfTourDetails);
            case cs = new case();
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
           // cs.Zip__c = mapOfTourObj.get('zip') != null ? string.valueOf(''+mapOfTourObj.get('zip')) : null;
            cs.Zip__c = String.valueOf(mapOfTourObj.get('zip'));
            cs.DepositAmount__c = mapOfTourObj.get('amount') != null && String.isNotBlank(''+mapOfTourObj.get('amount')) ? Decimal.valueOf(''+mapOfTourObj.get('amount')) : null;
            cs.TourDate__c = getDateValue(mapOfTourObj.get('tourDate'));
            system.debug('accomoMAP:::'+mapOfTourObj.get('accomodation'));
            string accomId = (ID) (mapOfTourObj.get('accomodation') != null ? ((map<string,Object>)mapOfTourObj.get('accomodation')).get('Id') : null);
            cs.Tour_Age_of_Children__c = String.valueOf(mapOfTourObj.get('tourage'));
            cs.Tour_No_of_Children__c = mapOfTourObj.get('noOfKids') != null ? Decimal.valueOf(''+mapOfTourObj.get('noOfKids')) : null;
            cs.Relationship_Status__c = String.valueOf(mapOfTourObj.get('relationshipStatus'));
            cs.Meets_Age_Minimum__c = String.valueOf(mapOfTourObj.get('meetsAgeMin'));
            cs.Meets_Income_Minimum__c = String.valueOf(mapOfTourObj.get('meetsIncomeMin'));
            cs.Owns_a_Credit_Card__c = String.valueOf(mapOfTourObj.get('ownsCreditCard'));
            cs.Lead__c = leadId;
            if(string.valueof(mapOfTourObj.get('campaign')) != ''){
            cs.Source_To_Campaign__c=(ID) (mapOfTourObj.get('campaign') != null ? ((map<string,Object>)mapOfTourObj.get('campaign')).get('Id') : null);
            }
            system.debug('tourwave.....'+mapOfTourObj.get('tourwave'));
            if(string.valueof(mapOfTourObj.get('tourwave')) != ''){
            cs.TourWave__c = (ID) (mapOfTourObj.get('tourwave') != null ? ((map<string,Object>)mapOfTourObj.get('tourwave')).get('Id') : null);
            }
            //added by Harshal
            if(gatewayId!=null){
                cs.Gateway__c= gatewayId;
            }
            insert cs;
            list<Premium__c> lstPremiumsToInsert = new list<Premium__c>();
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
          /*  if(String.isNotBlank(cs.Second_Guest_Last_Name__c) && String.isNotBlank(String.valueOf(mapOfTourObj.get('phone2'))) ){
                Lead guestLead = new Lead();
                guestLead.FirstName = cs.Second_Guest_First_Name__c;
                guestLead.LastName = cs.Second_Guest_Last_Name__c;
                guestLead.Phone = String.isNotBlank(String.valueOf(mapOfTourObj.get('phone2'))) ? String.valueOf(mapOfTourObj.get('phone2')) : String.valueOf(mapOfTourObj.get('phone'));   //'1231123132';
                guestLead.LeadType__c = 'Guest';
                insert guestLead;
                system.debug('guestLead'+guestLead);
            }
            system.debug('cs'+cs);
            */
            result=cs.Id;
            
            return result;
        }
        catch(exception e){
            system.debug('exception'+e.getMessage());
            system.debug('exceptionLine'+e.getLineNumber());
           throw new AuraHandledException('Failure, Error Occured While Processing Tour. \nEXCEPTION: '+e.getMessage());
          //  return null;
        }
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
    public static List<String> getRoomTypeOptions(){
        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = case.RoomType__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }/*comment*/
    
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
    @AuraEnabled
    public static Map<String, String> getLeadDetails(String leadId) {
        system.debug('leadId!!!'+leadId);
        Map<String, String> leadMap = new Map<String, String> ();
        for(Lead leadObj:[select id,name,Phone,Email,street,City__c,state,country,postalCode,RelationshipStatus__c 
                            from Lead where id=:leadId]){
            leadMap.put('name',leadObj.name); 
            leadMap.put('phone',leadObj.Phone);
            leadMap.put('email',leadObj.Email);
        }
        system.debug('leadMap'+leadMap);
        return leadMap;
    }
    
}