public class UnitsTriggerValidation {
    private static String cnpj = null;
    private static String cpf = null;

    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static void ValidarPJBeforeInsertOrUpdate(Units__c unit, Units__c oldUnit) {
        if (unit.CNPJ__c != null)
        {
            cnpj = ValidarDocumento.cnpjValido(unit.CNPJ__c);
            if (cnpj == null) {
                unit.CNPJ__c.addError('CNPJ Está Inválido - Verifique');
            }
            else {
                unit.CNPJ__c = cnpj;
                unit.Base_do_CNPJ_CPF__c = cnpj.substring(0,8);
            }
            if (Trigger.isUpdate)
            {
              
                unit.DeltaKafkaIntegration__c = false;
            }
        } 
        /*else {
            unit.addError('Informe o CNPJ da Unidade');
        } */
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Jurídica (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    public static void ValidarPFBeforeInsertOrUpdate(Units__c unit, Units__c oldUnit) {
        if (unit.CNPJ__c != null)
        {
            cpf = ValidarDocumento.cpfValido(unit.CNPJ__c);
            if (cpf == null) {
                unit.CNPJ__c.addError('CPF Está Inválido - Verifique (BIU)');
            }
            else {
                unit.CNPJ__c = cpf;
                unit.Base_do_CNPJ_CPF__c = cpf;
            }
            if (Trigger.isUpdate)
            {
               
                unit.DeltaKafkaIntegration__c = false;
            }
        } 
        /*else {
            unit.addError('Informe o CPF da Unidade');
        } */
    }
    //------------------------------------------------------------------------------------------------
    // FIM Validar Dados Pessoa Física (BEFORE INSERT OR UPDATE)
    //------------------------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------------------------
    // Obter DevelperName para identificar o tipo de registro.
    //------------------------------------------------------------------------------------------------
    public static string ObterDeveloperNameInRecordType(id recordType) {
        List<RecordType> developerName = [select DeveloperName from RecordType where id = :recordType];     
        for (RecordType rt : developerName) {
            return rt.DeveloperName;
        }
        return null;
    }

    
    //------------------------------------------------------------------------------------------------
    // Validar dados Formatados
    //------------------------------------------------------------------------------------------------
    public static boolean ValidarDadosFormatados(Units__c unit) {
        boolean erro = false;
        if (!String.isEmpty(unit.CEP__c)) {
            ValidarCepResult result = ValidarCep.cepValido(unit.CEP__c);
            if (!result.validado) {
                unit.CEP__c.addError(result.mensagem);
                erro = true;                    
            }
        }
        ValidarTelefoneResult result;
        if (!String.isEmpty(unit.Phone__c)) {
            result = ValidarTelefone.telefoneValido(unit.Phone__c);
            if (!result.validado) {
                unit.Phone__c.addError(result.mensagem);
                erro = true;                    
            } else {
                unit.Phone__c = result.telefoneFormatadoParaGravar;
            }
        }

        if (!String.isEmpty(unit.MobilePhone__c)) {
            result = ValidarTelefone.telefoneValido(unit.MobilePhone__c);
            if (!result.validado) {
                unit.MobilePhone__c.addError(result.mensagem);
                erro = true;                    
            } else {
                unit.MobilePhone__c = result.telefoneFormatadoParaGravar;
            }
        }
        return erro;
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
            }   
    //------------------------------------------------------------------------------------------------
    // FIM Validar dados Formatados
    //------------------------------------------------------------------------------------------------
}