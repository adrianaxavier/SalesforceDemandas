//------------------------------------------------------------------------------------------------
// Projeto Delta Energia - 11/08/2022 
//------------------------------------------------------------------------------------------------
trigger PreLeadTrigger on PreLead__c (before insert, before update) {
    // Map to store company IDs
    Map<String, Id> empresaMap = new Map<String, Id>();

    // Get all RecordTypes at once to avoid SOQL within loops
    Map<String, Id> recordTypeMap = new Map<String, Id>();
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'PreLead__c']) {
        recordTypeMap.put(rt.Name, rt.Id);
    }

    // Prepare a list of company names
    List<String> empresasNomes = new List<String>{'DELTA', 'LUZ'};
    Map<String, Company__c> empresas = new Map<String, Company__c>([SELECT Id, Name FROM Company__c WHERE Name IN :empresasNomes]);

    List<PreLead__c> preLeadsToUpdate = new List<PreLead__c>();

    for (PreLead__c preLead : Trigger.new) {
        // Initialize variables
        String nomeEmpresa;
        Id idEmpresa = null;

        // Determine the company
        if (preLead.PFPJ__c == 'PJ' && preLead.AccountValue__c >= 10000 && preLead.Produto__c != 'GD' && preLead.InformationSource__c != 'AreaLogada') {
            nomeEmpresa = 'DELTA';
        } else {
            nomeEmpresa = 'LUZ';
        }

        // Locate company ID
        if (empresas.containsKey(nomeEmpresa)) {
            idEmpresa = empresas.get(nomeEmpresa).Id;
        }

        // Set company of the group
        preLead.Company__c = idEmpresa;

        // Locate RecordTypeId based on company name
        if (recordTypeMap.containsKey(nomeEmpresa)) {
            preLead.RecordTypeId = recordTypeMap.get(nomeEmpresa);
        }

        // Determine the Fonte__c field based on InformationSource__c
        if (preLead.InformationSource__c == 'SiteLuz' || 
            preLead.InformationSource__c == 'AreaLogada' || 
            preLead.InformationSource__c == 'ADS') {
            preLead.Fonte__c = preLead.Parceiro__c ? 'Parceiros' : 'Inbound';
        } else {
            preLead.Fonte__c = 'Outbound';
        }

        // Set WhatsApp field
        preLead.Whatsapp__c = 'whatsapp:+' + preLead.PhoneNumber__c;
        preLead.NumeroInstalacao__c = '0';
        preLead.Locale__c = 'BR';

        // Validate ninth digit and update phones
        String telefoneMKT;
        if (preLead.PhoneNumber__c != null && preLead.PhoneNumber__c.length() == 12 && preLead.PhoneNumber__c.substring(0, 4) == '5541') {
            telefoneMKT = preLead.PhoneNumber__c.substring(0, 4) + '9' + preLead.PhoneNumber__c.substring(4, 12);
        } else {
            telefoneMKT = preLead.PhoneNumber__c;
        }

        preLead.Telefone_MKT__c = telefoneMKT;
        preLead.PhoneNumber__c = telefoneMKT;

        // Validate CPFCNPJ__c
        if (!String.isEmpty(preLead.CPFCNPJ__c)) {
            String docto = ValidarDocumento.cnpjValido(preLead.CPFCNPJ__c);
            if (docto == null) {
                docto = ValidarDocumento.cpfValido(preLead.CPFCNPJ__c);
                if (docto == null) {
                    preLead.CPFCNPJ__c.addError('CPF/CNPJ Está Inválido - Verifique');
                } else {
                    preLead.PFPJ__c = 'PF';
                    preLead.CPFCNPJ__c = docto;
                }
            } else {
                preLead.PFPJ__c = 'PJ';
                preLead.CPFCNPJ__c = docto;
            }
        }

        // Update date fields based on conditions
        if (preLead.Hired__c && preLead.DateContratado__c == null) {
            preLead.DateContratado__c = DateTime.now();
        }

        if (!preLead.Hired__c && preLead.DateContratado__c != null) {
            preLead.DateContratado__c = null;
        }

        if (preLead.ContratoGerado__c && preLead.DateContrato__c == null) {
            preLead.DateContrato__c = DateTime.now();
            preLead.Validade_do_Contrato__c = DateTime.now().addDays(60);
        }

        if (!preLead.ContratoGerado__c && preLead.DateContrato__c != null) {
            preLead.DateContrato__c = null;
            preLead.Validade_do_Contrato__c = null;
        }

        // Reset desqualificação fields if status is not 'Desqualificado'
        if (preLead.Data_de_Desqualificacao__c != null && preLead.Status__c != 'Desqualificado') {
            preLead.Data_de_Desqualificacao__c = null;
            preLead.Motivo_Desqualifica_o__c = null;
            preLead.Observa_o_da_Desqualifica_o__c = null;
        }

        // Assign owner based on CollaboratorId__c
        if (preLead.CollaboratorId__c != null) {
            for (User user : [SELECT Id, Name, IsActive FROM User WHERE DeltaCode__c = :preLead.CollaboratorId__c AND IsActive = true]) {
                preLead.OwnerId = user.Id;
                preLead.CollaboratorId__c = null;
            }
        }

        // Validate formatted data
        PreLeadTriggerValidation.ValidarDadosFormatados(preLead);

        if (preLead.Lead__c == null) {
            // Check if there's another lead with the same phone number
            List<Lead> leads = [SELECT Id, FirstName, LastName, CEP__c, LastModifiedDate, CNPJ__c, Office__c, Company, Email, Phone, MobilePhone, Company__c, Address__c, AdressNumber__c, Complement__c, District__c, City__c, UF__c, TotalUnitsQuantity__c, QuantityUnidtsNegotiable__c, Marketplace__c, Note__c, StateRegistration__c, MunicipalRegistration__c, EconomicGroup__c, MaritalStatus__c, Gender__c, Occupation__c, Description, Baixa_Renda__c, CONSUMO__c, Campaign__c, Comercialuz__c, ConsumoHistorico__c, ConsumoMensal__c, ConsumoUtilizado__c, Contrato_Assinado__c, Contrato_Gerado__c, Criativo__c, Cupom__c, Data_Simulacao__c, Data_do_contrato_assinado__c, Data_do_contrato_gerado__c, Desconto_Ofertado_1_anos__c, Desconto_Ofertado_2_anos__c, Desconto_Ofertado_3_anos__c, Desconto_Ofertado_4_anos__c, Desconto_Ofertado_5_anos__c, Desconto_Ofertado_Liberdade_total__c, Desconto_escolhido_pelo_cliente__c, DistribuidoraLuz__c, Distribuidora_n_o_Atendida__c, Email_do_Parceiro__c, Erro_Gen_rico_de_Simula_o__c, Erro_Leitura_Fatura__c, Erros__c, Fatura_Anexada__c, Fatura_Processada__c, Fluxo__c, Garantidor__c, Growth__c, GuidArquivoDaDigitalizacao__c, Industry, Industry__c, InitialDiscount__c, Inside_Sales__c, LOCALE__c, Medium__c, Multa_Da_distribuidora__c, N_o_Incomodar__c, Nome_do_Arquivo_anexo_com_extens_o__c, Nome_do_Parceiro__c, NumeroInstalacao__c, Numero_de_Contatos__c, Numero_de_E_mails__c, Observa_es_gerais_de_cr_dito__c, Origem_da_Opera_o__c, Fonte__c, Parceiro__c, Phone_second__c, Poss_vel_Fraude__c, Pr_Lead__c, Prazo_de_pagamento__c, Produto_escolhido_pelo_cliente__c, Qual_foi_a_base_de_c_lculo__c, Quantidade_de_meses__c, Rating, Redu_o_Custo__c, ReducaoCusto3anos__c, ReducaoCusto5anos__c, ReducaoCustoSemFidelidade__c, Score_SERASA__c, SimulacoesRealizadas__c, Source__c, Tarifa_Branca__c, Telefone_do_Parceiros__c, Term__c, Tipo_de_garantia__c, Tipo_de_produto__c, Validade_do_Contrato__c, Valor_Conta__c, Valor_da_Fatura__c, Volume_considerado_para_estudo_kWh__c, Whatsapp__c FROM Lead WHERE Phone = :preLead.PhoneNumber__c];
            Boolean createNewLead = true;
            if (!leads.isEmpty()) {
                for (Lead lead : leads) {
                    if (lead.CEP__c == preLead.CEP__c && lead.Company__c== preLead.Company__c) {
                        preLead.Lead__c = lead.Id;
                        // Update the existing lead with data from preLead
                        preLeadsToUpdate.add(preLead);
                        createNewLead = false;
                        break;
                    }
                    else
                   createNewLead = true; 
                }
            }
            if (createNewLead) {
                // Create new lead
                PreLeadTriggerValidation.CriarLead(preLead);
            }
        } else {
            // Add PreLead to the list for updating
            preLeadsToUpdate.add(preLead);
        }
    }

    // Call update of Leads if there are PreLeads to update
    if (!preLeadsToUpdate.isEmpty()) {
        PreleadToLeadUpdater.updateLeadsFromPreleads(preLeadsToUpdate);
    }
}