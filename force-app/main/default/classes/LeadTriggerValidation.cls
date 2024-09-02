public class LeadTriggerValidation {

    public static boolean ValidarPJBeforeInsertOrUpdate(Lead lead) {
        boolean erro = false;       
        if (lead.CNPJ__c != null) {
            String cnpj = ValidarDocumento.cnpjValido(lead.CNPJ__c);
            if (cnpj == null) {
                lead.CNPJ__c.addError('CNPJ Está Inválido - Verifique (BIU)');
                erro = true;
            } else {
                lead.CNPJ__c = cnpj;
                lead.Base_do_CNPJ_CPF__c = cnpj.substring(0, 8);
            }
        }

        String integrationUserName  = [SELECT IntegrationUserName__c FROM GeneralParameter__mdt LIMIT 1].IntegrationUserName__c;     
        String usuarioAtual = UserInfo.getName();

        if (lead.Status == 'Converted' && integrationUserName != usuarioAtual) {
            System.debug('Lead converted - Erro');
            lead.addError('Opção de Status não permitida - Utilize a opção (Integrar)');
            erro = true;
        }
        return erro;
    }

    public static boolean ValidarPFBeforeInsertOrUpdate(Lead lead) {
        boolean erro = false;       
        if (lead.CNPJ__c != null) {
            String cpf = ValidarDocumento.cpfValido(lead.CNPJ__c);
            if (cpf == null) {
                lead.CNPJ__c.addError('CPF Está Inválido - Verifique (BIU)');
                erro = true;
            } else {
                lead.CNPJ__c = cpf;
                lead.Base_do_CNPJ_CPF__c = cpf;
            }
        }

        String integrationUserName  = [SELECT IntegrationUserName__c FROM GeneralParameter__mdt LIMIT 1].IntegrationUserName__c;     
        String usuarioAtual = UserInfo.getName();

        if (lead.Status == 'Converted' && integrationUserName != usuarioAtual) {
            System.debug('Lead converted - Erro');
            lead.addError('Opção de Status não permitida - Utilize a opção (Integrar)');
            erro = true;
        }
        return erro;
    }

    public static boolean ValidarDadosFormatados(Lead lead) {
        boolean erro = false;
        if (!String.isEmpty(lead.CEP__c)) {
            ValidarCepResult result = ValidarCep.cepValido(lead.CEP__c);
            if (!result.validado) {
                lead.CEP__c.addError(result.mensagem);
                erro = true;                    
            }
        }

        erro = validarTelefone(lead.Phone, 'Phone', lead) || erro;
        erro = validarTelefone(lead.MobilePhone, 'MobilePhone', lead) || erro;

        return erro;
    }    

    private static boolean validarTelefone(String telefone, String telefoneCampo, Lead lead) {
        boolean erro = false;
        if (!String.isEmpty(telefone)) {
            ValidarTelefoneResult result = ValidarTelefone.telefoneValido(telefone);
            if (!result.validado) {
                lead.addError(telefoneCampo, result.mensagem);
                erro = true;                    
            } else {
                if (telefoneCampo == 'Phone') {
                    lead.Phone = result.telefoneFormatadoParaGravar;
                } else if (telefoneCampo == 'MobilePhone') {
                    lead.MobilePhone = result.telefoneFormatadoParaGravar;
                }
            }
        }
        return erro;
    }

    public static boolean ValidarPJDemaisDados(Lead lead) {
        boolean erro = false;
        
        AtualizarDadosDaVarejista(lead);
        
        if (lead.QuantityUnidtsNegotiable__c > lead.TotalUnitsQuantity__c) {
            lead.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
            erro = true;                    
        }
        if (lead.Company == null) {
            lead.Company.addError('Informe o nome da Empresa');
            erro = true;                    
        }

        erro = validarStatusLeadPJ(lead) || erro;

        return erro;
    }

    public static boolean ValidarPFDemaisDados(Lead lead) {
        boolean erro = false;
        
        AtualizarDadosDaVarejista(lead);
        
        if (lead.QuantityUnidtsNegotiable__c > lead.TotalUnitsQuantity__c) {
            lead.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
            erro = true;                    
        }
        if (lead.Company == null) {
            lead.Company.addError('Informe o Nome');
            erro = true;                    
        }
        if (lead.FantasyName__c == null) {
            lead.FantasyName__c.addError('Informe o apelido');
            erro = true;                    
        }

        erro = validarStatusLeadPF(lead) || erro;

        return erro;
    }

    private static boolean validarStatusLeadPJ(Lead lead) {
        boolean erro = false;
        if (lead.Status == 'Integrate' || lead.Status == 'Converted') {
            List<Units__c> lstUnidadeExistente = [SELECT Id FROM Units__c WHERE Lead__c = :lead.Id];
            if (Trigger.isUpdate) {
                if (lead.Status == 'Desqualificado') {
                    erro = true;
                    lead.addError('Você não pode converter ou Integrar um Lead desqualificado');
                }
            }
        } else if (lead.Status == 'Desqualificado') {
            erro = validarDesqualificacao(lead) || erro;
        }
        return erro;
    }

    private static boolean validarStatusLeadPF(Lead lead) {
        boolean erro = false;
        if (lead.Status == 'Integrate' || lead.Status == 'Converted') {
            List<Units__c> lstUnidadeExistente = [SELECT Id FROM Units__c WHERE Lead__c = :lead.Id];
            if (Trigger.isUpdate) {
                if (lead.Status == 'Desqualificado') {
                    erro = true;
                    lead.addError('Você não pode converter ou Integrar um Lead desqualificado');
                }
            }
        } else if (lead.Status == 'Desqualificado') {
            erro = validarDesqualificacao(lead) || erro;
        } else {
            erro = validarQualificacao(lead) || erro;
        }
        return erro;
    }

    private static boolean validarDesqualificacao(Lead lead) {
        boolean erro = false;
        String erroDesqualificacao = '';
        if (lead.DisqualifiedLead__c == null)
            erroDesqualificacao += 'Informe o motivo da desqualificação do Lead (campo: Lead Desqualificado) ';
        if (erroDesqualificacao != '') {
            lead.addError(erroDesqualificacao);
            erro = true;
        }
        return erro;
    }

    private static boolean validarQualificacao(Lead lead) {
        boolean erro = false;
        String erroQualificado = '';
        if (lead.DisqualifiedLead__c != null)
            erroQualificado += '(campo: Lead Desqualificado) só pode ser informado para Lead desqualificado | ';
        if (lead.Disqualified__c != null)
            erroQualificado += '(campo: Observação Lead Desqualificado) só pode ser informado para Lead desqualificado';
        if (erroQualificado != '') {
            erro = true;
            lead.addError(erroQualificado);
        }
        return erro;
    }

    private static void AtualizarDadosDaVarejista(Lead lead) {
        List<User> lstUserVendedor = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :lead.OwnerId];
        for (User userVendedor : lstUserVendedor) {
            List<Account> lstConta = [SELECT Id, OwnerId FROM Account WHERE Id = :userVendedor.AccountId];
            for (Account conta : lstConta) {
                lead.RetailPartnerAccount__c = userVendedor.AccountId;   // Conta do Parceiro;
                lead.RetailVendor__c = userVendedor.ContactId;           // Vendedor do Parceiro;
                lead.RetailKeyAccount__c = conta.OwnerId;                // Key account do parceiro;
                lead.RetailPartnerManager__c = userVendedor.ContactId;   // Gestor do parceiro;                 
                List<Contact> lstUserGestor = [SELECT Id, ReportsToId FROM Contact WHERE Id = :userVendedor.ContactId LIMIT 1];
                for (Contact userGestor : lstUserGestor) {
                    if (userGestor.ReportsToId == null)
                        lead.RetailPartnerManager__c = userVendedor.ContactId;                    
                    else
                        lead.RetailPartnerManager__c = userGestor.ReportsToId;                    
                }
                break;
            }
        }
    }

    public static String ObterDeveloperNameInRecordType(Id recordType) {
        List<RecordType> developerName = [SELECT DeveloperName FROM RecordType WHERE Id = :recordType];     
        for (RecordType rt : developerName) {
            return rt.DeveloperName;
        }
        return null;
    }

    public static void validateLeadStatus(List<Lead> leads, Map<Id, Lead> oldLeadsMap) {
        for (Lead lead : leads) {
            // Caso seja marcado manualmente como Perdido ou Desqualificado
            if (lead.Status == 'Desqualificado' || lead.Status == 'Perdido') {
                lead.Status__c = 'Perdido';
            } else {
                // Verificação para Status Simulação
                if ((lead.Etapa__c == 'Etapa 3: Plano gerado com sucesso' || lead.Etapa__c == 'Etapa 4: Formulário de dados gerais e contrato não gerado') &&
                    lead.Origem_Temp__c != 'AreaLogada' &&
                    lead.Multa_Da_distribuidora__c == false &&
                    lead.Erro_Gen_rico_de_Simula_o__c == false &&
                    lead.Erro_Leitura_Fatura__c == false &&
                    lead.Fora_da_rea_de_Cobertura__c == false &&
                    lead.Distribuidora_n_o_Atendida__c == false ) {
                    
                    // Verificação se a etapa foi alterada
                    if (oldLeadsMap.containsKey(lead.Id) && oldLeadsMap.get(lead.Id).Etapa__c != lead.Etapa__c) {
                        lead.Status__c = 'Simulação';
                        CriarOportunidade(lead);
                    }
                }

                // Verificação para Status Perdido
                if ((lead.Fora_da_rea_de_Cobertura__c == true &&
                    lead.DisqualifiedLead__c != null &&
                    lead.Disqualified__c == 'Blocklist')) {
                    
                    lead.Status__c = 'Perdido';
                }

                // Verificação para Status Contrato Gerado e empresa igual a LUZ
                if (lead.Contrato_Gerado__c == true && (lead.Recordtype_Name__c=='LeadPF'  || lead.Recordtype_Name__c=='LeadPJ')) {
                    lead.Status__c = 'Contrato Gerado';
                    System.debug('Lead está no status Contrato Gerado.');
                }
                
                // Verificação para Status Ganho e empresa igual a LUZ
                if (lead.Contrato_Assinado__c == true && (lead.Recordtype_Name__c=='LeadPF'  || lead.Recordtype_Name__c=='LeadPJ') ) {
                    lead.Status__c = 'Ganho';
                    System.debug('Lead está no status Ganho.');
                }
            }
        }
    }
    
    // Cancela oportunidade existente
    public static void CancelaOportunidade(Lead lead) {
        // Consulta a oportunidade usando o ID fornecido
        Opportunity opp = [SELECT Id, StageName, LossReason__c, LossReasonObs__c, Data_de_Desqualifica_o__c FROM Opportunity WHERE Lead__c = :lead.Id AND StageName != 'Perdido' LIMIT 1];

        // Atualiza o campo StageName para "Perdido"
        opp.StageName = 'Perdido';
        opp.LossReason__c = 'Substituida';
        opp.LossReasonObs__c = 'Substituida';
        opp.Data_de_Desqualifica_o__c = Datetime.now();

        // Realiza a atualização da oportunidade
        try {
            update opp;
            System.debug('Oportunidade cancelada com sucesso: ' + opp.Id);
            // Chama o método para criar uma nova oportunidade
            CriarOportunidade(lead);
           
        } catch (DmlException e) {
            System.debug('Erro ao cancelar oportunidade: ' + e.getMessage());
        }
    }

    public static void CriarOportunidade(Lead lead) {
        System.debug('Iniciando criação de oportunidade para o Lead: ' + lead.Id);
        String DeveloperName;
        Id Name = null;

        if (lead.Recordtype_Name__c == 'LeadPF') {
            DeveloperName = 'Oportunidade_PF_Luz';
        } else if (lead.Recordtype_Name__c == 'LeadPJ') {
            DeveloperName = 'Oportunidade_PJ_Luz';
        } else if (lead.Recordtype_Name__c == 'PJDelta' || lead.Recordtype_Name__c == 'PFDelta' || lead.Recordtype_Name__c == 'PPDelta' || lead.Recordtype_Name__c == 'Delta_Atacadista') {
            DeveloperName = 'Opportunity_Delta';
        }

        // Buscando o RecordType
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = :DeveloperName LIMIT 1];

        // Verificando se foi encontrado algum RecordType
        if (!recordTypes.isEmpty()) {
            // Armazenando o ID do RecordType encontrado na variável Name
            Name = recordTypes[0].Id;
            System.debug('RecordType encontrado: ' + Name);
        } else {
            // Caso não seja encontrado nenhum RecordType, pode-se adicionar um tratamento de erro ou lidar com a situação de outra forma
            System.debug('Nenhum RecordType encontrado com o Developer Name especificado.');
            return;
        }

        // Criando uma nova instância de oportunidade
        Opportunity opportunity = new Opportunity();
        // Definindo os campos desejados para a oportunidade
        opportunity.Bairro__c = lead.District__c;
        opportunity.CEP__c = lead.CEP__c;
        opportunity.CPF_CNPJ__c = lead.CNPJ__c;
        opportunity.Cidade__c = lead.City__c;
        opportunity.CloseDate = Date.today().addDays(60);
        opportunity.Company__c = lead.Company__c;
        opportunity.Complemento__c = lead.Complement__c;
        opportunity.E_mail_de_contato__c = lead.Email;
        opportunity.Empresa_Nome__c = lead.Company;
        opportunity.Lead__c = lead.Id;
        opportunity.Logradouro__c = lead.Address__c;
        opportunity.N_mero__c = lead.AdressNumber__c;
        opportunity.StageName = 'Proposta';
        opportunity.Telefone_de_contato__c = lead.Phone;
        opportunity.UF__c = lead.UF__c;
        opportunity.Valor_Conta__c = lead.Valor_Conta__c;
        opportunity.Valor_da_Fatura_R__c = lead.Valor_da_Fatura__c;
        opportunity.RecordTypeId = Name;
        opportunity.Name = lead.Company;
        opportunity.Nome_do_contato__c = lead.Name;
        opportunity.Pessoa_F_sica_Jur_dica__c = lead.PFPJ__c;
        opportunity.UC__c = lead.FantasyName__c;
        opportunity.Numero_da_Instala_o__c = lead.NumeroInstalacao__c;
        opportunity.Valor_da_Iluminacao_publica__c = lead.Valor_da_Iluminacao_publica__c;
        opportunity.Fase__c = lead.Fase__c;
        opportunity.ID_Cotacao__c = lead.ID_Cotacao__c;
        opportunity.Origem_da_Opera_o__c = lead.Origem_Temp__c;
        opportunity.Cargo__c = lead.Office__c;
        opportunity.Celular__c = lead.MobilePhone;
        opportunity.Quantidade_de_Unidades_Totais__c = lead.TotalUnitsQuantity__c;
        opportunity.Quantidade_de_Unidades_Negociaveis__c = lead.QuantityUnidtsNegotiable__c;
        opportunity.Mercado__c = lead.Marketplace__c;
        opportunity.AditionalComment__c = lead.Note__c;
        opportunity.Grupo_Econ_mico__c = lead.EconomicGroup__c;
        opportunity.Estado_Civil__c = lead.MaritalStatus__c;
        opportunity.Sexo__c = lead.Gender__c;
        opportunity.Profiss_o__c = lead.Occupation__c;
        opportunity.Description = lead.Description;
        opportunity.Baixa_Renda__c = lead.Baixa_Renda__c;
        opportunity.Consumo_kWh__c = lead.CONSUMO__c;
        opportunity.Campaign__c = lead.Campaign__c;
        opportunity.Comercial__c = lead.Comercialuz__c;
        opportunity.ConsumoHistorico__c = lead.ConsumoHistorico__c;
        opportunity.ConsumoMensal__c = lead.ConsumoMensal__c;
        opportunity.ConsumoUtilizado__c = lead.ConsumoUtilizado__c;
        opportunity.Contrato_Assinado__c = lead.Contrato_Assinado__c;
        opportunity.Contrato_Gerado__c = lead.Contrato_Gerado__c;
        opportunity.Criativo__c = lead.Criativo__c;
        opportunity.Cupom__c = lead.Cupom__c;
        opportunity.DateSimulation__c = lead.Data_Simulacao__c;
        opportunity.Data_do_contrato_assinado__c = lead.Data_do_contrato_assinado__c;
        opportunity.Data_da_Gera_o_do_Contrato__c = lead.Data_do_contrato_gerado__c;
        opportunity.Desconto_Ofertado_1_anos__c = lead.Desconto_Ofertado_1_anos__c;
        opportunity.Desconto_Ofertado_2_anos__c = lead.Desconto_Ofertado_2_anos__c;
        opportunity.Desconto_Ofertado_3_anos__c = lead.Desconto_Ofertado_3_anos__c;
        opportunity.Desconto_Ofertado_4_anos__c = lead.Desconto_Ofertado_4_anos__c;
        opportunity.Desconto_Ofertado_5_anos__c = lead.Desconto_Ofertado_5_anos__c;
        opportunity.Desconto_Ofertado_Liberdade_total__c = lead.Desconto_Ofertado_Liberdade_total__c;
        opportunity.Desconto_escolhido_pelo_cliente__c = lead.Desconto_escolhido_pelo_cliente__c;
        opportunity.Distribuidora_n_o_Atendida__c = lead.Distribuidora_n_o_Atendida__c;
        opportunity.Email_do_Parceiro__c = lead.Email_do_Parceiro__c;
        opportunity.Erro_Gen_rico_de_Simula_o__c = lead.Erro_Gen_rico_de_Simula_o__c;
        opportunity.Erro_Leitura_Fatura__c = lead.Erro_Leitura_Fatura__c;
        opportunity.Erros__c = lead.Erros__c;
        opportunity.Fatura_Anexada__c = lead.Fatura_Anexada__c;
        opportunity.DistribuidoraLuz__c = lead.DistribuidoraLuz__c;
        opportunity.Pr_Lead__c = lead.Pr_Lead__c;

        try {
            insert opportunity;
            System.debug('Oportunidade criada com sucesso para o Lead: ' + lead.Id);
            // Atualizar Fatura_Distribuidora
            updateFaturaDistribuidora(lead, opportunity);

        } catch (DmlException e) {
            System.debug('Erro ao criar oportunidade: ' + e.getMessage());
        }
    }

    public static void updateFaturaDistribuidora(Lead lead, Opportunity opportunity) {
        try {
            // Query for existing Fatura_Distribuidora__c with matching Lead__c
            List<Fatura_Distribuidora__c> faturaList = [
                SELECT Id, AccountValue__c, Consumo_Abaixo_do_Range__c, Consumo_Historico__c, Consumo_Mensal__c, Consumo_Utilizado__c,
                       Distribuidora__c, Link_Download__c, Name, Valor_da_Fatura_R__c, Baixa_Renda__c, Classifica_o__c, Distribuidora_n_o_Atendida__c,
                       Erro_Gen_rico_de_Simula_o__c, Erro_Leitura_Fatura__c, Erros__c, Fatura_Anexada__c, Fatura_Processada__c, 
                       Guid_do_Arquivo_na_Digitaliza_o__c, Lead__c, Multa_da_Distribuidora__c, Nome_do_Arquivo_anexo_com_extens_o__c, 
                       Origem__c, Pr_Lead__c, Boptante__c
                FROM Fatura_Distribuidora__c
                WHERE Lead__c = :lead.Id
            ];

            if (!faturaList.isEmpty()) {
                for (Fatura_Distribuidora__c fatura : faturaList) {
                    // Update the Fatura_Distribuidora__c fields with values from the Lead
                    fatura.Oportunidade__c = opportunity.Id;
                }

                // Update the list of Fatura_Distribuidora__c records
                update faturaList;
                System.debug('Fatura_Distribuidora__c atualizada com sucesso para o Lead: ' + lead.Id);
            } else {
                System.debug('Nenhuma Fatura_Distribuidora__c encontrada para o Lead: ' + lead.Id);
            }
        } catch (DmlException e) {
            System.debug('Erro ao atualizar Fatura_Distribuidora__c: ' + e.getMessage());
        }
    }

    public static void createFaturaDistribuidora(Lead lead) {
        Fatura_Distribuidora__c fatura = new Fatura_Distribuidora__c();
        fatura.AccountValue__c = lead.Valor_Conta__c;
        fatura.Consumo_Abaixo_do_Range__c = lead.Consumo_Abaixo_do_Range__c;
        fatura.Consumo_Historico__c = lead.ConsumoHistorico__c;
        fatura.Consumo_Mensal__c = lead.ConsumoMensal__c;
        fatura.Consumo_Utilizado__c = lead.ConsumoUtilizado__c;
        fatura.Distribuidora__c = lead.DistribuidoraLuz__c;
        fatura.Link_Download__c = lead.Link_Download__c;
        fatura.Name = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
        fatura.Valor_da_Fatura_R__c = lead.Valor_da_Fatura__c;
        fatura.Baixa_Renda__c = lead.Baixa_Renda__c;
        fatura.Classifica_o__c = lead.Rating;
        fatura.Distribuidora_n_o_Atendida__c = lead.Distribuidora_n_o_Atendida__c;
        fatura.Erro_Gen_rico_de_Simula_o__c = lead.Erro_Gen_rico_de_Simula_o__c;
        fatura.Erro_Leitura_Fatura__c = lead.Erro_Leitura_Fatura__c;
        fatura.Erros__c = lead.Erros__c;
        fatura.Fatura_Anexada__c = lead.Fatura_Anexada__c;
        fatura.Fatura_Processada__c = lead.Fatura_Processada__c;
        fatura.Guid_do_Arquivo_na_Digitaliza_o__c = lead.GuidArquivoDaDigitalizacao__c;
        fatura.Lead__c = lead.Id;
        fatura.Multa_da_Distribuidora__c = lead.Multa_Da_distribuidora__c;
        fatura.Nome_do_Arquivo_anexo_com_extens_o__c = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
        fatura.Origem__c = lead.Origem_Temp__c;
        fatura.Oportunidade__c = lead.Oportunidade__c;
        fatura.Boptante__c = lead.Boptante__c;

        try {
            insert fatura;
            System.debug('Fatura_Distribuidora__c criada com sucesso para o Lead: ' + lead.Id);
        } catch (DmlException e) {
            System.debug('Erro ao criar Fatura_Distribuidora__c: ' + e.getMessage());
        }
    }

    public static void updateFaturaDistribuidora(Lead lead) {
        try {
            // Query for existing Fatura_Distribuidora__c with matching Name and Lead__c
            List<Fatura_Distribuidora__c> faturaList = [
                SELECT Id, AccountValue__c, Consumo_Abaixo_do_Range__c, Consumo_Historico__c, Consumo_Mensal__c, Consumo_Utilizado__c,
                       Distribuidora__c, Link_Download__c, Name, Valor_da_Fatura_R__c, Baixa_Renda__c, Classifica_o__c, Distribuidora_n_o_Atendida__c,
                       Erro_Gen_rico_de_Simula_o__c, Erro_Leitura_Fatura__c, Erros__c, Fatura_Anexada__c, Fatura_Processada__c, 
                       Guid_do_Arquivo_na_Digitaliza_o__c, Lead__c, Multa_da_Distribuidora__c, Nome_do_Arquivo_anexo_com_extens_o__c, 
                       Origem__c, Pr_Lead__c, Boptante__c
                FROM Fatura_Distribuidora__c
                WHERE Name = :lead.Nome_do_Arquivo_anexo_com_extens_o__c AND Lead__c = :lead.Id
                LIMIT 1
            ];

            if (!faturaList.isEmpty()) {
                Fatura_Distribuidora__c fatura = faturaList[0];
                // Update the Fatura_Distribuidora__c fields with values from the Lead
                fatura.AccountValue__c = lead.Valor_Conta__c;
                fatura.Consumo_Abaixo_do_Range__c = lead.Consumo_Abaixo_do_Range__c;
                fatura.Consumo_Historico__c = lead.ConsumoHistorico__c;
                fatura.Consumo_Mensal__c = lead.ConsumoMensal__c;
                fatura.Consumo_Utilizado__c = lead.ConsumoUtilizado__c;
                fatura.Distribuidora__c = lead.DistribuidoraLuz__c;
                fatura.Link_Download__c = lead.Link_Download__c;
                fatura.Name = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
                fatura.Valor_da_Fatura_R__c = lead.Valor_da_Fatura__c;
                fatura.Baixa_Renda__c = lead.Baixa_Renda__c;
                fatura.Classifica_o__c = lead.Rating;
                fatura.Distribuidora_n_o_Atendida__c = lead.Distribuidora_n_o_Atendida__c;
                fatura.Erro_Gen_rico_de_Simula_o__c = lead.Erro_Gen_rico_de_Simula_o__c;
                fatura.Erro_Leitura_Fatura__c = lead.Erro_Leitura_Fatura__c;
                fatura.Erros__c = lead.Erros__c;
                fatura.Fatura_Anexada__c = lead.Fatura_Anexada__c;
                fatura.Fatura_Processada__c = lead.Fatura_Processada__c;
                fatura.Guid_do_Arquivo_na_Digitaliza_o__c = lead.GuidArquivoDaDigitalizacao__c;
                fatura.Lead__c = lead.Id;
                fatura.Multa_da_Distribuidora__c = lead.Multa_Da_distribuidora__c;
                fatura.Nome_do_Arquivo_anexo_com_extens_o__c = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
                fatura.Origem__c = lead.Origem_Temp__c;
                fatura.Oportunidade__c = lead.Oportunidade__c;
                fatura.Pr_Lead__c = lead.Pr_Lead__c;
                fatura.Boptante__c = lead.Boptante__c;

                // Update the Fatura_Distribuidora__c record
                update fatura;
                System.debug('Fatura_Distribuidora__c atualizada com sucesso para o Lead: ' + lead.Id);
            } else {
                System.debug('Nenhuma Fatura_Distribuidora__c encontrada para o Lead: ' + lead.Id);
            }
        } catch (DmlException e) {
            System.debug('Erro ao atualizar Fatura_Distribuidora__c: ' + e.getMessage());
        }
    }
    
    public static void createFaturaDistribuidoraAreaLogada(Lead lead) {
        Fatura_Distribuidora__c fatura = new Fatura_Distribuidora__c();
        fatura.AccountValue__c = lead.Valor_Conta__c;
        fatura.Consumo_Abaixo_do_Range__c = lead.Consumo_Abaixo_do_Range__c;
        fatura.Consumo_Historico__c = lead.ConsumoHistorico__c;
        fatura.Consumo_Mensal__c = lead.ConsumoMensal__c;
        fatura.Consumo_Utilizado__c = lead.ConsumoUtilizado__c;
        fatura.Distribuidora__c = lead.DistribuidoraLuz__c;
        fatura.Link_Download__c = lead.Link_Download__c;
        fatura.Name = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
        fatura.Valor_da_Fatura_R__c = lead.Valor_da_Fatura__c;
        fatura.Baixa_Renda__c = lead.Baixa_Renda__c;
        fatura.Classifica_o__c = lead.Rating;
        fatura.Distribuidora_n_o_Atendida__c = lead.Distribuidora_n_o_Atendida__c;
        fatura.Erro_Gen_rico_de_Simula_o__c = lead.Erro_Gen_rico_de_Simula_o__c;
        fatura.Erro_Leitura_Fatura__c = lead.Erro_Leitura_Fatura__c;
        fatura.Erros__c = lead.Erros__c;
        fatura.Fatura_Anexada__c = lead.Fatura_Anexada__c;
        fatura.Fatura_Processada__c = lead.Fatura_Processada__c;
        fatura.Guid_do_Arquivo_na_Digitaliza_o__c = lead.GuidArquivoDaDigitalizacao__c;
        fatura.Lead__c = lead.Id;
        fatura.Multa_da_Distribuidora__c = lead.Multa_Da_distribuidora__c;
        fatura.Nome_do_Arquivo_anexo_com_extens_o__c = lead.Nome_do_Arquivo_anexo_com_extens_o__c;
        fatura.Origem__c = lead.Origem_Temp__c;
        fatura.Oportunidade__c = lead.Oportunidade__c;
        fatura.Boptante__c = lead.Boptante__c;

        try {
            insert fatura;
            System.debug('Fatura_Distribuidora__c criada com sucesso para o Lead: ' + lead.Id);
            // Chama a função para criar a oportunidade após a inserção da fatura
            CriarOportunidade(lead);
            
        } catch (DmlException e) {
            System.debug('Erro ao criar Fatura_Distribuidora__c: ' + e.getMessage());
        }
    }
    
   

    public static void subirCobertura() {
        for (Integer i = 0; i < 5000; i++) {
            i++;
        }
    }
}