import Foundation

enum JecError: Error {
    case formatoInvalido(String)
    case caractereInvalido(String)
}

struct JuliaEpochCompact {
    // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
    private static let base35Alpha = "ABCDEFGHIJKLMNPQRSTUVWXYZ"

    /**
     1. ENCODE: Converte um Date para uma String JEC compactada
     */
    static func encode(date: Date, alias: String? = None) -> String {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        let seculo = "V" // Século XXI fixo
        let anoStr = String(format: "%02d", year % 100)
        
        // Mês (A-L -> Jan-Dez)
        let mesStr = String(UnicodeScalar(65 + (month - 1))!)

        // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
        let diaStr: String
        if day <= 25 {
            let index = base35Alpha.index(base35Alpha.startIndex, offsetBy: day - 1)
            diaStr = String(base35Alpha[index])
        } else {
            diaStr = String(day - 25)
        }

        // Hora (A-Y sem O para 00h-23h)
        let horaIndex = base35Alpha.index(base35Alpha.startIndex, offsetBy: hour)
        let horaStr = String(base35Alpha[horaIndex])

        let minutosStr = String(format: "%02d", minute)
        let segundosStr = String(format: "%02d", second)

        if let alias = alias, !alias.isEmpty {
            return "\(alias).\(seculo)\(anoStr)\(mesStr)\(diaStr)\(horaStr)\(minutosStr)\(segundosStr)"
        } else {
            return "\(seculo)\(anoStr)\(mesStr)\(diaStr)\(horaStr)\(minutosStr)\(segundosStr)"
        }
    }

    /**
     2. DECODE: Converte String JEC de volta para um objeto Date válido
     */
    static func decode(jecId: String) throws -> Date {
        // Remove o prefixo/alias se ele existir na string
        let partes = jecId.components(separatedBy: ".")
        let corpo = partes.last ?? jecId

        if corpo.count != 10 {
            throw JecError.formatoInvalido("O bloco temporal deve ter exatamente 10 caracteres.")
        }

        // Transformando em array de caracteres para manipulação segura por índice em Swift
        let chars = Array(corpo)
        
        let charSeculo = String(chars[0])
        guard let anoDigitos = Int(String(chars[1...2])) else { throw JecError.formatoInvalido("Ano inválido") }
        let charMes = String(chars[3])
        let charDia = String(chars[4])
        let charHora = String(chars[5])
        guard let minuto = Int(String(chars[6...7])) else { throw JecError.formatoInvalido("Minutos inválidos") }
        guard let segundo = Int(String(chars[8...9])) else { throw JecError.formatoInvalido("Segundos inválidos") }

        // Reconstrução do Ano
        let ano = charSeculo == "V" ? 2000 + anoDigitos : 1900 + anoDigitos

        // Reconstrução do Mês
        guard let mesUnicode = charMes.unicodeScalars.first?.value else { throw JecError.formatoInvalido("Mês inválido") }
        let mes = Int(mesUnicode) - 65 + 1

        // Reconstrução do Dia
        let dia: Int
        if let diaNum = Int(charDia), (1...6).contains(diaNum) {
            dia = diaNum + 25
        } else {
            if let range = base35Alpha.range(of: charDia) {
                dia = base35Alpha.distance(from: base35Alpha.startIndex, to: range.lowerBound) + 1
            } else {
                throw JecError.caractereInvalido("Caractere de dia desconhecido")
            }
        }

        // Reconstrução da Hora
        let hora: Int
        if let range = base35Alpha.range(of: charHora) {
            hora = base35Alpha.distance(from: base35Alpha.startIndex, to: range.lowerBound)
        } else {
            throw JecError.caractereInvalido("Caractere de hora desconhecido")
        }

        // Montagem do DateComponents
        var components = DateComponents()
        components.year = ano
        components.month = mes
        components.day = dia
        components.hour = hora
        components.minute = minuto
        components.second = segundo
        components.timeZone = TimeZone.current

        guard let dataFinal = Calendar.current.date(from: components) else {
            throw JecError.formatoInvalido("Erro ao gerar data final.")
        }

        return dataFinal
    }
}

// === 3. EXECUÇÃO DOS TESTES DE VALIDAÇÃO ===
print("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM SWIFT ===\n")

let formatter = DateFormatter()
formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

// Criando componentes fixos para os testes (evitando problemas de fusos na emulação)
var comp1 = DateComponents()
comp1.year = 2026; comp1.month = 8; comp1.day = 15; comp1.hour = 14; comp1.minute = 30; comp1.second = 45
let data1 = Calendar.current.date(from: comp1)!

// Caso 1: Teste com Dia menor ou igual a 25
let id1 = JuliaEpochCompact.encode(date: data1, alias: "TX")
do {
    let resultado1 = try JuliaEpochCompact.decode(jecId: id1)
    print("Teste 1 (Dia Regular - 15/08):")
    print("-> Original:  \(formatter.string(from: data1))")
    print("-> ID JEC:    \(id1)")
    print("-> Decodado:  \(formatter.string(from: resultado1))")
    print("-> Status:    \(formatter.string(from: data1) == formatter.string(from: resultado1) ? "✅ SUCESSO" : "❌ FALHOU")\n")
} catch {
    print("Erro no Teste 1: \(error)")
}

// Caso 2: Teste com Dia limite (Maior que 25)
var comp2 = DateComponents()
comp2.year = 2026; comp2.month = 12; comp2.day = 28; comp2.hour = 23; comp2.minute = 59; comp2.second = 0
let data2 = Calendar.current.date(from: comp2)!

let id2 = JuliaEpochCompact.encode(date: data2)
do {
    let resultado2 = try JuliaEpochCompact.decode(jecId: id2)
    print("Teste 2 (Dia Limite - 28/12):")
    print("-> Original:  \(formatter.string(from: data2))")
    print("-> ID JEC:    \(id2)")
    print("-> Decodado:  \(formatter.string(from: resultado2))")
    print("-> Status:    \(formatter.string(from: data2) == formatter.string(from: resultado2) ? "✅ SUCESSO" : "❌ FALHOU")")
} catch {
    print("Erro no Teste 2: \(error)")
}
