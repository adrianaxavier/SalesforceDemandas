public class ReportController {
    @RemoteAction
    public static Map<String, Object> getFilteredReports(String startDateStr, String endDateStr, String uf) {
        Map<String, Object> reportData = new Map<String, Object>();

        // Debug para mostrar os valores das variáveis de entrada
        System.debug('@@@ startDateStr: ' + startDateStr);
        System.debug('@@@ endDateStr: ' + endDateStr);
        System.debug('@@@ uf: ' + uf);

        // Filtrar por data
        String dateFilter = '';
        if (startDateStr != null && startDateStr != '') {
            dateFilter += ' AND CreatedDate >= ' + startDateStr + 'T00:00:00Z';
        }
        if (endDateStr != null && endDateStr != '') {
            dateFilter += ' AND CreatedDate <= ' + endDateStr + 'T23:59:59Z';
        }

        // Filtrar por UF
        String ufFilter = '';
        if (uf != null && uf != '' && uf != 'Todos') {
            ufFilter = ' AND UF__c = \'' + uf + '\'';
        }

        // Debug para mostrar os filtros aplicados
        System.debug('@@@ dateFilter: ' + dateFilter);
        System.debug('@@@ ufFilter: ' + ufFilter);

        // Consultas para cada relatório
        Integer leadsOriginadosCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Originados', leadsOriginadosCount);

        Integer leadsPerdidosCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND (Status=\'Perdido\' OR Status=\'Desqualificado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Perdidos', leadsPerdidosCount);

        Integer leadsProspeccaoCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND (Status=\'Novo\' OR Status=\'Prospecção\' OR Status=\'Produto Apresentado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads em Prospecção', leadsProspeccaoCount);

        Integer leadsFaturaGrupoACount = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Data_do_Diagn_stico__c != NULL' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Fatura Grupo A', leadsFaturaGrupoACount);

        Integer oportunidadesCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE RecordType.Name=\'Oportunidade Delta\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades', oportunidadesCount);

        Integer oportunidadesNegociacaoCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE RecordType.Name=\'Oportunidade Delta\' AND StageName IN (\'Negociação\', \'Dúvidas e Ajustes\', \'Ass. Termo de Adesão\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Negociacao', oportunidadesNegociacaoCount);

        Integer oportunidadesConvertidasCount = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE RecordType.Name=\'Oportunidade Delta\' AND StageName=\'Ganho\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Convertidas', oportunidadesConvertidasCount);

        // Consultas para gráficos de pizza
        List<AggregateResult> motivosPerdaLeads = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaLeads', motivosPerdaLeads);

        List<AggregateResult> motivosPerdaFaturaGrupoA = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' AND Data_do_Diagn_stico__c!=null GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaFaturaGrupoA', motivosPerdaFaturaGrupoA);

        List<AggregateResult> motivosPerdaOportunidades = [SELECT LossReason__c, COUNT(Id) total FROM Opportunity WHERE RecordType.Name='Oportunidade Delta' AND StageName='Perdido' GROUP BY LossReason__c];
        reportData.put('MotivosPerdaOportunidades', motivosPerdaOportunidades);

        // Inbound
        Integer leadsOriginadosCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'1 - Inbound - ACL Varejo\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Originados Inbound', leadsOriginadosCountInbound);

        Integer leadsPerdidosCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'1 - Inbound - ACL Varejo\' AND (Status=\'Perdido\' OR Status=\'Desqualificado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Perdidos Inbound', leadsPerdidosCountInbound);

        Integer leadsProspeccaoCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'1 - Inbound - ACL Varejo\' AND (Status=\'Novo\' OR Status=\'Prospecção\' OR Status=\'Produto Apresentado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads em Prospecção Inbound', leadsProspeccaoCountInbound);

        Integer leadsFaturaGrupoACountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'1 - Inbound - ACL Varejo\' AND Data_do_Diagn_stico__c != NULL' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Fatura Grupo A Inbound', leadsFaturaGrupoACountInbound);

        Integer oportunidadesCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'1 - Inbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Inbound', oportunidadesCountInbound);

        Integer oportunidadesNegociacaoCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'1 - Inbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName IN (\'Negociação\', \'Dúvidas e Ajustes\', \'Ass. Termo de Adesão\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Negociacao Inbound', oportunidadesNegociacaoCountInbound);

        Integer oportunidadesConvertidasCountInbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'1 - Inbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName=\'Ganho\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Convertidas Inbound', oportunidadesConvertidasCountInbound);

        // Consultas para gráficos de pizza Inbound
        List<AggregateResult> motivosPerdaLeadsInbound = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '1 - Inbound - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaLeads Inbound', motivosPerdaLeadsInbound);

        List<AggregateResult> motivosPerdaFaturaGrupoAInbound = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '1 - Inbound - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' AND Data_do_Diagn_stico__c!=null GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaFaturaGrupoA Inbound', motivosPerdaFaturaGrupoAInbound);

        List<AggregateResult> motivosPerdaOportunidadesInbound = [SELECT LossReason__c, COUNT(Id) total FROM Opportunity WHERE Fonte__c = '1 - Inbound - ACL Varejo' AND RecordType.Name='Oportunidade Delta' AND StageName='Perdido' GROUP BY LossReason__c];
        reportData.put('MotivosPerdaOportunidades Inbound', motivosPerdaOportunidadesInbound);

        // Outbound
        Integer leadsOriginadosCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'2 - Outbound - ACL Varejo\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Originados Outbound', leadsOriginadosCountOutbound);

        Integer leadsPerdidosCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'2 - Outbound - ACL Varejo\' AND (Status=\'Perdido\' OR Status=\'Desqualificado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Perdidos Outbound', leadsPerdidosCountOutbound);

        Integer leadsProspeccaoCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'2 - Outbound - ACL Varejo\' AND (Status=\'Novo\' OR Status=\'Prospecção\' OR Status=\'Produto Apresentado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads em Prospecção Outbound', leadsProspeccaoCountOutbound);

        Integer leadsFaturaGrupoACountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'2 - Outbound - ACL Varejo\' AND Data_do_Diagn_stico__c != NULL' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Fatura Grupo A Outbound', leadsFaturaGrupoACountOutbound);

        Integer oportunidadesCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'2 - Outbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Outbound', oportunidadesCountOutbound);

        Integer oportunidadesNegociacaoCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'2 - Outbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName IN (\'Negociação\', \'Dúvidas e Ajustes\', \'Ass. Termo de Adesão\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Negociacao Outbound', oportunidadesNegociacaoCountOutbound);

        Integer oportunidadesConvertidasCountOutbound = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'2 - Outbound - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName=\'Ganho\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Convertidas Outbound', oportunidadesConvertidasCountOutbound);

        // Consultas para gráficos de pizza Outbound
        List<AggregateResult> motivosPerdaLeadsOutbound = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '2 - Outbound - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaLeads Outbound', motivosPerdaLeadsOutbound);

        List<AggregateResult> motivosPerdaFaturaGrupoAOutbound = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '2 - Outbound - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' AND Data_do_Diagn_stico__c!=null GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaFaturaGrupoA Outbound', motivosPerdaFaturaGrupoAOutbound);

        List<AggregateResult> motivosPerdaOportunidadesOutbound = [SELECT LossReason__c, COUNT(Id) total FROM Opportunity WHERE Fonte__c = '2 - Outbound - ACL Varejo' AND RecordType.Name='Oportunidade Delta' AND StageName='Perdido' GROUP BY LossReason__c];
        reportData.put('MotivosPerdaOportunidades Outbound', motivosPerdaOportunidadesOutbound);

        // Parcerias
        Integer leadsOriginadosCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'3 - Parcerias - ACL Varejo\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Originados Parcerias', leadsOriginadosCountParcerias);

        Integer leadsPerdidosCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'3 - Parcerias - ACL Varejo\' AND (Status=\'Perdido\' OR Status=\'Desqualificado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Perdidos Parcerias', leadsPerdidosCountParcerias);

        Integer leadsProspeccaoCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'3 - Parcerias - ACL Varejo\' AND (Status=\'Novo\' OR Status=\'Prospecção\' OR Status=\'Produto Apresentado\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads em Prospecção Parcerias', leadsProspeccaoCountParcerias);

        Integer leadsFaturaGrupoACountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Lead WHERE (RecordType.Name=\'Delta Inside Sales\' OR RecordType.Name=\'Delta Parceiros - ACL\' OR RecordType.Name=\'Outros Sté\') AND Fonte__c = \'3 - Parcerias - ACL Varejo\' AND Data_do_Diagn_stico__c != NULL' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Leads Fatura Grupo A Parcerias', leadsFaturaGrupoACountParcerias);

        Integer oportunidadesCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'3 - Parcerias - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Parcerias', oportunidadesCountParcerias);

        Integer oportunidadesNegociacaoCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'3 - Parcerias - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName IN (\'Negociação\', \'Dúvidas e Ajustes\', \'Ass. Termo de Adesão\')' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Negociacao Parcerias', oportunidadesNegociacaoCountParcerias);

        Integer oportunidadesConvertidasCountParcerias = (Integer)Database.query('SELECT COUNT(Id) total FROM Opportunity WHERE Fonte__c = \'3 - Parcerias - ACL Varejo\' AND RecordType.Name=\'Oportunidade Delta\' AND StageName=\'Ganho\'' + dateFilter + ufFilter)[0].get('total');
        reportData.put('Oportunidades Convertidas Parcerias', oportunidadesConvertidasCountParcerias);

        // Consultas para gráficos de pizza Parcerias
        List<AggregateResult> motivosPerdaLeadsParcerias = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '3 - Parcerias - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaLeads Parcerias', motivosPerdaLeadsParcerias);

        List<AggregateResult> motivosPerdaFaturaGrupoAParcerias = [SELECT Motivo_da_Perda__c, COUNT(Id) total FROM Lead WHERE Fonte__c = '3 - Parcerias - ACL Varejo' AND (RecordType.Name='Delta Inside Sales' OR RecordType.Name='Delta Parceiros - ACL' OR RecordType.Name='Outros Sté') AND Status='Desqualificado' AND Data_do_Diagn_stico__c!=null GROUP BY Motivo_da_Perda__c];
        reportData.put('MotivosPerdaFaturaGrupoA Parcerias', motivosPerdaFaturaGrupoAParcerias);

        List<AggregateResult> motivosPerdaOportunidadesParcerias = [SELECT LossReason__c, COUNT(Id) total FROM Opportunity WHERE Fonte__c = '3 - Parcerias - ACL Varejo' AND RecordType.Name='Oportunidade Delta' AND StageName='Perdido' GROUP BY LossReason__c];
        reportData.put('MotivosPerdaOportunidades Parcerias', motivosPerdaOportunidadesParcerias);

        return reportData;
    }
}