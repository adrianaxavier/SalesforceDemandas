trigger ChamadoTrigger on Chamado__c (after insert, after update) {
    
    // Verificar se o trigger já foi executado para evitar recursão infinita
    if (ChamadoTriggerHelper.isTriggerExecuted) {
        return;
    }
    
    // Definir a variável estática como true para evitar futuras execuções nesta transação
    ChamadoTriggerHelper.isTriggerExecuted = true;

    // Obter o ID da fila "BackOffice"
    Group backOfficeQueue = [SELECT Id FROM Group WHERE Name = 'BackOffice' AND Type = 'Queue' LIMIT 1];
    
    List<Chamado__c> chamadosToUpdate = new List<Chamado__c>();
    
    for (Chamado__c chamado : Trigger.new) {
        
        Chamado__c chamadoToUpdate = new Chamado__c();
        chamadoToUpdate.Id = chamado.Id;

        if (chamado.IdColaborador__c != null) {
            User user = [SELECT Id, Email FROM User WHERE DeltaCode__c = :chamado.IdColaborador__c AND IsActive = true LIMIT 1];
            
            if (user != null) {
                chamadoToUpdate.Solicitante__c = user.Id;
                chamadoToUpdate.IdColaborador__c = null;
                chamadoToUpdate.Email_Solicitante__c = user.Email;
            }
        }
        
        if (chamado.IdUnidade__c != null) {
            Units__c unidade = [SELECT Id, Account__c FROM Units__c WHERE ID_de_Unidade__c = :chamado.IdUnidade__c LIMIT 1];
            
            if (unidade != null) {
                chamadoToUpdate.Unidade__c = unidade.Id;
                chamadoToUpdate.Nome_da_Conta__c = unidade.Account__c;
            }
        }

        chamadoToUpdate.OwnerId = backOfficeQueue.Id;
        
        chamadosToUpdate.add(chamadoToUpdate);
    }
    
    if (!chamadosToUpdate.isEmpty()) {
        update chamadosToUpdate;
    }
}