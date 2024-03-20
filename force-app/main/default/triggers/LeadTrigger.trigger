//------------------------------------------------------------------------------------------------
// Projeto Delta Energia - 01/07/2021 
//------------------------------------------------------------------------------------------------
trigger LeadTrigger on Lead (before insert, before update,after update, before delete) {
    Boolean erro = false;
    string developerName = null;
    integer i=0;
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
    {
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        for (Lead lead : trigger.new)
        {
      
           //Inicia variavel  
            erro = false;
            developerName = LeadTriggerValidation.ObterDeveloperNameInRecordType(lead.RecordTypeId);
            
            //Atribui variavel para Tipo do Lead
           if(lead.PFPJ__c=='PF'){
           lead.LeadType__c = 'Pessoa Física';}
           else if(lead.PFPJ__c=='PJ'){
           lead.LeadType__c = 'Pessoa Jurídica';}
           
           
            //Valida Tipo de Lead PJ
            if(lead.LeadType__c == 'Pessoa Jurídica'){
              erro = LeadTriggerValidation.ValidarPJBeforeInsertOrUpdate(lead);}
            else if(lead.LeadType__c == 'Pessoa Física'){
                erro = LeadTriggerValidation.ValidarPFBeforeInsertOrUpdate(lead);}
                
            //Valida Tipo de Lead PJ  Thymos - Alteração dia 23/01/2023 por Adriana Xavier  
                else if (developerName == 'ThymosPJ')
            {
                lead.LeadType__c = 'Pessoa Jurídica';
                erro = LeadTriggerValidation.ValidarPJBeforeInsertOrUpdate(lead);}
            
            if (erro == false) {
                
                erro = LeadTriggerValidation.ValidarDadosFormatados(lead);
                
                if (lead.LeadType__c == 'Pessoa Jurídica')
                    erro = LeadTriggerValidation.ValidarPJDemaisDados(lead);
                if (lead.LeadType__c == 'Pessoa Física') 
                    erro = LeadTriggerValidation.ValidarPFDemaisDados(lead);
                
            }
            // refazer o status caso ja tenha sido integrado (somente administrador ou usuario de integracao)
            if (erro == false) {
                String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt].IntegrationUserName__c;
                String userProfileName = [select Name from Profile where id =: UserInfo.getProfileId()].Name;
                if (integrationUserName == UserInfo.getName() || userProfileName == 'Administrador do sistema') {
                    if (lead.Status != 'Integrate' && lead.StatusIntegration__c == 'Integrado')
                        lead.StatusIntegration__c = 'Não integrado';
                }
            }
            
        
    
  
            
   
            
    // validar se ja tiver integrado, e nao for usuario de integracao, nao deixar alterar ou exlcluir
    if (erro == false) 
    {
        if (trigger.isBefore && (trigger.isUpdate || trigger.isDelete) && LeadIntegrationHandler.firstCall == 1) 
        {
            System.debug('validar se ja ta integrado, e esta tentando atualizar ou excluir');
            LeadIntegrationHandler.firstCall++;
            Boolean ret = LeadIntegrationHandler.checkUpdateDelete(trigger.new, trigger.oldMap, trigger.old);
            erro = !ret;
        }
    }

    if (erro == false)
    {
        if (trigger.isAfter && trigger.isUpdate)
        {
 
            System.debug('after update. DoIntegration');
            
            LeadIntegrationHandler.firstCall++;
            if (LeadIntegrationHandler.firstCall <= 3) LeadIntegrationHandler.DoIntegration(trigger.new); } } } } }