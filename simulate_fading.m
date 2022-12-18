% Rayleigh Fading Channel
% Muhammad Sulthan Ariq (18119034)
% 2022.12.17

clc;
% clear;
% close all;

data_length_t2 = 1e6;
ebno_t2_db = 0:5:25;
f_Doppler_t2 = 30; % Doppler shift frequency in Hz
data_rate_t2 = 64e3; % in bits per second (bps)

carlo_t2 = 1; % Monte Carlo

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary_t2 = zeros(carlo_t2, data_length_t2);
tx_data_bpsk_t2 = zeros(carlo_t2, data_length_t2);
awgn_noise_t2 = zeros(carlo_t2, data_length_t2);
rx_raw_t2 = zeros(carlo_t2, data_length_t2);
rx_equalised_t2 = zeros(carlo_t2, data_length_t2);
rx_decoded_t2 = zeros(carlo_t2, data_length_t2);
ber_t2 = zeros(carlo_t2,1);
mean_ber_t2 = zeros(length(ebno_t2_db),1);
fading_var_t2 = ones(carlo_t2, 1);


% Fading channel configuration
fading_channel_t2 = fading(data_length_t2, f_Doppler_t2, 1/data_rate_t2)';
% To be honest, I still don't get what this function actually does.
% Is this only small scale fading?  

for k = 1:length(ebno_t2_db)
    for j = 1:carlo_t2
        % Tx
        tx_data_binary_t2(j,:) = randi([0 1], data_length_t2, 1); % Generates binary [0 1] code of size data_length x 1
        tx_data_bpsk_t2(j,:) = bpsk_modulate(tx_data_binary_t2(j,:)); % Modulates bit stream into symbol stream with BPSK

        % Channel
%         fading_var_t2(j) = sum(abs(fading_channel_t2.*tx_data_bpsk_t2(j,:)).^2/data_length_t2); % Let's say no variance for now
        awgn_noise_t2(j,:) = (1/sqrt(2))*(randn(data_length_t2, 1)+1i*randn(data_length_t2, 1)); % Generates noise according to Eb/No
        rx_raw_t2(j,:) = tx_data_bpsk_t2(j,:).*fading_channel_t2 + ...
            10^(-ebno_t2_db(k)/20)*awgn_noise_t2(j,:); % Combines symbol stream with fading channel with per-element multiplication, then noise channel by simple addition

        % Rx
        rx_equalised_t2(j,:) = rx_raw_t2(j,:)./fading_channel_t2; % Equalizing according to fading channel estimation, for now assume Rx knows exactly what the channel characteristics are
        rx_decoded_t2(j,:) = bpsk_demodulate(rx_raw_t2(j,:)); % Demodulates symbol stream into bitstream
        ber_t2(j) = sum(tx_data_binary_t2(j,:)~=rx_decoded_t2(j,:)) / data_length_t2;
    end
    mean_ber_t2(k) = mean(ber_t2);
end


% Theoretical
% ebno_theoretical_t2_dB = ebno_t2_dB; % Uncomment if you want them to be the same
ebno_theoretical_t2_db = 0:2:30; % Comment if you want them to be the same
ebno_theoretical_t2 = 10.^(ebno_theoretical_t2_db/10);
ber_theoretical_t2 = 0.5*(1-(sqrt((ebno_theoretical_t2)./(1+ebno_theoretical_t2))));

% Plotting whopee
figure(3)
semilogy(ebno_t2_db, mean_ber_t2,'-r','marker','o','color','#e04f3f',LineWidth=2);
hold on;
semilogy(ebno_theoretical_t2_db, ber_theoretical_t2,'--g','color','#9e1708',LineWidth=2);
grid on;
xlim([0 30]);
ylim([1e-6 1e0]);
xlabel("Eb/No (dB)");
ylabel("Bit Error Rate");
legend('Simulated Rayleigh fading channel', 'Theoretical Rayleigh fading channel', 'Location', 'southeast');
legend boxoff;
title("BER Performance in a Rayleigh fading channel");


% Constellation mapping
figure(4)
set(gcf,'Position',[800 100 1000 400])
subplot(1,2,1);
scatter(real(tx_data_bpsk_t2(j,1:1000:data_length_t2)), imag(tx_data_bpsk_t2(j,1:1000:data_length_t2)), 'color', '#0988ba');
grid on;
axis([-2 2 -2 2]);
xlabel('Real');
ylabel('Imaginary');
title("Constellation at Tx");
hold off;
subplot(1,2,2);
scatter(real(rx_equalised_t2(j,1:1000:data_length_t2)), imag(rx_equalised_t2(j,1:1000:data_length_t2)), 'color','#1ef7f4');
grid on;
axis([-2 2 -2 2]);
xlabel('Real');
ylabel('Imaginary');
title("Constellation at Rx");
hold off;