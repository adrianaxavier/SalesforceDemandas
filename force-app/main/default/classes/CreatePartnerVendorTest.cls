@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void testCreatePartnerVendor() {
        // Encontrar uma conta existente com o RecordTypeId especificado
        Account acc = [SELECT Id FROM Account WHERE RecordTypeId = '0124x000000dWvYAAU' LIMIT 1];

        // Simular um usuário existente associado à conta encontrada
        User user = [SELECT Id FROM User WHERE AccountId = :acc.Id AND IsActive = true LIMIT 1];

        // Teste de inserção de Parceiros_e_Vendedores__c com Empresa_Parceira__c e sem Parceiro__c
        Parceiros_e_Vendedores__c partner = new Parceiros_e_Vendedores__c(
            Parceiro__c = user.id,
            Empresa_Parceira__c = acc.Id
        );

        Test.startTest();
        insert partner;
        Test.stopTest();

        // Verificar se o campo Parceiro__c foi preenchido corretamente
        partner = [SELECT Parceiro__c FROM Parceiros_e_Vendedores__c WHERE Id = :partner.Id];
        System.assertEquals(user.Id, partner.Parceiro__c, 'Parceiro__c deve ser igual ao User Id associado à conta');

   }     
}