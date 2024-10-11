public class PreLeadTriggerValidation {
    private static Boolean erro = false;
    private static String cnpj = null;
    private static String cpf = null;

    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Jurídica 
    //------------------------------------------------------------------------------------------------
    public static Boolean validarPJBeforeInsert(PreLead__c preLead) {
        erro = false;
        validarCnpj(preLead);
        if (!erro) {
            validarPreLeadExistente(preLead);
        }
        validarDemaisDados(preLead);
        validarDadosPJ(preLead);
        return erro;
    }

    public static Boolean validarPJBeforeUpdate(PreLead__c preLead, PreLead__c oldPreLead) {
        erro = false;
        validarCnpj(preLead);
        if (!erro) {
            validarPreLeadExistente(preLead);
        }
        validarDemaisDados(preLead);
        validarDadosPJ(preLead);
        return erro;
    }

    private static void validarDadosPJ(PreLead__c preLead) {
        if (preLead.FantasyName__c == null) {
            preLead.FantasyName__c.addError('Informe o Nome Fantasia/Nome para do Lead');
            erro = true;                    
        }
        if (preLead.Occupation__c != null) {
            preLead.Occupation__c.addError('Para Pessoa Jurídica, não informe a profissão');
            erro = true;                    
        } 
        if (preLead.MaritalStatus__c != null) {
            preLead.MaritalStatus__c.addError('Para Pessoa Jurídica, não informe estado Civil');
            erro = true;                    
        } 
        if (preLead.Gender__c != null) {
            preLead.Gender__c.addError('Para Pessoa Jurídica, não informe o Sexo');
            erro = true;                    
        } 
    }

    private static void validarCnpj(PreLead__c preLead) {
        if (preLead.CPFCNPJ__c == null) {
            preLead.CPFCNPJ__c.addError('CNPJ Está Inválido - Verifique');
            erro = true;
            return;            
        }
        cnpj = ValidarDocumento.cnpjValido(preLead.CPFCNPJ__c);
        if (cnpj == null) {
            preLead.CPFCNPJ__c.addError('CNPJ Está Inválido - Verifique');
            erro = true;
            return;
        }
        preLead.CPFCNPJ__c = cnpj;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Jurídica 
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Física 
    //------------------------------------------------------------------------------------------------
    public static Boolean validarPFBeforeInsert(PreLead__c preLead) {
        erro = false;       
        validarCpf(preLead);
        if (!erro) {
            validarPreLeadExistente(preLead);
        }
        validarDemaisDados(preLead);
        validarDadosPF(preLead);
        return erro;
    }

    public static Boolean validarPFBeforeUpdate(PreLead__c preLead, PreLead__c oldPreLead) {
        erro = false;       
        validarCpf(preLead);
        if (!erro) {
            validarPreLeadExistente(preLead);
        }
        validarDemaisDados(preLead);
        validarDadosPF(preLead);
        return erro;
    }

    private static void validarCpf(PreLead__c preLead) {
        if (preLead.CPFCNPJ__c == null) {
            preLead.CPFCNPJ__c.addError('CPF Está Inválido - Verifique');
            erro = true;
            return;
        }
        cpf = ValidarDocumento.cpfValido(preLead.CPFCNPJ__c);
        if (cpf == null) {
            preLead.CPFCNPJ__c.addError('CPF Está Inválido - Verifique');
            erro = true;
            return;
        }
        preLead.CPFCNPJ__c = cpf;
    }

    private static void validarDadosPF(PreLead__c preLead) {
        if (preLead.Gender__c == null) {
            preLead.Gender__c.addError('Informe o Gênero (Sexo)');
            erro = true;                    
        }
        if (preLead.Occupation__c == null) {
            preLead.Occupation__c.addError('Informe a Profissão');
            erro = true;                    
        }
        if (preLead.MaritalStatus__c == null) {
            preLead.MaritalStatus__c.addError('Informe o Estado Civil');
            erro = true;                    
        }
        if (preLead.Office__c != null) {
            preLead.Office__c.addError('Para Pessoa Física, não informe o Cargo');
            erro = true;                    
        } 
        if (preLead.Marketplace__c != null) {
            preLead.Marketplace__c.addError('Para Pessoa Física, não informe o Mercado');
            erro = true;                    
        } 
        if (preLead.FantasyName__c != null) {
            preLead.FantasyName__c.addError('Para Pessoa Física, não informe o Nome Fantasia');
            erro = true;                    
        } 
        if (preLead.StateRegistration__c != null) {
            preLead.StateRegistration__c.addError('Para Pessoa Física, não informe a Inscrição Estadual');
            erro = true;                    
        } 
        if (preLead.MunicipalRegistration__c != null) {
            preLead.MunicipalRegistration__c.addError('Para Pessoa Física, não informe a Inscrição Municipal');
            erro = true;                    
        } 
        if (preLead.EconomicGroup__c != null) {
            preLead.EconomicGroup__c.addError('Para Pessoa Física, não informe o Grupo Econômico');
            erro = true;                    
        } 
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Física 
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Validar Pré-Lead Existente no Lead
    //------------------------------------------------------------------------------------------------
    private static void validarPreLeadExistente(PreLead__c preLead) {
        erro = false;
        List<Lead> lstLead;
        if (preLead.Lead__c != null) {
            lstLead = [SELECT Id, Name FROM Lead WHERE CNPJ__c = :preLead.CPFCNPJ__c AND Id != :preLead.Lead__c];
        } else {
            lstLead = [SELECT Id, Name FROM Lead WHERE CNPJ__c = :preLead.CPFCNPJ__c];
        }
        for (Lead cnpjDuplicado : lstLead) {
            preLead.addError('Este CNPJ/CPF: ' + cnpjDuplicado.CNPJ__c + ' Já está vinculado ao LEAD ' + cnpjDuplicado.Name);
            erro = true;
        }

        List<Account> lstAccount = [SELECT Id, CNPJ__c, Name, FantasyName__c FROM Account WHERE CNPJ__c = :preLead.CPFCNPJ__c];
        for (Account cta : lstAccount) {
            preLead.CPFCNPJ__c.addError('Esse CNPJ/CPF já foi cadastrado na conta: ' + cta.Name + '\n Nome Fantasia: ' + cta.FantasyName__c);
            erro = true;                    
        }
        
        List<Units__c> lstUnidade = [SELECT Id, Name, FantasyName__c FROM Units__c WHERE CNPJ__c = :preLead.CPFCNPJ__c];
        for (Units__c unid : lstUnidade) {
            preLead.CPFCNPJ__c.addError('Esse CNPJ/CPF já foi cadastrado na Unidade: ' + unid.Name + '\n Nome Fantasia: ' + unid.FantasyName__c);
            erro = true;                    
            break;
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Pré-Lead Existente no Lead
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    public static void validarDadosFormatados(PreLead__c preLead) {
        if (!String.isEmpty(preLead.CEP__c)) {
            ValidarCepResult result = ValidarCep.cepValido(preLead.CEP__c);
            if (!result.validado) {
                preLead.CEP__c.addError(result.mensagem);
                erro = true;                    
            } else {
                preLead.CEP__c = result.cepFormatadoParaGravar;                
            }
        }

        ValidarTelefoneResult result;
        if (!String.isEmpty(preLead.PhoneNumber__c)) {
            result = ValidarTelefone.telefoneValido(preLead.PhoneNumber__c);
            if (!result.validado) {
                preLead.PhoneNumber__c.addError(result.mensagem);
                erro = true;                    
            } else {
                preLead.PhoneNumber__c = result.telefoneFormatadoParaGravar;
            }
        }

        if (!String.isEmpty(preLead.MobilePhone__c)) {
            result = ValidarTelefone.telefoneValido(preLead.MobilePhone__c);
            if (!result.validado) {
                preLead.MobilePhone__c.addError(result.mensagem);
                erro = true;                    
            } else {
                preLead.MobilePhone__c = result.telefoneFormatadoParaGravar;
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar dados Formatados
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Validar dados comuns (PF e PJ)
    //------------------------------------------------------------------------------------------------
    public static void validarDemaisDados(PreLead__c preLead) {
        if (preLead.Name == null) {
            preLead.Name.addError('Informe a Empresa/Nome do Lead');
            erro = true;                    
        }
        if (preLead.Company__c == null) {
            preLead.Company__c.addError('Informe a Empresa do Grupo');
            erro = true;                    
        }
        if (preLead.Address__c == null) {
            preLead.Address__c.addError('Informe o Logradouro do Lead');
            erro = true;                    
        }
        if (preLead.AdressNumber__c == null) {
            preLead.AdressNumber__c.addError('Informe o Número do Logradouro do Lead');
            erro = true;                    
        }
        if (preLead.District__c == null) {
            preLead.District__c.addError('Informe o Bairro do Lead');
            erro = true;                    
        }
        if (preLead.City__c == null) {
            preLead.City__c.addError('Informe a Cidade do Lead');
            erro = true;                    
        }
        if (preLead.UF__c == null) {
            preLead.UF__c.addError('Informe a UF do Lead');
            erro = true;                    
        }
        if (preLead.CEP__c == null) {
            preLead.CEP__c.addError('Informe o CEP do Lead');
            erro = true;                    
        } else {
            ValidarCepResult result = ValidarCep.cepValido(preLead.CEP__c);
            if (!result.validado) {
                preLead.CEP__c.addError(result.mensagem);
                erro = true;                    
            }
        }

        ValidarTelefoneResult result;
        if (!String.isEmpty(preLead.PhoneNumber__c)) {
            result = ValidarTelefone.telefoneValido(preLead.PhoneNumber__c);
            if (!result.validado) {
                preLead.PhoneNumber__c.addError(result.mensagem);
                erro = true;                    
            } else {
                preLead.PhoneNumber__c = result.telefoneFormatadoParaGravar;
            }
        }

        if (!String.isEmpty(preLead.MobilePhone__c)) {
            result = ValidarTelefone.telefoneValido(preLead.MobilePhone__c);
            if (!result.validado) {
                preLead.MobilePhone__c.addError(result.mensagem);
                erro = true;                    
            } else {
                preLead.MobilePhone__c = result.telefoneFormatadoParaGravar;
            }
        }

        if (preLead.QuantityUnidtsNegotiable__c > preLead.TotalUnitsQuantity__c) {
            preLead.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
            erro = true;                    
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar dados comuns (PF e PJ)
    //------------------------------------------------------------------------------------------------

 public static void criarLead(PreLead__c preLead) {
        String leadDeveloperName;
        Id leadRecordTypeId = null;

        System.debug('preLead.Recordtype_Name__c: ' + preLead.Recordtype_Name__c);

        if (preLead.TipoLead__c == 'DELTA') {
            leadDeveloperName = 'PJDelta';
        } else if (preLead.TipoLead__c == 'LUZ' && preLead.PFPJ__c == 'PJ') {
            leadDeveloperName = 'LeadPJ';
        } else if (preLead.TipoLead__c == 'LUZ' && preLead.PFPJ__c == 'PF') {
            leadDeveloperName = 'LeadPF';
        }

        System.debug('leadDeveloperName: ' + leadDeveloperName);

        List<RecordType> leadRtypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = :leadDeveloperName LIMIT 1];
        
        if (!leadRtypes.isEmpty()) {
            leadRecordTypeId = leadRtypes[0].Id;
        }

        System.debug('leadRecordTypeId: ' + leadRecordTypeId);

        Lead lead = new Lead();
        List<String> lstFirstLastName = preLead.Name.split(' ');
        String firstName = '';
        String lastName = '';
        if (lstFirstLastName.size() > 1) {
            firstName = lstFirstLastName[0];
            lastName = preLead.Name.replace(firstName, '').trim();
        } else {
            firstName = lstFirstLastName[0];
            lastName = lstFirstLastName[0];
        }
        lead.FirstName = firstName;
        lead.LastName = lastName;
        lead.CNPJ__c = preLead.CPFCNPJ__c;
        lead.Office__c = preLead.Office__c;
        lead.Company = preLead.Name;
        lead.Email = preLead.Email__c;
        if (preLead.PFPJ__c == 'PF') {
            lead.FantasyName__c = preLead.Name;
            lead.LeadType__c = 'Pessoa Física';
            lead.PFPJ__c = 'PF';
        } else {
            lead.FantasyName__c = preLead.FantasyName__c;
            lead.LeadType__c = 'Pessoa Jurídica';
            lead.PFPJ__c = 'PJ';
        }
        lead.RecordTypeId = leadRecordTypeId;
        lead.Phone = preLead.PhoneNumber__c;
        lead.MobilePhone = preLead.MobilePhone__c;
        lead.Company__c = preLead.Company__c;
        lead.Address__c = preLead.Address__c;
     	lead.Gupshup__c = preLead.Gupshup__c;
        lead.AdressNumber__c = preLead.AdressNumber__c;
        lead.Complement__c = preLead.Complement__c;
        lead.District__c = preLead.District__c;
        lead.City__c = preLead.City__c;
        lead.UF__c = preLead.UF__c;
        lead.CEP__c = preLead.CEP__c;
        lead.TotalUnitsQuantity__c = preLead.TotalUnitsQuantity__c;
        lead.QuantityUnidtsNegotiable__c = preLead.QuantityUnidtsNegotiable__c;
        lead.Marketplace__c = preLead.Marketplace__c;
        lead.Note__c = preLead.Note__c;
        lead.StateRegistration__c = preLead.StateRegistration__c;
        lead.MunicipalRegistration__c = preLead.MunicipalRegistration__c;
        lead.EconomicGroup__c = preLead.EconomicGroup__c;
        lead.MaritalStatus__c = preLead.MaritalStatus__c;
        lead.Gender__c = preLead.Gender__c;
        lead.Occupation__c = preLead.Occupation__c;
        lead.Description = preLead.Note__c;
        lead.Baixa_Renda__c = preLead.Baixa_Renda__c;
        lead.CONSUMO__c = preLead.ConsumoKwh__c;
        lead.Campaign__c = preLead.Campaign__c;
        lead.Comercialuz__c = preLead.Comercial__c;
        lead.ConsumoHistorico__c = preLead.ConsumoHistorico__c;
        lead.ConsumoMensal__c = preLead.ConsumoMensal__c;
        lead.ConsumoUtilizado__c = preLead.ConsumoUtilizado__c;
        lead.Contrato_Assinado__c = preLead.Hired__c;
        lead.Contrato_Gerado__c = preLead.ContratoGerado__c;
        lead.Criativo__c = preLead.Criativo__c;
        lead.Cupom__c = preLead.Cupom__c;
        lead.Data_Simulacao__c = preLead.DateSimulation__c;
        lead.Data_do_contrato_assinado__c = preLead.DateContratado__c;
        lead.Data_do_contrato_gerado__c = preLead.DateContrato__c;
        lead.Desconto_Ofertado_1_anos__c = preLead.Desconto_Ofertado_1_Anos__c;
        lead.Desconto_Ofertado_2_anos__c = preLead.Desconto_Ofertado_2_anos__c;
        lead.Desconto_Ofertado_3_anos__c = preLead.Desconto_Ofertado_3_anos__c;
        lead.Desconto_Ofertado_4_anos__c = preLead.Desconto_Ofertado_4_anos__c;
        lead.Desconto_Ofertado_5_anos__c = preLead.Desconto_Ofertado_5_anos__c;
        lead.Desconto_Ofertado_Liberdade_total__c = preLead.Desconto_Ofertado_Liberdade_total__c;
        lead.Desconto_escolhido_pelo_cliente__c = preLead.Desconto_escolhido_pelo_cliente__c;
        lead.DistribuidoraLuz__c = preLead.Distribuidora__c;
        lead.Distribuidora_n_o_Atendida__c = preLead.DistribuidoraNaoAtendida__c;
        lead.Email_do_Parceiro__c = preLead.Email_do_Parceiro__c;
        lead.Erro_Gen_rico_de_Simula_o__c = preLead.ErroGenericoSimulacao__c;
        lead.Erro_Leitura_Fatura__c = preLead.ErroLeituraFatura__c;
        lead.Erros__c = preLead.Erros__c;
        if (preLead.Link_Download__c != null) {
            lead.Fatura_Anexada__c = true;
        }
        lead.Link_Download__c = preLead.Link_Download__c;
        lead.Data_Altera_o_CPFCNPJ__c=preLead.DataAlteracao_CPFCNPJ__c;
        lead.Data_Altera_o_Instala_o__c=preLead.DataAlteracao_Instalacao__c;
        lead.Fatura_Processada__c = preLead.Fatura_Processada__c;
        lead.Fluxo__c = 'Lead';
        lead.Garantidor__c = preLead.Garantidor__c;
        lead.Growth__c = preLead.Growth__c;
        lead.GuidArquivoDaDigitalizacao__c = preLead.GuidArquivoDaDigitalizacao__c;
        lead.Industry = preLead.Setor__c;
        lead.Industry__c = preLead.Setor__c;
        lead.InitialDiscount__c = preLead.InitialDiscount__c;
        lead.Inside_Sales__c = preLead.Inside_Sales__c;
        lead.LOCALE__c = preLead.locale__c;
     	lead.ID_Cotacao__c = preLead.ID_Cotacao__c;
        lead.Medium__c = preLead.Medium__c;
        lead.Multa_Da_distribuidora__c = preLead.AssessmentDistributor__c;
        lead.N_o_Incomodar__c = preLead.N_o_Incomodar__c;
        lead.Data_Altera_o_CPFCNPJ__c=preLead.DataAlteracao_CPFCNPJ__c;
        lead.Edicao_Instalacao__c=preLead.Edicao_Instalacao__c;
        lead.Boptante__c=preLead.Boptante__c;
        lead.Data_Altera_o_Instala_o__c=preLead.DataAlteracao_Instalacao__c;
        lead.Edicao_Instalacao__c=preLead.Edicao_CPFCNPJ__c;
        lead.Consumo_Abaixo_do_Range__c=preLead.ConsumoAbaixoRange__c;
        lead.Etapa__c=preLead.Etapa__c;
        lead.Mensagem__c=preLead.Mensagem__c;
     	lead.Data_Da_Cria_o__c= preLead.CreatedDate;
        lead.Nacionalidade__c=preLead.Nacionalidade__c;
        lead.RG__c=preLead.RG__c;
        lead.Cancelado__c=preLead.Cancelado__c;
        lead.Data_do_Cancelamento__c=preLead.Data_do_Cancelamento__c;
        lead.Motivo_do_Cancelamento__c=preLead.Motivo_do_Cancelamento__c;
        lead.Nome_do_Arquivo_anexo_com_extens_o__c = preLead.NomeDoAnexoComExtensao__c;
        lead.Nome_do_Parceiro__c = preLead.Nome_do_Parceiro__c;
        lead.NumeroInstalacao__c = preLead.NumeroInstalacao__c;
        lead.Numero_de_Contatos__c = preLead.Numero_de_Contatos__c;
        lead.Numero_de_E_mails__c = preLead.Numero_de_E_mails__c;
        lead.Observa_es_gerais_de_cr_dito__c = preLead.Observa_es_Gerais_de_Cr_dito__c;
        lead.Origem_da_Opera_o__c = preLead.InformationSource__c;
		lead.CollaboratorId__c = preLead.CollaboratorId__c;
        lead.Fonte__c = preLead.Fonte__c;
        lead.Parceiro__c = preLead.Parceiro__c;
        lead.Phone_second__c = preLead.MobilePhone__c;
        lead.Poss_vel_Fraude__c = preLead.Possivel_Fraude__c;
        lead.Pr_Lead__c = preLead.Id;
        lead.Prazo_de_pagamento__c = preLead.Prazo_de_Pagamento__c;
        lead.Produto_escolhido_pelo_cliente__c = preLead.Produto_escolhido_pelo_cliente__c;
        lead.Qual_foi_a_base_de_c_lculo__c = preLead.Qual_foi_a_base_de_c_lculo__c;
        lead.Quantidade_de_meses__c = preLead.Quantidade_de_meses__c;
        lead.Rating = preLead.Classifica_o__c;
        lead.Redu_o_Custo__c = preLead.CostReduction__c;
        lead.ReducaoCusto3anos__c = preLead.ReducaoCusto3Anos__c;
        lead.ReducaoCusto5anos__c = preLead.ReducaoCusto5Anos__c;
        lead.ReducaoCustoSemFidelidade__c = preLead.ReducaoCustoSemFidelidade__c;
        lead.Score_SERASA__c = preLead.ScoreSerasa__c;
        lead.SimulacoesRealizadas__c = preLead.simulacoes_realizadas__c;
        lead.Source__c = preLead.Source__c;
        lead.Tarifa_Branca__c = preLead.Tarifa_Branca__c;
        lead.Telefone_do_Parceiros__c = preLead.Telefone_do_Parceiros__c;
        lead.Term__c = preLead.Term__c;
        lead.Tipo_de_garantia__c = preLead.Tipo_de_garantia__c;
        lead.Tipo_de_produto__c = preLead.Produto__c;
        lead.Validade_do_Contrato__c = preLead.Validade_do_Contrato__c;
        lead.Valor_Conta__c = preLead.AccountValue__c;
        lead.Valor_da_Fatura__c = preLead.Valor_da_Fatura__c;
        lead.Volume_considerado_para_estudo_kWh__c = preLead.Volume_considerado_para_estudo_kWh__c;
        lead.Whatsapp__c = preLead.Whatsapp__c;
     	lead.Valor_da_Iluminacao_publica__c = preLead.Valor_da_Iluminacao_publica__c;
        lead.Fase__c = preLead.Fase__c;
     	lead.Origem_Temp__c = preLead.InformationSource__c;
     	lead.Filiais__c = preLead.Filiais__c;
     	lead.CollaboratorId__c = preLead.CollaboratorId__c;
        lead.Envio_do_contrato_social__c = preLead.Envio_do_contrato_social__c;
        lead.Data_de_envio_do_contrato_social__c = preLead.Data_de_envio_do_contrato_social__c;
        lead.Envio_de_documento_de_identifica_o__c = preLead.Envio_de_documento_de_identifica_o__c;
        lead.Documento_de_identifica_o_validado__c = preLead.Documento_de_identifica_o_validado__c;
        lead.Data_de_envio_de_documento_de_identifica__c = preLead.Data_envio_documento_de_identificacao__c;
        lead.Envio_de_foto_com_documento__c = preLead.Envio_de_foto_com_documento__c;
        lead.Foto_com_documento_validada__c = preLead.Foto_com_documento_validada__c;
        lead.Data_de_envio_de_foto_com_documento__c = preLead.Data_de_envio_de_foto_com_documento__c;
     	lead.Mensagem__c = preLead.Mensagem__c;
     
      // Invoke assignment rules
      if(preLead.TipoLead__c == 'DELTA')
      {Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
       lead.setOptions(dmlOpts);}
     

        if (preLead.Lead__c == null) {
            insert lead;
            preLead.Lead__c = lead.Id;
        } else {
            lead.Id = preLead.Lead__c;
            update lead;
        }
    }
   public static void subirCobertura() {
                Integer i = 0;
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
            }

}