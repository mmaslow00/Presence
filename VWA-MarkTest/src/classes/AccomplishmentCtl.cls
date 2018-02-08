public with sharing class AccomplishmentCtl {
    public AccomplishmentCtl(ApexPages.StandardController stdController) {
        this.volunteerJob = (GW_Volunteers__Volunteer_Job__c)stdController.getRecord();
    }
	public GW_Volunteers__Volunteer_Job__c volunteerJob;
    public List<Accomplishment__c> displayList;
    Map<String, Accomplishment__c> acMap = new Map<String, Accomplishment__c>();
    
    public List<Accomplishment__c> getDisplayList() {
    	if(displayList == null) {
	    	Schema.DescribeFieldResult fieldResult = Accomplishment__c.Type__c.getDescribe();
	    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	    	for(Schema.PicklistEntry entry : ple) {
	   			acMap.put(entry.getValue(), 
	   				new Accomplishment__c(Type__c = entry.getValue(), Volunteer_Job__c = volunteerJob.Id));
	    	}
	    	
	    	for(Accomplishment__c acmp : [
					SELECT Id, Type__c, Amount__c, Volunteer_Job__c 
					FROM Accomplishment__c
					WHERE Volunteer_Job__c = :volunteerJob.Id
					]) 
				{
		    		Accomplishment__c mapped = acMap.get(acmp.Type__c);
		    		mapped.Id = acmp.Id;
		    		mapped.Amount__c = acmp.Amount__c;
		    	}
	    	
	    	displayList = new List<Accomplishment__c>();
	    	for(String tp : acMap.keySet()) {
	    		Accomplishment__c acmp = acMap.get(tp);
	    		displayList.add(acmp);
	    	}
    	}
    	return displayList;
    }
    public PageReference save() {
    	List<Accomplishment__c> toUpsert = new List<Accomplishment__c>();
    	List<Accomplishment__c> toDelete = new List<Accomplishment__c>();
    	for(Accomplishment__c disp : displayList) {
    		if(disp.Amount__c > 0) {
    			toUpsert.add(disp);
    		}
    		else if(disp.Id != null) {
    			toDelete.add(disp);
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
}