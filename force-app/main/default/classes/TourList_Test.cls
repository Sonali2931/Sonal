@isTest
public class TourList_Test {
    @isTest
    static void doTest(){
        
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        String RecTypeIdLo= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Tour Operations').getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Opportunity').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeID=RecTypeId;
        acc.FirstName='Test FName';
        acc.LastName='Test LName';
        acc.PersonHomePhone='12345678901';
        acc.Phone='12345678901'; 
        insert acc;
        
        Account accLocation = new Account();
        accLocation.RecordTypeID=RecTypeIdLo;
        accLocation.Name = 'Palm Springs - Desert Oasis';
        accLocation.LocationCode__c = '9999999999';
        accLocation.Timezone__c = 'Asia/Bangkok';
        insert accLocation;
            
        Contact conNew = new Contact();
        conNew.FirstName='test';
        conNew.LastName = 'test';
        conNew.Email = 'test@clouddee.th.com';
        conNew.Phone = '9743800309';
        conNew.flRotor__c =  'SalesLine';
        conNew.flLocation__c ='Palm Springs - Desert Oasis';
        insert conNew; 
        
        Opportunity oppNew = new Opportunity();
        oppNew.StageName = 'Assigned';
        oppNew.CloseDate = Date.today();
        oppNew.AccountId = acc.Id;
        oppNew.Name = 'Test Opportunity';
        oppNew.RecordTypeId = oppRecordTypeId;
        insert oppNew;
        
        Case caseNew = new Case();
        caseNew.RecordTypeId = caseRecordTypeId;   
        caseNew.SalesAgent__c=conNew.Id;
        caseNew.Status = 'Assigned';
        caseNew.TourType__c ='Day Drive';
        caseNew.Opportunity__c = oppNew.Id;
        caseNew.BookingAgent__c = conNew.Id;
        caseNew.TourLocation__c = accLocation.Id;
        caseNew.AccountId = acc.Id;
        caseNew.TourDate__c = Date.today();
        insert caseNew;
        
        Case caseNew2 = new Case();
        caseNew2.RecordTypeId = caseRecordTypeId;
        caseNew2.SalesAgent__c=conNew.Id;
        caseNew2.Status = 'On Tour';
        caseNew2.TourType__c ='Day Drive';
        caseNew2.Opportunity__c = oppNew.Id;
        caseNew2.BookingAgent__c = conNew.Id;
        caseNew2.TourLocation__c = accLocation.Id;
        caseNew2.AccountId = acc.Id;
        caseNew2.TourDate__c = Date.today();
        insert caseNew2;
        
        Case caseNew3 = new Case();
        caseNew3.RecordTypeId = caseRecordTypeId;   
        caseNew3.SalesAgent__c=conNew.Id;
        caseNew3.Status = 'NQed';
        caseNew3.TourType__c ='Day Drive';
        caseNew3.Opportunity__c = oppNew.Id;
        caseNew3.BookingAgent__c = conNew.Id;
        caseNew3.TourLocation__c = accLocation.Id;
        caseNew3.AccountId = acc.Id;
        caseNew3.TourDate__c = Date.today();
        caseNew3.ClosedLostReason__c = 'NQ- Age Under';
        insert caseNew3;
        
        Salesrotor__c sr = new Salesrotor__c();
        sr.Contact__c = conNew.Id;
        sr.Skill__c = 'First Generation';
        insert sr;
         
        Test.startTest();
        TourList tl = new TourList();
        
        TourList.getPicklistStatus();
        TourList.getPicklistClosedLostReason();
        TourList.getTabLists();
        TourList.oldPicklistStatus(caseNew2.id);
        TourList.updateCaseToNQed(caseNew3.Id,oppNew.Id,'NQ- Age Under','TestComment','AU',true);
        TourList.getTourDecisonWrapper(oppNew.Id);
        TourList.chkMacthPhone(new list<Account>{acc},acc.id);
        TourList.RemoveSalesAgent(caseNew.Id);
        TourList.tabOntourUpdateToursById(caseNew.Id,sr.Id);
        //
        string tabName; 
        string currentdate;
        string currentlocation;
        string rotortype; 
        string param;
        string searchText;
        
        tabName = 'Checked-In';
        rotortype = 'SalesLine';
        currentdate = string.valueofGmt(Date.today());
        currentlocation = 'Palm Springs - Desert Oasis';
        searchText = '';
        
        Date curDate = String.isEmpty(currentdate) ? Date.today() : Date.valueOf(currentdate);
        System.debug(curDate);
        
        String newRotorType = '';
        newRotorType = 'SalesOpportunity';      
        
        TourList.lookupToursStatus(tabName, currentdate, currentlocation, rotortype, param, searchText);
        searchText = 'Test';
        TourList.lookupToursStatus(tabName, currentdate, currentlocation, rotortype, param, searchText);
        searchText = '12';
        TourList.lookupToursStatus(tabName, currentdate, currentlocation, rotortype, param, searchText);
        
        tabName = 'On Tour';
        rotortype = 'SalesLine';
        searchText = 'Test';
        TourList.lookupToursStatus(tabName, currentdate, currentlocation, rotortype, param, searchText);
        
        tabName = 'Complete';
        rotortype = 'Auditions';
        searchText = '12';
        TourList.lookupToursStatus(tabName, currentdate, currentlocation, rotortype, param, searchText);
        
        TourList.updateBookedCheckedIn(caseNew.Id);
        TourList.updateCaseByStatus(caseNew2.Id, 'On Tour');
        TourList.updateCaseByStatusAndComment(caseNew.Id, 'NQed', 'Test', 'NQ- Age Under');
        TourList.UpdateToursById(caseNew.Id, sr.Id);
        
        Test.stopTest();
    }
}