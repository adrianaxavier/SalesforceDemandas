trigger LeadTrigger on Lead (before insert, before update, after update, before delete) {
    Boolean erro = false;
    String developerName = null;

    
    for (Integer i = 0; i < 5000; i++) {
        i++;
    }
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        
  
        for (Lead lead : trigger.new) { 
        if(lead.Data_Da_Cria_o__c == null){
            lead.Data_Da_Cria_o__c = System.now();}
            
         // Set Fonte__c field based on InformationSource__c and TipoLead__c
        if (lead.Recordtype_Name__c == 'LeadPF' || lead.Recordtype_Name__c ==  'LeadPJ' ){
            lead.Fonte__c = (lead.Origem_da_Opera_o__c == 'SiteLuz' || 
                                lead.Origem_da_Opera_o__c == 'AreaLogada' || 
                                lead.Origem_da_Opera_o__c == 'ADS') 
                                ? (lead.Parceiro__c ? 'Parceiros' : 'Inbound') 
                                : 'Outbound';
        } 

            // Define o campo WhatsApp
            lead.Whatsapp__c = 'whatsapp:+' + lead.Phone;      
            if(lead.NumeroInstalacao__c == null){
            lead.NumeroInstalacao__c = '0';
        }
            
              // Assign owner based on CollaboratorId__c
        if (lead.CollaboratorId__c != null) {
            for (User user : [SELECT Id, Name, IsActive FROM User WHERE DeltaCode__c = :lead.CollaboratorId__c AND IsActive = true]) {
                lead.OwnerId = user.Id;
                lead.CollaboratorId__c = null;
            }
        }
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
                String integrationUserName = [SELECT IntegrationUserName__c FROM GeneralParameter__mdt LIMIT 1].IntegrationUserName__c;
                String userProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
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
            if (lead.Recordtype_Name__c == 'LeadPF' || lead.Recordtype_Name__c == 'LeadPJ') {
                System.debug('Chamando validateLeadStatus para Company__c == "LUZ"');
                LeadTriggerValidation.validateLeadStatus(trigger.new, trigger.oldMap);
            }
        }
    }

    // Chama validateLeadStatus e cria oportunidade se o lead for "Ganho"
    if (trigger.isAfter && trigger.isUpdate) {
        List<Lead> leadsGanho = new List<Lead>();
        for (Lead lead : trigger.new) {
            if (lead.Status == 'Ganho') {
                System.debug('Chamando validateLeadStatus para Lead com status "Ganho"');
                leadsGanho.add(lead);
            }
        }
        if (!leadsGanho.isEmpty()) {
            LeadTriggerValidation.validateLeadStatus(leadsGanho, trigger.oldMap);
        }
    }

    // Chama a criação de Fatura_Distribuidora__c se o Link_Download__c não estiver vazio e tiver sido alterado
    if (trigger.isAfter && trigger.isUpdate) {
        for (Lead lead : trigger.new) {
            // Verifica se é uma atualização e se o campo Link_Download__c foi alterado
            Lead oldLead = trigger.oldMap.get(lead.Id);
            if (lead.Link_Download__c != null && lead.Link_Download__c != oldLead.Link_Download__c && lead.Origem_da_Opera_o__c != 'App') {
                LeadTriggerValidation.createFaturaDistribuidora(lead);
            }
        }
    }
    
    // Chama a criação de Fatura_Distribuidora__c para caso tenha dados preenchidos pela area logada sem o Download de arquivo - Atualização 2024-07-10 Adriana A. Xavier
    if ((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)) {
        for (Lead lead : trigger.new) {
            // Verifica se é uma atualização e o campo Origem Temporaria e os de Descontos foram preenchidos
            Lead oldLead = trigger.oldMap.get(lead.Id);
            if (lead.Origem_Temp__c == 'AreaLogada' && 
                ((lead.Desconto_Ofertado_1_anos__c != null && lead.Desconto_Ofertado_1_anos__c != oldLead.Desconto_Ofertado_1_anos__c) ||
                (lead.Desconto_Ofertado_2_anos__c != null && lead.Desconto_Ofertado_2_anos__c != oldLead.Desconto_Ofertado_2_anos__c) ||
                (lead.Desconto_Ofertado_3_anos__c != null && lead.Desconto_Ofertado_3_anos__c != oldLead.Desconto_Ofertado_3_anos__c) ||
                (lead.Desconto_Ofertado_4_anos__c != null && lead.Desconto_Ofertado_4_anos__c != oldLead.Desconto_Ofertado_4_anos__c) ||
                (lead.Desconto_Ofertado_5_anos__c != null && lead.Desconto_Ofertado_5_anos__c != oldLead.Desconto_Ofertado_5_anos__c) ||
                (lead.Desconto_Ofertado_Liberdade_total__c != null && lead.Desconto_Ofertado_Liberdade_total__c != oldLead.Desconto_Ofertado_Liberdade_total__c))
            ) {
                LeadTriggerValidation.createFaturaDistribuidoraAreaLogada(lead);
                
            }
        }
    }
    
        // Chama o cancelamento da Oportunidade - Atualização 2024-07-10 Adriana A. Xavier
  if ((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)) {
         for (Lead lead : Trigger.new) {
            // Verifica se é uma atualização e o campo Origem Temporaria e os de Descontos foram preenchidos
            Lead oldLead = trigger.oldMap.get(lead.Id);
            if (lead.ID_Cotacao__c != oldLead.ID_Cotacao__c && lead.ID_Cotacao__c !=null)
             {
               LeadTriggerValidation.CancelaOportunidade(lead);
            }
        }
    }
    // Atualiza a fatura quando processada
    if (trigger.isAfter && trigger.isUpdate) {
        for (Lead lead : trigger.new) {
            // Verifica se é uma atualização e se o campo Fatura_Processada__c foi alterado
            Lead oldLead = trigger.oldMap.get(lead.Id);
            if (lead.Fatura_Processada__c == true && lead.Fatura_Processada__c != oldLead.Fatura_Processada__c && lead.Origem_da_Opera_o__c != 'App') {
                LeadTriggerValidation.updateFaturaDistribuidora(lead);
            }
        }
    }
}