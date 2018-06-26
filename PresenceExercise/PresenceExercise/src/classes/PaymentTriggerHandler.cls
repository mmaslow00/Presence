public with sharing class PaymentTriggerHandler {
    public static void summarizePayments(List<Payment__c> paymentList) {
    	Set<Id> contactIds = new Set<Id>();
    	Set<Id> projectIds = new Set<Id>();
    	for(Payment__c payment : paymentList) {
    		contactIds.add(payment.Contact__c);
    		projectIds.add(payment.Project__c);
    	}
    	List<SObject> toUpdate = new List<SObject>();

    	AggregateResult[] contactSummary = [
    		SELECT
    			Contact__c Id,
    			SUM(Amount__c) totalAmount, 
    			MAX(Date_Paid__c) lastDate 
    		FROM Payment__c
    		WHERE Contact__c IN :contactIds
    		GROUP BY Contact__c
    	];
    	for(AggregateResult ar : contactSummary) {
    		Contact personToUpdate = new Contact(
    			Id=(Id)ar.get('id'),
    			Total_Payments__c=(Decimal)ar.get('totalAmount'),
    			Last_Payment_Date__c=(Date)ar.get('lastDate')
    		);
    		toUpdate.add(personToUpdate);
    	}
    	
    	AggregateResult[] projectSummary = [
    		SELECT
    			Project__c Id,
    			SUM(Amount__c) totalAmount 
    		FROM Payment__c
    		WHERE Project__c IN :projectIds
    		GROUP BY Project__c
    	];
    	for(AggregateResult ar : projectSummary) {
    		Project__c projectToUpdate = new Project__c(
    			Id=(Id)ar.get('id'),
    			Total_Payments__c=(Decimal)ar.get('totalAmount')
    		);
    		toUpdate.add(projectToUpdate);
    	}
    	
    	update toUpdate;
    }
}