trigger UpdateEmpresaOfficerOnQuote on Quote (before insert, before update) {

    // Percorre todos os registros de Quote que estão sendo inseridos ou atualizados
    for (Quote Proposta : Trigger.new) {

        // Se for uma inserção (novo registro)
        if (Trigger.isInsert) {
            // Busca o proprietário relacionado ao OwnerId
            User owner = [SELECT CompanyName FROM User WHERE Id = :Proposta.OwnerId LIMIT 1];

            // Atualiza o campo Empresa_Officer__c com o valor de CompanyName do proprietário
            Proposta.Empresa_Officer__c = owner.CompanyName;
        }

        // Se for uma atualização e o OwnerId foi alterado
        else if (Trigger.isUpdate && Proposta.OwnerId != Trigger.oldMap.get(Proposta.Id).OwnerId) {
            // Busca o proprietário relacionado ao novo OwnerId
            User owner = [SELECT CompanyName FROM User WHERE Id = :Proposta.OwnerId LIMIT 1];

            // Atualiza o campo Empresa_Officer__c com o valor de CompanyName do novo proprietário
            Proposta.Empresa_Officer__c = owner.CompanyName;
        }
    }
}