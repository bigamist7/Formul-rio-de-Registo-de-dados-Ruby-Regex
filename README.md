# Registo de Funcionários — Empresa de Suporte Técnico

Projeto Final de UFCD desenvolvido em **Ruby**. Trata-se de um programa de consola
para o registo dos dados dos funcionários da rede de uma empresa de suporte técnico,
com **validação de cada campo através de expressões regulares (Regex)**, de modo a
garantir a integridade e a consistência da informação introduzida.

---

## Funcionalidades

- Menu de contexto com quatro opções (registar, listar, gravar, sair).
- Registo de vários funcionários de forma consecutiva, num ciclo repetitivo.
- Validação obrigatória de todos os campos antes de serem aceites; sempre que um
  valor é inválido, o programa apresenta uma mensagem de erro e volta a solicitá-lo.
- Gravação dos registos num ficheiro CSV (um registo por linha, campos separados
  por vírgula).
- **Persistência entre sessões:** ao arrancar, o programa carrega os registos já
  existentes no ficheiro, acrescenta os novos e grava o conjunto completo, sem
  perder o histórico de dias anteriores e sem duplicar registos.

---

## Requisitos

- **Ruby** instalado na máquina (versão 3.x recomendada).

Para confirmar que o Ruby está disponível, execute na linha de comandos:

```bash
ruby --version
```

Se o comando devolver, por exemplo, `ruby 3.2.3`, está tudo pronto. Caso contrário,
é necessário instalar o Ruby (em Windows, através do *RubyInstaller*).

---

## Como executar

A partir da pasta onde se encontra o ficheiro, execute:

```bash
ruby registo_funcionarios.rb
```

> O programa é **interativo** (lê os dados que o utilizador escreve), pelo que deve
> ser corrido no **Terminal / linha de comandos** e não numa consola apenas de leitura.

---

## Menu principal

```
1 — Registar funcionário(s)
2 — Listar registos
3 — Gravar registos em ficheiro (funcionarios.csv)
4 — Sair
```

A opção **1** inicia o ciclo de registo. Após cada funcionário, o programa pergunta:

```
Pretende registar outro funcionário? (S/N)
```

- **S** — inicia um novo registo.
- **N** — termina o ciclo e apresenta a mensagem
  `Registos do dia concluídos com sucesso.`, regressando ao menu.

---

## Dados recolhidos e respetivas validações

| Campo | Regra de validação |
|---|---|
| Nome completo | Apenas letras, espaços e caracteres acentuados. |
| NIF | Exatamente 9 dígitos. |
| Data de ingresso | Formato `DD/MM/AAAA` **e** data existente no calendário (rejeita, por exemplo, `31/02/2025`). |
| Hora de início / fim | Formato `HH:MM` em 24 horas (`00:00`–`23:59`). |
| Nome do computador (Hostname) | Letras, números e hífen. |
| Endereço IP | Formato IPv4 válido, com cada octeto entre 0 e 255. |
| Endereço MAC | `XX:XX:XX:XX:XX:XX` ou `XX-XX-XX-XX-XX-XX` (separador uniforme). |
| E-mail | Endereço de correio eletrónico válido. |

---

## Formato do ficheiro

Os registos são guardados em **`funcionarios.csv`**, no mesmo diretório do programa.
Cada linha corresponde a um funcionário e os campos são separados por vírgula, pela
seguinte ordem:

```
nome,nif,data,hora_inicio,hora_fim,hostname,ip,mac,email
```

Exemplo:

```
João Casanova,999999990,15/03/2024,09:00,18:00,PC-01,192.168.73.10,00:1A:2B:3C:4D:5E,joao@suporte.pt
Ana Sá,123456789,01/06/2023,08:30,17:30,PC-02,10.0.0.5,aa-bb-cc-dd-ee-ff,ana.sa@suporte.pt
```

---

## Notas técnicas

- O programa força a codificação **UTF-8** na entrada e na saída, para tratar
  corretamente caracteres acentuados (ã, ç, é…) em qualquer terminal.
- A primeira linha do ficheiro (`#!/usr/bin/env ruby`) permite a execução direta em
  sistemas Linux/macOS. Em Windows é inofensiva, bastando correr o programa com
  `ruby registo_funcionarios.rb`.
- O carregamento do CSV assume ficheiros gerados pelo próprio programa (campos sem
  vírgulas internas). As validações de entrada garantem essa condição.

---

## Estrutura do projeto

```
.
├── registo_funcionarios.rb   # programa principal
├── funcionarios.csv          # ficheiro de dados (criado na primeira gravação)
└── README.md                 # este ficheiro
```

---

## Autoria

Projeto Final de UFCD — CET em Cibersegurança.
Desenvolvido por **João Casanova**.
