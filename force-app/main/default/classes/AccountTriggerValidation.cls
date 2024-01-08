public class AccountTriggerValidation {
    private static String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt  ].IntegrationUserName__c;     
    private static String usuarioAtual = UserInfo.getName();
    private static String cnpj = null;
    private static String cpf = null;
    
    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static void ValidationPJBeforeInsertOrUpdate(Account acc, Account oldAcc) {
        if (acc.CNPJ__c != null) {
            cnpj = ValidarDocumento.cnpjValido(acc.CNPJ__c);
            if (cnpj != null) {
                acc.CNPJ__c = cnpj;
                acc.Base_do_CNPJ_CPF__c = acc.CNPJ__c.substring(0,8);
            }
        }
        
        // Atualizar o owner da conta em funcao do Lead, caso exista, senao o Owner da conta ficara como o usuario de integracao;
        if (trigger.isInsert)
        {
            if (UserInfo.getName() == integrationUserName) {
                // Se encontrar o lead, o owner da conta será o mesmo owner do lead;
                boolean encontrouLead = false;
                for (Lead  lead: [select id, CNPJ__C, OwnerId, (select id, Account__c from Units__r) from Lead where cnpj__c = :acc.CNPJ__c and isConverted=false])
                {
                    encontrouLead = true;
                    acc.OwnerId = lead.OwnerId;
                }
                // Se não encontrar o lead, o owner da conta será o user que tenha o codigo do colaborador que vem 
                // do delta digital.
                
                if (!encontrouLead) {
                    for (User user: [select Id, Name, IsActive from User where DeltaCode__c = :acc.CollaboratorId__c and IsActive = true])
                    {
                        acc.OwnerId = user.Id;
                        break;
                    }
                }
            }
        }
        
        AtualizarDadosDePerfilVarejista(acc);
        
        string erros = '';
        if (acc.QuantityUnidtsNegotiable__c > acc.TotalUnitsQuantity__c)
            acc.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
        if (acc.CNPJ__c != null)
        {
            cnpj = null;
            cnpj = ValidarDocumento.cnpjValido(acc.CNPJ__c);
            if (cnpj != null) {
                acc.CNPJ__c = cnpj;
                acc.Base_do_CNPJ_CPF__c = acc.CNPJ__c.substring(0,8);
            } else {
                acc.CNPJ__c.addError('CNPJ Está Inválido - Verifique');
            }
        }
        else
        {
            acc.CNPJ__c.addError('CNPJ para a conta deve ser informado');
        }
        // consistir os dados obrigatórios de endereço da conta para a integração com o Delta Digital;
        if (acc.CompanyName__c == null)
            acc.CompanyName__c.addError('Razão Social deve ser informada');
        if (acc.FantasyName__c == null)
            acc.FantasyName__c.addError('Nome Fantasia deve ser informado');
       
        ConsistirEnderecoStatusEhEmpresa(acc);
        
      /*  // consistir os campos que não podem ser alterados na conta, pois eles devem ser alterados no Delta Digital;   
        String userProfileName = [select Name from Profile where id =: UserInfo.getProfileId()].Name;
        
        if (Trigger.isUpdate && UserInfo.getName() != integrationUserName && (userProfileName != 'Administrador do sistema' || userProfileName != 'Analista Comercial Thymos' || userProfileName != 'Coordenador Comercial Thymos'))
        {
            string AlteracaoNaoPermitida = 'Alteração permitida só pelo Delta Digital';
            if (acc.Name != oldAcc.Name)
                acc.Name.addError(AlteracaoNaoPermitida);
            if (acc.CompanyName__c != oldAcc.CompanyName__c) 
                acc.CompanyName__c.addError(AlteracaoNaoPermitida);
            if (acc.FantasyName__c != oldAcc.FantasyName__c) 
                acc.FantasyName__c.addError(AlteracaoNaoPermitida);
            if (acc.CNPJ__c != oldAcc.CNPJ__c)
                acc.CNPJ__c.addError(AlteracaoNaoPermitida);
            if (acc.MunicipalRegistration__c != oldAcc.MunicipalRegistration__c) 
                acc.MunicipalRegistration__c.addError(AlteracaoNaoPermitida);
            if (acc.StateRegistration__c != oldAcc.StateRegistration__c) 
                acc.StateRegistration__c.addError(AlteracaoNaoPermitida);
            if (acc.Address__c != oldAcc.Address__c) 
                acc.Address__c.addError(AlteracaoNaoPermitida);
            if (acc.AdressNumber__c != oldAcc.AdressNumber__c) 
                acc.AdressNumber__c.addError(AlteracaoNaoPermitida);
            if (acc.Complement__c != oldAcc.Complement__c) 
                acc.Complement__c.addError(AlteracaoNaoPermitida);
            if (acc.District__c != oldAcc.District__c) 
                acc.District__c.addError(AlteracaoNaoPermitida);
            if (acc.City__c != oldAcc.City__c) 
                acc.City__c.addError(AlteracaoNaoPermitida);
            if (acc.UF__c != oldAcc.UF__c) 
                acc.UF__c.addError(AlteracaoNaoPermitida);
            if (acc.CEP__c != oldAcc.CEP__c) 
                acc.CEP__c.addError(AlteracaoNaoPermitida);
            if (acc.Empresa__c != oldAcc.Empresa__c) 
                acc.Empresa__c.addError(AlteracaoNaoPermitida);
            if (acc.Status__c != oldAcc.Status__c)
                acc.Status__c.addError(AlteracaoNaoPermitida);
            
            if ((acc.Name != oldAcc.Name) ||
                (acc.CompanyName__c != oldAcc.CompanyName__c) ||
                (acc.FantasyName__c != oldAcc.FantasyName__c) ||
                (acc.CNPJ__c != oldAcc.CNPJ__c) ||
                (acc.MunicipalRegistration__c != oldAcc.MunicipalRegistration__c) ||
                (acc.StateRegistration__c != oldAcc.StateRegistration__c) ||
                (acc.Address__c != oldAcc.Address__c) ||
                (acc.AdressNumber__c != oldAcc.AdressNumber__c) ||
                (acc.Complement__c != oldAcc.Complement__c) ||
                (acc.District__c != oldAcc.District__c) ||
                (acc.City__c != oldAcc.City__c) ||
                (acc.UF__c != oldAcc.UF__c) ||
                (acc.CEP__c != oldAcc.CEP__c) ||
                (acc.Empresa__c != oldAcc.Empresa__c) 
               (acc.Status__c != oldAcc.Status__c)
                )
                erros += 'Atenção: Dados da Conta e Dados de Endereço, só podem ser alterados pelo Delta Digital.';
        }*/
        if (erros != '')
            acc.addError(erros);
    }   
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
  
    
    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Jurídica (AFTER INSERT)
    //------------------------------------------------------------------------------------------------
    public static void ConverterPJLeadParaContaAfterInsert(Account acc) {
        if (usuarioAtual == integrationUserName)
        {
            // converter lead relacionado
            System.debug('converter leads relacionados - PJ');
            List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, apiname  FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Map <String,id> cnpjAcountList = new Map<String,Id>();
            cnpjAcountList.put(acc.CNPJ__C,acc.id);
            System.debug('cnpjs '+cnpjAcountList.size());
            List <Units__c> unitsList = new List<Units__c>();
            for (Lead  lead: [select id, CNPJ__C, (select id, Account__c from Units__r) from Lead where cnpj__c in :cnpjAcountList.keySet() and isConverted=false])
            {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(lead.id);
                lc.setAccountId(cnpjAcountList.get(lead.CNPJ__C));
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(convertStatus.apiname );
                lcList.add(lc);
                for ( Units__c unit:lead.Units__r){
                    unit.Account__c = lc.getAccountId();
                    unitsList.add(unit);
                }
            }
            System.debug('Lista de leads a serem convertidos - PJ '+lcList.size());
            if ( lcList.size() > 0 ) 
            {
                try
                {  
                    Database.LeadConvertResult[] lcr = Database.convertLead(lcList, false);
                    System.debug('Lead convertidos - PJ ' + JSON.serialize(lcr));
                } 
                catch(DmlException n)
                {
                    system.debug('Erro convertendo leads PJ : ' + n);
                }
                // associar leads.units com account Units
                if (unitsList.size() > 0)
                    update unitsList;
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Jurídica (AFTER INSERT)
    //------------------------------------------------------------------------------------------------
    

    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static void ValidationPFBeforeInsertOrUpdate(Account acc, Account oldAcc) {
        if (acc.CNPJ__c != null) {
            cpf = ValidarDocumento.cpfValido(acc.CNPJ__c);
            if (cpf != null) {
                acc.CNPJ__c = cpf;
                acc.Base_do_CNPJ_CPF__c = cpf;
            }
        }
        
        // Atualizar o owner da conta em funcao do Lead, caso exista, senao o Owner da conta ficara como o usuario de integracao;
        if (trigger.isInsert)
        {
            if (UserInfo.getName() == integrationUserName) {
                // Se encontrar o lead, o owner da conta será o mesmo owner do lead;
                boolean encontrouLead = false;
                for (Lead  lead: [select id, CNPJ__C, OwnerId, (select id, Account__c from Units__r) from Lead where cnpj__c = :acc.CNPJ__c and isConverted=false])
                {
                    encontrouLead = true;
                    acc.OwnerId = lead.OwnerId;
                }
                // Se não encontrar o lead, o owner da conta será o user que tenha o codigo do colaborador que vem 
                // do delta digital.
                
                if (!encontrouLead) {
                    for (User user: [select Id, Name, IsActive from User where DeltaCode__c = :acc.CollaboratorId__c and IsActive = true])
                    {
                        acc.OwnerId = user.Id;
                        break;
                    }
                }
            }
        }
        
        AtualizarDadosDePerfilVarejista(acc);
        
        string erros = '';
        if (acc.QuantityUnidtsNegotiable__c > acc.TotalUnitsQuantity__c)
            acc.TotalUnitsQuantity__c.addError('Quantidade total não pode ser menor que quantidade negociável');
        if (acc.CNPJ__c != null)
        {
            cpf = null;
            cpf = ValidarDocumento.cpfValido(acc.CNPJ__c);
            if (cpf != null) {
                acc.CNPJ__c = cpf;
                acc.Base_do_CNPJ_CPF__c = cpf;
            } else {
                acc.CNPJ__c.addError('CPF Está Inválido - Verifique');
            }
        }
        else
        {
            acc.CNPJ__c.addError('CPF para a conta deve ser informado');
        }
        // consistir os dados obrigatórios de endereço da conta para a integração com o Delta Digital;
        if (acc.CompanyName__c == null)
            acc.CompanyName__c = acc.FantasyName__c;
        if (acc.CompanyName__c == null)
            acc.CompanyName__c.addError('Nome deve ser informado');
        if (acc.FantasyName__c == null)
            acc.FantasyName__c.addError('Apelido deve ser informado');
        if (acc.MaritalStatus__c == null)
            acc.MaritalStatus__c.addError('Selecione um Estado civil');
        if (acc.Gender__c == null)
            acc.Gender__c.addError('Selecione um Gênero');
        if (acc.Occupation__c == null)
            acc.Occupation__c.addError('Informe a Profissão');
        if (acc.BirthDate__c == null)
            acc.BirthDate__c.addError('Informe a Data de Nascimento');
        else
        {
            if (acc.BirthDate__c >= system.Today())
                acc.BirthDate__c.addError('Data de Aniversário está inválida');
        }

        ConsistirEnderecoStatusEhEmpresa(acc);
        
        // consistir os campos que não podem ser alterados na conta, pois eles devem ser alterados no Delta Digital;   
        String userProfileName = [select Name from Profile where id =: UserInfo.getProfileId()].Name;
        
      /*  if (Trigger.isUpdate && UserInfo.getName() != integrationUserName && (userProfileName != 'Administrador do sistema' || userProfileName != 'Analista Comercial Thymos' || userProfileName != 'Coordenador Comercial Thymos'))
        {
            string AlteracaoNaoPermitida = 'Alteração permitida só pelo Delta Digital';
            if (acc.Name != oldAcc.Name)
                acc.Name.addError(AlteracaoNaoPermitida);
            if (acc.CompanyName__c != oldAcc.CompanyName__c) 
                acc.CompanyName__c.addError(AlteracaoNaoPermitida);
            if (acc.FantasyName__c != oldAcc.FantasyName__c) 
                acc.FantasyName__c.addError(AlteracaoNaoPermitida);
            if (acc.CNPJ__c != oldAcc.CNPJ__c)
                acc.CNPJ__c.addError(AlteracaoNaoPermitida);
            if (acc.MunicipalRegistration__c != oldAcc.MunicipalRegistration__c) 
                acc.MunicipalRegistration__c.addError(AlteracaoNaoPermitida);
            if (acc.StateRegistration__c != oldAcc.StateRegistration__c) 
                acc.StateRegistration__c.addError(AlteracaoNaoPermitida);
            if (acc.Address__c != oldAcc.Address__c) 
                acc.Address__c.addError(AlteracaoNaoPermitida);
            if (acc.AdressNumber__c != oldAcc.AdressNumber__c) 
                acc.AdressNumber__c.addError(AlteracaoNaoPermitida);
            if (acc.Complement__c != oldAcc.Complement__c) 
                acc.Complement__c.addError(AlteracaoNaoPermitida);
            if (acc.District__c != oldAcc.District__c) 
                acc.District__c.addError(AlteracaoNaoPermitida);
            if (acc.City__c != oldAcc.City__c) 
                acc.City__c.addError(AlteracaoNaoPermitida);
            if (acc.UF__c != oldAcc.UF__c) 
                acc.UF__c.addError(AlteracaoNaoPermitida);
            if (acc.CEP__c != oldAcc.CEP__c) 
                acc.CEP__c.addError(AlteracaoNaoPermitida);
            if (acc.Empresa__c != oldAcc.Empresa__c) 
                acc.Empresa__c.addError(AlteracaoNaoPermitida);
            if (acc.Status__c != oldAcc.Status__c)
                acc.Status__c.addError(AlteracaoNaoPermitida);
            
            if ((acc.Name != oldAcc.Name) ||
                (acc.CompanyName__c != oldAcc.CompanyName__c) ||
                (acc.FantasyName__c != oldAcc.FantasyName__c) ||
                (acc.CNPJ__c != oldAcc.CNPJ__c) ||
                (acc.MunicipalRegistration__c != oldAcc.MunicipalRegistration__c) ||
                (acc.StateRegistration__c != oldAcc.StateRegistration__c) ||
                (acc.Address__c != oldAcc.Address__c) ||
                (acc.AdressNumber__c != oldAcc.AdressNumber__c) ||
                (acc.Complement__c != oldAcc.Complement__c) ||
                (acc.District__c != oldAcc.District__c) ||
                (acc.City__c != oldAcc.City__c) ||
                (acc.UF__c != oldAcc.UF__c) ||
                (acc.CEP__c != oldAcc.CEP__c) ||
                (acc.Empresa__c != oldAcc.Empresa__c) 
               (acc.Status__c != oldAcc.Status__c))
                erros += 'Atenção: Dados da Conta e Dados de Endereço, só podem ser alterados pelo Delta Digital.';
        }*/
        if (erros != '')
            acc.addError(erros);
        
    }   
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
  
    
    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Física (AFTER INSERT)
    //------------------------------------------------------------------------------------------------
    public static void ConverterPFLeadParaContaAfterInsert(Account acc) {
        if (usuarioAtual == integrationUserName)
        {
            // converter lead relacionado
            System.debug('converter leads relacionados - PF');
            List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, apiname  FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Map <String,id> cnpjAcountList = new Map<String,Id>();
            cnpjAcountList.put(acc.CNPJ__C,acc.id);
            System.debug('cnpjs '+cnpjAcountList.size());
            List <Units__c> unitsList = new List<Units__c>();
            for (Lead  lead: [select id, CNPJ__C, (select id, Account__c from Units__r) from Lead where cnpj__c in :cnpjAcountList.keySet() and isConverted=false])
            {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(lead.id);
                lc.setAccountId(cnpjAcountList.get(lead.CNPJ__C));
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(convertStatus.apiname );
                lcList.add(lc);
                for ( Units__c unit:lead.Units__r){
                    unit.Account__c = lc.getAccountId();
                    unitsList.add(unit);
                }
            }
            System.debug('Lista de leads a serem convertidos - PF '+lcList.size());
            if ( lcList.size() > 0 ) 
            {
                try
                {  
                    Database.LeadConvertResult[] lcr = Database.convertLead(lcList, false);
                    System.debug('Lead convertidos - PF ' + JSON.serialize(lcr));
                } 
                catch(DmlException n)
                {
                    system.debug('Erro convertendo leads PF : ' + n);
                }
                // associar leads.units com account Units
                if (unitsList.size() > 0)
                    update unitsList;
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Física (AFTER INSERT)
    //------------------------------------------------------------------------------------------------

    
    //------------------------------------------------------------------------------------------------
    // Obter DevelperName para identificar o tipo de registro.
    // Client = Cliente Pessoa Jurídica;
    // Partner = Parceiro Pessoa Jurídica;
    // ClientePF = Cliente Pessoa Física;
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
    // Atualizar os dados do Perfil Varejista (Arvore Organizacional)
    //------------------------------------------------------------------------------------------------
    private static void AtualizarDadosDePerfilVarejista(Account acc) {
        List<User> lstUserVendedor = [Select Id, AccountId, ContactId from User where id = :acc.OwnerId];
        for (User userVendedor : lstUserVendedor) 
        {
            List<Account> lstConta = [select Id, OwnerId from Account where Id = :userVendedor.AccountId];
            for (Account conta : lstConta)
            {
                acc.RetailPartnerAccount__c = userVendedor.AccountId;   // Conta do Parceiro;
                acc.RetailVendor__c = userVendedor.ContactId;           // Vendedor do Parceiro;
                acc.RetailKeyAccount__c = conta.OwnerId;                // Vendedor do Parceiro;
                acc.RetailPartnerManager__c = userVendedor.ContactId;                    
                List<Contact> lstUserGestor = [Select Id, ReportsToId from Contact where id = :userVendedor.ContactId limit 1];
                for (Contact userGestor : lstUserGestor) 
                {
                    if (userGestor.ReportsToId == null)
                        acc.RetailPartnerManager__c = userVendedor.ContactId;                    
                    else
                        acc.RetailPartnerManager__c = userGestor.ReportsToId;                    
                }
                break;
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    // FIM Atualizar os dados do Perfil Varejista (Arvore Organizacional)
    //------------------------------------------------------------------------------------------------

    
    //------------------------------------------------------------------------------------------------
    // Consistir dados de Endereço, Status e Empresa (Pessoa Física e/ou Pessoa Jurídica)
    //------------------------------------------------------------------------------------------------
    private static void ConsistirEnderecoStatusEhEmpresa(Account acc) {
        if (acc.Address__c == null)
            acc.Address__c.addError('Logradouro deve ser informado');
        if (acc.AdressNumber__c == null)
            acc.AdressNumber__c.addError('Número do Logradouro deve ser informado');
        if (acc.CEP__c == null)
            acc.CEP__c.addError('CEP deve ser informado');
        if (acc.City__c == null)
            acc.City__c.addError('Cidade deve ser informada');
        if (acc.UF__c == null)
            acc.UF__c.addError('UF Deve ser informada');
        if (acc.Empresa__c == null)
            acc.Empresa__c.addError('Empresa do Grupo Delta deve ser informada');
        if (acc.Status__c == null)
            acc.Status__c.addError('Status deve ser informado');
    }    
    //------------------------------------------------------------------------------------------------
    // FIM Consistir dados de Endereço, Status e Empresa (Pessoa Física e/ou Pessoa Jurídica)
    //------------------------------------------------------------------------------------------------
    
    
    
    //------------------------------------------------------------------------------------------------
    // Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarDadosFormatados(Account acc) {
        boolean erro = false;
        if (!String.isEmpty(acc.CEP__c)) {
            ValidarCepResult result = ValidarCep.cepValido(acc.CEP__c);
            if (!result.validado) {
                acc.CEP__c.addError(result.mensagem);
                erro = true;                    
            }
        }
        ValidarTelefoneResult result;
        if (!String.isEmpty(acc.Phone)) {
            result = ValidarTelefone.telefoneValido(acc.Phone);
            if (!result.validado) {
                acc.Phone.addError(result.mensagem);
                erro = true;                    
            } else {
                acc.Phone = result.telefoneFormatadoParaGravar;
            }
        }
        return erro;
    }    
    //------------------------------------------------------------------------------------------------
    // FIM Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    
}