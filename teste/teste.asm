.data
.text
.globl imprimir_mensagem
.globl ler_tecla
.globl gravar_escolha

imprimir_mensagem:         # imprime a string em $a0
li   $v0, 4
syscall
jr   $ra

ler_tecla:                 # DUBLÊ: digite 0-9 ou A-F (Enter é ignorado)
dub_le:
li   $v0, 12               # lê um caractere
syscall
move $t0, $v0
li   $t1, 10
beq  $t0, $t1, dub_le      # ignora Enter (\n)
li   $t1, 13
beq  $t0, $t1, dub_le      # ignora \r
li   $t1, '0'
blt  $t0, $t1, dub_le      # abaixo de '0': ignora
li   $t1, '9'
ble  $t0, $t1, dub_digito  # '0'..'9'
li   $t1, 'a'
blt  $t0, $t1, dub_maiuscula
addi $t0, $t0, -32         # minúscula -> maiúscula
dub_maiuscula:
li   $t1, 'A'
blt  $t0, $t1, dub_le
li   $t1, 'F'
bgt  $t0, $t1, dub_le      # fora de A..F: ignora
addi $v0, $t0, -55         # 'A'(65) -> 10 ... 'F' -> 15
jr   $ra
dub_digito:
addi $v0, $t0, -48         # '0'(48) -> 0 ... '9' -> 9
jr   $ra

gravar_escolha:            # DUBLÊ: mostra o que seria gravado
move $t0, $a1
li   $v0, 1                # combustível ($a0)
syscall
li   $a0, 32
li   $v0, 11               # espaço
syscall
move $a0, $t0
li   $v0, 1                # preço
syscall
jr   $ra
