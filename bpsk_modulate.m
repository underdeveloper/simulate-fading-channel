function symbols = bpsk_modulate(bits)
    % bits : Bitstream, column vector(s)
    % symbols : Symbol stream, column vector(s)

    symbols = (bits - 0.5)*-2;