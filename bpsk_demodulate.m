function recovered_bits = bpsk_demodulate(received_symbols)
    % received_symbols : Symbol stream, column vector(s)
    % recovered_bits : Bitstream, column vector(s)

    recovered_bits = floor((sign(real(received_symbols))*-0.5) + 0.5);
    