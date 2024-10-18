@isTest
public class TestUpdateEmpresaOfficerOnQuote {
    
    @isTest
    static void testInsertQuote() {
        // Busca o usuário com o e-mail fornecido
        User testUser = [SELECT Id, CompanyName FROM User WHERE Email = 'adriana.xavier@deltaenergia.com.br' LIMIT 1];

        // Criação de um registro de Quote com o OwnerId como o usuário encontrado
        Quote proposta = new Quote(
            Name = 'Test Quote',
            OwnerId = testUser.Id
        );
        insert proposta;

        // Validação que o campo Empresa_Officer__c foi atualizado com o valor correto
        Quote insertedProposta = [SELECT Empresa_Officer__c FROM Quote WHERE Id = :proposta.Id];
        System.assertEquals(testUser.CompanyName, insertedProposta.Empresa_Officer__c);
    }
    
    @isTest
    static void testUpdateQuote() {
        // Busca o usuário com o e-mail fornecido
        User testUser = [SELECT Id, CompanyName FROM User WHERE Email = 'adriana.xavier@deltaenergia.com.br' LIMIT 1];

        // Criação de um registro de Quote com o OwnerId como o usuário encontrado
        Quote proposta = new Quote(
            Name = 'Test Quote Update',
            OwnerId = testUser.Id
        );
        insert proposta;

        // Atualiza o OwnerId para o mesmo usuário (apenas para garantir a execução)
        proposta.OwnerId = testUser.Id;
        update proposta;

        // Validação que o campo Empresa_Officer__c foi atualizado corretamente
        Quote updatedProposta = [SELECT Empresa_Officer__c FROM Quote WHERE Id = :proposta.Id];
        System.assertEquals(testUser.CompanyName, updatedProposta.Empresa_Officer__c);
    }
}