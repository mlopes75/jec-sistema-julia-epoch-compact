import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object JuliaEpochCompact {
    // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
    private const val BASE35_ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ"

    /**
     * 1. ENCODE: Converte um LocalDateTime para uma String JEC compactada
     */
    fun encode(dt: LocalDateTime, alias: String? = null): String {
        val seculo = "V" // Século XXI fixo
        val ano = String.format("%02d", dt.year % 100)
        
        // Mês (A-L -> Jan-Dez)
        val mes = (65 + (dt.monthValue - 1)).toChar().toString()

        // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
        val dia = if (dt.dayOfMonth <= 25) {
            BASE35_ALPHA[dt.dayOfMonth - 1].toString()
        } else {
            (dt.dayOfMonth - 25).toString()
        }

        // Hora (A-Y sem O para 00h-23h)
        val hora = BASE35_ALPHA[dt.hour].toString()

        val minutos = String.format("%02d", dt.minute)
        val segundos = String.format("%02d", dt.second)

        val prefixo = if (!alias.isNullOrEmpty()) "$alias." else ""
        
        return "$prefixo$seculo$ano$mes$dia$hora$minutos$segundos"
    }

    /**
     * 2. DECODE: Converte uma String JEC de volta para um objeto LocalDateTime
     */
    fun decode(jecId: String): LocalDateTime {
        // Remove o prefixo/alias se ele existir na string
        val corpo = jecId.substringAfterLast('.')

        if (corpo.length != 10) {
            throw IllegalArgumentException("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.")
        }

        // Fatiamento preciso baseado na estrutura posicional rígida de 10 caracteres
        val charSeculo = corpo[0].toString()
        val anoDigitos = corpo.substring(1, 3).toInt()
        val charMes = corpo[3]
        val charDia = corpo[4].toString()
        val charHora = corpo[5]
        val minuto = corpo.substring(6, 8).toInt()
        val segundo = corpo.substring(8, 10).toInt()

        // Reconstrução do Ano
        val ano = if (charSeculo == "V") 2000 + anoDigitos else 1900 + anoDigitos

        // Reconstrução do Mês
        val mes = charMes.code - 65 + 1

        // Reconstrução do Dia
        val dia = if (charDia.matches(Regex("[1-6]"))) {
            charDia.toInt() + 25
        } else {
            BASE35_ALPHA.indexOf(charDia) + 1
        }

        // Reconstrução da Hora
        val hora = BASE35_ALPHA.indexOf(charHora)

        return LocalDateTime.of(ano, mes, dia, hora, minuto, segundo)
    }
}

/**
 * 3. EXECUÇÃO DOS TESTES DE VALIDAÇÃO (Simulação de Terminal)
 */
fun main() {
    println("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM KOTLIN ===\n")
    val formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")

    // Caso 1: Teste com Dia menor ou igual a 25
    val data1 = LocalDateTime.of(2026, 8, 15, 14, 30, 45)
    val id1 = JuliaEpochCompact.encode(data1, "TX")
    val resultado1 = JuliaEpochCompact.decode(id1)
    
    println("Teste 1 (Dia Regular - 15/08):")
    println("-> Original:  ${data1.format(formatter)}")
    println("-> ID JEC:    $id1")
    println("-> Decodado:  ${resultado1.format(formatter)}")
    println("-> Status:    ${if (data1 == resultado1) "✅ SUCESSO" else "❌ FALHOU"}\n")

    // Caso 2: Teste com Dia limite (Maior que 25)
    val data2 = LocalDateTime.of(2026, 12, 28, 23, 59, 0)
    val id2 = JuliaEpochCompact.encode(data2)
    val resultado2 = JuliaEpochCompact.decode(id2)

    println("Teste 2 (Dia Limite - 28/12):")
    println("-> Original:  ${data2.format(formatter)}")
    println("-> ID JEC:    $id2")
    println("-> Decodado:  ${resultado2.format(formatter)}")
    println("-> Status:    ${if (data2 == resultado2) "✅ SUCESSO" else "❌ FALHOU"}")
}
