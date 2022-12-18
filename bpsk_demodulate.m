function recovered_bits = bpsk_demodulate(received_symbols)
    % received_symbols : Symbol stream, column vector(s)
    % recovered_bits : Bitstream, column vector(s)
    % Turns symbols on the right side of the y-axis into '0' bits, and
    % symbols on the left side into '1' bits

    recovered_bits = floor((sign(real(received_symbols))*-0.5) + 0.5);
    