% Rayleigh Fading Channel
% Muhammad Sulthan Ariq (18119034)
% 2022.12.17

clc;
% clear;
% close all;

data_length_t2 = 1e6;
ebno_t2_dB = 0:5:25;
f_Doppler_t2 = 30; % Doppler shift frequency in Hz
data_rate_t2 = 64e3; % in bits per second (bps)

carlo_t2 = 1; % Monte Carlo

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary_t2 = zeros(carlo_t2, data_length_t2);
tx_data_bpsk_t2 = zeros(carlo_t2, data_length_t2);
awgn_noise_t2 = zeros(carlo_t2, data_length_t2);
rx_raw_t2 = zeros(carlo_t2, data_length_t2);
rx_decoded_t2 = zeros(carlo_t2, data_length_t2);
ber_t2 = zeros(carlo_t2,1);
mean_ber_t2 = zeros(length(ebno_t2_dB),1);
fading_var_t2 = zeros(carlo_t2, 1);


% Fading channel configuration
fading_channel_t2 = (fading(data_length_t2, f_Doppler_t2, 1/data_rate_t2))';

for k = 1:length(ebno_t2_dB)
    for j = 1:carlo_t2
        % Tx
        tx_data_binary_t2(j,:) = randi([0 1], data_length_t2, 1); % Generates binary [0 1] code of size data_length x 1
        tx_data_bpsk_t2(j,:) = bpsk_modulate(tx_data_binary_t2(j,:)); % Modulates bit stream into symbol stream with BPSK

        % Channel
        fading_var_t2(j) = sum(abs(fading_channel_t2.*tx_data_bpsk_t2(j,:)).^2/data_length_t2);
        awgn_noise_t2(j,:) = 1/sqrt(2/fading_var_t2(j))*(randn(data_length_t2, 1)+1i*randn(data_length_t2, 1));

        % Rx
        rx_raw_t2(j,:) = tx_data_bpsk_t2(j,:).*fading_channel_t2 + 10^(-ebno_t2_dB(k)/20)*awgn_noise_t2(j,:); % Combines symbol stream with noise channel by simple addition
        rx_decoded_t2(j,:) = bpsk_demodulate(rx_raw_t2(j,:)); % Demodulates symbol stream into bitstream
        ber_t2(j) = sum(tx_data_binary_t2(j,:)~=rx_decoded_t2(j,:)) / data_length_t2;
    end
    mean_ber_t2(k) = mean(ber_t2);
end


% Theoretical
% ebno_theoretical_dB = ebno_dB; % Uncomment if you want them to be the same
ebno_theoretical_t2_dB = 0:2:30; % Comment if you want them to be the same
ebno_theoretical_t2 = 10.^(ebno_theoretical_t2_dB/10);
ber_theoretical_t2 = 0.5*(1-(sqrt((ebno_theoretical_t2)./(1+ebno_theoretical_t2))));

% Plotting whopee
clf(2);
figure(2)
semilogy(ebno_t2_dB, mean_ber_t2,'-r','marker','x','color','#e04f3f',LineWidth=2);
hold on;
semilogy(ebno_theoretical_t2_dB, ber_theoretical_t2,'--g','color','#9e1708',LineWidth=2);
grid on;
xlim([0 30]);
ylim([1e-6 1e0]);
xlabel("Eb/No (dB)");
ylabel("Bit Error Rate");
legend('Simulated Rayleigh fading channel', 'Theoretical Rayleigh fading channel');
title("BER Performance in a Rayleigh fading channel");