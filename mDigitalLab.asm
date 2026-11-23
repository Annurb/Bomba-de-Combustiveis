.data

tecla_atual:	.word 0
tecla_pub:	.word 0
tecla_nova:	.word 0
# Lembrar do display buffer depois
.text
.globl mDigitalLab
.globl tecla_pub
.globl tecla_nova

mDigitalLab:
# Estado 0
# O estado 0 serve pra varrer o teclado, lê-lo e devolver seu valor
Varrer:
jal atualizar_display # mantem o display atualizado sem techa
jal varrer_teclado # Devolve uma tecla ou 0 em v0, basicamente é um procedimento que lê o teclado e devolver o valor
beq $v0, $zero, Varrer # Se v0 for 0 entao volta pro estado varrer
sw $v0, tecla_atual # Se nao, guarda o valor na tecla_atual
j Tecla_detectada # Proximo estado

# Estado 1
# O estado 1 serve para decodificar o valor na tecla de 0 a F
Tecla_detectada:

lw $a0, tecla_atual # Pega o valor da tecla atual e coloca em a0
jal decodificar_tecla # Vai para a função de decodificar tecla, onde vai ser decodificado o valor de 0 a f
# Se decodificar_tecla for -1
bltz $v0, Varrer # Descarta
sw $v0, tecla_atual
j Aguardar_liberacao

# Estado 2
# O estado 2 serve pra esperar que o varrer teclado devolva 0, no caso que a tecla seja solta
Aguardar_liberacao:

jal atualizar_display
jal varrer_teclado
bnez $v0, Aguardar_liberacao # Se o valor for diferente de 0, vai continuar aqui
j Publicar

# Estado 3
# O estado 3 serve pra entregar para a maquina principal a tecla
Publicar:
lw $t0, tecla_atual
sw $t0, tecla_pub
li $t1, 1
sw $t1, tecla_nova # flag que vai dizer se tem uma tecla nova, a maquina vai tratar ela e zerar novamente
j Varrer
