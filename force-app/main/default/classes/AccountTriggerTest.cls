@IsTest
public class AccountTriggerTest {

    @IsTest
    public static void  testConvertionOk() {        
        id recordTypePF = null;
        id recordTypePJ = null;
        List<RecordType> rtypes = [select id, name,Description,SobjectType,IsActive,DeveloperName from RecordType where SobjectType = 'Account'];
        for (RecordType rtype : rtypes)
        {
            if (rtype.DeveloperName == 'Client')
                recordTypePJ = rtype.Id;
            if (rtype.DeveloperName == 'ClientPF')
                recordTypePF = rtype.Id;
        }
        
        String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt  ].IntegrationUserName__c;
        User usu  = [select id from User where name = :integrationUserName];
        // executar com o usuario integracao;
        System.runAs(usu)  {
            Test.startTest();
      
            Company__c company = new Company__c();
            company.CNPJ__c='48601237000154';
            company.DeltaCode__c= 1;
            insert company;
            
            EconomicGroup__c eg = new EconomicGroup__c();
            eg.DeltaCode__c = 1;
            insert eg;

            Lead lead = new Lead();
            lead.LastName='teste';
            lead.FantasyName__c = 'teste';
            lead.Company='leadName';
            lead.CNPJ__c='15710320000102'; 
            lead.Company__c=company.id;
            lead.Address__c='Av das tulipas';
            lead.AdressNumber__c='1234';
            lead.CEP__c='05512-120';
            lead.District__c='Vila Re';
            lead.city__c = 'Sao Paulo';
            lead.EconomicGroup__c = eg.Id;
            lead.UF__c = 'SP';
            lead.status = 'Integrate';
            lead.StatusIntegration__c='Integrado';
            lead.QuantityUnidtsNegotiable__c = 15;
            lead.TotalUnitsQuantity__c = 15;
            insert lead;
            System.debug('Inseriu Lead');
            
            
            Units__c unit = new Units__c();
            unit.Lead__c = lead.Id;
            unit.CNPJ__c='15710320000102'; 
            unit.Status__c='PP';
            unit.UF__c='SP';
            unit.Address__c = 'Unidade';
            unit.CEP__c = '04112-011';
            unit.Number__c = '123';
            unit.City__c = 'Unidade';
            unit.Complement__c = 'ap';
            unit.District__c = 'UNidade';    
            //unit.DeltaCode__c = '1045';
            //unit.DeltaKafkaIntegration__c = false;
            insert unit;
            System.debug('Inseriu Unit');
            
            // PESSOA JURIDICA
            Account acc = new Account();
            acc.RecordTypeId = recordTypePJ;             
            acc.cnpj__c = '15710320000102';
            acc.name = 'accountName';
            acc.CompanyName__c = 'teste';
            acc.Empresa__c = company.Id;
            acc.FantasyName__c = 'teste';
            acc.UF__c='SP';
            acc.Address__c = 'Endereço';
            acc.AdressNumber__c = '455';
            acc.CEP__c = '08420-160';
            acc.City__c = 'Sao paulo';
            acc.District__c = 'Sao Paulo';
            acc.StateRegistration__c = '213.678-9';
            acc.MunicipalRegistration__c = 'isento';
            acc.Status__c = 'Cliente Ativo';
            acc.QuantityUnidtsNegotiable__c = 10;
            acc.TotalUnitsQuantity__c = 15;
            //acc.Phone = '11 2192-3455';
            acc.OwnerId = usu.id;

            try
            {
                insert acc;
                System.debug('INSERIU CONTA COMM LEAD E UNIDADE PJ..... ');  
                
                List<Account> accs = [select id, Name, Base_do_CNPJ_CPF__c, CompanyName__c,
                                FantasyName__c, CNPJ__c, MunicipalRegistration__c,
                                StateRegistration__c, Address__c, AdressNumber__c,
                                Complement__c, District__c, City__c
                                from Account where CNPJ__c = '15710320000102' limit 1];
                for (Account accA : accs)
                {
                    accA.Base_do_CNPJ_CPF__c = '05086028825';
                    accA.Name = 'NAME ALT';
                    accA.CompanyName__c = 'COMPANY NAME ALT';
                    accA.FantasyName__c = 'FANTASY NAME ALT';
                    accA.CNPJ__c = '09404371807';
                    accA.MunicipalRegistration__c = 'MR ALT';
                    accA.StateRegistration__c = 'SR ALT';
                    accA.Address__c = 'Address ALT';
                    accA.AdressNumber__c = 'Number ALT'; 
                    accA.Complement__c = 'compl alt';
                    accA.District__c = 'District alt';
                    accA.City__c = 'City alt';
                    accA.UF__c = 'MG';
                    accA.CEP__c = '04112-160';
                    accA.Empresa__c = null;
                    accA.Status__c = null;
                    
                    update accA;
                    System.debug('ALTEROU CONTA PESSOA FISICA (2)..... ');                
                
                }
                
            }
            catch (DmlException e) 
            {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));                
                System.debug('erro Insert CONTA COM LEAD E UNIDADE PJ: ' + e);                
            }

            try
            {
                // pessoa fisica;
                Account acc1 = new Account();
                acc1.CNPJ__c = '09404371800';
                acc1.RecordTypeId = recordTypePF;             
                acc1.QuantityUnidtsNegotiable__c = 15;
                acc1.TotalUnitsQuantity__c = 10;
                acc1.MaritalStatus__c = null; //'Casado';
                acc1.Gender__c = null;  //'Masculino';
                acc1.Occupation__c = null; //'Carroceiro';
                acc1.BirthDate__c = null; //Date.newInstance(1960, 2, 17);
                insert acc1;
                System.debug('INSERIU CONTA PESSOA FISICA (1)..... ');                
                
                //acc1.Base_do_CNPJ_CPF__c = '09404371800';
                //update acc1;
                //System.debug('ALTEROU CONTA PESSOA FISICA (1)..... ');                
            }
            catch (DmlException e) 
            {
                System.debug('erro Insert and update PESSOA FISICA (1): ' + e);                
            }
            Test.stopTest();
            //System.assertEquals(true,[select isconverted from Lead limit 1].isConverted ); // lead foi convertido? 
            //System.assertEquals('accountName',[select name  from Account limit 1].name ); // conversao nao trocou nome da conta
            //System.assertEquals(acc.Id,[select account__c  from Units__c limit 1].account__c );// associou unit com conta ?
            //System.debug([select status from lead].status);
            //System.debug([select account__c from Units__c]);
        }
    }
    

    
    @IsTest
    public static void  testInclusaoUsuarioOk() {       
        User usu;
        usu = [select id, name, AccountId  from user where AccountId <> null limit 1];
        if (usu == null)
            usu  = [select id, CreatedDate from User where email = 'adriana.xavier@deltaenergia.com.br' and isActive = true order by CreatedDate limit 1];

        User usuarioNormal = [select id from User where email = 'adriana.xavier@deltaenergia.com.br' and isActive = true limit 1];
        
        id recordTypePF = null;
        id recordTypePJ = null;
        List<RecordType> rtypes = [select id, name,Description,SobjectType,IsActive,DeveloperName from RecordType where SobjectType = 'Account'];
        for (RecordType rtype : rtypes)
        {
            if (rtype.DeveloperName == 'Client')
                recordTypePJ = rtype.Id;
            if (rtype.DeveloperName == 'ClientPF')
                recordTypePF = rtype.Id;
        }

        System.runAs(usuarioNormal)  {
            Test.startTest();
      
            Company__c company = new Company__c();
            company.CNPJ__c='48601237000154';
            company.DeltaCode__c= 1;
            insert company;
            
            
            Account acc = new Account();
            acc.RecordTypeId = recordTypePJ;             
            acc.cnpj__c = '15710320000102';
            acc.name = 'accountName';
            acc.CompanyName__c = 'teste';
            acc.Empresa__c = company.Id;
            acc.FantasyName__c = 'teste';
            acc.UF__c='SP';
            acc.Address__c = 'Endereço';
            acc.AdressNumber__c = '455';
            acc.CEP__c = '08420-160';
            acc.City__c = 'Sao paulo';
            acc.District__c = 'Sao Paulo';
            acc.StateRegistration__c = '213.678-9';
            acc.MunicipalRegistration__c = 'isento';
            acc.Status__c = 'Cliente Ativo';
            acc.QuantityUnidtsNegotiable__c = 10;
            acc.TotalUnitsQuantity__c = 15;
            acc.OwnerId = usuarioNormal.id;
            try
            {
                insert acc;
                System.debug('INSERIU CONTA PESSOA JURIDICA (2)..... ');  
                
                
                
                
                List<Account> accs = [select id, Name, Base_do_CNPJ_CPF__c, CompanyName__c,
                                FantasyName__c, CNPJ__c, MunicipalRegistration__c,
                                StateRegistration__c, Address__c, AdressNumber__c,
                                Complement__c, District__c, City__c
                                from Account where CNPJ__c = '15710320000102' limit 1];
                for (Account accA : accs)
                {
                    //accA.Base_do_CNPJ_CPF__c = '05086028825';
                    accA.Name = 'NAME ALT';
                    accA.CompanyName__c = 'COMPANY NAME ALT';
                    accA.FantasyName__c = 'FANTASY NAME ALT';
                    //accA.CNPJ__c = '09404371807';
                    accA.MunicipalRegistration__c = 'MR ALT';
                    accA.StateRegistration__c = 'SR ALT';
                    accA.Address__c = 'Address ALT';
                    accA.AdressNumber__c = 'Number ALT'; 
                    accA.Complement__c = 'compl alt';
                    accA.District__c = 'District alt';
                    accA.City__c = 'City alt';
                    accA.UF__c = 'MG';
                    accA.CEP__c = '04112-160';
                    accA.Empresa__c = null;
                    accA.Status__c = null;
                    
                    update accA;
                    System.debug('ALTEROU CONTA PESSOA juridica 1..... ');                
                    
                }
                
                
                
                
                
                
                
            }
            catch (DmlException e) 
            {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));                
                System.debug('erro Insert CONTA PESSOA JURIDICA (2): ' + e);                
            }

            try
            {
                // pessoa Física;
                Account acc1 = new Account();
                acc1.RecordTypeId = recordTypePF;             
                acc1.cnpj__c = '05086028825';
                acc1.name = 'accountName PF';
                acc1.CompanyName__c = 'teste PF';
                acc1.Empresa__c = company.Id;
                acc1.FantasyName__c = 'teste PF';
                acc1.UF__c='SP';
                acc1.Address__c = 'Endereço';
                acc1.AdressNumber__c = '455';
                acc1.CEP__c = '08420-160';
                acc1.City__c = 'Sao paulo';
                acc1.District__c = 'Sao Paulo';
                acc1.StateRegistration__c = '213.678-9';
                acc1.MunicipalRegistration__c = 'isento';
                acc1.Status__c = 'Cliente Ativo';
                acc1.QuantityUnidtsNegotiable__c = 10;
                acc1.TotalUnitsQuantity__c = 15;
                //acc1.Phone = '55112192-3455';
                acc1.OwnerId = usuarioNormal.id;
                acc1.MaritalStatus__c = 'Casado';
                acc1.Gender__c = 'Masculino';
                acc1.Occupation__c = 'Carroceiro';
                acc1.BirthDate__c = Date.newInstance(1960, 2, 17);
                insert acc1;
                System.debug('INSERIU CONTA PESSOA FISICA (2)..... ');                
               
                List<Account> accs = [select id, Name, Base_do_CNPJ_CPF__c, CompanyName__c,
                                FantasyName__c, CNPJ__c, MunicipalRegistration__c,
                                StateRegistration__c, Address__c, AdressNumber__c,
                                Complement__c, District__c, City__c
                                from Account where CNPJ__c = '05086028825' limit 1];
                for (Account accA : accs)
                {
                    accA.Base_do_CNPJ_CPF__c = '05086028825';
                    accA.Name = 'NAME ALT';
                    accA.CompanyName__c = 'COMPANY NAME ALT';
                    accA.FantasyName__c = 'FANTASY NAME ALT';
                    accA.CNPJ__c = '09404371807';
                    accA.MunicipalRegistration__c = 'MR ALT';
                    accA.StateRegistration__c = 'SR ALT';
                    accA.Address__c = 'Address ALT';
                    accA.AdressNumber__c = 'Number ALT'; 
                    accA.Complement__c = 'compl alt';
                    accA.District__c = 'District alt';
                    accA.City__c = 'City alt';
                    accA.UF__c = 'MG';
                    accA.CEP__c = '04112-160';
                    accA.Empresa__c = null;
                    accA.Status__c = null;
                    
                    update accA;
                    System.debug('ALTEROU CONTA PESSOA FISICA (2)..... ');                
                    
                }
            }
            catch (DmlException e) 
            {
                System.debug('erro insert and update PESSOA FISICA (2): ' + e);                
            }
            
            Test.stopTest();
        }
    }
   
}