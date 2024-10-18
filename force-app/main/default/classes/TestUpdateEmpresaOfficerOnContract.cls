@isTest
public class TestUpdateEmpresaOfficerOnContract {

    @isTest
    static void testInsertContract() {
        // Busca o usuário com o e-mail fornecido
        User testUser = [SELECT Id, CompanyName FROM User WHERE Email = 'adriana.xavier@deltaenergia.com.br' LIMIT 1];

        // Criação de um registro de Contract com o OwnerId como o usuário encontrado
        Contract contrato = new Contract(
            OwnerId = testUser.Id
        );
        insert contrato;

        // Validação que o campo Empresa_Officer__c foi atualizado com o valor correto
        Contract insertedContrato = [SELECT Empresa_Officer__c FROM Contract WHERE Id = :contrato.Id];
        System.assertEquals(testUser.CompanyName, insertedContrato.Empresa_Officer__c);
    }
    
    @isTest
    static void testUpdateContract() {
        // Busca o usuário com o e-mail fornecido
        User testUser = [SELECT Id, CompanyName FROM User WHERE Email = 'adriana.xavier@deltaenergia.com.br' LIMIT 1];

        // Criação de um registro de Contract com o OwnerId como o usuário encontrado
        Contract contrato = new Contract(
            OwnerId = testUser.Id
        );
        insert contrato;

        // Atualiza o OwnerId para o mesmo usuário (apenas para garantir a execução)
        contrato.OwnerId = testUser.Id;
        update contrato;

        // Validação que o campo Empresa_Officer__c foi atualizado corretamente
        Contract updatedContrato = [SELECT Empresa_Officer__c FROM Contract WHERE Id = :contrato.Id];
        System.assertEquals(testUser.CompanyName, updatedContrato.Empresa_Officer__c);
    }
}