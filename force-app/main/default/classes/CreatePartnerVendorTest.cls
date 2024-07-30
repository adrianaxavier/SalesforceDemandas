@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void testCreatePartnerVendor() {
        // Encontrar contas existentes com o RecordTypeId especificado que possam ter usuários associados
        List<Account> accounts = [
            SELECT Id, (SELECT Id FROM Users WHERE IsActive = true LIMIT 1)
            FROM Account
            WHERE IsPartner = true
            LIMIT 100
        ];

        Account acc = null;
        User user = null;

        // Iterar pelas contas até encontrar uma que tenha um usuário associado
        for (Account account : accounts) {
            if (!account.Users.isEmpty()) {
                acc = account;
                user = account.Users[0];
                break;
            }
        }

        // Verificar se uma conta com usuário associado foi encontrada
        System.assert(acc != null && user != null, 'Nenhuma conta encontrada com o RecordTypeId especificado e usuário associado');

        // Teste de inserção de Parceiros_e_Vendedores__c com Empresa_Parceira__c e sem Parceiro__c
        Parceiros_e_Vendedores__c partner = new Parceiros_e_Vendedores__c(
            Empresa_Parceira__c = acc.Id
        );

        Test.startTest();
        insert partner;
        Test.stopTest();

        // Verificar se o campo Parceiro__c foi preenchido corretamente
        partner = [SELECT Parceiro__c FROM Parceiros_e_Vendedores__c WHERE Id = :partner.Id];
        // Assegurando que Parceiro__c foi preenchido durante a execução do acionador
        System.assertEquals(user.Id, partner.Parceiro__c, 'Parceiro__c deve ser igual ao User Id associado à conta');
    }
}