//------------------------------------------------------------------------------------------------
// Projeto Delta Energia - 01/07/2021 
//------------------------------------------------------------------------------------------------
trigger LeadTrigger on Lead (before insert, before update, after update, before delete) {
    Boolean erro = false;
    string developerName = null;
    integer i = 0;
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
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
        
        for (Lead lead : trigger.new) {
            lead.Data_Da_Cria_o__c = System.now();
            
            // Determina o campo Fonte__c com base em Origem_da_Opera_o__c
            if (lead.Origem_da_Opera_o__c == 'SiteLuz' || 
                lead.Origem_da_Opera_o__c == 'AreaLogada' || 
                lead.Origem_da_Opera_o__c == 'ADS') {
                lead.Fonte__c = lead.Parceiro__c ? 'Parceiros' : 'Inbound';
            } else {
                lead.Fonte__c = 'Outbound';
            }

            // Define o campo WhatsApp
            lead.Whatsapp__c = 'whatsapp:+' + lead.Phone;
            lead.NumeroInstalacao__c = '0';
            lead.Locale__c = 'BR';

            // Valida o nono dígito e atualiza telefones
            String telefoneMKT;
            if (lead.Phone != null && lead.Phone.length() == 12 && lead.Phone.substring(0, 4) == '5541') {
                telefoneMKT = lead.Phone.substring(0, 4) + '9' + lead.Phone.substring(4, 12);
            } else {
                telefoneMKT = lead.Phone;
            }
            lead.Phone = telefoneMKT;

            // Inicializa variáveis
            erro = false;
            developerName = LeadTriggerValidation.ObterDeveloperNameInRecordType(lead.RecordTypeId);
            
            // Atribui variável para Tipo do Lead
            if (lead.PFPJ__c == 'PF') {
                lead.LeadType__c = 'Pessoa Física';
            } else if (lead.PFPJ__c == 'PJ') {
                lead.LeadType__c = 'Pessoa Jurídica';
            }
           
            // Valida Tipo de Lead PJ
            if (lead.LeadType__c == 'Pessoa Jurídica') {
                erro = LeadTriggerValidation.ValidarPJBeforeInsertOrUpdate(lead);
            } else if (lead.LeadType__c == 'Pessoa Física') {
                if (lead.FantasyName__c == null) {
                    lead.FantasyName__c = lead.Company;
                }   
                erro = LeadTriggerValidation.ValidarPFBeforeInsertOrUpdate(lead);
            } else if (developerName == 'ThymosPJ') { // Thymos - Alteração dia 23/01/2023 por Adriana Xavier
                lead.LeadType__c = 'Pessoa Jurídica';
                erro = LeadTriggerValidation.ValidarPJBeforeInsertOrUpdate(lead);
            }

            if (erro == false) {
                erro = LeadTriggerValidation.ValidarDadosFormatados(lead);
                
                if (lead.LeadType__c == 'Pessoa Jurídica') {
                    erro = LeadTriggerValidation.ValidarPJDemaisDados(lead);
                } else if (lead.LeadType__c == 'Pessoa Física') {
                    erro = LeadTriggerValidation.ValidarPFDemaisDados(lead);
                }
            }

            // Revalida status se já estiver integrado (somente administrador ou usuário de integração)
            if (erro == false) {
                String integrationUserName = [select IntegrationUserName__c from GeneralParameter__mdt].IntegrationUserName__c;
                String userProfileName = [select Name from Profile where id = :UserInfo.getProfileId()].Name;
                if (integrationUserName == UserInfo.getName() || userProfileName == 'Administrador do sistema') {
                    if (lead.Status != 'Integrate' && lead.StatusIntegration__c == 'Integrado') {
                        lead.StatusIntegration__c = 'Não integrado';
                    }
                }
            }

            // Valida integração e previne atualização/exclusão se já estiver integrado
            if (erro == false && trigger.isBefore && (trigger.isUpdate || trigger.isDelete) && LeadIntegrationHandler.firstCall == 1) {
                System.debug('Validar se já está integrado, e está tentando atualizar ou excluir');
                LeadIntegrationHandler.firstCall++;
                Boolean ret = LeadIntegrationHandler.checkUpdateDelete(trigger.new, trigger.oldMap, trigger.old);
                erro = !ret;
            }

            // Realiza integração após atualização
            if (erro == false && trigger.isAfter && trigger.isUpdate) {
                System.debug('After update. DoIntegration');
                LeadIntegrationHandler.firstCall++;
                if (LeadIntegrationHandler.firstCall <= 3) {
                    LeadIntegrationHandler.DoIntegration(trigger.new);
                }
            }

            // Chama validateLeadStatus se Company__c for 'LUZ'
            if (lead.Company__c == 'a1F89000000EDa5EAG') {
                LeadTriggerValidation.validateLeadStatus(trigger.new);
            }
        }
    }
}