public with sharing class PersonPaymentsController {
	List<PersonPayment> personPaymentList;
	
	public List<personPayment> getPersonPaymentList() {
		List<Payment__c> paymentList = [
			select id, Amount__c, Date_Paid__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Total_Payments__c, Contact__r.Last_Payment_Date__c 
			from Payment__c
			order by Contact__r.LastName, Contact__r.FirstName, Id, Date_Paid__c desc
		];
		Integer rowNum=0;
		Person pers = new Person();
		personPaymentList = new List<PersonPayment>();
		List<PaymentWrapper> wrapList = new List<PaymentWrapper>();

		Payment__c firstRow = paymentList.get(0);
		pers.contactId = firstRow.Contact__c;
		pers.firstName = firstRow.Contact__r.FirstName;
		pers.lastName = firstRow.Contact__r.LastName;
		pers.totalPayments = firstRow.Contact__r.Total_Payments__c;
		
		while(rowNum < paymentList.size()) {
			Payment__c payment = paymentList.get(rowNum);
			if(payment.Contact__c != pers.contactId) {
				PersonPayment persPay = new PersonPayment();
				persPay.payor = pers;
				persPay.paymentList = wrapList;
				personPaymentList.add(persPay);

				pers = new Person();
				wrapList = new List<PaymentWrapper>();
			}
			pers.contactId = payment.Contact__c;
			pers.firstName = payment.Contact__r.FirstName;
			pers.lastName = payment.Contact__r.LastName;
			pers.totalPayments = payment.Contact__r.Total_Payments__c;
			pers.lastDate = payment.Contact__r.Last_Payment_Date__c;
			PaymentWrapper wrap = new PaymentWrapper();
			wrap.payment = payment;
			wrap.inputPayment = new Payment__c(Amount__c = payment.Amount__c, Date_Paid__c = payment.Date_Paid__c);
			wrapList.add(wrap);
			rowNum++;
		}

		PersonPayment persPay = new PersonPayment();
		persPay.payor = pers;
		persPay.paymentList = wrapList;
		personPaymentList.add(persPay);

		return personPaymentList;
	}
	public PageReference save() {
		List<Payment__c> paymentList = new List<Payment__c>();
		for(PersonPayment pp : personPaymentList) {
			for(paymentWrapper wrap : pp.paymentList) {
				if(wrap.inputPayment.Amount__c != wrap.payment.Amount__c || wrap.inputPayment.Date_Paid__c != wrap.payment.Date_Paid__c) {
					Payment__c toUpdate = new Payment__c(
						Id=wrap.payment.Id, 
						Amount__c = wrap.inputPayment.Amount__c,
						Date_Paid__c = wrap.inputPayment.Date_Paid__c
					);
					paymentList.add(toUpdate);
				}
			}
		}
		if( ! paymentList.isEmpty()) {
			update paymentList;
		}
		return null;
	}
	class Person {
		Id contactId {get; set;}
		public String firstName {get; set;}
		public String lastName {get; set;}
		public Decimal totalPayments {get; set;}
		public Date lastDate {get; set;}
	}
 	class PersonPayment {
 		public Person payor {get; set;}
 		public List<PaymentWrapper> paymentList {get; set;}
 	}
 	class PaymentWrapper {
 		public Payment__c payment {get; set;}
 		public Payment__c inputPayment {get; set;}
 	}  
}