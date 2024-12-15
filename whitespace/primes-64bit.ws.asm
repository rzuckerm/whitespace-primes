;Store number of bits (B=(sieve_size-1)//2) in memory[64]
push 64       ;stack: 64
inn           ;memory[64]=sieve_size, stack: empty
push 64       ;stack: 64
dup           ;stack: 64, 64
retr          ;stack: 64, sieve_size=memory[64]
push 1        ;stack: 64, sieve_size, 1
sub           ;stack: 64, sieve_size-1
push 2        ;stack: 64, sieve_size-1, 2
div           ;stack: 64, B=(sieve_size-1)//2
store         ;memory[64]=B
              ;stack: empty

;Store 2**n in memory[n], for n = 0 to 63
push 1        ;stack: mask=1
push 0        ;stack: mask=1, memaddr=0
label 0
  dup         ;stack: mask, memaddr, memaddr
  copy 2      ;stack: mask, memaddr, memaddr, mask
  store       ;memory[memaddr]=mask
              ;stack: mask, memaddr
  swap        ;stack: memaddr, mask
  push 2      ;stack: memaddr, mask, 2
  mult        ;stack: memaddr, mask=mask*2
  swap        ;stack: mask, memaddr
  push 1      ;stack: mask, memaddr, 1
  add         ;stack: mask, memaddr=memaddr+1
  dup         ;stack: mask, memaddr, memaddr
  push 64     ;stack: mask, memaddr, memaddr, 64
  sub         ;stack: mask, memaddr, memaddr-64
  jumpn 0     ;stack: mask, memaddr
              ;repeat loop if memaddr<64

pop           ;stack: mask
pop           ;stack: empty

;end_memaddr=(B+63)//64+66
push 64       ;stack: 64
retr          ;stack: memory[64]=B
push 63       ;stack: B, 63
add           ;stack: B+63
push 64       ;stack: B+63, 64
div           ;stack: (B+63)//64
push 66       ;stack: (B+63)//64, 66
add           ;stack: end_memaddr=(B+63)//64+66

;Clear sieve (memory[66..end_memaddr-1]), where each word holds 64 bits.
;Each bit represents whether a factor is prime (0) or composite (1).
;bit 0: 3
;bit 1: 5
;...
;bit B-1: sieve_size - (sieve_size mod 2) (next lowest odd value -- e.g., 1000 becomes 999)
push 66       ;stack: end_memaddr, memaddr=66
label 1
  dup         ;stack: end_memaddr, memaddr, memaddr
  push 0      ;stack: end_memaddr, memaddr, memaddr, 0
  store       ;mem[memaddr]=0
              ;stack: end_memaddr, memaddr
  push 1      ;stack: end_memaddr, memaddr, 1
  add         ;stack: end_memaddr, memaddr=memaddr+1
  dup         ;stack: end_memaddr, memaddr, memaddr
  copy 2      ;stack: end_memaddr, memaddr, memaddr, end_memaddr
  sub         ;stack: end_memaddr, memaddr, memaddr-end_memaddr
  jumpn 1     ;stack: end_memaddr, memaddr
              ;repeat loop if memaddr<end_memaddr

;memory[65]=end_memaddr
pop           ;stack: end_memaddr
push 65       ;stack: end_memaddr, 65
swap          ;stack: 65, end_memaddr
store         ;memory[65]=end_memaddr
              ;stack: empty

;Do prime sieve:
;  b=0
;  bsq=3
;  while bsq<B:
;    if bit b clear in sieve:
;        k=bsq
;        kinc=2*b+3
;        while k<B:
;            Set bit k in sieve
;            k=k+kinc
;    b=b+1
;    bsq=bsq+4*(b+1)
push 64       ;stack: 64
dup           ;stack: 64, 64
retr          ;stack: 64, B
push 1        ;stack: 64, B, 1
sub           ;stack: 64, B-1
store         ;memaddr[64]=B-1
              ;stack: empty
push 3        ;stack: bsq=3
push 0        ;stack: bsq, b=0

;outer loop
label 00
  push 64     ;stack: bsq, b, 64
  retr        ;stack: bsq, b, B-1
  copy 2      ;stack: bsq, b, B-1, bsq
  sub         ;stack: bsq, b, B-1-bsq
  jumpn 100   ;stack: bsq, b
              ;exit outer loop if bsq>=B
  call 1001   ;stack: bsq, b, 0 if bit b set else -1
  jumpz 11    ;stack: bsq, b
              ;skip over inner loop if bit b set
  copy 1      ;stack: bsq, b, k=bsq
  copy 1      ;stack: bsq, b, k, b
  push 2      ;stack: bsq, b, k, b, 2
  mult        ;stack: bsq, b, k, b*2
  push 3      ;stack: bsq, b, k, b*2
  add         ;stack: bsq, b, k, kinc=b*2+3

;inner loop
label 01
  push 64     ;stack: bsq, b, k, kinc, 64
  retr        ;stack: bsq, b, k, kinc, B-1
  copy 2      ;stack: bsq, b, k, kinc, B-1, k
  sub         ;stack: bsq, b, k, kinc, B-1-k
  jumpn 10    ;stack: bsq, b, k, kinc
              ;exit inner loop if B>=k
  copy 1      ;stack: bsq, b, k, kinc, k
  call 1010   ;set bit k in sieve, stack: bsq, b, k, kinc
  swap        ;stack: bsq, b, kinc, k
  copy 1      ;stack: bsq, b, kinc, k, kinc
  add         ;stack: bsq, b, kinc, k=k+kinc
  swap        ;stack: bsq, b, k, kinc
  jump 01     ;repeat inner loop

;End of inner loop
label 10
  pop         ;stack: bsq, b, k
  pop         ;stack: bsq, b

;Above stack cleanup already done
label 11
  push 1      ;stack: bsq, b, 1
  add         ;stack: bsq, b=b+1
  swap        ;stack: b, bsq
  copy 1      ;stack: b, bsq, b
  push 1      ;stack: b, bsq, b, 1
  add         ;stack: b, bsq, b+1
  push 4      ;stack: b, bsq, b+1, 4
  mult        ;stack: b, bsq, (b+1)*4
  add         ;stack: b, bsq=bsq+(b+1)*4
  swap        ;stack: bsq, b
  jump 00     ;repeat outer loop
; End of outer loop

;Display sieve as a list of space-separated numeric values
label 100
  pop         ;stack: bsq
  pop         ;stack: empty
  push 65     ;stack: 65
  retr        ;stack: memory[65]=end_memaddr
  push 66     ;stack: end_memaddr, memaddr=66
label 101
  dup         ;stack: end_memaddr, memaddr, memaddr
  retr        ;stack: end_memaddr, memaddr, memory[memaddr]
  outn        ;Output memory[memaddr], stack: end_memaddr, memaddr
  push ' '    ;stack: end_memaddr, memaddr, ' '
  outc        ;Output ' ', stack: end_memaddr, memaddr
  push 1      ;stack: end_memaddr, memaddr, 1
  add         ;stack: end_memaddr, memaddr=memaddr+1
  dup         ;stack: end_memaddr, memaddr, memaddr
  copy 2      ;stack: end_memaddr, memaddr, memaddr, end_memaddr
  sub         ;stack: end_memaddr, memaddr, memaddr-end_memaddr
  jumpn 101   ;stack: end_memaddr, memaddr
              ;repeat if memaddr<end_memaddr

pop           ;stack: end_memaddr
pop           ;stack: empty
end

;Get sieve word and mask for bit x
;Input stack: ..., x
;Output stack: ..., x, sieve_memaddr, sieve_word, mask, 0 if bit x set else -1
label 1000
  dup         ;stack: ..., x, x
  push 64     ;stack: ..., x, x, 64
  div         ;stack: ..., x, x//64
  push 66     ;stack: ..., x, x//64, 66
  add         ;stack: ..., x, sieve_memaddr=x//64+66
  dup         ;stack: ..., x, sieve_memaddr, sieve_memaddr
  retr        ;stack: ..., x, sieve_memaddr, sieve_word=memory[sieve_memaddr]
  copy 2      ;stack: ..., x, sieve_memaddr, sieve_word, x
  push 64     ;stack: ..., x, sieve_memaddr, sieve_word, x, 64
  mod         ;stack: ..., x, sieve_memaddr, sieve_word, mask_memaddr=x%64
  retr        ;stack: ..., x, sieve_memaddr, sieve_word, mask=memory[mask_memaddr]
  copy 1      ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_word
  copy 1      ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_word, mask
  div         ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_word//mask
  push 2      ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_word//mask, 2
  mod         ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_bit=(sieve_word//mask)%2
  push 1      ;stack: ..., x, sieve_memaddr, sieve_word, mask, sieve_bit, 1
  sub         ;stack: ..., x, sieve_memaddr, sieve_word, mask, 0 if bit x set else -1
  ret

;Determine if bit x is set in sieve
;Input stack: ..., x
;Output stack: ..., x, 0 if bit x set else -1
label 1001
  call 1000   ;stack: ..., x, sieve_memaddr, sieve_word, mask, 0 if bit x set else -1
  slide 3     ;stack: ..., x, 0 if bit x set else -1
  ret

;Set bit b in sieve
;Input stack: ..., x
;Output stack: ...
label 1010
  call 1000   ;stack: ..., x, sieve_memaddr, sieve_word, mask, 0 if bit x set else -1
  jumpz 1011  ;stack: ..., x, sieve_memaddr, sieve_word, mask
              ;jump if bit x set
  add         ;stack: ..., x, sieve_memaddr, sieve_word=sieve_word+mask (set bit x)
  store       ;memory[sieve_memaddr]=sieve_word, stack: ..., x
  pop         ;stack: ...
  ret
label 1011
  pop         ;stack: ..., x, sieve_memaddr, sieve_word
  pop         ;stack: ..., x, sieve_memaddr
  pop         ;stack: ..., x
  pop         ;stack: ...
  ret
