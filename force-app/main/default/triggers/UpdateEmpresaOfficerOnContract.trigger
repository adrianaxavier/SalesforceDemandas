trigger UpdateEmpresaOfficerOnContract on Contract (before insert, before update) {

    // Percorre todos os registros de Contract que estão sendo inseridos ou atualizados
    for (Contract Contrato : Trigger.new) {

        // Se for uma inserção (novo registro)
        if (Trigger.isInsert) {
            // Busca o proprietário relacionado ao OwnerId
            User owner = [SELECT CompanyName FROM User WHERE Id = :Contrato.OwnerId LIMIT 1];

            // Atualiza o campo Empresa_Officer__c com o valor de CompanyName do proprietário
            Contrato.Empresa_Officer__c = owner.CompanyName;
        }

        // Se for uma atualização e o OwnerId foi alterado
        else if (Trigger.isUpdate && Contrato.OwnerId != Trigger.oldMap.get(Contrato.Id).OwnerId) {
            // Busca o proprietário relacionado ao novo OwnerId
            User owner = [SELECT CompanyName FROM User WHERE Id = :Contrato.OwnerId LIMIT 1];

            // Atualiza o campo Empresa_Officer__c com o valor de CompanyName do novo proprietário
            Contrato.Empresa_Officer__c = owner.CompanyName;
        }
    }
}