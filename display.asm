.globl mostrar_display
.globl atualizar_display

.data
digitos:	.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
display_ultimo:	.word -2 # -2 = nunca escrito (força a primeira escrita)

.text

mostrar_display:
	sw	$a0 display_buf
	jr	$ra
	
atualizar_display:
	lw	$t0 display_buf
	lw	$t1 display_ultimo
	beq	$t0 $t1 atualizar_fim
	sw	$t0 display_ultimo
	
	li	$t7 0xFFFF0011 # Display esquerdo (dezenas)
	li	$t8 0xFFFF0010 # Display direito (unidades)
	bltz	$t0 apagar_display
	
	li	$t1 100
	div	$t0 $t1
	mfhi	$t0 # valor mod 100
	li	$t1 10
	div	$t0 $t1
	mflo	$t2 # dezenas
	mfhi	$t3 # unidades
	la	$t4 digitos
	addu	$t5 $t4 $t2
	lbu	$t6 0($t5)
	addu	$t5 $t4 $t3
	lbu	$t9 0($t5)
	sb	$t6 0($t7)
	sb	$t9 0($t8)
atualizar_fim:
	jr	$ra
	
apagar_display:
	sb	$zero 0($t7)
	sb	$zero 0($t8)
	jr	$ra
