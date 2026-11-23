.globl imprimir_mensagem
.globl copiar_string
.globl copiar_decimal

.text
imprimir_mensagem:
	li	$v0 4
	syscall
	jr	$ra

# a0 = origem, a1 = destino, v0 = ponteiro para o '\0' final
copiar_string:
	lbu	$t0 0($a0)
	sb	$t0 0($a1)
	beqz	$t0 copiar_string_fim
	addiu	$a0 $a0 1
	addiu	$a1 $a1 1
	j	copiar_string
copiar_string_fim:
	move	$v0 $a1
	jr	$ra

# a0 = valor, a1 = divisor, a2 = destino, v0 = ponteiro para o '\0' final
copiar_decimal:
	div	$a0 $a1
	mflo	$t0 # parte inteira
	mfhi	$t1 # parte fracionária
	
	li	$t2 1
	li	$t3 10
copiar_decimal_potencia: # t2 = maior potencia de 10 <= inteiro
	mul	$t4 $t2 $t3
	bgt	$t4 $t0 copiar_decimal_init
	move	$t2 $t4
	j	copiar_decimal_potencia
copiar_decimal_init:
	div	$t0 $t2
	mflo	$t5
	mfhi	$t0
	addiu	$t5 $t5 48
	sb	$t5 0($a2)
	addiu	$a2 $a2 1
	div	$t2 $t3
	mflo	$t2
	bnez	$t2 copiar_decimal_init
	
	li	$t5 44 # ","
	sb	$t5 0($a2)
	addiu	$a2 $a2 1
	
	div	$a1 $t3
	mflo	$t2
copiar_decimal_frac:
	div	$t1 $t2
	mflo	$t5
	mfhi	$t1
	addiu	$t5 $t5 48
	sb	$t5 0($a2)
	addiu	$a2 $a2 1
	div	$t2 $t3
	mflo	$t2
	bnez	$t2 copiar_decimal_frac
	
	sb	$zero 0($a2)
	move	$v0 $a2
	jr	$ra
	