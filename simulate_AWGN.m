% AWGN Channel
% Muhammad Sulthan Ariq (18119034)
% 2022.12.17

clc;
clear;
close all;

data_length = 1e6;
ebno_db = 0:2:8;
ebno_num = 10.^(ebno_db/10);

carlo = 5; % Monte Carlo

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary = zeros(carlo, data_length);
tx_data_bpsk = zeros(carlo, data_length);
awgn_noise = zeros(carlo, data_length);
rx_raw = zeros(carlo, data_length);
rx_decoded = zeros(carlo, data_length);
ber = zeros(carlo,1);
mean_ber = zeros(length(ebno_db),1);

for k = 1:length(ebno_db)
    for j = 1:carlo
        % Tx
        tx_data_binary(j,:) = randi([0 1], data_length, 1); % Generates binary [0 1] code of size data_length x 1
        tx_data_bpsk(j,:) = bpsk_modulate(tx_data_binary(j,:)); % Modulates bit stream into symbol stream with BPSK

        % Channel
        awgn_noise(j,:) = (1/sqrt(2*ebno_num(k)))*randn(data_length, 1); % Generates noise according to Eb/No

        % Rx
        rx_raw(j,:) = tx_data_bpsk(j,:) + awgn_noise(j,:); % Combines symbol stream with noise channel by simple addition
%         rx_raw(j,:) = awgn(tx_data_bpsk(j,:),ebno_dB(i)); % This is a lot better haha
        rx_decoded(j,:) = bpsk_demodulate(rx_raw(j,:)); % Demodulates symbol stream into bitstream
        ber(j) = sum(tx_data_bpsk(j,:)==rx_decoded(j,:)) / data_length;
    end
    mean_ber(k) = mean(ber);
end

% Theoretical
% ebno_theoretical_dB = ebno_dB; % Uncomment if you want them to be the same
ebno_theoretical_dB = 0:0.1:10; % Comment if you want them to be the same
ebno_theoretical_num = 10.^(ebno_theoretical_dB/10);
ber_theoretical = 0.5*(erfc(sqrt(ebno_theoretical_num)));

% Plotting whopee
figure(1)
semilogy(ebno_db, mean_ber,'-r','marker','o','color','#1ef7f4',LineWidth=2);
hold on;
semilogy(ebno_theoretical_dB, ber_theoretical,'--g','color','#0988ba',LineWidth=2);
grid on;
xlim([0 30]);
ylim([1e-6 1e0]);
xlabel("Eb/No (dB)");
ylabel("Bit Error Rate");
legend('Simulated AWGN channel', 'Theoretical AWGN channel');
title("BER Performance in an AWGN channel");