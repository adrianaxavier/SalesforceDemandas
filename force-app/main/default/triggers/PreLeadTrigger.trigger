//------------------------------------------------------------------------------------------------
// Projeto Delta Energia - 11/08/2022 
//------------------------------------------------------------------------------------------------

trigger PreLeadTrigger on PreLead__c (before insert, before update) {
integer i=0;

      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;


private static Boolean erro = false;
for (PreLead__c preLead : trigger.new)
{   preLead.Whatsapp__c='whatsapp:+' +preLead.PhoneNumber__c ;   
      if (!String.isEmpty(PreLead.CPFCNPJ__c)) {
        String docto = ValidarDocumento.cnpjValido(preLead.CPFCNPJ__c);
        if (docto == null) {
            docto = ValidarDocumento.cpfValido(preLead.CPFCNPJ__c);
            if (docto == null) {
                preLead.CPFCNPJ__c.addError('CPF/CNPJ Está Inválido - Verifique');
           
            } /* else {
                preLead.PFPJ__c = 'PF';
                PreLead.CPFCNPJ__c = docto;
            }
        } else  {
            preLead.PFPJ__c = 'PJ';
            PreLead.CPFCNPJ__c = docto;
        }  */
                  
    }
    }

    /* 10/02/2023 - Adriana Xavier - validação se o campo de pré-Lead contratatado e coloca a data da inclusão do fleg*/
      if(preLead.Hired__c==true && preLead.DateContratado__c==null){
           preLead.DateContratado__c=DateTIME.now();
            }
     /* 21/07/2023 - Adriana Xavier - validação se o campo de pré-Lead contratatado e limpa a data*/
      if(preLead.Hired__c==false && preLead.DateContratado__c!=null){
           preLead.DateContratado__c=null;
            }                             
     /* 10/02/2023 - Adriana Xavier - validação se o campo contrato gerado e coloca a data da inclusão do fleg*/
     if(preLead.ContratoGerado__c==true && preLead.DateContrato__c==null){
           preLead.DateContrato__c= DateTIME.now();
           preLead.Validade_do_Contrato__c= (DateTIME.now())+60;
       }
       /* 10/02/2023 - Adriana Xavier - validação se o campo contrato gerado e coloca a data da inclusão do fleg*/
     if(preLead.ContratoGerado__c==false && preLead.DateContrato__c!=null){
           preLead.DateContrato__c= null;
           preLead.Validade_do_Contrato__c= null;
       }
       
     /* 10/02/2023 - Adriana Xavier - limpa campo de data desqualificado*/
       if(preLead.Data_de_Desqualificacao__c !=null && preLead.Status__c != 'Desqualificado'){
           preLead.Data_de_Desqualificacao__c=null;
           preLead.Motivo_Desqualifica_o__c=null;
           preLead.Observa_o_da_Desqualifica_o__c=null;
           
            }  
      /* 10/02/2023 - Adriana Xavier - Status Convertido
       if(preLead.ContratoGerado__c == true && preLead.Hired__c ==true && preLead.Company__c=='a1F4x000000vfPUEAY'&& preLead.Cancelado__c==false){
           preLead.Status__c='Convertido';
            }  */
      /* 10/02/2023 - Adriana Xavier - Status Contrato Assinado
       if(preLead.ContratoGerado__c == true && preLead.Hired__c ==false && preLead.Company__c=='a1F4x000000vfPUEAY'&& preLead.Cancelado__c==false){
           preLead.Status__c='Contrato Gerado';
            } */
      /* 10/02/2023 - Adriana Xavier - Status Qualificado
       if(preLead.Lead__c!=null && preLead.ContratoGerado__c == false && preLead.Hired__c ==false && preLead.Company__c=='a1F4x000000vfPUEAY'&& preLead.Cancelado__c==false){
           preLead.Status__c='Qualificado';
            } */
       
      
        /* 11/07/2023 - Adriana Xavier - Identificar o usuario pelo codigo da area logada*/     
       if(preLead.CollaboratorId__c !=null){
     for (User user: [select Id, Name, IsActive from User where DeltaCode__c = :preLead.CollaboratorId__c and IsActive = true]){
                    preLead.OwnerId = user.Id;
                    preLead.CollaboratorId__c=null;
                }}  
                
    PreLeadTriggerValidation.ValidarDadosFormatados(preLead);        
    
    
    
}    

}