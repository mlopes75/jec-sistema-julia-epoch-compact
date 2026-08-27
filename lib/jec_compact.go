package main

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// JuliaEpochCompact gerencia a codificação e decodificação do padrão JEC.
type JuliaEpochCompact struct{}

// BASE35_ALPHA é a tabela oficial que exclui totalmente a letra 'O'.
const BASE35_ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ"

// Encode converte um objeto time.Time para uma String JEC compactada.
func (j JuliaEpochCompact) Encode(dt time.Time, alias string) string {
	seculo := "V" // Século XXI fixo
	ano := fmt.Sprintf("%02d", dt.Year()%100)

	// Mês (A-L -> Jan-Dez)
	mes := string(rune(65 + int(dt.Month()) - 1))

	// Dia (A-Z sem O para 1-25; 1-6 para 26-31)
	var dia string
	if dt.Day() <= 25 {
		dia = string(BASE35_ALPHA[dt.Day()-1])
	} else {
		dia = strconv.Itoa(dt.Day() - 25)
	}

	// Hora (A-Y sem O para 00h-23h)
	hora := string(BASE35_ALPHA[dt.Hour()])

	minutos := fmt.Sprintf("%02d", dt.Minute())
	segundos := fmt.Sprintf("%02d", dt.Second())

	if alias != "" {
		return fmt.Sprintf("%s.%s%s%s%s%s%s%s", alias, seculo, ano, mes, dia, hora, minutos, segundos)
	}
	return fmt.Sprintf("%s%s%s%s%s%s%s", seculo, ano, mes, dia, hora, minutos, segundos)
}

// Decode converte uma String JEC de volta para um objeto time.Time válido.
func (j JuliaEpochCompact) Decode(jecID string) (time.Time, error) {
	// Remove o prefixo/alias se ele existir na string
	partes := strings.Split(jecID, ".")
	corpo := partes[len(partes)-1]

	if len(corpo) != 10 {
		return time.Time{}, fmt.Errorf("formato JEC inválido: o bloco deve ter 10 caracteres")
	}

	// Fatiamento preciso baseado na estrutura posicional rígida de 10 caracteres
	charSeculo := string(corpo[0])
	anoDigitos, err := strconv.Atoi(corpo[1:3])
	if err != nil {
		return time.Time{}, fmt.Errorf("ano inválido: %v", err)
	}
	charMes := string(corpo[3])
	charDia := string(corpo[4])
	charHora := string(corpo[5])
	minuto, err := strconv.Atoi(corpo[6:8])
	if err != nil {
		return time.Time{}, fmt.Errorf("minutos inválidos: %v", err)
	}
	segundo, err := strconv.Atoi(corpo[8:10])
	if err != nil {
		return time.Time{}, fmt.Errorf("segundos inválidos: %v", err)
	}

	// Reconstrução do Ano
	ano := 1900 + anoDigitos
	if charSeculo == "V" {
		ano = 2000 + anoDigitos
	}

	// Reconstrução do Mês
	mes := int(charMes[0]) - 65 + 1

	// Reconstrução do Dia
	var dia int
	isDigit, _ := regexp.MatchString("^[1-6]$", charDia)
	if isDigit {
		diaNum, _ := strconv.Atoi(charDia)
		dia = diaNum + 25
	} else {
		idx := strings.Index(BASE35_ALPHA, charDia)
		if idx == -1 {
			return time.Time{}, fmt.Errorf("caractere de dia inválido: %s", charDia)
		}
		dia = idx + 1
	}

	// Reconstrução da Hora
	hora := strings.Index(BASE35_ALPHA, charHora)
	if hora == -1 {
		return time.Time{}, fmt.Errorf("caractere de hora inválido: %s", charHora)
	}

	// Montagem do objeto de tempo (Usando fuso local padrão para o teste)
	return time.Date(ano, time.Month(mes), dia, hora, minuto, segundo, 0, time.Local), nil
}

func main() {
	fmt.Println("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM GO ===\n")
	jec := JuliaEpochCompact{}
	layout := "02/01/2006 15:04:05"

	// Caso 1: Teste com Dia menor ou igual a 25
	data1 := time.Date(2026, time.August, 15, 14, 30, 45, 0, time.Local)
	id1 := jec.Encode(data1, "TX")
	resultado1, err1 := jec.Decode(id1)

	fmt.Println("Teste 1 (Dia Regular - 15/08):")
	fmt.Printf("-> Original:  %s\n", data1.Format(layout))
	fmt.Printf("-> ID JEC:    %s\n", id1)
	if err1 != nil {
		fmt.Printf("-> Erro:      %v\n", err1)
	} else {
		fmt.Printf("-> Decodado:  %s\n", resultado1.Format(layout))
		status := "❌ FALHOU"
		if data1.Equal(resultado1) {
			status = "✅ SUCESSO"
		}
		fmt.Printf("-> Status:    %s\n\n", status)
	}

	// Caso 2: Teste com Dia limite (Maior que 25)
	data2 := time.Date(2026, time.December, 28, 23, 59, 0, 0, time.Local)
	id2 := jec.Encode(data2, "")
	resultado2, err2 := jec.Decode(id2)

	fmt.Println("Teste 2 (Dia Limite - 28/12):")
	fmt.Printf("-> Original:  %s\n", data2.Format(layout))
	fmt.Printf("-> ID JEC:    %s\n", id2)
	if err2 != nil {
		fmt.Printf("-> Erro:      %v\n", err2)
	} else {
		fmt.Printf("-> Decodado:  %s\n", resultado2.Format(layout))
		status := "❌ FALHOU"
		if data2.Equal(resultado2) {
			status = "✅ SUCESSO"
		}
		fmt.Printf("-> Status:    %s\n", status)
	}
}
