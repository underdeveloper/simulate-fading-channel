% Power Control
% Muhammad Sulthan Ariq (18119034)
% 2022.12.18

clc;
% clear;
% close all;
clf;

data_length_t3 = 1e6;
ebno_t3_db = 10;
f_Doppler_t3 = [15 30 180]; % Doppler shift frequency in Hz
f_power_control_t3 = 1800; % Power control frequency in Hz
data_rate_t3 = 64e3; % in bits per second (bps)

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary_t3 = zeros(length(f_Doppler_t3), data_length_t3);
tx_data_bpsk_t3 = zeros(length(f_Doppler_t3), data_length_t3);
awgn_noise_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_raw_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_equalised_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_decoded_t3 = zeros(length(f_Doppler_t3), data_length_t3);
fading_channel_t3 = zeros(length(f_Doppler_t3), data_length_t3);
ber_t3 = zeros(1,length(f_Doppler_t3));
% fading_var_t3 = ones(carlo_t3, 1);


for m = 1:length(f_Doppler_t3)
    % Tx
    tx_data_binary_t3(m,:) = randi([0 1], data_length_t3, 1); % Generates binary [0 1] code of size data_length x 1
    tx_data_bpsk_t3(m,:) = bpsk_modulate(tx_data_binary_t3(m,:)); % Modulates bit stream into symbol stream with BPSK

    % Channel
        % Fading channel configuration
    % fading_channel_t3 = fading(data_length_t3, f_Doppler_t3, 1/data_rate_t3)';
    % % To be honest, I still don't get what this function actually does.
    % % Is this only small scale fading?  
    fading_channel_t3(m,:) = fading2(data_length_t3, f_Doppler_t3(m), 1/data_rate_t3); % Using someone else's code
%         fading_var_t3(m) = sum(abs(fading_channel_t3.*tx_data_bpsk_t3(m,:)).^2/data_length_t3); % Let's say no variance for now
    awgn_noise_t3(m,:) = (1/sqrt(2))*(randn(data_length_t3, 1)+1i*randn(data_length_t3, 1)); % Generates noise according to Eb/No
    rx_raw_t3(m,:) = tx_data_bpsk_t3(m,:).*fading_channel_t3(m,:) ...
        + 10^(-ebno_t3_db/20)*awgn_noise_t3(m,:); % Combines symbol stream with fading channel with per-element multiplication, then noise channel by simple addition

    % Rx
    rx_equalised_t3(m,:) = rx_raw_t3(m,:)./fading_channel_t3(m,:); % Equalizing according to fading channel estimation, for now assume Rx knows exactly what the channel characteristics are
    rx_decoded_t3(m,:) = bpsk_demodulate(rx_equalised_t3(m,:)); % Demodulates symbol stream into bitstream
    ber_t3(m) = sum(tx_data_binary_t3(m,:)~=rx_decoded_t3(m,:)) / data_length_t3;
end

% 
% % Theoretical
% % ebno_theoretical_t3_dB = ebno_t3_dB; % Uncomment if you want them to be the same
% ebno_theoretical_t3_db = 0:2:30; % Comment if you want them to be the same
% ebno_theoretical_t3 = 10.^(ebno_theoretical_t3_db/10);
% ber_theoretical_t3 = 0.5*(1-(sqrt((ebno_theoretical_t3)./(1+ebno_theoretical_t3))));
% 
% % Plotting whopee
% figure(5)
% semilogy(ebno_t3_db, ber_t3,'-r','marker','o','color','#e04f3f',LineWidth=2);
% hold on;
% semilogy(ebno_theoretical_t3_db, ber_theoretical_t3,'--g','color','#9e1708',LineWidth=1);
% grid on;
% xlim([0 30]);
% ylim([1e-6 1e0]);
% xlabel("Eb/No (dB)");
% ylabel("Bit Error Rate");
% legend('Simulated Rayleigh fading channel', 'Theoretical Rayleigh fading channel', 'Location', 'southeast');
% legend boxoff;
% title("BER Performance in a Rayleigh fading channel");


% Constellation mapping
figure(6)
set(gcf,'Position',[800 100 1000 400])
subplot(1,2,1);
scatter(real(tx_data_bpsk_t3(m,1:10:data_length_t3)), imag(tx_data_bpsk_t3(m,1:10:data_length_t3)), 'color', '#0988ba');
grid on;
axis([-2 2 -2 2]);
xlabel('Real');
ylabel('Imaginary');
title("Constellation at Tx");
hold off;
subplot(1,2,2);
scatter(real(rx_equalised_t3(m,1:10:data_length_t3)), imag(rx_equalised_t3(m,1:10:data_length_t3)), 'color','#1ef7f4');
grid on;
axis([-2 2 -2 2]);
xlabel('Real');
ylabel('Imaginary');
title("Constellation at Rx");
hold off;