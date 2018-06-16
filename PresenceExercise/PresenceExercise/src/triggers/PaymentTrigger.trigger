trigger PaymentTrigger on Payment__c (after delete, after insert, after undelete, after update) {
	List<Payment__c> paymentList;
	if(trigger.isDelete) {
		paymentList = trigger.old;
	}
	else {
		paymentList = trigger.new;
	}
	PaymentTriggerHandler.summarizePayments(paymentList);
}