@isTest
private class AccomplishmentCtlTest {

	static GW_Volunteers__Volunteer_Job__c job;
	static PageReference pageRef = Page.JobAccomplishments;
	static AccomplishmentCtl ext;		

	private static void init() {
		Campaign camp = new Campaign(Name='Test Campaign');
		insert camp;
		job = new GW_Volunteers__Volunteer_Job__c(
			Name='Test Job',
			GW_Volunteers__Campaign__c = camp.Id
		);
		insert job;
		
		Accomplishment__c accomplishment1 = new Accomplishment__c(
			Type__c = 'Visitor Contacts',
			Amount__c = 10,
			Volunteer_Job__c = job.Id
		);
		insert accomplishment1;
		
		pageRef.getParameters().put('id',job.id);
    	Test.setCurrentPage(pageRef);

    	ApexPages.StandardController con = new ApexPages.StandardController(job);
    	ext = new AccomplishmentCtl(con);		
	}        
    static testMethod void myUnitTest() {
    	init();
    	List<Accomplishment__c> displayList = ext.getDisplayList();
    	for(Accomplishment__c disp : displayList) {
    		if(disp.Id != null) {
    			disp.Amount__c = 0;
    		}
    	}
    	displayList.add(new Accomplishment__c(Type__c='Acreage Impacted', Amount__c = 5, Volunteer_Job__c = job.Id));
    	ext.save();
    	
		List<Accomplishment__c> acList = [
			SELECT Id, Type__c, Amount__c
			FROM Accomplishment__c
			WHERE Volunteer_Job__c = :job.Id
		];
		System.assertEquals(1, acList.size());
		Accomplishment__c ac = acList.get(0);
		System.assertEquals('Acreage Impacted', ac.Type__c);
		System.assertEquals(5, ac.Amount__c);    	
    }
}