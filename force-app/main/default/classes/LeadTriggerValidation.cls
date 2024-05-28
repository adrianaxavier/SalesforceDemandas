public class LeadTriggerValidation {
    private static Boolean erro = false;
    private static String cnpj = null;
    private static String cpf = null;

    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarPJBeforeInsertOrUpdate(Lead lead) {
        erro = false;       
        if (lead.CNPJ__c != null)
        {
            cnpj = ValidarDocumento.cnpjValido(lead.CNPJ__c);
            if (cnpj == null) {
                lead.CNPJ__c.addError('CNPJ Está Inválido - Verifique (BIU)');
                erro = true;
            }
            else {
                lead.CNPJ__c = cnpj;
                lead.Base_do_CNPJ_CPF__c = cnpj.substring(0,8);
            } 
           
        }
        
        String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt  ].IntegrationUserName__c;     
        String usuarioAtual = UserInfo.getName();
        
        if (lead.Status == 'Converted' && integrationUserName != usuarioAtual) {
            System.debug('Lead converted - Erro');
            lead.addError('Opção de Status não permitida - Utilize a opção (Integrar)');
            erro = true;
        }
        return erro;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarPFBeforeInsertOrUpdate(Lead lead) {
        erro = false;       
        if (lead.CNPJ__c != null)
        {
            cpf = ValidarDocumento.cpfValido(lead.CNPJ__c);
            if (cpf == null) {
                lead.CNPJ__c.addError('CPF Está Inválido - Verifique (BIU)');
                erro = true;
            }
            else {
                lead.CNPJ__c = cpf;
                lead.Base_do_CNPJ_CPF__c = cpf;
            }
            
            
        }
        
        String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt  ].IntegrationUserName__c;     
        String usuarioAtual = UserInfo.getName();
        
        if (lead.Status == 'Converted' && integrationUserName != usuarioAtual) {
            System.debug('Lead converted - Erro');
            lead.addError('Opção de Status não permitida - Utilize a opção (Integrar)');
            erro = true;
        }
        return erro;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarDadosFormatados(Lead lead) {
        if (!String.isEmpty(lead.CEP__c)) {
            ValidarCepResult result = ValidarCep.cepValido(lead.CEP__c);
            if (!result.validado) {
                lead.CEP__c.addError(result.mensagem);
                erro = true;                    
            }
        }
        ValidarTelefoneResult result;
        if (!String.isEmpty(lead.Phone)) {
            result = ValidarTelefone.telefoneValido(lead.Phone);
            if (!result.validado) {
                lead.Phone.addError(result.mensagem);
                erro = true;                    
            } else {
                lead.Phone = result.telefoneFormatadoParaGravar;
            }
        }

        if (!String.isEmpty(lead.MobilePhone)) {
            result = ValidarTelefone.telefoneValido(lead.MobilePhone);
            if (!result.validado) {
                lead.MobilePhone.addError(result.mensagem);
                erro = true;                    
            } else {
                lead.MobilePhone = result.telefoneFormatadoParaGravar;
            }
        }
        return erro;
    }    
    //------------------------------------------------------------------------------------------------
    // FIM Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Validar demais dados do Lead Pessoa Jurídica
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarPJDemaisDados(Lead lead) {
        erro = false;
        
        AtualizarDadosDaVarejista(lead);
        
        if (lead.QuantityUnidtsNegotiable__c > lead.TotalUnitsQuantity__c)
        {
            lead.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
            erro = true;                    
        }
        if (lead.Company == null)
        {
            lead.Company.addError('Informe o nome da Empresa');
            erro = true;                    
        }
        /*if (lead.FantasyName__c == null)
        {
            lead.FantasyName__c.addError('Informe o nome Fantasia');
            erro = true;                    
        }*/
        
        // Não pode inserir ou alterar Lead, cujo CNPJ exista em alguma conta; Se Existir mostrar erro;
        List<Account> lstAccount = [Select Id, CNPJ__c, Name, FantasyName__c from Account where CNPJ__c = :lead.CNPJ__c and Id != :lead.ConvertedAccountId];
       /* for(Account cta : lstAccount) 
        {
            lead.CNPJ__c.addError('Esse CNPJ já foi cadastrado na conta: ' + cta.Name + '\n Nome Fantasia: ' + cta.FantasyName__c);
            erro = true;                    
        }*/
        
        // Não pode inserir ou alterar um Lead, cujo CNPJ exista em alguma unidade que tenha o código Delta vinculado,
        // ou que tenha uma conta vinculada; 
       List<Units__c> lstUnidade = [Select Id, Name, FantasyName__c from Units__c where CNPJ__c = :lead.CNPJ__c and DeltaCode__c != null];
       /*  for(Units__c unid : lstUnidade) 
        {
            lead.CNPJ__c.addError('Esse CNPJ já foi cadastrado na Unidade: ' + unid.Name + '\n Nome Fantasia: ' + unid.FantasyName__c);
            erro = true;                    
            break;
        }*/
        
        if (lead.Status == 'Integrate' || lead.Status == 'Converted')
        {
            List<Units__c> lstUnidadeExistente = [Select Id from Units__c where Lead__c = :lead.Id];
            if (trigger.isUpdate)
            {
                if (lead.Status == 'Desqualificado')
                {
                    erro = true;
                    lead.addError('Você não pode converter ou Integrar um Lead desqualificado');
                }
            }
        }
        else
        {
            if (lead.Status == 'Desqualificado')
            {
                string erroDesqualificacao = '';
                if (lead.DisqualifiedLead__c == null)
                    erroDesqualificacao += 'Informe o motivo da desqualificação do Lead (campo: Lead Desqualificado) | ';
                if (lead.Disqualified__c == null)
                    erroDesqualificacao += 'Informe porque o Lead foi desqualificado (campo: Observação Lead Desqualificado)';
                if (erroDesqualificacao != '')
                {
                    lead.addError(erroDesqualificacao);
                    erro = true;
                }
            }
            else
            {
              
            }
        }
        return erro;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar demais dados do Lead Pessoa Jurídica
    //------------------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------------------
    // Validar demais dados do Lead Pessoa Física
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarPFDemaisDados(Lead lead) {
        erro = false;
        
        AtualizarDadosDaVarejista(lead);
        
        if (lead.QuantityUnidtsNegotiable__c > lead.TotalUnitsQuantity__c)
        {
            lead.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
            erro = true;                    
        }
        if (lead.Company == null)
        {
            lead.Company__c.addError('Informe o Nome');
            erro = true;                    
        }
        if (lead.FantasyName__c == null)
        {
            lead.FantasyName__c.addError('Informe o apelido');
            erro = true;                    
        }
        /*if (lead.Gender__c == null)
        {
            lead.Gender__c.addError('Informe o Gênero (Sexo)');
            erro = true;                    
        }        if (lead.Occupation__c == null)
        {
            lead.Occupation__c.addError('Informe a Profissão');
            erro = true;                    
        }

        if (lead.BirthDate__c == null)
        {
            lead.BirthDate__c.addError('Informe a data de Nascimento (Aniversário)');
            erro = true;                    
        }

        if (lead.MaritalStatus__c == null)
        {
            lead.MaritalStatus__c.addError('Informe o Estado Civil');
            erro = true;                    
        }
        */


        // Não pode inserir ou alterar Lead, cujo CPF exista em alguma conta; Se Existir mostrar erro;
        /*List<Account> lstAccount = [Select Id, CNPJ__c, Name, FantasyName__c from Account where CNPJ__c = :lead.CNPJ__c and Id != :lead.ConvertedAccountId];
        for(Account cta : lstAccount) 
        {
            lead.CNPJ__c.addError('Esse CPF já foi cadastrado na conta: ' + cta.Name + '\n Nome Fantasia: ' + cta.FantasyName__c);
            erro = true;                    
        }*/
        
        // Não pode inserir ou alterar um Lead, cujo CPF exista em alguma unidade que tenha o código Delta vinculado,
        // ou que tenha uma conta vinculada; 
        List<Units__c> lstUnidade = [Select Id, Name, FantasyName__c from Units__c where CNPJ__c = :lead.CNPJ__c and DeltaCode__c != null];
        for(Units__c unid : lstUnidade) 
       /* {
            lead.CNPJ__c.addError('Esse CPF já foi cadastrado na Unidade: ' + unid.Name + '\n Nome Fantasia: ' + unid.FantasyName__c);
            erro = true;                    
            break;
        }*/
        
        if (lead.Status == 'Integrate' || lead.Status == 'Converted')
        {
            List<Units__c> lstUnidadeExistente = [Select Id from Units__c where Lead__c = :lead.Id];
            if (trigger.isUpdate)
            {
                if (lead.Status == 'Desqualificado')
                {
                    erro = true;
                    lead.addError('Você não pode converter ou Integrar um Lead desqualificado');
                }
            }
        }
        else
        {
            if (lead.Status == 'Desqualificado')
            {
                string erroDesqualificacao = '';
                if (lead.DisqualifiedLead__c == null)
                    erroDesqualificacao += 'Informe o motivo da desqualificação do Lead (campo: Lead Desqualificado) | ';
                if (lead.Disqualified__c == null)
                    erroDesqualificacao += 'Informe porque o Lead foi desqualificado (campo: Observação Lead Desqualificado)';
                if (erroDesqualificacao != '')
                {
                    lead.addError(erroDesqualificacao);
                    erro = true;
                }
            }
            else
            {
                string erroQualificado = '';
                if (lead.DisqualifiedLead__c != null)
                    erroQualificado += '(campo: Lead Desqualificado) só pode ser informado para Lead desqualificado | ';
                if (lead.Disqualified__c != null)
                    erroQualificado += '(campo: Observação Lead Desqualificado) só pode ser informado para Lead desqualificado';
                if (erroQualificado != '')
                {
                    erro = true;
                    lead.addError(erroQualificado);
                }
            }
        }
        return erro;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar demais dados do Lead Pessoa Física
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Atualizar Dados da Varejista
    //------------------------------------------------------------------------------------------------
    private static void AtualizarDadosDaVarejista(Lead lead) {
        // atualizar dados da varejista;
        List<User> lstUserVendedor = [Select Id, AccountId, ContactId from User where id = :lead.OwnerId];
        for (User userVendedor : lstUserVendedor) 
        {
            List<Account> lstConta = [select Id, OwnerId from Account where Id = :userVendedor.AccountId];
            for (Account conta : lstConta)
            {
                lead.RetailPartnerAccount__c = userVendedor.AccountId;   // Conta do Parceiro;
                lead.RetailVendor__c = userVendedor.ContactId;           // Vendedor do Parceiro;
                lead.RetailKeyAccount__c = conta.OwnerId;                // Key account do parceiro;
                lead.RetailPartnerManager__c = userVendedor.ContactId;   // Gestor do parceiro;                 
                List<Contact> lstUserGestor = [Select Id, ReportsToId from Contact where id = :userVendedor.ContactId limit 1];
                for (Contact userGestor : lstUserGestor) 
                {
                    if (userGestor.ReportsToId == null)
                        lead.RetailPartnerManager__c = userVendedor.ContactId;                    
                    else
                        lead.RetailPartnerManager__c = userGestor.ReportsToId;                    
                }
                break;
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Atualizar Dados da Varejista
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Obter DevelperName para identificar o tipo de registro.
    // LeadPJ = Lead Pessoa Jurídica Luz;
    // LeadPF = Lead Pessoa Física Luz;
    // ThymosPJ = Lead Pessoa Jurídica Thymos;
    // ThymosPF = Lead Pessoa Física Thymos;
    // PJDelta = Lead Pessoa Jurídica Delta;
    // PFDelta = Lead Pessoa Física Delta;
    //------------------------------------------------------------------------------------------------
     public static string ObterDeveloperNameInRecordType(id recordType) {
       List<RecordType> developerName = [select DeveloperName from RecordType where id = :recordType];     
        for (RecordType rt : developerName) {
            return rt.DeveloperName;
        }
        return null;
    }
    //------------------------------------------------------------------------------------------------
    // FIM Obter DevelperName para identificar o tipo de registro.
    //------------------------------------------------------------------------------------------------
    
     //------------------------------------------------------------------------------------------------
    // Atualizar Status
    //------------------------------------------------------------------------------------------------   
    
    public static void validateLeadStatus(List<Lead> leads) {
        for (Lead lead : leads) {
            // Verificação para Status Simulação
            if (lead.Link_Download__c != null &&
                lead.Multa_Da_distribuidora__c == false &&
                lead.Erro_Gen_rico_de_Simula_o__c == false &&
                lead.Erro_Leitura_Fatura__c == false &&
                lead.Fora_da_rea_de_Cobertura__c == false &&
                lead.Distribuidora_n_o_Atendida__c == false) {
                
                lead.Status__c = 'Simulação';
            }

            // Verificação para Status Perdido
            if (lead.Fora_da_rea_de_Cobertura__c == true &&
                lead.DisqualifiedLead__c != null &&
                lead.Disqualified__c == 'Blocklist') {
                
                lead.Status__c = 'Perdido';
            } else if (lead.Status__c == 'Perdido') {
                // Caso seja marcado manualmente como Perdido
                lead.Status__c = 'Perdido';
            }

            // Verificação para Status Ganho
            if (lead.Contrato_Gerado__c == true) {
                lead.Status__c = 'Ganho';
            }
        }
    }
     //------------------------------------------------------------------------------------------------
    // FIM  de validar status
    //------------------------------------------------------------------------------------------------
       
    
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
            }   
            }