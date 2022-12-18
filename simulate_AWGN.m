% AWGN Channel
% Muhammad Sulthan Ariq (18119034)
% 2022.12.17

clc;
clear;
close all;

data_length_t1 = 1e6;
ebno_t1_db = 0:2:8;
ebno_t1_num = 10.^(ebno_t1_db/10); % Note to myself: Eb/No is a power value so dB to numerical conversion is /10

carlo_t1 = 5; % Monte Carlo

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary_t1 = zeros(carlo_t1, data_length_t1);
tx_data_bpsk_t1 = zeros(carlo_t1, data_length_t1);
awgn_noise_t1 = zeros(carlo_t1, data_length_t1);
rx_raw_t1 = zeros(carlo_t1, data_length_t1);
rx_decoded_t1 = zeros(carlo_t1, data_length_t1);
ber_t1 = zeros(carlo_t1,1);
mean_ber_t1 = zeros(length(ebno_t1_db),1);

for k = 1:length(ebno_t1_db)
    for j = 1:carlo_t1
        % Tx
        tx_data_binary_t1(j,:) = randi([0 1], data_length_t1, 1); % Generates binary [0 1] code of size data_length x 1
        tx_data_bpsk_t1(j,:) = bpsk_modulate(tx_data_binary_t1(j,:)); % Modulates bit stream into symbol stream with BPSK

        % Channel
        awgn_noise_t1(j,:) = (1/sqrt(2*ebno_t1_num(k)))*(randn(data_length_t1, 1)+1i*randn(data_length_t1, 1)); % Generates noise according to Eb/No

        % Rx
        rx_raw_t1(j,:) = tx_data_bpsk_t1(j,:) + awgn_noise_t1(j,:); % Combines symbol stream with noise channel by simple addition
%         rx_raw(j,:) = awgn(tx_data_bpsk(j,:),ebno_db(k)); % This is a lot better haha
        rx_decoded_t1(j,:) = bpsk_demodulate(rx_raw_t1(j,:)); % Demodulates symbol stream into bitstream
        ber_t1(j) = sum(tx_data_binary_t1(j,:)~=rx_decoded_t1(j,:)) / data_length_t1;
    end
    mean_ber_t1(k) = mean(ber_t1);
end

% Theoretical
% ebno_theoretical_db = ebno_dB; % Uncomment if you want them to be the same
ebno_theoretical_t1_db = 0:0.1:10; % Comment if you want them to be the same
ebno_theoretical_t1_num = 10.^(ebno_theoretical_t1_db/10);
ber_theoretical_t1 = 0.5*(erfc(sqrt(ebno_theoretical_t1_num)));

% Plotting whopee
clf(1);
figure(1)
semilogy(ebno_t1_db, mean_ber_t1,'-r','marker','o','color','#1ef7f4',LineWidth=2);
hold on;
semilogy(ebno_theoretical_t1_db, ber_theoretical_t1,'--g','color','#0988ba',LineWidth=2);
grid on;
xlim([0 30]);
ylim([1e-6 1e0]);
xlabel("Eb/No (dB)");
ylabel("Bit Error Rate");
legend('Simulated AWGN channel', 'Theoretical AWGN channel');
title("BER Performance in an AWGN channel");
hold off;