public with sharing class PaymentTriggerHandler {
    public static void summarizePayments(List<Payment__c> paymentList) {
    	Set<Id> contactIds = new Set<Id>();
    	Set<Id> projectIds = new Set<Id>();
    	for(Payment__c payment : paymentList) {
    		contactIds.add(payment.Contact__c);
    		projectIds.add(payment.Project__c);
    	}
    	List<sObject> toUpdate = new List<sObject>();

    	AggregateResult[] contactSummary = [
    		select 
    			Contact__c id, 
    			SUM(Amount__c) totalAmount, 
    			MAX(Date_Paid__c) lastDate 
    		from Payment__c
    		where Contact__c in :contactIds
    		group by Contact__c
    	];
    	for(aggregateResult ar : contactSummary) {
    		Contact personToUpdate = new Contact(
    			Id=(Id)ar.get('id'),
    			Total_Payments__c=(Decimal)ar.get('totalAmount'),
    			Last_Payment_Date__c=(Date)ar.get('lastDate')
    		);
    		toUpdate.add(personToUpdate);
    	}
    	
    	AggregateResult[] projectSummary = [
    		select 
    			Project__c id, 
    			SUM(Amount__c) totalAmount 
    		from Payment__c
    		where Project__c in :projectIds
    		group by Project__c
    	];
    	for(aggregateResult ar : projectSummary) {
    		Project__c projectToUpdate = new Project__c(
    			Id=(Id)ar.get('id'),
    			Total_Payments__c=(Decimal)ar.get('totalAmount')
    		);
    		toUpdate.add(projectToUpdate);
    	}
    	
    	update toUpdate;
    }
}