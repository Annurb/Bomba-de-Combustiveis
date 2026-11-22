.data 
msg_ligar_desligar:	.asciiz "\nDigite A para ligar a máquina e B para desligar: "
msg_operador_cliente:	.asciiz "\nEscolha modo [A]Cliente/[B]Operador: "

msg_operador_combustivel:	.asciiz "\nEscolha o combustível a ser alterado e clique em A para confirmar a escolha: "
msg_tipo_combustivel:	.asciiz "\n1 - Gasolina Comum\n2- Gasolina Aditivada\n3- Álcool\nEscolha: "
msg_digitar_novo_preco:	.asciiz "\nDigite o novo preço a ser inserido pro tipo de combustível escolhido [1-999 centavos]: "

msg_invalido:	.asciiz "\nNúmero inválido inserido, digite novamente"

mds_desligar:	.asciiz "\nMáquina desligada, aperte A caso queira ligar novamente "

escolha_combustivel:	.word 0
escolha_preco:	.word 0

.eqv TECLA_A 0xA
.eqv TECLA_B 0xB

.text

# Estado 0
# O estado 0 serve para inicializar a máquina de estados 
Inicio:
j Selecionar_ciclo

# Estado 1
# O estado 1 serve para se
Selecionar_ciclo:

la $a0, msg_ligar_desligar
jal imprimir_mensagem

espera_selecionar_ciclo:
jal ler_tecla
# Se v0 for igual a B, vai pra desligar, se for igual a A, ele liga, se nao for nada, a máquina fica ociosa
li $t0, TECLA_B
beq $v0, $t0, Desligar

li $t0, TECLA_A
beq $v0, $t0, Operador_cliente 
j espera_selecionar_ciclo

# Estado pra escolha do operador o cliente
Operador_Cliente:

la $a0, msg_operador_cliente
jal imprimir_mensagem

espera_operador_cliente:
jal ler_tecla
# Se v0 for igual a B, vai pro operador, se for igual a A, vai pro cliente
li $t0, TECLA_B
beq $v0, $t0, Escolher_combustivel_a_alterar

li $t0, TECLA_A
beq $v0, $t0, Escolha_combustivel

j espera_operador_cliente

# Estado pro operador escolher o combustível a ser alterado
Escolher_combustivel_a_alterar:

la $a0, msg_operador_combustivel
jal imprimir_mensagem

la $a0, msg_tipo_combustivel
jal imprimir_mensagem

jal ler_tecla
if_escolher_combustivel:
# v0 vai estar o numero
li $t0, 4
bge $v0, $t0, else_escolher_combustivel
li $t0, -1
bge $t0, $v0, else_escolher_combustivel
sw $v0, escolha_combustivel

j fim_escolher_combustivel

else_escolher_combustivel:
la $a0, msg_invalido
jal imprimir_mensagem

j Escolher_combustivel_a_alterar
fim_escolher_combustivel:
j Digitar_novo_preco

# Estado para o operador digitar o novo preço
Digitar_novo_preco:
la   $a0, msg_digitar_novo_preco
jal  imprimir_mensagem
sw   $zero, escolha_preco          # acumulador em 0

loop_preco:
jal  ler_tecla
li   $t0, TECLA_A
beq  $v0, $t0, confirmar_preco # A = confirma
li   $t0, TECLA_B
beq  $v0, $t0, Selecionar_ciclo # B = cancela
li   $t0, 9
bgt  $v0, $t0, loop_preco # C a F: ignora
lw   $t1, escolha_preco
mul  $t1, $t1, 10
add  $t1, $t1, $v0 # valor = valor*10 + dígito
li   $t2, 999
bgt  $t1, $t2, loop_preco # passou do limite: ignora
sw   $t1, escolha_preco
j    loop_preco

confirmar_preco:
lw   $t1, escolha_preco
beqz $t1, preco_invalido           # preço 0 não vale
j    Gravar
preco_invalido:
la   $a0, msg_invalido
jal  imprimir_mensagem
j    Digitar_novo_preco

Gravar:
lw $a0, escolha_combustivel
lw $a1, escolha_preco
jal gravar_escolha

j Selecionar_ciclo

#Estado final desligar
Desligar:
la   $a0, msg_desligar
jal imprimir_mensagem

espera_desligar:

jal ler_tecla
li $t0, TECLA_A
beq $v0, $t0, Inicio

j espera_desligar

Escolha_combustivel:

j Escolha_combustivel
