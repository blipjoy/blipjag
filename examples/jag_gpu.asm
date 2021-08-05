; Atari Jaguar RISC GPU assembler

#bits 16

#subruledef gpr {
    r{reg: u5} => reg
}

#subruledef immediate_word {
    {value: u32} => {
        value[15:0] @ value[31:16]
    }
}

#subruledef index {
    {value: u6} => {
        assert(value >= 1)
        assert(value <= 32)
        value`5
    }
}

#subruledef condition_code {
    nz,    => 0b00001
    z,     => 0b00010
    nc,    => 0b00100
    nc nz, => 0b00101
    nc z,  => 0b00110
    c,     => 0b01000
    c nz,  => 0b01001
    c z,   => 0b01010
    nn,    => 0b10100
    nn nz, => 0b10101
    nn z,  => 0b10110
    n,     => 0b11000
    n nz,  => 0b11001
    n z,   => 0b11010
    {}     => 0b00000
}

#subruledef jump_offset {
    {offset: u16} => {
        offset = offset - $ - 1
        assert(offset <= 15)
        assert(offset >= !15)
        offset`5
    }
}

#ruledef jaguar_risc {
    add    {reg1: gpr}, {reg2: gpr}                   => 0b000000 @ reg1 @ reg2
    addc   {reg1: gpr}, {reg2: gpr}                   => 0b000001 @ reg1 @ reg2
    addq   {n: u5}, {reg2: gpr}                       => 0b000010 @ n @ reg2
    addqt  {n: u5}, {reg2: gpr}                       => 0b000011 @ n @ reg2
    sub    {reg1: gpr}, {reg2: gpr}                   => 0b000100 @ reg1 @ reg2
    subc   {reg1: gpr}, {reg2: gpr}                   => 0b000101 @ reg1 @ reg2
    subq   {n: u5}, {reg2: gpr}                       => 0b000110 @ n @ reg2
    subqt  {n: u5}, {reg2: gpr}                       => 0b000111 @ n @ reg2
    neg    {reg2: gpr}                                => 0b001000 @ 0b00000 @ reg1
    and    {reg1: gpr}, {reg2: gpr}                   => 0b001001 @ reg1 @ reg2
    not    {reg1: gpr}, {reg2: gpr}                   => 0b001010 @ reg1 @ reg2
    xor    {reg1: gpr}, {reg2: gpr}                   => 0b001011 @ reg1 @ reg2
    or     {reg2: gpr}                                => 0b001100 @ 0b00000 @ reg1
    btst   {n: u5}, {reg2: gpr}                       => 0b001101 @ n @ reg2
    bset   {n: u5}, {reg2: gpr}                       => 0b001110 @ n @ reg2
    bclr   {n: u5}, {reg2: gpr}                       => 0b001111 @ n @ reg2
    mult   {reg1: gpr}, {reg2: gpr}                   => 0b010000 @ reg1 @ reg2
    imult  {reg1: gpr}, {reg2: gpr}                   => 0b010001 @ reg1 @ reg2
    imultn {reg1: gpr}, {reg2: gpr}                   => 0b010010 @ reg1 @ reg2
    resmac {reg2: gpr}                                => 0b010011 @ 0b00000 @ reg2
    imacn  {reg1: gpr}, {reg2: gpr}                   => 0b010100 @ reg1 @ reg2
    div    {reg1: gpr}, {reg2: gpr}                   => 0b010101 @ reg1 @ reg2
    abs    {reg2: gpr}                                => 0b010110 @ 0b00000 @ reg2
    sh     {reg1: gpr}, {reg2: gpr}                   => 0b010111 @ reg1 @ reg2
    shlq   {n: u5}, {reg2: gpr}                       => 0b011000 @ n @ reg2
    shrq   {n: u5}, {reg2: gpr}                       => 0b011001 @ n @ reg2
    sha    {reg1: gpr}, {reg2: gpr}                   => 0b011010 @ reg1 @ reg2
    sharq  {n: u5}, {reg2: gpr}                       => 0b011011 @ n @ reg2
    ror    {reg1: gpr}, {reg2: gpr}                   => 0b011100 @ reg1 @ reg2
    rorq   {n: u5}, {reg2: gpr}                       => 0b011101 @ n @ reg2
    cmp    {reg1: gpr}, {reg2: gpr}                   => 0b011110 @ reg1 @ reg2
    cmpq   {n: u5}, {reg2: gpr}                       => 0b011111 @ n @ reg2
    sat8   {reg2: gpr}                                => 0b100000 @ 0b00000 @ reg2
    sat16  {reg2: gpr}                                => 0b100001 @ 0b00000 @ reg2
    move   {reg1: gpr}, {reg2: gpr}                   => 0b100010 @ reg1 @ reg2
    moveq  {n: u5}, {reg2: gpr}                       => 0b100011 @ n @ reg2
    moveta {reg1: gpr}, {reg2: gpr}                   => 0b100100 @ reg1 @ reg2
    movefa {reg1: gpr}, {reg2: gpr}                   => 0b100101 @ reg1 @ reg2
    movei  {n: immediate_word}, {reg2: gpr}           => 0b100110 @ 0b00000 @ reg2 @ n
    loadb  ({reg1: gpr}), {reg2: gpr}                 => 0b100111 @ reg1 @ reg2
    loadw  ({reg1: gpr}), {reg2: gpr}                 => 0b101000 @ reg1 @ reg2
    load   ({reg1: gpr}), {reg2: gpr}                 => 0b101001 @ reg1 @ reg2
    loadp  ({reg1: gpr}), {reg2: gpr}                 => 0b101010 @ reg1 @ reg2
    load   (r14 + {n: index}), {reg2: gpr}            => 0b101011 @ n @ reg2
    load   (r15 + {n: index}), {reg2: gpr}            => 0b101100 @ n @ reg2
    storeb {reg1: gpr}, ({reg2: gpr})                 => 0b101101 @ reg1 @ reg2
    storew {reg1: gpr}, ({reg2: gpr})                 => 0b101110 @ reg1 @ reg2
    store  {reg1: gpr}, ({reg2: gpr})                 => 0b101111 @ reg1 @ reg2
    storep {reg1: gpr}, ({reg2: gpr})                 => 0b110000 @ reg1 @ reg2
    store  {reg1: gpr}, (r14 + {n: index})            => 0b110001 @ reg1 @ n
    store  {reg1: gpr}, (r15 + {n: index})            => 0b110010 @ reg1 @ n
    move   pc, {reg2: gpr}                            => 0b110011 @ 0b00000 @ reg2
    jump   {cc: condition_code} {reg2: gpr}           => 0b110100 @ cc @ reg2
    jr     {cc: condition_code} {offset: jump_offset} => 0b110101 @ cc @ offset
    mmult  {reg1: gpr}, {reg2: gpr}                   => 0b110110 @ reg1 @ reg2
    mtoi   {reg1: gpr}, {reg2: gpr}                   => 0b110111 @ reg1 @ reg2
    normi  {reg1: gpr}, {reg2: gpr}                   => 0b111000 @ reg1 @ reg2
    nop                                               => 0b111001 @ 0[9:0]
    load   (r14 + {reg1: gpr}), {reg2: gpr}           => 0b111010 @ reg1 @ reg2
    load   (r15 + {reg1: gpr}), {reg2: gpr}           => 0b111011 @ reg1 @ reg2
    store  {reg1: gpr}, (r14 + {reg2: gpr})           => 0b111100 @ reg1 @ reg2
    store  {reg1: gpr}, (r15 + {reg2: gpr})           => 0b111101 @ reg1 @ reg2
    sat24  {reg2: gpr}                                => 0b111110 @ 0b00000 @ reg2
    pack   {reg2: gpr}                                => 0b111111 @ 0b00000 @ reg2
    unpack {reg2: gpr}                                => 0b111111 @ 0b00001 @ reg2
}
