.data 
msg_ligar_desligar:		.asciiz "\nDigite A para ligar a máquina e B para desligar: "
msg_operador_cliente:		.asciiz "\nEscolha modo [A]Cliente/[B]Operador: "
msg_f_cancelar:			.asciiz "\n[Pressione F a qualquer momento para cancelar.]"

msg_operador_combustivel:	.asciiz "\nEscolha o combustível a ser alterado: "
msg_tipo_combustivel:		.asciiz "\n1 - Gasolina Comum\n2 - Gasolina Aditivada\n3 - Álcool\nEscolha: "
msg_digitar_novo_preco:		.asciiz "\nDigite o novo preço a ser inserido pro tipo de combustível escolhido (1-999 centavos) [A - Confirmar]: "

msg_invalido:			.asciiz "\nNúmero inválido inserido, digite novamente"

msg_desligar:			.asciiz "\nMáquina desligada, aperte A caso queira ligar novamente "

msg_escolha_combustivel:	.asciiz "\nEscolha o tipo de combustível: "
msg_escolher_modo:		.asciiz "\nEscolha o modo [A - Quantidade de litros/ B - Valor monetário]: "
msg_finalizado:			.asciiz "\nTransação finalizada!"
msg_digitar_quantidade:		.asciiz "\nDigite a quantidade desejada: (1-99 litros) [A - Confirmar]"
msg_digitar_valor:		.asciiz "\nDigite o valor desejado: (1-99 reais) [A - Confirmar]"

escolha_combustivel_operador:	.word 0
escolha_preco:			.word 0

escolha_combustivel_cliente:	.word 0 

.globl modo_abastecimento
modo_abastecimento:		.word 0

quantidade:			.word 0 
.eqv TECLA_A 0xA
.eqv TECLA_B 0xB
.eqv TECLA_CANCELA 0xF   # cancela em qualquer tela de entrada

.eqv MODO_LITROS 0
.eqv MODO_REAIS 1

.globl precos
precos: 			.word 579, 649, 449 # centavos por litro: [0]=comum, [1]=aditivada, [2]=álcool
preco_venda:                 	.word 0
volume_ml:                   	.word 0

.globl display_buf
display_buf: 			.word -1 # Displays apagados (-1) ou valor a mostrar
.text

# Estado 0
# O estado 0 serve para inicializar a máquina de estados 
.globl mPrincipal
mPrincipal:
Inicio:
j Selecionar_ciclo

# Estado 1
# O estado 1 serve para se
Selecionar_ciclo:

li $a0, 0
jal mostrar_display

la $a0, msg_ligar_desligar
jal imprimir_mensagem

espera_selecionar_ciclo:
jal ler_tecla
# Se v0 for igual a B, vai pra desligar, se for igual a A, ele liga, se nao for nada, a máquina fica ociosa
li $t0, TECLA_B
beq $v0, $t0, Desligar

li $t0, TECLA_A
beq $v0, $t0, Operador_Cliente 
j espera_selecionar_ciclo

# Estado pra escolha do operador o cliente
Operador_Cliente:

la $a0, msg_f_cancelar
jal imprimir_mensagem
la $a0, msg_operador_cliente
jal imprimir_mensagem

espera_operador_cliente:
jal ler_tecla
# Se v0 for igual a B, vai pro operador, se for igual a A, vai pro cliente
li $t0, TECLA_B
beq $v0, $t0, Escolher_combustivel_a_alterar

li $t0, TECLA_A
beq $v0, $t0, Escolha_combustivel

li $t0, TECLA_CANCELA
beq $v0, $t0, Selecionar_ciclo

j espera_operador_cliente

# Estado pro operador escolher o combustível a ser alterado
Escolher_combustivel_a_alterar:

la $a0, msg_operador_combustivel
jal imprimir_mensagem

la $a0, msg_tipo_combustivel
jal imprimir_mensagem

loop_escolher_combustivel_a_alterar:
jal ler_tecla

li $t0, TECLA_CANCELA
beq $v0, $t0, Selecionar_ciclo
if_escolher_combustivel:
# v0 vai estar o numero (valido: 1 a 3)
li $t0, 1
blt $v0, $t0, else_escolher_combustivel
li $t0, 3
bgt $v0, $t0, else_escolher_combustivel
sw $v0, escolha_combustivel_operador

move $a0, $v0
jal mostrar_display              # eco: combustivel escolhido

j fim_escolher_combustivel

else_escolher_combustivel:
la $a0, msg_invalido
jal imprimir_mensagem

j loop_escolher_combustivel_a_alterar
fim_escolher_combustivel:
j Digitar_novo_preco

# Estado para o operador digitar o novo preço
Digitar_novo_preco:
la   $a0, msg_digitar_novo_preco
jal  imprimir_mensagem
sw   $zero, escolha_preco          # acumulador em 0
li   $a0, 0
jal  mostrar_display               # display comeca em 0

loop_preco:
jal  ler_tecla

li   $t0, TECLA_A
beq  $v0, $t0, confirmar_preco # A = confirma
li   $t0, TECLA_CANCELA
beq  $v0, $t0, Selecionar_ciclo # F = cancela
li   $t0, 9
bgt  $v0, $t0, loop_preco # C a F: ignora
lw   $t1, escolha_preco
mul  $t1, $t1, 10
add  $t1, $t1, $v0 # valor = valor*10 + dígito
li   $t2, 999
bgt  $t1, $t2, loop_preco # passou do limite: ignora
sw   $t1, escolha_preco
move $a0, $t1
jal  mostrar_display               # mostra o numero acumulado
j    loop_preco

confirmar_preco:
lw   $t1, escolha_preco
beqz $t1, preco_invalido # preço 0 não vale
j    Gravar
preco_invalido:
la   $a0, msg_invalido
jal  imprimir_mensagem
j    Digitar_novo_preco

Gravar:
lw $a0, escolha_combustivel_operador
lw $a1, escolha_preco
jal gravar_escolha

j Selecionar_ciclo

#Estado final desligar
Desligar:
li $a0, -1
jal mostrar_display              
jal atualizar_display	# apaga o display

li	$v0 10
syscall
# -------------------------------------------------------------------------------------------
# Estado para que o cliente escolha o combustível que ele quer 
Escolha_combustivel:      

la $a0, msg_escolha_combustivel
jal imprimir_mensagem

la $a0, msg_tipo_combustivel
jal imprimir_mensagem

espera_escolha_combustivel:

jal ler_tecla

li $t0, TECLA_CANCELA
beq $v0, $t0, Selecionar_ciclo
if_escolha_combustivel:
# v0 vai estar o numero (valido: 1 a 3)
li $t0, 1
blt $v0, $t0, else_escolha_combustivel
li $t0, 3
bgt $v0, $t0, else_escolha_combustivel
sw $v0, escolha_combustivel_cliente

# fixa o preco desta venda (o operador nao altera mais o que o cliente ja vai pagar)
move $a0, $v0
jal mostrar_display              # eco: combustivel escolhido

lw $a0, escolha_combustivel_cliente
jal obter_preco
sw $v0, preco_venda

j fim_escolha_combustivel

else_escolha_combustivel:
la $a0, msg_invalido
jal imprimir_mensagem

j Escolha_combustivel
fim_escolha_combustivel:
j Escolher_modo

# Estado para o cliente escolher o modo que ele quer
Escolher_modo:
la $a0, msg_escolher_modo
jal imprimir_mensagem

espera_escolher_modo:
jal ler_tecla

li $t0, TECLA_CANCELA
beq $v0, $t0, Selecionar_ciclo

# Se v0 for igual a B, a variavel modo recebe 1, se for igual a A, recebe 0
li $t0, TECLA_B
beq $v0, $t0, escolha_opcao_valor

li $t0, TECLA_A
beq $v0, $t0, escolha_opcao_quantidade

else_nenhum_modo: 
la $a0, msg_invalido
jal imprimir_mensagem

j Escolher_modo

escolha_opcao_valor:
li $t0, 1

j fim_escolher_modo

escolha_opcao_quantidade:
li $t0, 0

fim_escolher_modo:
sw $t0, modo_abastecimento

j Digitar_quantidade

# Estado para digitar a quantidade que o cliente deseja
Digitar_quantidade:
lw   $t0, modo_abastecimento
beq  $t0, 1, msg_valor # Imprime a mensagem de acordo com o modo selecionado
la   $a0, msg_digitar_quantidade
j    continuar_digitar_quantidade
msg_valor:
la   $a0, msg_digitar_valor
continuar_digitar_quantidade:
jal  imprimir_mensagem
sw   $zero, quantidade              # zera o acumulador
li   $a0, 0
jal  mostrar_display                # display comeca em 0

loop_quantidade:
jal  ler_tecla

li   $t0, TECLA_CANCELA
beq  $v0, $t0, Selecionar_ciclo     # F = cancela

li   $t0, TECLA_A
beq  $v0, $t0, confirmar_quantidade # A = confirma

li   $t0, 9
bgt  $v0, $t0, loop_quantidade # B, C, D, E: ignora

lw   $t1, quantidade
mul  $t1, $t1, 10
add  $t1, $t1, $v0 # valor = valor*10 + dígito
li   $t2, 99
bgt  $t1, $t2, loop_quantidade # passou do limite: ignora o dígito
sw   $t1, quantidade
move $a0, $t1
jal  mostrar_display                # mostra o numero acumulado
j    loop_quantidade

confirmar_quantidade:
lw   $t1, quantidade
beqz $t1, quantidade_invalida # quantidade 0 não vale
j    Enchendo

quantidade_invalida:
la   $a0, msg_invalido
jal  imprimir_mensagem
j    Digitar_quantidade

#Estado para encher os litros
Enchendo:

lw $t0, modo_abastecimento
lw $a0, quantidade
li $t1, MODO_REAIS
beq $t0, $t1, enchendo_reais

# Modo litros litros=> mL
mul $a0, $a0, 1000
j enchendo_executa

enchendo_reais:
# Função de calcula os mililitros a partir dos reais
lw $a1, preco_venda
jal calculo_mililitros_reais 
move $a0, $v0

enchendo_executa:
# Funcao que vai enchendo a bomba por varios segundos
jal enchendo_bomba
sw $v0, volume_ml # guarda o volume em mL antes de qualquer outra chamada

li $t0, 1000
div $a0, $v0, $t0 # mL => litros inteiros
jal mostrar_display # (a atualizacao ao vivo deve ficar dentro de enchendo_bomba, no caso mostrar display dentro de enchendo bomba)
j Gerar_cupom_fiscal


# Estado pra gerar o cupom fiscal
Gerar_cupom_fiscal:
lw $a0, escolha_combustivel_cliente
lw $a1, preco_venda
lw $a2, volume_ml
lw $a3, quantidade
jal gerar_cupom # Funcao pra gerar o cupom fiscal a partir desses 
j Finalizado

# Estado para a finalização da transação
Finalizado:

la $a0, msg_finalizado
jal imprimir_mensagem

j Selecionar_ciclo
