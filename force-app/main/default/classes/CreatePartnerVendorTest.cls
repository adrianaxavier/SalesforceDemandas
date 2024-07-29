@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void testCreatePartnerVendor() {
        // Busca a conta com o campo CNPJ__c = 31329646000140
        Account testAccount = [SELECT Id, OwnerId FROM Account WHERE CNPJ__c = '31329646000140' LIMIT 1];

        // Verifica se a conta foi encontrada
        System.assertNotEquals(null, testAccount, 'A conta com o CNPJ especificado não foi encontrada.');

        // Busca o primeiro usuário atrelado a essa conta
        User testUser = [SELECT Id FROM User WHERE AccountId = :testAccount.Id LIMIT 1];

        // Verifica se o usuário foi encontrado
        System.assertNotEquals(null, testUser, 'Nenhum usuário encontrado para a conta especificada.');

        // Define a role de parceiro comunitário
        UserRole partnerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CasaVerdeUsuriodeParceiro' LIMIT 1];

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

        // Cria uma Account sem User associado (exemplo adicional para testar comportamento de erro)
        Account testAccountNoUser = new Account(
            Name = 'Test Account No User',
            CNPJ__c = '98765432000195', // Adicionando um CNPJ válido sem formatação
            CompanyName__c = 'Test Company No User', // Adicionando Razão Social
            FantasyName__c = 'Test Fantasy Name No User', // Adicionando Nome Fantasia
            CollaboratorId__c = 12345678, // Valor numérico
            Managementtree__c = 90, // Valor numérico
            OwnerId = testAccount.OwnerId // ID do proprietário da conta com um papel definido
        );
        insert testAccountNoUser;

        // Cria um registro de Parceiros_e_Vendedores__c associado à Account sem User
        Parceiros_e_Vendedores__c partnerNoUser = new Parceiros_e_Vendedores__c(
            Empresa_Parceira__c = testAccountNoUser.Id
        );

        Test.startTest();
        try {
            insert partnerNoUser;
            System.assert(false, 'Expected an exception due to no associated User');
        } catch (DmlException e) {
            // Verifica se a exceção foi causada pelo erro esperado
            System.assert(e.getMessage().contains('A empresa não possui líder cadastrado. Solicite o cadastramento junto à equipe de tecnologia.'));
        }
        Test.stopTest();
    }
}