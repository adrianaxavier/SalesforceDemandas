@isTest
public class CreatePartnerVendorTest {
    @isTest
    static void testCreatePartnerVendor() {
        // Obtém o ID do usuário com base no DeltaCode__c
        User ownerUser = [SELECT Id, ProfileId FROM User WHERE DeltaCode__c = 2621 LIMIT 1];

        // Cria uma Account de teste com os campos adicionais
        Account testAccount = new Account(
            Name = 'Test Account',
            CNPJ__c = '12345678000195', // Adicionando um CNPJ válido sem formatação
            CompanyName__c = 'Test Company', // Adicionando Razão Social
            FantasyName__c = 'Test Fantasy Name', // Adicionando Nome Fantasia
            CollaboratorId__c = 89992666, // Valor numérico
            Managementtree__c = 72, // Valor numérico
            OwnerId = ownerUser.Id // ID do proprietário da conta com um papel definido
        );
        insert testAccount;

        // Define a role de parceiro comunitário
        UserRole partnerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CasaVerdeUsuriodeParceiro' LIMIT 1];

        // Cria um User com licença Partner Community
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@test.com.partner',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = partnerProfile.Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = partnerRole.Id,
            CommunityNickname = 'testuser',
            IsActive = true
        );
        insert testUser;

        // Cria um registro de Parceiros_e_Vendedores__c sem Parceiro__c
        Parceiros_e_Vendedores__c partner = new Parceiros_e_Vendedores__c(
            Empresa_Parceira__c = testAccount.Id
        );
        insert partner;

        // Recupera o registro inserido e verifica se o acionador preencheu o campo Parceiro__c
        partner = [SELECT Id, Parceiro__c FROM Parceiros_e_Vendedores__c WHERE Id = :partner.Id];
        System.assertEquals(testUser.Id, partner.Parceiro__c);

        // Cria uma Account sem User associado
        Account testAccountNoUser = new Account(
            Name = 'Test Account No User',
            CNPJ__c = '98765432000195', // Adicionando um CNPJ válido sem formatação
            CompanyName__c = 'Test Company No User', // Adicionando Razão Social
            FantasyName__c = 'Test Fantasy Name No User', // Adicionando Nome Fantasia
            CollaboratorId__c = 12345678, // Valor numérico
            Managementtree__c = 90, // Valor numérico
            OwnerId = ownerUser.Id // ID do proprietário da conta com um papel definido
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