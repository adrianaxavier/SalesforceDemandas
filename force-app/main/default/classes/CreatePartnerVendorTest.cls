@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void testCreatePartnerVendor() {
        // Busca a conta com o campo CNPJ__c = 31329646000140
        List<Account> accountList = [SELECT Id, OwnerId FROM Account WHERE CNPJ__c = '31329646000140' LIMIT 1];

        // Verifica se a conta foi encontrada
        System.assert(!accountList.isEmpty(), 'A conta com o CNPJ especificado não foi encontrada.');

        Account testAccount = accountList[0];

        // Busca o primeiro usuário atrelado a essa conta
        List<User> userList = [SELECT Id FROM User WHERE AccountId = :testAccount.Id LIMIT 1];

        // Verifica se o usuário foi encontrado
        System.assert(!userList.isEmpty(), 'Nenhum usuário encontrado para a conta especificada.');

        User testUser = userList[0];

        // Cria um registro de Parceiros_e_Vendedores__c sem Parceiro__c
        Parceiros_e_Vendedores__c partner = new Parceiros_e_Vendedores__c(
            Empresa_Parceira__c = testAccount.Id
        );

        Test.startTest();
        insert partner;
        Test.stopTest();

        // Recupera o registro inserido e verifica se o acionador preencheu o campo Parceiro__c
        partner = [SELECT Id, Parceiro__c FROM Parceiros_e_Vendedores__c WHERE Id = :partner.Id];
        System.assertEquals(testUser.Id, partner.Parceiro__c);
    }
}