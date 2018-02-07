public with sharing class AccomplishmentCtl {
    public AccomplishmentCtl(ApexPages.StandardController stdController) {
        this.volunteerJob = (GW_Volunteers__Volunteer_Job__c)stdController.getRecord();
    }
	public GW_Volunteers__Volunteer_Job__c volunteerJob;
    public List<AcDisplay> displayList;
    Map<String, Accomplishment__c> acMap = new Map<String, Accomplishment__c>();
    
    public List<AcDisplay> getDisplayList() {
    	if(displayList == null) {
	    	Schema.DescribeFieldResult fieldResult = Accomplishment__c.Type__c.getDescribe();
	    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	    	for(Schema.PicklistEntry entry : ple) {
	   			acMap.put(entry.getValue(), 
	   				new Accomplishment__c(Type__c = entry.getValue()));
	    	}
	    	
	    	for(Accomplishment__c acmp : [
					SELECT Id, Type__c, Amount__c 
					FROM Accomplishment__c
					WHERE Volunteer_Job__c = :volunteerJob.Id
					]) 
				{
		    		Accomplishment__c mapped = acMap.get(acmp.Type__c);
		    		mapped.Id = acmp.Id;
		    		mapped.Amount__c = acmp.Amount__c;
		    	}
	    	
	    	displayList = new List<AcDisplay>();
	    	for(String tp : acMap.keySet()) {
	    		Accomplishment__c acmp = acMap.get(tp);
	    		AcDisplay acDisp = new AcDisplay(acmp.id, acmp.Type__c, acmp.Amount__c);
	    		displayList.add(acDisp);
	    	}
    	}
    	return displayList;
    }
    public PageReference save() {
    	List<Accomplishment__c> toUpsert = new List<Accomplishment__c>();
    	List<Accomplishment__c> toDelete = new List<Accomplishment__c>();
    	for(AcDisplay disp : displayList) {
    		if(disp.amount > 0) {
    			toUpsert.add(
    				new Accomplishment__c(Id=disp.Id, Type__c=disp.acType, Amount__c=disp.amount, Volunteer_Job__c=volunteerJob.Id));
    		}
    		else if(disp.Id != null) {
    			toDelete.add(new Accomplishment__c(Id=disp.Id));
    		}
    	}
    	if( ! toUpsert.isEmpty()) {
    		upsert toUpsert;
    	}
    	if(! toDelete.isEmpty()) {
    		delete toDelete;
    	}
        displayList = null;
    	return null;
    }
    public Class AcDisplay {
    	public AcDisplay(String id, String acType, Decimal amount) {
    		this.id=id;
    		this.acType=acType;
    		this.amount=amount;
    	}
    	public String id {get; set;}
    	public String acType {get; set;}
    	public Decimal amount {get; set;}
    }
}