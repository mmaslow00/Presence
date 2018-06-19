@isTest
private class PersonPaymentsControllerTest {

    static testMethod void myUnitTest() {
    	List<Contact> contactList = new List<Contact>();
        Contact contact1 = new Contact(FirstName='First1', LastName='Last1');
        Contact contact2 = new Contact(FirstName='First2', LastName='Last2');
        contactList.add(contact1);
        contactList.add(contact2);
        insert contactList;
        
        Project__c project1 = new Project__c(Name='Project1');
        insert project1;

        Payment__c payment1 = new Payment__c(Contact__c = contact1.Id, Project__c = project1.Id, Amount__c = 100, Date_Paid__c = System.today());
        Payment__c payment2 = new Payment__c(Contact__c = contact1.Id, Project__c = project1.Id, Amount__c = 150, Date_Paid__c = System.today()-1);
        Payment__c payment3 = new Payment__c(Contact__c = contact2.Id, Project__c = project1.Id, Amount__c = 200, Date_Paid__c = System.today());
        Payment__c payment4 = new Payment__c(Contact__c = contact2.Id, Project__c = project1.Id, Amount__c = 250, Date_Paid__c = System.today()-1);
        List<Payment__c> paymentList = new List<Payment__c>();
        paymentList.add(payment1);
        paymentList.add(payment2);  
        paymentList.add(payment3);
        paymentList.add(payment4);  
        
        insert paymentList;

		PersonPaymentsController ctl = new PersonPaymentsController();
		List<PersonPaymentsController.PersonPayment> perPayList = ctl.getPersonPaymentList();

		System.assertEquals(2, perPayList.size());
		
		PersonPaymentsController.PersonPayment pp = perPayList.get(0);
		List<PersonPaymentsController.PaymentWrapper> wrapList = pp.paymentList;
		PersonPaymentsController.PaymentWrapper wrap = wrapList.get(0);
		Payment__c pay = wrap.inputPayment;
		pay.Amount__c = 200;

		pp = perPayList.get(1);
		wrapList = pp.paymentList;
		wrapList.get(0).isDeleted = true;
		wrapList.get(1).isDeleted = true;
		ctl.save();

		System.assertEquals(1, ctl.getPersonPaymentList().size());
				
		System.assertEquals(1, ctl.getProjectOptions().size());

		ctl.getPersonPaymentList();
		ctl.selectedRowNum='0';
		ctl.addPayment();
		ctl.cancel();
    }
}