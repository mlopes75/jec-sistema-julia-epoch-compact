use std::fmt;

pub struct JuliaEpochCompact;

impl JuliaEpochCompact {
    // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
    const BASE35_ALPHA: &'static str = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

    /// 1. ENCODE: Converte uma tupla de data/hora para String JEC
    /// Formato de entrada: (ano, mes, dia, hora, minuto, segundo)
    pub fn encode(year: u32, month: u32, day: u32, hour: u32, minute: u32, second: u32, alias: Option<&str>) -> String {
        let seculo = "V"; // Século XXI fixo
        let ano = format!("{:02}", year % 100);
        
        // Mês (A-L)
        let mes = ((65 + (month - 1)) as u8 as char).to_string();

        // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
        let dia = if day <= 25 {
            Self::BASE35_ALPHA.chars().nth((day - 1) as usize).unwrap().to_string()
        } else {
            (day - 25).to_string()
        };

        // Hora (A-Y sem O para 00h-23h)
        let hora = Self::BASE35_ALPHA.chars().nth(hour as usize).unwrap().to_string();

        let minutos = format!("{:02}", minute);
        let segundos = format!("{:02}", second);

        match alias {
            Some(a) if !a.is_empty() => format!("{}.{}{}{}{}{}{}{}", a, seculo, ano, mes, dia, hora, minutos, segundos),
            _ => format!("{}{}{}{}{}{}{}", seculo, ano, mes, dia, hora, minutos, segundos),
        }
    }

    /// 2. DECODE: Converte String JEC de volta para uma tupla de data/hora
    /// Retorna: Result<(ano, mes, day, hora, minuto, segundo), String>
    pub fn decode(jec_id: &str) -> Result<(u32, u32, u32, u32, u32, u32), String> {
        // Remove o prefixo/alias se ele existir na string
        let corpo = match jec_id.find('.') {
            Some(idx) => &jec_id[idx + 1..],
            None => jec_id,
        };

        if corpo.len() != 10 {
            return Err("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.".to_string());
        }

        // Fatiamento seguro de caracteres ASCII nativos
        let chars: Vec<char> = corpo.chars().collect();
        let char_seculo = chars[0];
        let ano_digitos: u32 = corpo[1..3].parse().map_err(|_| "Erro ao ler o ano")?;
        let char_mes = chars[3];
        let char_dia = chars[4];
        let char_hora = chars[5];
        let minuto: u32 = corpo[6..8].parse().map_err(|_| "Erro ao ler os minutos")?;
        let segundo: u32 = corpo[8..10].parse().map_err(|_| "Erro ao ler os segundos")?;

        // Reconstrução do Ano (Século XXI para 'V')
        let ano = if char_seculo == 'V' { 2000 + ano_digitos } else { 1900 + ano_digitos };

        // Reconstrução do Mês
        let mes = (char_mes as u32) - 65 + 1;

        // Reconstrução do Dia
        let dia = if char_dia.is_ascii_digit() {
            char_dia.to_digit(10).unwrap() + 25
        } else {
            Self::BASE35_ALPHA.find(char_dia).ok_or("Dia inválido no ID")? as u32 + 1
        };

        // Reconstrução da Hora
        let hora = Self::BASE35_ALPHA.find(char_hora).ok_or("Hora inválida no ID")? as u32;

        Ok((ano, mes, dia, hora, minuto, segundo))
    }
}

fn main() {
    println!("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM RUST ===\n");

    // Teste 1: Dia Regular (15/08) com Alias
    let (y1, m1, d1, h1, min1, s1) = (2026, 8, 15, 14, 30, 45);
    let id1 = JuliaEpochCompact.encode(y1, m1, d1, h1, min1, s1, Some("TX"));
    let res1 = JuliaEpochCompact::decode(&id1).unwrap();
    
    println!("Teste 1 (Dia Regular - 15/08):");
    println!("-> Original:  {}-{:02}-{:02} {:02}:{:02}:{:02}", y1, m1, d1, h1, min1, s1);
    println!("-> ID JEC:    {}", id1);
    println!("-> Decodado:  {}-{:02}-{:02} {:02}:{:02}:{:02}", res1.0, res1.1, res1.2, res1.3, res1.4, res1.5);
    println!("-> Status:    {}\n", if (y1, m1, d1, h1, min1, s1) == res1 { "✅ SUCESSO" } else { "❌ FALHOU" });

    // Teste 2: Dia Limite (28/12) sem Alias
    let (y2, m2, d2, h2, min2, s2) = (2026, 12, 28, 23, 59, 0);
    let id2 = JuliaEpochCompact::encode(y2, m2, d2, h2, min2, s2, None);
    let res2 = JuliaEpochCompact::decode(&id2).unwrap();

    println!("Teste 2 (Dia Limite - 28/12):");
    println!("-> Original:  {}-{:02}-{:02} {:02}:{:02}:{:02}", y2, m2, d2, h2, min2, s2);
    println!("-> ID JEC:    {}", id2);
    println!("-> Decodado:  {}-{:02}-{:02} {:02}:{:02}:{:02}", res2.0, res2.1, res2.2, res2.3, res2.4, res2.5);
    println!("-> Status:    {}\n", if (y2, m2, d2, h2, min2, s2) == res2 { "✅ SUCESSO" } else { "❌ FALHOU" });
}
