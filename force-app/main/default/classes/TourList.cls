public with sharing class  TourList {
    @AuraEnabled(cacheable=true) 
    public static String oldPicklistStatus(id caseid) {  
     case ca=[select Status from case where id=:caseid];
      return ca.Status;
    }      
    @AuraEnabled(cacheable=true)
    public static List<optionWrapper> getPicklistStatus() {     
        List<optionWrapper> options = new List<optionWrapper>();
        Schema.DescribeFieldResult fieldResult = case.status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> labelList = new List<String>();
        for( Schema.PicklistEntry f : ple)
        {
            labelList.add(f.getLabel());
        }
        labelList.sort();

        for(String label : labelList){
            for( Schema.PicklistEntry ff : ple)
            {
                if (label == ff.getLabel()) options.add(new optionWrapper(ff.getLabel(), ff.getValue()));
            }
        }
        System.debug(options);
                
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<optionWrapper> getPicklistClosedLostReason() {     
        List<optionWrapper> options = new List<optionWrapper>();
        Schema.DescribeFieldResult fieldResult = case.ClosedLostReason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> labelList = new List<String>();
        for( Schema.PicklistEntry f : ple)
        {
            labelList.add(f.getLabel());
        }
        labelList.sort();

        for(String label : labelList){
            for( Schema.PicklistEntry ff : ple)
            {
                if (label == ff.getLabel()) options.add(new optionWrapper(ff.getLabel(), ff.getValue()));
            }
        }
             
        System.debug(options);
                
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static TourDecisionWrapper getTourDecisonWrapper(String oppId) {
        List<optionWrapper> tourDecisionList = new List<optionWrapper>();

        for( Schema.PicklistEntry tdOption : Case.Tour_Decision__c.getDescribe().getPicklistValues()) {
            tourDecisionList.add(new optionWrapper(tdOption.getLabel(), tdOption.getValue()));
        }

        Boolean courtesyTour = [SELECT CourtesyTour__c FROM Opportunity WHERE Id = :oppId LIMIT 1].CourtesyTour__c;

        return new TourDecisionWrapper(tourDecisionList, courtesyTour);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FloorManagerListView__mdt> getTabLists() {
        
        FloorManagerListView__mdt[] listViewList = [SELECT id,MasterLabel,DeveloperName, Order__c FROM FloorManagerListView__mdt ORDER BY Order__c ASC];
        
        return listViewList;
    }

    // for tab Checked-In ,On Tour, Complete
    @AuraEnabled(cacheable=true)
    public static dataTableWrapper lookupToursStatus(string tabName, string currentdate,string currentlocation, string rotortype, string param, string searchText) {
        System.debug('tabName = ' + tabName);
        System.debug('currentdate = ' + currentdate);
        System.debug('currentlocation = ' + currentlocation);
        System.debug('rotortype = ' + rotortype);
        System.debug('searchText = ' + searchText);

        dataTableWrapper dw = new dataTableWrapper();
        
        String[] statusList = new String[]{};
        String[] statusCheckedIn = new String[]{'Assigned', 'Booked - Checked In'};
        String[] statusOntour = new String[]{'On Tour'};
        String[] statusComplete = new String[]{'NQed','Booked - No Show','Sale','No Sale'};

        if (tabName == 'Checked-In') {
            dw.columns = DataTableWithMdt.getColumnSettingMdt('Checked_In');
            statusList = statusCheckedIn;
        }
        else if (tabName == 'On Tour') 
        {
            dw.columns = DataTableWithMdt.getColumnSettingMdt('On_tour');
            statusList = statusOntour;
        }
        else if (tabName == 'Complete') 
        {
            dw.columns = DataTableWithMdt.getColumnSettingMdt('Completed');
            statusList = statusComplete;
        }
        
        String newRotorType = '';
        if (rotortype == 'Auditions') newRotorType = 'Auditions';
        else if (rotortype == 'SalesLine') newRotorType = 'SalesOpportunity';

        Date curDate = String.isEmpty(currentdate) ? Date.today() : Date.valueOf(currentdate);
        System.debug(curDate);
        System.debug('---------------');
        System.debug(statusList);
        System.debug(curDate);
        System.debug(currentlocation);
        System.debug(newRotorType);
        System.debug('---------------');
        List<case> listCases = [select Id,AccountId, ContactId, 
                                Opportunity__c, Opportunity__r.Name, Opportunity__r.RecordTypeId,
                                Account.Phone, Account.Name, Account.FirstName, Account.LastName, 
                                CaseNumber,TourType__c,CheckInDate__c,TourLocation__c, Notes__c ,Locator__c ,
                                TourWave__r.TourTime__c,ML_Tour_Result__c ,On_Tour_Time__c ,BookingDepartment__c ,Time_Stamp1__c , BookingAgent__r.Name, SalesAgent__r.Name , toLabel(Status)
                                from  Case 
                                where status in : statusList
                                and TourDate__c >=: curDate and TourDate__c <=: curDate
                                and LocationName__c =: currentlocation 
                                //and RecordTypeName__c = 'Tour_Operations'
                                and Opportunity__r.RecordTypeName__c =: newRotorType
                                Order by CaseNumber LIMIT 500];


        boolean isFindPhone = false;
        List<Account> listPhonesInAcc = null;
        if (!String.isBlank(searchText) && searchText.length() >= 2)
        {
            isFindPhone = true;
            String q = 'FIND {' + searchText + '*} IN Phone FIELDS RETURNING Account(Id, Name, Phone, PersonMobilePhone)';
            List<List<sObject>> c  = search.query(q);

            for (List<sObject> cc : c)
            {
                listPhonesInAcc = (List<Account>)cc;
                System.debug(listPhonesInAcc);
            }
            listPhonesInAcc.sort();
        }
        
        List<caseWrapper> listTours = new List<caseWrapper>();
        System.debug('List of Case = ' + listCases);
        for(case c : listCases)
        { 
            caseWrapper cw = new caseWrapper();
            cw.Id = c.Id;
            cw.AccountId = c.AccountId;
            String firstName = c.Account.FirstName != null ? c.Account.FirstName : '';
            String lastName = c.Account.LastName != null ? c.Account.LastName : '';
            cw.AccountName = lastName + ' ' + firstName;
            cw.AccountNameUrl = c.AccountId != null ? '/' + c.AccountId : '';
            cw.CaseNumber = c.CaseNumber;
            cw.CaseNumberUrl =  c.Id != null ? '/' + c.Id : '';
            cw.OpportunityId = c.Opportunity__c != null ? c.Opportunity__c : '';
            cw.OpportunityName = c.Opportunity__c != null ? c.Opportunity__r.Name : '';
            cw.OpportunityNameUrl = c.Opportunity__c != null ? '/' + c.Opportunity__c : '';
            cw.OppRecordTypeId = c.Opportunity__r.RecordTypeId != null ? c.Opportunity__r.RecordTypeId :'';
            cw.WaveTime = c.TourWave__r.TourTime__c != null ? c.TourWave__r.TourTime__c : '';
            cw.TourType = c.TourType__c;
            cw.Locator = c.Locator__C;
            cw.Notes = c.Notes__C;
            cw.MLTourResult = c.ML_Tour_Result__c;
            cw.BookingDepartment= c.BookingDepartment__c;
            cw.TimeStamp= string.valueOf(c.Time_Stamp1__c);
            cw.TourStartTime = string.valueOf(c.On_Tour_Time__c);
            cw.TourLocationId = c.TourLocation__c != null ? c.TourLocation__c : '';
            cw.CheckInTime = '';
            
          //  cw.BookingAgentName = c.BookingAgent__r.Name;
            cw.BookingAgentName = c.SalesAgent__r.Name;
            cw.Status = c.Status;
            
            if (!String.isBlank(searchText))
            {
                String fullname = lastName + ' ' + firstName;
                if ((c.Account.Name != null && fullname.toLowerCase().contains(searchText)))
                    listTours.add(cw);

                if (isFindPhone && (chkMacthPhone(listPhonesInAcc, c.AccountId)))
                {
                    listTours.add(cw);
                }    
            }
            else
            {
                listTours.add(cw);
            }
            
        }
        
        dw.data = listTours;
        return dw;
    }

    public static boolean chkMacthPhone(List<Account> compareList, String idStr)
    {
        boolean chk = false;
        for(Account acc : compareList){ 
            if(acc.Id == idStr){ 
                chk = true;
                break; 
            } 
        }

        return chk;
    }
    
    @AuraEnabled
    public static void updateBookedCheckedIn(string caseid){
        System.debug('caseid -' + caseid);
        List<string> idStr;                    
        idStr = caseid.split(',');
        
        RecordType rt = [select Id, Name from RecordType where name = 'Tour Operations' and SobjectType = 'Case' limit 1];
        
        List<case> listcase  = new List<case>();
        for(String cid: idStr){
            case ca = new case();
            ca.id = cid;
            ca.Status = 'Booked - Checked In';
            ca.RecordTypeId = rt.Id;
          //  ca.BookingAgent__c = null;
            listcase.add(ca);
        }
        update listcase;
    }
    
    @AuraEnabled
    public static void updateCaseByStatus(string caseId, string status){
        System.debug('caseId -' + caseId);
        System.debug('status -' + status);
              
        RecordType rt1 = [select Id, Name from RecordType where name = 'Tour Booking' and SobjectType = 'Case' limit 1];
        RecordType rt2 = [select Id, Name from RecordType where name = 'Tour Operations' and SobjectType = 'Case' limit 1];
        case ca = [select id, status,SalesAgent__c, BookingAgent__c,RecordTypeId , RecordType.Name,Opportunity__r.RecordType.Name from case where id =: caseId];
		SalesRotor__c Slr;
        if(ca.SalesAgent__c != null){
        Slr =[Select Id,Status__c,Contact__c from Salesrotor__c where contact__c =:ca.SalesAgent__c];
        }   
        system.debug('sales rotor'+Slr);
        if(status == 'On Tour'){
        Slr.Status__c='On Tour';
        update Slr;    
        }
        
        if (ca != null)
        {            
            if (ca.RecordType.Name == 'Tour Booking')
            {
                if(status == 'Booked - Checked In') ca.RecordTypeId = rt2.Id;
                if(status == 'Assigned') ca.RecordTypeId = rt2.Id;
                if(status == 'On Tour') ca.RecordTypeId = rt2.Id;
                if(status == 'Sale') ca.RecordTypeId = rt2.Id;
                if(status == 'No Sale') ca.RecordTypeId = rt2.Id;
                if(status == 'Closed_Lost') ca.RecordTypeId = rt2.Id;
                
            }
            else if (ca.RecordType.Name == 'Tour Operations')
            {
                 if(status == 'Booked - Dated') ca.RecordTypeId = rt1.Id;
                 if(status == 'Booked - Confirmed') ca.RecordTypeId = rt1.Id;
            }
            
            ca.Status = status;
            if(status=='NQed'){
              ca.ML_Tour_Result__c=ca.ClosedLostReason__c ; 
          }
            if(status=='No Sale'	){
                if (ca.Opportunity__r.RecordType.Name != 'Auditions'){  
                    ca.ML_Tour_Result__c='No Sale' ; }
             if(ca.SalesAgent__c != null){
                 Slr.Status__c='Available';
                 ca.SalesAgent__c=null;
                 update Slr;
             }
          }
            if(status=='Sale'	){
                if (ca.Opportunity__r.RecordType.Name != 'Auditions'){  
                    ca.ML_Tour_Result__c='Sale' ; }
             if(ca.SalesAgent__c != null){
                 Slr.Status__c='Unavailable';
                 ca.SalesAgent__c=null;
                 update Slr;
             }
          }
            if(status == 'Assigned' && Slr.Status__c == 'On Tour' ){
                ca.status = status;
                Slr.Status__c = 'Assigned';
                update Slr;
            }

            update ca;           
        }
    }

    private static final String DECISION_MAINLINE = 'Mainline';
    private static final String DECISION_AU = 'AU';
    private static final String DECISION_NO_TOUR = 'No Tour';
    private static final String NO_SALE = 'No Sale';
    private static final String STATUS_NQED = 'NQed';
    private static final String STATUS_CHK = 'Booked - Checked In';

    @AuraEnabled
    public static void updateCaseToNQed(String caseId, String oppId, String nqedReason, String comments, String tourDecision, Boolean courtesyTour){
        System.debug('caseId : ' + caseId);
        System.debug('oppId : ' + oppId);
        Case tourCase = [SELECT Id,Opportunity__r.RecordTypeId, Comments,SalesAgent__c, Status, ClosedLostReason__c, ML_Tour_Result__c, Tour_Decision__c 
                         FROM Case 
                         WHERE Id = :caseId
                         LIMIT 1];
        SalesRotor__c Slr;
        if(tourCase.SalesAgent__c != null){
        Slr =[Select Id,Status__c,Contact__c from Salesrotor__c where contact__c =:tourCase.SalesAgent__c];
        }   
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Auditions').getRecordTypeId();
        Opportunity tourOpp = new Opportunity(Id = Id.valueOf(oppId));
            tourOpp.CourtesyTour__c = courtesyTour;
        	
       		tourCase.Comments = comments;
        	tourCase.Tour_Decision__c = tourDecision;	
        	//tourCase.ML_Tour_Result__c = nqedReason;
			tourCase.ClosedLostReason__c = nqedReason;
        if(oppRecordTypeId == tourcase.Opportunity__r.RecordTypeId){
            
              tourCase.Status = STATUS_NQED;
                          
        if(tourCase.SalesAgent__c != null){
                 Slr.Status__c='Available';
                 tourCase.SalesAgent__c=null;
                 update Slr;
             }
        }else {
            tourCase.ML_Tour_Result__c = nqedReason;
        }
         
        if(tourDecision.equals(DECISION_MAINLINE)){
            tourCase.Status = tourCase.Status;
        }
        else if(tourDecision.equals(DECISION_AU)) {
            // Change rotor type from Mainline to Auditions -- can't find any relation b/w Case & Sales Rotor
            tourOpp.RecordTypeId = oppRecordTypeId; 
            tourCase.Status = STATUS_CHK;
            if(tourCase.SalesAgent__c != null){
                 Slr.Status__c='Available';
                 tourCase.SalesAgent__c=null;
                 update Slr;
             }
        }else if(tourDecision.equals(DECISION_NO_TOUR)) {
            tourCase.Status = NO_SALE;
            tourCase.ClosedLostReason__c = nqedReason;
            tourOpp.StageName = 'Closed Lost';
            if(tourCase.SalesAgent__c != null){
                 Slr.Status__c='Available';
                 tourCase.SalesAgent__c=null;
                 update Slr;
             }
        }
        update tourOpp;
        update tourCase;
    }
       
    @AuraEnabled
    public static void updateCaseByStatusAndComment(string caseId, string status, string comment, string closedlostreason){
        System.debug('caseId -' + caseId);
        System.debug('status -' + status);
        System.debug('comment -' + comment);
        
        case ca = [select id,SalesAgent__c, Comments,ClosedLostReason__c, status from case where id =: caseId];

        if (ca != null) {
            ca.Comments = comment;
            ca.ClosedLostReason__c = closedlostreason;
            ca.Status = status;
            
            if(status == 'NQed') {
                ca.ML_Tour_Result__c = ca.ClosedLostReason__c ;
            }
        }

        update ca;
    }
    
    @AuraEnabled
    public static void UpdateToursById(string caseid,string salesid){
        Case b = [SELECT  Id,CaseNumber,BookingAgent__c,SalesAgent__c,Status  from  Case  where Id = :caseid];
        system.debug('case agent***'+b.BookingAgent__c);
    
         if(string.isNotBlank(b.SalesAgent__c)) {
        
           SalesRotor__c oldc=[Select Id,Contact__c from Salesrotor__c where contact__c=:b.SalesAgent__c];
            oldc.Status__c='Available';
            
            SalesRotor__c c = [Select Id,Contact__c from Salesrotor__c where Id = :salesid];
            Contact d = [Select Id from Contact where Id = :c.Contact__c];
        
            if(d.id != null){
                b.SalesAgent__c = d.Id;  
             }
           
            b.ContactId =  d.Id;
            if(b.Status == 'Assigned'){ 
            b.Status ='Assigned';
            c.Status__c = 'Assigned';
             } 
          if(b.Status == 'On Tour'){ 
            b.Status ='On Tour';
            c.Status__c = 'On Tour';
             }    
            update b;
            List<SalesRotor__c> lstRotar=new List<SalesRotor__c>();
            lstRotar.add(oldc);
            lstRotar.add(c);
            
            update lstRotar;
        }
        else{
            SalesRotor__c c = [Select Id,Contact__c from Salesrotor__c where Id = :salesid];
            Contact d = [Select Id from Contact where Id = :c.Contact__c];
          //  b.BookingAgent__c = d.Id;
           if(d.id != null){
               b.SalesAgent__c = d.Id;  
            }
            b.ContactId =  d.Id;
            b.Status ='Assigned';
            c.Status__c = 'Assigned';
            update b;
            update c;
        }

    }

    @AuraEnabled
    public static void RemoveSalesAgent(string caseid){
        Case b = [SELECT  Id,CaseNumber,BookingAgent__c,SalesAgent__c,SalesAgent__r.id,Status  from  Case  where Id = :caseid];
        SalesRotor__c srr = [Select Id,Contact__c,group__c from Salesrotor__c where contact__c=:b.SalesAgent__c];
        system.debug('case agent***'+b.BookingAgent__c);
        system.debug('b***'+b);
            b.SalesAgent__c = null;  
            b.Status ='Booked - Checked In';
            update b;
        if(srr.group__c != true){
                 srr.Status__c = 'Available'; 
        }
        List<SalesRotor__c> lstRotarremove = new List<SalesRotor__c>();
            lstRotarremove.add(srr);
           // lstRotar.add(c);
           update lstRotarremove;
    }
    @AuraEnabled
    public static void tabOntourUpdateToursById(string caseid,string salesid){
        Case b = [SELECT  Id,CaseNumber,BookingAgent__c,SalesAgent__c,Status  from  Case  where Id = :caseid];
        system.debug('Bookong Agent*****' +b.BookingAgent__c);
        system.debug('Bookong Agent*****' +b.SalesAgent__c);
        
        if(string.isNotBlank(b.SalesAgent__c)) {
        
           SalesRotor__c oldc=[Select Id,Contact__c from Salesrotor__c where contact__c=:b.SalesAgent__c];
            oldc.Status__c='Available';
            
            SalesRotor__c c = [Select Id,Contact__c from Salesrotor__c where Id = :salesid];
            Contact d = [Select Id from Contact where Id = :c.Contact__c];
        
       
      // b.BookingAgent__c = d.Id;
      if(d.id != null){
               b.SalesAgent__c = d.Id;  
            } 
        b.ContactId =  d.Id;
        if(b.Status == 'Assigned'){
        c.Status__c = 'Assigned';
        } 
        if(b.Status == 'On Tour'){
        c.Status__c = 'On Tour';
        }   
        update b;            
        update c;
       List<SalesRotor__c> lstRotar=new List<SalesRotor__c>(); 
       lstRotar.add(oldc); 
       update lstRotar;     

    }
 }  
    public class dataTableWrapper
    {
        @AuraEnabled
        public List<Object> columns {get;set;}
        @AuraEnabled
        public List<caseWrapper> data {get;set;}
    }
    
    public class caseWrapper
    {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String AccountId {get;set;}
        @AuraEnabled
        public String AccountName {get;set;}
        @AuraEnabled
        public String AccountNameUrl {get;set;}
        @AuraEnabled
        public String CaseNumber {get;set;}
        @AuraEnabled
        public String CaseNumberUrl {get;set;}
        @AuraEnabled
        public String OpportunityId {get;set;}
        @AuraEnabled
        public String OpportunityName {get;set;}
        @AuraEnabled
        public String OpportunityNameUrl {get;set;}
        @AuraEnabled
        public String OppRecordTypeId {get;set;}
        @AuraEnabled
        public String WaveTime {get;set;}
        @AuraEnabled
        public String TourType {get;set;}
        @AuraEnabled
        public String TourLocationId {get;set;}
        @AuraEnabled
        public String CheckInTime {get;set;}
        @AuraEnabled
        public String BookingAgentName {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String Locator {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public String MLTourResult {get;set;}
		@AuraEnabled
        public String TimeStamp {get;set;}
		@AuraEnabled
        public String BookingDepartment {get;set;}  
        @AuraEnabled
        public String TourStartTime {get;set;} 
    }
    
    public class optionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        
        public optionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    public class TourDecisionWrapper {
        @AuraEnabled
        public List<optionWrapper> tourDecisionList {get; private set;}
        @AuraEnabled
        public Boolean courtesyTour {get; private set;}

        public TourDecisionWrapper(List<optionWrapper> tourDecisionList, Boolean courtesyTour) {
            this.tourDecisionList = tourDecisionList;
            this.courtesyTour = courtesyTour;
        }
    }
}