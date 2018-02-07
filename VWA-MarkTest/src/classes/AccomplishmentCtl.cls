public with sharing class AccomplishmentCtl {
    public AccomplishmentCtl(ApexPages.StandardController stdController) {
        this.volunteerJob = (GW_Volunteers__Volunteer_Job__c)stdController.getRecord();
    }
	public List<Accomplishment__c> accomplishmentList;
	GW_Volunteers__Volunteer_Job__c volunteerJob;
    public Id jobId;
    public List<AcDisplay> displayList;
    Map<String, Accomplishment__c> acMap = new Map<String, Accomplishment__c>();
    
    public List<Accomplishment__c> getAccomplishmentList() {
    	if(accomplishmentList == null) {
    		jobId = volunteerJob.Id;
    		accomplishmentList = [
    			SELECT Id, Type__c, Amount__c 
    			FROM Accomplishment__c
    			WHERE Volunteer_Job__c = :jobId
    		];
    	}
    	System.debug('accomplishmentList: ' + accomplishmentList);
    	return accomplishmentList;
    }

    public List<AcDisplay> getDisplayList() {
    	if(displayList == null) {
    		displayList = createAcDisplayList();
    	}
    	return displayList;
    }

    public Class AcDisplay {
    	public Integer recNo {get; set;}
    	public String id {get; set;}
    	public String acType {get; set;}
    	public Decimal amount {get; set;}
    }

    public List<AcDisplay> createAcDisplayList() {
    	Schema.DescribeFieldResult fieldResult = Accomplishment__c.Type__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	for(Schema.PicklistEntry entry : ple) {
   			acMap.put(entry.getValue(), new Accomplishment__c(Type__c = entry.getValue(), Amount__c=0));
    	}

    	for(Accomplishment__c acmp : getAccomplishmentList()) {
    		Accomplishment__c mapped = acMap.get(acmp.Type__c);
    		mapped.Id = acmp.Id;
    		mapped.Amount__c = acmp.Amount__c;
    	}
    	
    	Integer recNo = 0;
    	displayList = new List<AcDisplay>();
    	for(String tp : acMap.keySet()) {
    		Accomplishment__c acmp = acMap.get(tp);
    		AcDisplay acDisp = new AcDisplay();
    		acDisp.id = acmp.id;
    		acDisp.acType = acmp.Type__c;
    		acDisp.amount = acmp.Amount__c;
    		acDisp.recNo = recNo ++;
    		displayList.add(acDisp);
    	}
    	return displayList;
    }
    public PageReference save() {
    	List<Accomplishment__c> toUpdate = new List<Accomplishment__c>();
    	List<Accomplishment__c> toDelete = new List<Accomplishment__c>();
    	for(AcDisplay disp : displayList) {
    		if(disp.amount > 0) {
    			toUpdate.add(new Accomplishment__c(Id=disp.Id, Type__c=disp.acType, Amount__c=disp.amount, Volunteer_Job__c=volunteerJob.Id));
    		}
    		else if(disp.Id != null) {
    			toDelete.add(new Accomplishment__c(Id=disp.Id));
    		}
    	}
    	System.debug('toUpdate: ' + toUpdate);
    	System.debug('toDelete: ' + toDelete);
    	upsert toUpdate;
    	delete toDelete;
    	return null;
    }
}