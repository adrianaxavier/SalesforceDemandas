@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void simpleTest() {
        // Criação de um registro de Parceiros_e_Vendedores__c para teste
        Parceiros_e_Vendedores__c partner = new Parceiros_e_Vendedores__c(
            Empresa__c= 'a1F4x000000vfPUEAY',
            Cupom__c = 'Teste1',
            Empresa_Parceira__c='001HY000006UuELYA0'
        );

        Test.startTest();
        insert partner;
        Test.stopTest();

        // Verificar se o registro foi inserido
        partner = [SELECT Id, Empresa_Parceira__c FROM Parceiros_e_Vendedores__c WHERE Id = :partner.Id];
        System.assert(partner != null, 'O registro Parceiros_e_Vendedores__c deve ser inserido com sucesso.');
    }
}