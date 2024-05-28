@isTest
public class PreLeadTriggerTest {
    @isTest
    public static void InserirPreLead() {
        User user  = [SELECT Id FROM User WHERE email = 'adriana.xavier@deltaenergia.com.br' LIMIT 1];
        System.debug('Usuario: ' + user);
        System.runAs(user)  {
            Test.startTest();

            // Create necessary records for test
            Company__c company = new Company__c(CNPJ__c='48601237000154', DeltaCode__c=1);
            insert company;

            EconomicGroup__c ec = new EconomicGroup__c(Name='Grupo Nestle', DeltaCode__c=1);
            insert ec;

            DDDBrasil__c ddd = new DDDBrasil__C(DDD__c=11, UF__c='SP');
            insert ddd;

            // Test insertion and update for PF without inconsistencies
            try {
                PreLead__c preLead = CriarPreLeadPessoaFisica();
                preLead.RecordTypeId='012HY0000004Lm9YAE';
                preLead.CPFCNPJ__c = '28183959091';
                preLead.CollaboratorId__c = 223313;
                preLead.Status__c = 'Novo';
                preLead.Hired__c = false;
                preLead.Lead__c= null;
                preLead.Data_de_Desqualificacao__c=null;
                preLead.Motivo_Desqualifica_o__c=null;
                preLead.Observa_o_da_Desqualifica_o__c=null;
                preLead.DateContrato__c= null;
                preLead.Validade_do_Contrato__c= null;
                preLead.ContratoGerado__c = false;
                preLead.Company__c = company.Id;
                preLead.Lead__c = null;
                preLead.MobilePhone__c = '113122-4545';
                preLead.PhoneNumber__c = '554143435555';
                insert preLead;
                System.debug('-------------------------> insert efetuado com sucesso..');
                List<PreLead__c> lstPreLeadExistente = [SELECT Id, Name, Lead__c FROM PreLead__c WHERE CPFCNPJ__c = '28183959091' LIMIT 1]; 
                System.debug('Lista preLead: ' + lstPreLeadExistente);
                for (PreLead__c preLeadExistente : lstPreLeadExistente) {
                    update preLeadExistente;
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!> update efetuado com sucesso..');
                }
            } catch (Exception ex) {
                System.debug('Erro preLead: ' + ex.getMessage());
            }

            // Test insertion of another PF record
            try {
                PreLead__c preLead1 = CriarPreLeadPessoaFisica();
                preLead1.RecordTypeId='012HY0000004Lm9YAE';
                preLead1.CollaboratorId__c = 223313;
                preLead1.Status__c = 'Em andamento';
                preLead1.Lead__c= null;
                preLead1.Data_de_Desqualificacao__c=null;
                preLead1.Motivo_Desqualifica_o__c=null;
                preLead1.Observa_o_da_Desqualifica_o__c=null;
                preLead1.DateContrato__c= null;
                preLead1.Validade_do_Contrato__c= null;
                preLead1.CPFCNPJ__c = '94546252099';
                preLead1.Hired__c = false;
                preLead1.ContratoGerado__c = false;
                preLead1.Company__c = company.Id;
                insert preLead1;
            } catch (Exception ex) {
                System.debug('Erro preLead1: ' + ex.getMessage());
            }

            // Test insertion of PF with hired and contract generated flags
            try {
                PreLead__c preLead2 = new PreLead__c();
                preLead2.Company__c = company.Id;
                preLead2.Status__c = 'Novo';
                preLead2.Lead__c= null;
                preLead2.Data_de_Desqualificacao__c=null;
                preLead2.Motivo_Desqualifica_o__c=null;
                preLead2.Observa_o_da_Desqualifica_o__c=null;
                preLead2.DateContrato__c= null;
                preLead2.Validade_do_Contrato__c= null;
                preLead2.Hired__c = true;
                preLead2.ContratoGerado__c = true;
                preLead2.RecordTypeId='012HY0000004Lm9YAE';
                preLead2.PFPJ__c = 'PF';
                preLead2.CPFCNPJ__c = '12345678901';
                insert preLead2;
            } catch (Exception ex) {
                System.debug('Erro preLead2: ' + ex.getMessage());
            }

            // Test insertion of PF with null CPFCNPJ
            try {
                PreLead__c preLead3 = new PreLead__c();
                preLead3.CPFCNPJ__c = null;
                preLead3.Status__c = 'Novo';
                preLead3.RecordTypeId='012HY0000004Lm9YAE';
                preLead3.CollaboratorId__c = 223313;
                preLead3.Lead__c= null;
                preLead3.Data_de_Desqualificacao__c=null;
                preLead3.Motivo_Desqualifica_o__c=null;
                preLead3.Observa_o_da_Desqualifica_o__c=null;
                preLead3.DateContrato__c= null;
                preLead3.Validade_do_Contrato__c= null;
                preLead3.PFPJ__c = 'PF';
                preLead3.Company__c = company.Id;
                preLead3.Hired__c = true;
                preLead3.ContratoGerado__c = false;
                insert preLead3;
            } catch (Exception ex) {
                System.debug('Erro preLead3: ' + ex.getMessage());
            }

            // Test insertion of PF with invalid CPFCNPJ
            try {
                PreLead__c preLead4 = new PreLead__c();
                preLead4.CPFCNPJ__c = '26222900048';
                preLead4.Status__c = 'Novo';
                preLead4.RecordTypeId='012HY0000004Lm9YAE';
                preLead4.CollaboratorId__c = 223313;
                preLead4.CPFCNPJ__c = null;
                preLead4.Lead__c= null;
                preLead4.Data_de_Desqualificacao__c=null;
                preLead4.Motivo_Desqualifica_o__c=null;
                preLead4.Observa_o_da_Desqualifica_o__c=null;
                preLead4.DateContrato__c= null;
                preLead4.Validade_do_Contrato__c= null;
                preLead4.PFPJ__c = 'PF';
                preLead4.Hired__c = true;
                preLead4.ContratoGerado__c = true;
                preLead4.Company__c = company.Id;
                preLead4.MobilePhone__c = '113122-4545';
                preLead4.PhoneNumber__c = '114343-5555';
                insert preLead4;
            } catch (Exception ex) {
                System.debug('Erro preLead4: ' + ex.getMessage());
            }

            // Test insertion of PF with various attributes
            try {
                PreLead__c preLead5 = CriarPreLeadPessoaFisica();
                preLead5.CPFCNPJ__c = '80050398083';
                preLead5.RecordTypeId='012HY0000004Lm9YAE';
                preLead5.CollaboratorId__c = 223313;
                preLead5.Status__c = 'Novo';
                preLead5.Lead__c = null;
                preLead5.Hired__c = false;
                preLead5.ContratoGerado__c = false;
                preLead5.PFPJ__c = 'PF';
                preLead5.Office__c = 'Diretor';
                preLead5.Marketplace__c = 'Livre';
                preLead5.StateRegistration__c = '01';
                preLead5.MunicipalRegistration__c = '01';
                preLead5.FantasyName__c = 'Nome fantasia';
                preLead5.EconomicGroup__c = ec.Id;
                preLead5.Company__c = company.Id;
                insert preLead5;
            } catch (Exception ex) {
                System.debug('Erro preLead5: ' + ex.getMessage());
            }

            // Test deletion of PF pre-lead
            List<PreLead__c> lstPreLeadExistente = [SELECT Id, Name, Lead__c FROM PreLead__c WHERE CPFCNPJ__c = '28183959091' LIMIT 1]; 
            System.debug('Lista preLead: ' + lstPreLeadExistente);
            for (PreLead__c preLeadExistente : lstPreLeadExistente) {
                delete preLeadExistente;
                System.debug('*************************> delete efetuado com sucesso..');
            }

            // Test insertion and update for PJ without inconsistencies
            try {
                PreLead__c preLead90 = CriarPreLeadPessoaJuridica();
                preLead90.RecordTypeId='012HY0000004Lm9YAE';
                preLead90.CollaboratorId__c = 223313;
                preLead90.Status__c = 'Novo';
                preLead90.Hired__c = false;
                preLead90.Lead__c= null;
                preLead90.Data_de_Desqualificacao__c=null;
                preLead90.Motivo_Desqualifica_o__c=null;
                preLead90.Observa_o_da_Desqualifica_o__c=null;
                preLead90.DateContrato__c= null;
                preLead90.Validade_do_Contrato__c= null;
                preLead90.ContratoGerado__c = false;
                preLead90.CPFCNPJ__c = '06202179000146';
                preLead90.PFPJ__c = 'PJ';
                preLead90.Company__c = company.Id;
                preLead90.Lead__c = null;
                insert preLead90;
                System.debug('-------------------------> insert PJ efetuado com sucesso..');
                List<PreLead__c> lstPreLeadExistentePJ = [SELECT Id, Name, Lead__c FROM PreLead__c WHERE CPFCNPJ__c = '06202179000146' LIMIT 1]; 
                System.debug('Lista preLead PJ: ' + lstPreLeadExistentePJ);
                for (PreLead__c preLeadExistente : lstPreLeadExistentePJ) {
                    update preLeadExistente;
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!> update efetuado com sucesso..');
                }
            } catch (Exception ex) {
                System.debug('Erro preLead90: ' + ex.getMessage());
            }

            // Test insertion of another PJ record
            try {
                PreLead__c preLead91 = CriarPreLeadPessoaJuridica();
                preLead91.RecordTypeId='012HY0000004Lm9YAE';
                preLead91.CollaboratorId__c = 223313;
                preLead91.Status__c = 'Novo';
                preLead91.Hired__c = false;
                preLead91.Lead__c= null;
                preLead91.Data_de_Desqualificacao__c=null;
                preLead91.Motivo_Desqualifica_o__c=null;
                preLead91.Observa_o_da_Desqualifica_o__c=null;
                preLead91.DateContrato__c= null;
                preLead91.Validade_do_Contrato__c= null;
                preLead91.ContratoGerado__c = false;
                preLead91.CPFCNPJ__c = '44179580000100';
                preLead91.PFPJ__c = 'PJ';
                preLead91.Company__c = company.Id;
                insert preLead91;
            } catch (Exception ex) {
                System.debug('Erro preLead91: ' + ex.getMessage());
            }

            // Test insertion of PJ with hired and contract generated flags
            try {
                PreLead__c preLead92 = new PreLead__c();
                preLead92.Company__c = company.Id;
                preLead92.Status__c = 'Novo';
                preLead92.Hired__c = false;
                preLead92.Lead__c= null;
                preLead92.Data_de_Desqualificacao__c=null;
                preLead92.Motivo_Desqualifica_o__c=null;
                preLead92.Observa_o_da_Desqualifica_o__c=null;
                preLead92.DateContrato__c= null;
                preLead92.Validade_do_Contrato__c= null;
                preLead92.ContratoGerado__c = false;
                preLead92.RecordTypeId='012HY0000004Lm9YAE';
                preLead92.CollaboratorId__c = 223313;
                preLead92.PFPJ__c = 'PJ';
                preLead92.CPFCNPJ__c = '12345678000199';
                insert preLead92;
            } catch (Exception ex) {
                System.debug('Erro preLead92: ' + ex.getMessage());
            }

            // Test insertion of PJ with null CPFCNPJ
            try {
                PreLead__c preLead93 = new PreLead__c();
                preLead93.RecordTypeId='012HY0000004Lm9YAE';
                preLead93.Status__c = 'Novo';
                preLead93.Hired__c = false;
                preLead93.ContratoGerado__c = false;
                preLead93.Lead__c= null;
                preLead93.Data_de_Desqualificacao__c=null;
                preLead93.Motivo_Desqualifica_o__c=null;
                preLead93.Observa_o_da_Desqualifica_o__c=null;
                preLead93.DateContrato__c= null;
                preLead93.Validade_do_Contrato__c= null;
                preLead93.CollaboratorId__c = 223313;
                preLead93.CPFCNPJ__c = null;
                preLead93.PFPJ__c = 'PJ';
                preLead93.Company__c = company.Id;
                insert preLead93;
            } catch (Exception ex) {
                System.debug('Erro preLead93: ' + ex.getMessage());
            }

            // Test insertion of PJ with invalid CPFCNPJ
            try {
                PreLead__c preLead94 = new PreLead__c();
                preLead94.RecordTypeId='012HY0000004Lm9YAE';
                preLead94.Status__c = 'Novo';
                preLead94.Hired__c = false;
                preLead94.ContratoGerado__c = false;
                preLead94.CollaboratorId__c = 223313;
                preLead94.CPFCNPJ__c = '44179580000199';
                preLead94.Lead__c= null;
                preLead94.Data_de_Desqualificacao__c=null;
                preLead94.Motivo_Desqualifica_o__c=null;
                preLead94.Observa_o_da_Desqualifica_o__c=null;
                preLead94.DateContrato__c= null;
                preLead94.Validade_do_Contrato__c= null;
                preLead94.PFPJ__c = 'PJ';
                preLead94.Company__c = company.Id;
                insert preLead94;
            } catch (Exception ex) {
                System.debug('Erro preLead94: ' + ex.getMessage());
            }

            // Test insertion of PJ with various attributes
            try {
                PreLead__c preLead95 = CriarPreLeadPessoaJuridica();
                preLead95.RecordTypeId='012HY0000004Lm9YAE';
                preLead95.CPFCNPJ__c = '83378908000160';
                preLead95.Status__c = 'Novo';
                preLead95.Lead__c = null;
                preLead95.Hired__c = false;
                preLead95.ContratoGerado__c = false;
                preLead95.PFPJ__c = 'PJ';
                preLead95.MaritalStatus__c = 'CASADO';
                preLead95.Marketplace__c = 'Livre';
                preLead95.StateRegistration__c = '01';
                preLead95.MunicipalRegistration__c = '01';
                preLead95.FantasyName__c = 'Nome fantasia';
                preLead95.EconomicGroup__c = ec.Id;
                preLead95.Company__c = company.Id;
                preLead95.Lead__c= null;
                preLead95.Data_de_Desqualificacao__c=null;
                preLead95.Motivo_Desqualifica_o__c=null;
                preLead95.Observa_o_da_Desqualifica_o__c=null;
                preLead95.DateContrato__c= null;
                preLead95.Validade_do_Contrato__c= null;
                preLead95.MaritalStatus__c = 'CASADO';
                preLead95.Gender__c = 'M';
                preLead95.Occupation__c = 'Gestor';
                insert preLead95;
            } catch (Exception ex) {
                System.debug('Erro preLead95: ' + ex.getMessage());
            }

            // Test deletion of PJ pre-lead
            List<PreLead__c> lstPreLeadExistentePJ = [SELECT Id, Name, Lead__c FROM PreLead__c WHERE CPFCNPJ__c = '06202179000146' LIMIT 1]; 
            System.debug('Lista preLead PJ: ' + lstPreLeadExistentePJ);
            for (PreLead__c preLeadExistente : lstPreLeadExistentePJ) {
                delete preLeadExistente;
                System.debug('*************************> delete efetuado com sucesso..');
            }

            Test.stopTest();
        }
    }    

    public static PreLead__c CriarPreLeadPessoaFisica() {
        return new PreLead__c(
            RecordTypeId='012HY0000004Lm9YAE',
            Name='Pré Teste',
            CPFCNPJ__c=null,
            Status__c='Novo',
            Email__c='teste@teste.com.br',
            PFPJ__c='PF',
            PhoneNumber__c='554138976500',
            MobilePhone__c=null,
            Hired__c=false,
            ContratoGerado__c=false,
            Company__c='a1F4x000000vfPUEAY',
            Address__c='Av brig faria lima',
            AdressNumber__c='4100',
            Complement__c='7o andar',
            District__c='Vila Olimpia',
            City__c='São Paulo',
            UF__c='SP',
            CEP__c='05320000',
            TotalUnitsQuantity__c=0,
            QuantityUnidtsNegotiable__c=0,
            Note__c='Observações Gerais',
            MaritalStatus__c='CASADO',
            Gender__c='M',
            Occupation__c='Gestor',
            Lead__c=null,
            Data_de_Desqualificacao__c=null,
            Motivo_Desqualifica_o__c=null,
            Observa_o_da_Desqualifica_o__c=null,
            DateContrato__c=null,
            Validade_do_Contrato__c=null
        );
    }

    public static PreLead__c CriarPreLeadPessoaJuridica() {
        return new PreLead__c(
            RecordTypeId='012HY0000004Lm9YAE',
            Name='Pré Teste',
            Hired__c=false,
            ContratoGerado__c=false,
            Company__c='a1F4x000000vfPUEAY',
            CPFCNPJ__c=null,
            Status__c='Novo',
            Office__c='Gestor',
            Email__c='teste@teste.com.br',
            PFPJ__c='PJ',
            PhoneNumber__c='554138976500',
            MobilePhone__c=null,
            Address__c='Av brig faria lima',
            AdressNumber__c='4100',
            Complement__c='7o andar',
            District__c='Vila Olimpia',
            City__c='São Paulo',
            UF__c='SP',
            CEP__c='05320000',
            TotalUnitsQuantity__c=0,
            QuantityUnidtsNegotiable__c=0,
            Marketplace__c=null,
            Note__c='Observações Gerais',
            StateRegistration__c=null,
            MunicipalRegistration__c=null,
            EconomicGroup__c=null,
            Lead__c=null,
            Data_de_Desqualificacao__c=null,
            Motivo_Desqualifica_o__c=null,
            Observa_o_da_Desqualifica_o__c=null,
            DateContrato__c=null,
            Validade_do_Contrato__c=null
        );
    }
}