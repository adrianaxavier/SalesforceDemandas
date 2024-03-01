//------------------------------------------------------------------------------------------------
// Validar horario de funcionamento Inside Sales 
//------------------------------------------------------------------------------------------------
public with sharing class CHATBOTHorarioFuncionamentoInsideSales {

    public class InformacoesDeEntrada {
        @InvocableVariable(required=false)
        public boolean ValidarHorarioFuncionamento_input;
        @InvocableVariable(required=false)
        public DateTime DataHoraFuncionamento_input;
    }

    public class InformacoesDeSaida {
        @InvocableVariable(required=false)
        public boolean HorarioValidado;
        @InvocableVariable(required=false)
        public string Resposta_Mensagem;
    }
    
    @InvocableMethod(label='Validar Horário de Funcionamento InsideSales')
    public static List<InformacoesDeSaida> CHATBOTHorarioFuncionamentoInsideSales(List<InformacoesDeEntrada> dadosDeEntrada) {
        InformacoesDeSaida infSaida = new InformacoesDeSaida();
        for (InformacoesDeEntrada entrada : dadosDeEntrada) {
            if (entrada.ValidarHorarioFuncionamento_input == true) {
                ValidarHorario(infSaida, entrada.DataHoraFuncionamento_input);
                continue;
            } 
        }        
        return new List<InformacoesDeSaida> { infSaida };
    }
 

    private static void ValidarHorario(InformacoesDeSaida saida, DateTime dataHoraInformada) {
        string mensagem = 'Agradecemos muito o seu contato! Nosso horário de atendimento é de Segunda a Sexta-Feira das 09 às 20hrs e aos sábados e feriados, das 10 às 14hrs. Por favor, retorne seu contato durante esse período. Muito obrigada!';
        saida.HorarioValidado = false;
        saida.Resposta_Mensagem = mensagem;
        
        Datetime now = Datetime.now(); 
        if (dataHoraInformada != null) {
            try {
                now = dataHoraInformada;
            } catch (Exception ex) {}            
        }

    DateTime local = Datetime.newInstanceGmt(now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());
        integer hora = local.hourGMT();
    integer minuto = local.minute();
        if (hora < 9) return;
        if ((hora == 20 && minuto > 0) || (hora > 22)) return;
    string diaDaSemana = local.format('EEEE'); 
    if (diaDaSemana.toUpperCase() == 'SUNDAY') return;        
        if (diaDaSemana.toUpperCase() == 'SATURDAY') {
            if (hora < 10) return;
            if ((hora == 14 && minuto > 0) || (hora > 14)) return;
        }   
        if (EncontrouFeriado(local) == true) {
            if (hora < 10) return;
            if ((hora == 14 && minuto > 0) || (hora > 14)) return;
        } 
        saida.HorarioValidado = true;
        saida.Resposta_Mensagem = '';
    }

    private static boolean EncontrouFeriado(DateTime dataBase) {
    if (dataBase == null) return false;
    List<Holiday> feriados;
    // feriados sem recursividade;
        feriados = [select id, Name from Holiday where ActivityDate = :dataBase.date() and IsRecurrence = false];
    for (Holiday feriado : feriados)
             return true;

        // feriados com recursividade;        
        feriados = [select id, IsRecurrence, RecurrenceType, RecurrenceStartDate from Holiday where IsRecurrence = true];
        for (Holiday feriado : feriados) {
            if (feriado.RecurrenceType == 'RecursYearly') {
                if (feriado.RecurrenceStartDate.day() == dataBase.day() && feriado.RecurrenceStartDate.month() == dataBase.month()) {
                    return true;
                }
            }
        }
        return false;    
    }
    
}