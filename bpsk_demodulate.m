function recovered_bits = bpsk_demodulate(received_symbols)
arguments
    received_symbols (1,:) double {mustBeNumeric};
end
%BPSK_DEMODULATE turns a BPSK-modulated symbol stream into its original bitstream.
%Turns symbols on the right side of the y-axis into '0' bits,
%and symbols on the left side into '1' bits
%This is paired with BPSK_MODULATE.
%
%% Syntax
%
% bpsk_demodulate(bits)
%
%% Description
%
% bpsk_demodulate(bits) returns the BPSK demodulation of a symbol stream.
%
% See also comm.BPSKDemodulator

recovered_bits = real(received_symbols)<0;
end