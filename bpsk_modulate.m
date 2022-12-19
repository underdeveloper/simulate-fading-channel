function symbols = bpsk_modulate(bits)
arguments
    bits (1,:) double {mustBeNumeric};
end
%BPSK_MODULATE turns a bitstream (represented by a vector of bits) into 
%a BPSK-modulated symbol stream. 
%Turns '0' bits into +1, and '1' bits into -1.
%This is paired with BPSK_DEMODULATE.
%
%% Syntax
%
% bpsk_modulate(bits)
%
%% Description
%
% bpsk_modulate(bits) returns the BPSK modulation of bits.
%
% See also comm.BPSKModulator

symbols = (bits - 0.5)*-2;

end