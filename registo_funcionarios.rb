#!/usr/bin/env ruby
# encoding: utf-8
# =============================================================
#  Projeto Final de UFCD  —  Registo de Funcionários (Ruby)
#  Empresa de Suporte Técnico
#  Validação de cada campo através de Expressões Regulares
# =============================================================

require 'date'

# Garante o tratamento de acentos (ã, ç, é…) em qualquer terminal
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

FICHEIRO = 'funcionarios.csv'   # ficheiro de gravação dos registos

# Lista que mantém todos os registos em memória durante a execução
$funcionarios = []

# ── Expressões Regulares de validação ─────────────────────────
RE_NOME     = /\A[A-Za-zÀ-ÖØ-öø-ÿ ]+\z/                                   # letras, espaços e acentos
RE_NIF      = /\A\d{9}\z/                                                 # exatamente 9 dígitos
RE_HORA     = /\A([01]\d|2[0-3]):[0-5]\d\z/                               # HH:MM em formato 24 horas
RE_HOSTNAME = /\A[A-Za-z0-9\-]+\z/                                        # letras, números e hífen
RE_IP       = /\A(25[0-5]|2[0-4]\d|1?\d?\d)(\.(25[0-5]|2[0-4]\d|1?\d?\d)){3}\z/  # IPv4 (0–255)
RE_MAC      = /\A[0-9A-Fa-f]{2}([:-])(?:[0-9A-Fa-f]{2}\1){4}[0-9A-Fa-f]{2}\z/    # separador uniforme : ou -
RE_EMAIL    = /\A[\w.+-]+@[\w-]+(?:\.[\w-]+)*\.[A-Za-z]{2,}\z/            # e-mail válido

# ── Leitura genérica de um campo com validação por Regex ──────
def ler_campo(rotulo, regex, erro)
  loop do
    print "#{rotulo}: "
    valor = gets.chomp.strip
    return valor if valor.match?(regex)
    puts "  ⚠️  #{erro}"
  end
end

# ── Leitura específica da data (valida formato E data real) ───
def ler_data(rotulo)
  loop do
    print "#{rotulo}: "
    valor = gets.chomp.strip
    if valor.match?(%r{\A\d{2}/\d{2}/\d{4}\z})
      begin
        Date.strptime(valor, '%d/%m/%Y')   # rejeita 31/02/2025, 00/00/0000, etc.
        return valor
      rescue ArgumentError
        puts "  ⚠️  Essa data não existe no calendário."
      end
    else
      puts "  ⚠️  Formato inválido. Utilize DD/MM/AAAA."
    end
  end
end

# ── Registo de um único funcionário ───────────────────────────
def registar_funcionario
  puts "\n── Novo registo ───────────────────────────────────────"
  nome  = ler_campo("Nome completo",            RE_NOME,     "Apenas letras, espaços e caracteres acentuados.")
  nif   = ler_campo("NIF",                      RE_NIF,      "O NIF deve ter exatamente 9 dígitos.")
  data  = ler_data ("Data de ingresso (DD/MM/AAAA)")
  hi    = ler_campo("Hora de início (HH:MM)",   RE_HORA,     "Hora inválida (00:00 a 23:59).")
  hf    = ler_campo("Hora de fim    (HH:MM)",   RE_HORA,     "Hora inválida (00:00 a 23:59).")
  host  = ler_campo("Nome do computador",       RE_HOSTNAME, "Apenas letras, números e hífen.")
  ip    = ler_campo("Endereço IP",              RE_IP,       "IPv4 inválido (ex.: 192.168.1.10).")
  mac   = ler_campo("Endereço MAC",             RE_MAC,      "Use XX:XX:XX:XX:XX:XX ou XX-XX-XX-XX-XX-XX.")
  email = ler_campo("E-mail",                   RE_EMAIL,    "Endereço de e-mail inválido.")

  $funcionarios << {
    nome: nome, nif: nif, data: data,
    hora_inicio: hi, hora_fim: hf,
    hostname: host, ip: ip, mac: mac, email: email
  }
  puts "✅ Funcionário registado com sucesso!"
end

# ── Ciclo de registo de vários funcionários ───────────────────
def ciclo_registos
  loop do
    registar_funcionario
    resposta = ''
    loop do
      print "\nPretende registar outro funcionário? (S/N): "
      resposta = gets.chomp.strip.upcase
      break if %w[S N].include?(resposta)
      puts "  ⚠️  Responda apenas S ou N."
    end
    break if resposta == 'N'
  end
  puts "\nRegistos do dia concluídos com sucesso."
end

# ── Listagem dos registos em memória ──────────────────────────
def listar_funcionarios
  if $funcionarios.empty?
    puts "\n(Não existem registos em memória.)"
    return
  end
  puts "\n── Funcionários registados (#{$funcionarios.size}) ─────────"
  $funcionarios.each_with_index do |f, i|
    puts "#{i + 1}. #{f[:nome]}"
    puts "    NIF: #{f[:nif]}  |  Ingresso: #{f[:data]}  |  Turno: #{f[:hora_inicio]}–#{f[:hora_fim]}"
    puts "    Host: #{f[:hostname]}  |  IP: #{f[:ip]}  |  MAC: #{f[:mac]}"
    puts "    E-mail: #{f[:email]}"
  end
end

# ── Gravação dos registos no ficheiro CSV ─────────────────────
def gravar_ficheiro
  if $funcionarios.empty?
    puts "\n(Não há registos para gravar.)"
    return
  end
  File.open(FICHEIRO, 'w') do |f|
    $funcionarios.each do |r|
      f.puts [r[:nome], r[:nif], r[:data], r[:hora_inicio], r[:hora_fim],
              r[:hostname], r[:ip], r[:mac], r[:email]].join(',')
    end
  end
  puts "\n💾 #{$funcionarios.size} registo(s) gravado(s) em '#{FICHEIRO}'."
end

# ── Carregamento dos registos já existentes no ficheiro ───────
# Lê o CSV (se existir) para a memória ao arrancar, para que os
# dados de dias anteriores não se percam e não sejam duplicados.
def carregar_ficheiro
  return unless File.exist?(FICHEIRO)
  File.foreach(FICHEIRO) do |linha|
    linha = linha.chomp
    next if linha.empty?
    campos = linha.split(',')
    next unless campos.size == 9   # ignora linhas mal formadas
    $funcionarios << {
      nome: campos[0], nif: campos[1], data: campos[2],
      hora_inicio: campos[3], hora_fim: campos[4],
      hostname: campos[5], ip: campos[6], mac: campos[7], email: campos[8]
    }
  end
  unless $funcionarios.empty?
    puts "📂 #{$funcionarios.size} registo(s) carregado(s) de '#{FICHEIRO}'."
  end
end

# ── Menu de contexto (programa principal) ─────────────────────
def menu
  puts "═══════════════════════════════════════════════════════"
  puts "   REGISTO DE FUNCIONÁRIOS — EMPRESA DE SUPORTE TÉCNICO"
  puts "═══════════════════════════════════════════════════════"
  carregar_ficheiro   # traz para a memória o que já estava gravado
  loop do
    puts "\n──────────────── MENU PRINCIPAL ───────────────────────"
    puts "  1 — Registar funcionário(s)"
    puts "  2 — Listar registos"
    puts "  3 — Gravar registos em ficheiro (#{FICHEIRO})"
    puts "  4 — Sair"
    print "Opção: "
    case gets.chomp.strip
    when '1' then ciclo_registos
    when '2' then listar_funcionarios
    when '3' then gravar_ficheiro
    when '4'
      puts "\nA terminar o programa. Até breve! 👋"
      break
    else
      puts "  ⚠️  Opção inválida. Escolha um número entre 1 e 4."
    end
  end
end

menu
