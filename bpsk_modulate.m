function symbols = bpsk_modulate(bits)
    % bits : Bitstream, column vector(s)
    % symbols : Symbol stream, column vector(s)
    % Turns '0' bits into +1, and '1' bits into -1

    symbols = (bits - 0.5)*-2;