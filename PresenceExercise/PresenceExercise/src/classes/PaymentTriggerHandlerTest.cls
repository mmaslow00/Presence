@isTest
private class PaymentTriggerHandlerTest {

    static testMethod void myUnitTest() {
        Contact contact1 = new Contact(FirstName='First1', LastName='Last1');
        insert contact1;
        
        Project__c project1 = new Project__c(Name='Project1');
        insert project1;

        Payment__c payment1 = new Payment__c(Contact__c = contact1.Id, Project__c = project1.Id, Amount__c = 100, Date_Paid__c = System.today()-1);
        Payment__c payment2 = new Payment__c(Contact__c = contact1.Id, Project__c = project1.Id, Amount__c = 150, Date_Paid__c = System.today());
        List<Payment__c> paymentList = new List<Payment__c>();
        paymentList.add(payment1);
        paymentList.add(payment2);  
        
        insert paymentList;
        
        contact1 = [select Last_Payment_Date__c, Total_Payments__c from Contact where Id=:contact1.Id];
        System.assertEquals(System.today(), contact1.Last_Payment_Date__c);
        System.assertEquals(250, contact1.Total_Payments__c);
        
        project1 = [select Total_Payments__c from Project__c where Id=:project1.Id];
        System.assertEquals(250, project1.Total_Payments__c);
        
        delete payment2;
        
        contact1 = [select Last_Payment_Date__c, Total_Payments__c from Contact where Id=:contact1.Id];
        System.assertEquals(System.today()-1, contact1.Last_Payment_Date__c);
        System.assertEquals(100, contact1.Total_Payments__c);
        
        project1 = [select Total_Payments__c from Project__c where Id=:project1.Id];
        System.assertEquals(100, project1.Total_Payments__c);
              
    }
    
}