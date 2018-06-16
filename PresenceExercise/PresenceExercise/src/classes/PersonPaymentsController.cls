public with sharing class PersonPaymentsController {
	List<PersonPayment> personPaymentList;
	
	public List<personPayment> getPersonPaymentList() {
		List<Payment__c> paymentList = [
			select id, Amount__c, Date_Paid__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Total_Payments__c 
			from Payment__c
			order by Contact__r.LastName, Contact__r.FirstName, Id, Date_Paid__c desc
		];
		Integer rowNum=0;
		Person pers = new Person();
		List<PersonPayment> persPayList = new List<PersonPayment>();
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
				persPayList.add(persPay);
				pers = new Person();
				wrapList = new List<PaymentWrapper>();
			}
			pers.contactId = payment.Contact__c;
			pers.firstName = payment.Contact__r.FirstName;
			pers.lastName = payment.Contact__r.LastName;
			pers.totalPayments = payment.Contact__r.Total_Payments__c;
			PaymentWrapper wrap = new PaymentWrapper();
			wrap.payment = payment;
			wrap.inputPayment = payment;
			wrapList.add(wrap);
			rowNum++;
		}

		PersonPayment persPay = new PersonPayment();
		persPay.payor = pers;
		persPay.paymentList = wrapList;
		persPayList.add(persPay);
		return persPayList;
	}
	class Person {
		Id contactId {get; set;}
		public String firstName {get; set;}
		public String lastName {get; set;}
		public Decimal totalPayments {get; set;}
	}
 	class PersonPayment {
 		public Person payor {get; set;}
 		public List<PaymentWrapper> paymentList {get; set;}
 	}
 	class PaymentWrapper {
 		public Payment__c payment {get; set;}
 		public Payment__c inputPayment {get; set;}
 		//public Decimal amountPaid {get; set;}
 		//public Date datePaid {get; set;}
 	}  
}