.globl varrer_teclado
.globl decodificar_tecla

.data
teclas:	.byte 0x11,0x21,0x41,0x81,0x12,0x22,0x42,0x82,0x14,0x24,0x44,0x84,0x18,0x28,0x48,0x88
	
.text
varrer_teclado:
	li	$t0 0xFFFF0012 # Endereço de seleção de linha
	li	$t1 0xFFFF0014 # Endereço de leitura de coluna
	li	$t2 1 # Começa na linha 1
	li	$t3 16 # Verifica até a linha 8 (0x8?)
varrer_loop:
	sb	$t2 0($t0) # Seleciona a linha
	lbu	$v0 0($t1) # Lê (coluna<<4 | linhas), 0 se nada
	bnez	$v0 varrer_fim # Devolve em $v0 se a tecla for encontrada
	sll	$t2 $t2 1 # Próxima linha
	bne	$t2 $t3 varrer_loop
	li	$v0 0 # Nenhuma tecla
varrer_fim:
	jr	$ra

decodificar_tecla:
	la	$t0 teclas
	li	$t1 0 # Índice = valor da tecla
	li	$t2 16 # Teclado do LabSim vai de 0 até f (0 a 15)
decodificar_loop:
	lbu	$t3 0($t0)
	beq	$t3 $a0 decodificar_achou
	addiu	$t0 $t0 1
	addiu	$t1 $t1 1
	bne	$t1 $t2 decodificar_loop
	li	$v0 -1 # Tecla inválida
	jr	$ra
decodificar_achou:
	move	$v0 $t1
	jr	$ra
