.globl obter_preco
.globl gravar_escolha
.globl calculo_mililitros_reais

.text
# a0 = escolha de combustível, v0 = preço do combustível selecionado
obter_preco:
	addiu	$t0 $a0 -1
	sll	$t0 $t0 2
	la	$t1 precos
	addu	$t1 $t1 $t0
	lw	$v0 0($t1)
	jr	$ra
# a0 = escolha de combustível, a1 = novo preço
gravar_escolha:
	addiu	$t0 $a0 -1
	sll	$t0 $t0 2
	la	$t1 precos
	addu	$t1 $t1 $t0
	sw	$a1 0($t1)
	jr	$ra
# a0 = reais, a1 = preço, v0 = mL
# mL = reais * 100 * 1000 / preço
calculo_mililitros_reais:
	li	$t0 100000
	mul	$t0 $a0 $t0
	div	$t0 $a1
	mflo	$v0
	jr	$ra
