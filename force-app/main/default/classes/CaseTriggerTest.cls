@IsTest
public class CaseTriggerTest {

    @IsTest
    public static void  inserirCaso() {		
        id callCenterRecordType = null;
        List<RecordType> rtypes = [select id, name,Description,SobjectType,IsActive,DeveloperName from RecordType where SobjectType = 'Case'];
        for (RecordType rtype : rtypes)
        {
            if (rtype.DeveloperName == 'CallCenter')
                callCenterRecordType = rtype.Id;
        }
        
        String integrationUserName  = [select IntegrationUserName__c from GeneralParameter__mdt  ].IntegrationUserName__c;
        User usu  = [select id from User where name = :integrationUserName];
        // executar com o usuario integracao;
        System.runAs(usu)  {
            Test.startTest();
			Case caso = new Case();
			caso.Status = 'Aberto';            
            caso.Origin = 'EMail';
            caso.Reason = 'Dúvida';
            caso.NaoIdentificado__c = true;
            caso.Description = 'Teste de inserçao';
            try
            {
                insert caso;
                System.debug('Inseriu Caso');
            } catch(Exception ex) {
                system.debug('Erro: ' + ex.getMessage());
            }

            
			Case caso1 = new Case();
			caso1.Status = 'Aberto';            
            caso1.Origin = 'web';
            caso1.Reason = 'Dúvida';
            caso1.NaoIdentificado__c = false;
            caso1.AccountId = null;
            caso1.PreLead__c = null;
            //caso1.RecordTypeId = null;
            caso1.Description = 'Teste de inserçao';
            try
            {
                insert caso1;
                System.debug('Inseriu Caso1');
            } catch(Exception ex) {
                System.debug('ERRO AO Inserir Caso1');
                system.debug('Erro: ' + ex.getMessage());
            }
            
            
            
            
            Test.stopTest();
        }
    }
}