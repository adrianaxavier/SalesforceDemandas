trigger AtualizarAssunto on Case (before insert, before update) {
    Map<String, String> mapeamentoMotivoAssunto = new Map<String, String>{
        'AQUISIÇÃO' => 'AQUISIÇÃO',
        'INTERESSE LUZ' => 'INTERESSE LUZ',
        'OUTROS' => 'OUTROS',
        'VISITA TÉCNICA' => 'VISITA TÉCNICA',
        'APP' => 'APP',
        'CONTRATO' => 'CONTRATO',
        'FATURA' => 'FATURA',
        'PAGAMENTO' => 'PAGAMENTO',
        'UPLOAD DOCUMENTAÇÃO' => 'UPLOAD DOCUMENTAÇÃO',
        'MIGRAÇÃO' => 'MIGRAÇÃO',
        'MEDIDOR' => 'MEDIDOR',
        'BOAS VINDAS' => 'BOAS VINDAS',
        'DISTRIBUIDORA' => 'DISTRIBUIDORA',
        'CADASTRO' => 'CADASTRO',
        'RECLAMAÇÃO' => 'RECLAMAÇÃO',
        'CHAMADO' => 'CHAMADO',
        'AÇÃO ISOLADA' => 'AÇÃO ISOLADA'
    };
    
    for (Case caso : Trigger.new) {
        if (caso.Origin != 'AreaLogada' && caso.motivo__c != null && mapeamentoMotivoAssunto.containsKey(caso.motivo__c) ) {
            caso.Subject = mapeamentoMotivoAssunto.get(caso.motivo__c);
        }
    }
}