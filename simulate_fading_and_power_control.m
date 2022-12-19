% Power Control
% Muhammad Sulthan Ariq (18119034)
% 2022.12.18
% Please note that _t3 is just marking that the variables are in use for
% Task #3 and has no other meaning.

clc;
% clear;
% close all;
clf;

% Data
data_length_t3 = 1e6;
ebno_t3_db = 0:5:25;
f_Doppler_t3 = [15 30 180];     % Doppler shift frequency in Hz
f_power_control_t3 = 1800;      % Power control sampling rate in Hz
data_rate_t3 = 64e3;            % in bits per second (bps)

% carlo_t3 = 1; % Monte Carlo

% Preallocating memory (for performance reasons)
% There's actually no need to do this if data_length is relatively small I just like doing it
tx_data_binary_t3 = zeros(length(f_Doppler_t3), data_length_t3);
tx_data_bpsk_t3 = zeros(length(f_Doppler_t3), data_length_t3);
awgn_noise_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_raw_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_controlled_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_equalised_t3 = zeros(length(f_Doppler_t3), data_length_t3);
rx_decoded_t3 = zeros(length(f_Doppler_t3), data_length_t3);
ber_t3 = zeros(length(ebno_t3_db),length(f_Doppler_t3));
fading_channel_t3 = zeros(length(f_Doppler_t3), data_length_t3);
% fading_var_t3 = ones(length(f_Doppler_t3), 1);

% System characteristics
% This is to simulate (large-scale) path loss
tx_power_t3 = 0.5;          % Transmit power at Tx, in Watts
tx_gain_t3_db = 30;         % Transmitter gain at Tx, in dB
tx_mod_freq_t3 = 3.5e9;     % Modulation frequency, in Hz
distance_tx_rx_t3 = 60e3;   % Distance between Tx and Rx, in metres
rx_gain_t3_db = 60;         % Receiver gain at Rx, in dB
% target_ebno_t3_db = 10;   % Likely unneeded
path_loss = tx_power_t3 * 10^(tx_gain_t3_db/10 + rx_gain_t3_db/10) * (physconst('Lightspeed')/(4*pi*distance_tx_rx_t3*tx_mod_freq_t3))^2

for m = 1:length(f_Doppler_t3)
    for k = 1:length(ebno_t3_db)
        % Tx
        tx_data_binary_t3(m,:) = randi([0 1], data_length_t3, 1); % Generates binary [0 1] code of size data_length x 1
        tx_data_bpsk_t3(m,:) = bpsk_modulate(tx_data_binary_t3(m,:)); % Modulates bit stream into symbol stream with BPSK

        % Channel
            % Fading channel configuration
        % fading_channel_t3 = fading(data_length_t3, f_Doppler_t3, 1/data_rate_t3)';
        % % To be honest, I still don't get what this function actually does.
        % % Is this only small scale fading?  
        fading_channel_t3(m,:) = fading2(data_length_t3, f_Doppler_t3(m), 1/data_rate_t3); % Using someone else's code
%         fading_var_t3(j) = sum(abs(fading_channel_t3.*tx_data_bpsk_t3(j,:)).^2/data_length_t3); % Let's say no variance for now
        awgn_noise_t3(m,:) = (1/sqrt(2))*(randn(data_length_t3, 1)+1i*randn(data_length_t3, 1)); % Generates noise according to Eb/No
        rx_raw_t3(m,:) = path_loss*tx_data_bpsk_t3(m,:).*fading_channel_t3(m,:) + 10^(-ebno_t3_db(k)/20)*awgn_noise_t3(m,:); % Combines symbol stream with fading channel with per-element multiplication, then noise channel by simple addition

        % Rx
        rx_controlled_t3(m,:) = power_control(rx_raw_t3(m,:),data_rate_t3,-30,10,f_power_control_t3);
        rx_equalised_t3(m,:) = rx_controlled_t3(m,:)./fading_channel_t3(m,:); % Equalizing according to fading channel estimation, for now assume Rx knows exactly what the channel characteristics are
        rx_decoded_t3(m,:) = bpsk_demodulate(rx_equalised_t3(m,:)); % Demodulates symbol stream into bitstream
        ber_t3(k,m) = sum(tx_data_binary_t3(m,:)~=rx_decoded_t3(m,:)) / data_length_t3;
    end
end


% % Theoretical
% ebno_theoretical_t3_dB = ebno_t3_dB; % Uncomment if you want them to be the same
ebno_theoretical_t3_db = 0:2:30; % Comment if you want them to be the same
ebno_theoretical_t3 = 10.^(ebno_theoretical_t3_db/10);
ber_theoretical_t3 = 0.5*(1-(sqrt((ebno_theoretical_t3)./(1+ebno_theoretical_t3))));

% Plotting whopee
figure(5)
semilogy(ebno_t3_db, ber_t3(:,1),'-o','color','#22b800',LineWidth=1); % fd = 15 Hz
hold on;
semilogy(ebno_t3_db, ber_t3(:,2),'-o','color','#c49300',LineWidth=1); % fd = 30 Hz
semilogy(ebno_t3_db, ber_t3(:,3),'-o','color','#bf1d00',LineWidth=1); % fd = 180 Hz
semilogy(ebno_theoretical_t3_db, ber_theoretical_t3,'--g','color','#9e1708',LineWidth=1.5);
grid on;
xlim([0 30]);
ylim([1e-6 1e0]);
xlabel("Eb/No (dB)");
ylabel("Bit Error Rate");
legend('Fading channel with fD = 15 Hz', 'Fading channel with fD = 30 Hz', 'Fading channel with fD = 180 Hz', 'Theoretical BER', 'Location', 'southeast');
legend boxoff;
title("BER Performance in a Rayleigh fading channel");


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

disp("Done!");