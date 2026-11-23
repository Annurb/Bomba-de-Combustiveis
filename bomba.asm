.globl enchendo_bomba

.text
# a0 = volume alvo em mL, v0 = mL abastecidos
enchendo_bomba:
	addiu	$sp $sp -16
	sw	$ra 0($sp)
	sw	$s0 4($sp)
	sw	$s1 8($sp)
	sw	$s2 12($sp)
	move	$s0 $a0 # alvo
	li	$s1 0 # atual
bomba_loop:
	bge	$s1 $s0 bomba_fim
	li	$v0 30
	syscall
	move	$s2 $a0
bomba_espera:
	li	$v0 30
	syscall
	subu	$t0 $a0 $s2
	li	$t1 100
	bltu	$t0 $t1 bomba_espera # espera 100 ms
	
	addiu	$s1 $s1 100
	ble	$s1 $s0 bomba_ok
	move	$s1 $s0
bomba_ok:
	li	$t0 1000
	div	$s1 $t0
	mflo	$a0
	jal	mostrar_display
	j	bomba_loop
bomba_fim:
	move	$v0 $s1
	lw	$ra 0($sp)
	lw	$s0 4($sp)
	lw	$s1 8($sp)
	lw	$s2 12($sp)
	addi	$sp $sp 16
	jr	$ra