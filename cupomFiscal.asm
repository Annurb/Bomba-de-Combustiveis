.globl gerar_cupom
.data
cupom_arquivo:		.asciiz "cupom_fiscal.txt"
cupom_cabeceira:		.asciiz "\n========== CUPOM FISCAL ==========\n"
cupom_comb:		.asciiz "Combustivel: "
cupom_vol:		.asciiz "\nVolume: "
cupom_litr:		.asciiz " L"
cupom_prec:		.asciiz "\nPreço/L: R$ "
cupom_total:		.asciiz "\nTotal:   R$ "
cupom_rodape:		.asciiz "\n==================================\n"
cupom_virg:		.asciiz ","
cupom_zero:		.asciiz "0"
comb1:			.asciiz "Gasolina Comum"
comb2:			.asciiz "Gasolina Aditivada"
comb3:			.asciiz "Álcool"
combustiveis:		.word comb1, comb2, comb3
buffer_cupom:		.space 256
.text
gerar_cupom:
	addiu	$sp $sp -28
	sw	$ra 0($sp)
	sw	$s0 4($sp)
	sw	$s1 8($sp)
	sw	$s2 12($sp)
	sw	$s3 16($sp)
	sw	$s4 20($sp)
	sw	$s5 24($sp)
	
	move	$s0 $a0
	move	$s1 $a1
	move	$s2 $a2
	move	$s3 $a3
	la	$s5 buffer_cupom # ponteiro de escrita
	
	la	$a0 cupom_cabeceira
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	
	la	$a0 cupom_comb
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	
	addiu	$t0 $s0 -1
	sll	$t0 $t0 2
	la	$t1 combustiveis
	addu	$t1 $t1 $t0
	lw	$a0 0($t1)
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	
	la	$a0 cupom_vol
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	move	$a0 $s2
	li	$a1 1000
	move	$a2 $s5
	jal	copiar_decimal
	move	$s5 $v0
	la	$a0 cupom_litr
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	
	la	$a0 cupom_prec
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	move	$a0 $s1
	li	$a1 100
	move	$a2 $s5
	jal	copiar_decimal
	move	$s5 $v0
	
	la	$a0 cupom_total
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	lw	$s4 modo_abastecimento
	beq	$s4 0 modo_litros
	j	modo_reais
	modo_litros:
	mul	$t0 $s2 $s1
	li	$t1 1000
	div	$t0 $t1
	mflo	$a0 # total em centavos
	j	continuar_cupom_total
	modo_reais:
	mul	$a0 $s3 100
	continuar_cupom_total:
	li	$a1 100
	move	$a2 $s5
	jal	copiar_decimal
	move	$s5 $v0
	
	la	$a0 cupom_rodape
	move	$a1 $s5
	jal	copiar_string
	move	$s5 $v0
	
	la	$t0 buffer_cupom
	subu	$s2 $s5 $t0 # tamanho do texto
	
	la	$a0 buffer_cupom # mostra no console
	jal	imprimir_mensagem
	
	la	$a0 cupom_arquivo
	li	$a1 1 # escrita
	li	$a2 0
	li	$v0 13
	syscall # cria o arquivo
	bltz	$v0 cupom_fim
	move	$s0 $v0 # descritor
	
	move	$a0 $s0 
	la	$a1 buffer_cupom
	move	$a2 $s2
	li	$v0 15
	syscall	# escreve
	
	move	$a0 $s0 # fecha
	li	$v0 16
	syscall
cupom_fim:
	lw	$ra 0($sp)
	lw	$s0 4($sp)
	lw	$s1 8($sp)
	lw	$s2 12($sp)
	lw	$s3 16($sp)
	lw	$s4 20($sp)
	lw	$s5 24($sp)
	addiu	$sp $sp 28
	jr	$ra
