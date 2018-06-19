public with sharing class PersonPaymentsController {
	public List<PersonPayment> personPaymentList;
	public String selectedRownum {get; set;}
	public List<SelectOption> projectOptions;
	
	public List<personPayment> getPersonPaymentList() {
		if(personPaymentList == null) {
			List<Payment__c> paymentList = [
				select id, Amount__c, Date_Paid__c, Contact__c, Project__c, 
				Contact__r.FirstName, Contact__r.LastName, Contact__r.Total_Payments__c, Contact__r.Last_Payment_Date__c 
				from Payment__c
				order by Contact__r.LastName, Contact__r.FirstName, Contact__c, Date_Paid__c desc
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
			Integer personNum = 0;
			while(rowNum < paymentList.size()) {
				Payment__c payment = paymentList.get(rowNum);
				if(payment.Contact__c != pers.contactId) {
					PersonPayment persPay = new PersonPayment();
					persPay.payor = pers;
					persPay.paymentList = wrapList;
					persPay.rowNum = personNum++;
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
				wrap.inputPayment = new Payment__c(
					Amount__c = payment.Amount__c, 
					Date_Paid__c = payment.Date_Paid__c,
					Project__c = payment.Project__c
				);
				wrap.isDeleted = false;
				wrapList.add(wrap);
				rowNum++;
			}
	
			PersonPayment persPay = new PersonPayment();
			persPay.payor = pers;
			persPay.paymentList = wrapList;
			persPay.rowNum = personNum++;
			personPaymentList.add(persPay);
		}

		return personPaymentList;
	}
	public PageReference save() {
		List<Payment__c> paymentsToUpsert = new List<Payment__c>();
		List<Payment__c> paymentsToDelete = new List<Payment__c>();
		for(PersonPayment pp : personPaymentList) {
			for(paymentWrapper wrap : pp.paymentList) {
				if(wrap.isDeleted) {
					if(wrap.payment.Id != null) {
						paymentsToDelete.add(wrap.payment);
					}
				}
				else if(wrap.inputPayment.Amount__c != wrap.payment.Amount__c || wrap.inputPayment.Date_Paid__c != wrap.payment.Date_Paid__c || wrap.inputPayment.Project__c != wrap.payment.Project__c) {
					Payment__c toUpsert = new Payment__c(
						Id=wrap.payment.Id,
						Contact__c = wrap.payment.Contact__c, 
						Amount__c = wrap.inputPayment.Amount__c,
						Date_Paid__c = wrap.inputPayment.Date_Paid__c,
						Project__c = wrap.inputPayment.Project__c
					);
					paymentsToUpsert.add(toUpsert);
				}
			}
		}
		if( ! paymentsToUpsert.isEmpty()) {
			upsert paymentsToUpsert;
		}
		if( ! paymentsToDelete.isEmpty()) {
			delete paymentsToDelete;
		}
		personPaymentList = null;
		return null;
	}
	public PageReference cancel() {
		personPaymentList = null;
		return  null;
	}
	public List<SelectOption> getProjectOptions() {
		if(projectOptions == null) {
			projectOptions = new List<SelectOption>();
			for(Project__c proj : [select Id, Name from Project__c order by Name]) {
				projectOptions.add(new SelectOption(proj.Id, proj.Name));				
			}
		}
		return projectOptions;
	}
	public PageReference addPayment() {
		Integer row = Integer.valueOf(selectedRowNum);
		PersonPayment persPay = personPaymentList.get(row);
		PaymentWrapper wrap = new PaymentWrapper();
		wrap.payment = new Payment__c(Contact__c = persPay.payor.contactId);
		wrap.inputPayment = new Payment__c();
		wrap.isDeleted = false;
		persPay.paymentList.add(wrap);
		return null;
	}
	public class Person {
		Id contactId {get; set;}
		public String firstName {get; set;}
		public String lastName {get; set;}
		public Decimal totalPayments {get; set;}
		public Date lastDate {get; set;}
	}
 	public class PersonPayment {
 		public Integer rowNum {get; set;}
 		public Person payor {get; set;}
 		public List<PaymentWrapper> paymentList {get; set;}
 	}
 	public class PaymentWrapper {
 		public Payment__c payment {get; set;}
 		public Payment__c inputPayment {get; set;}
 		public Boolean isDeleted {get; set;}
 	}  
}