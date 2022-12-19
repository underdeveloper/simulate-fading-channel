% Power Control Attempt 2
% Muhammad Sulthan Ariq (18119034)
% 2022.12.19
% Please note that _t3 is just marking that the variables are in use for
% Task #3 and has no other meaning.

% clc;
% clear;
% close all;
clf;

% Transmitting side params
data_length_t3 = 1e6;        % How long the data bitstream is
ebno_t3_db = 0:5:25;         % Eb/N0 in dB
data_rate_t3 = 64e3;         % Data rate in bits per second (bps)
f_Doppler_t3 = [15 30 180];  % Doppler shift rates in Hz

tx_power_t3 = 1;             % Power transmitted by Tx, in Watts (just set it to 1)

% Receiving side
rx_pc_sample_rate_t3 = 1800; % Power control sampling rate in Hz
rx_pc_step_size_t3_db = 10;  % Power control step size, in dB    
rx_gain_t3_db = 0;           % Gain of Rx antenna, in dB (just leave it at 0)

% Pre-allocating (for memory)
carlo = 10;                  % Monte Carlo realizations (probably unneeded.)
ber_t3 = zeros(1,carlo);

% Theoretical Eb/No
ebno_theoretical_t3_db = 0:2:30; % Comment if you want them to be the same
ebno_theoretical_t3 = 10.^(ebno_theoretical_t3_db/10);
ber_theoretical_t3 = 0.5*(1-(sqrt((ebno_theoretical_t3)./(1+ebno_theoretical_t3))));

% Loop
for d = 1:length(f_Doppler_t3)
    % Tx side
    tx_data_binary_t3 = randi([0 1], 1, data_length_t3);
    tx_data_bpsk_t3 = bpsk_modulate(tx_data_binary_t3);
    % Channel
    fading_channel_t3(d,:) = fading2(data_length_t3,f_Doppler_t3(d),1/data_rate_t3);
    var_fading_t3(d,:) = sum(abs(fading_channel_t3(d,:).*tx_data_bpsk_t3.^2/data_length_t3));
    awgn_noise_t3(d,:) = 1/sqrt(2./var_fading_t3(d,:))*(randn(data_length_t3, 1)+1i*randn(data_length_t3, 1));
    for k = 1:length(ebno_t3_db)
        for c = 1:carlo
            rx_raw_t3(k,:) = tx_data_bpsk_t3.*fading_channel_t3(d,:) + 10^(-ebno_t3_db(k)/20)*awgn_noise_t3(d,:); 
            % Equalisation sans power control
            rx_equalised_t3(k,:) = rx_raw_t3(k,:)./fading_channel_t3(d,:); % Equalizing according to fading channel estimation, for now assume Rx knows exactly what the channel characteristics are
            rx_decoded_t3(k,:) = bpsk_demodulate(rx_equalised_t3(k,:)); % Demodulates symbol stream into bitstream
            ber_t3(c) = sum(tx_data_binary_t3~=rx_decoded_t3(k,:)) / data_length_t3;
            
            % Equalisation with power control
            % TO DO LATER
        end
        mean_ber_t3(d,k) = mean(ber_t3);
    end
    figure(d);
    semilogy(ebno_t3_db, mean_ber_t3(d,:),'-o',LineWidth=1);
    hold on;
    semilogy(ebno_theoretical_t3_db, ber_theoretical_t3,'--g',LineWidth=1.5);
    grid on;
    hold off;
    xlim([0 30]);
    ylim([1e-6 1e0]);
    xlabel("Eb/No (dB)");
    ylabel("Bit Error Rate");
    legend('Simulated fading ch. sans power control', 'Theoretical flat fading ch., 'Location', 'southeast')
    a = strcat('fD = ',num2str(f_Doppler_t3(d)));
    legend boxoff;
    title('BER performance in a Rayleigh fading channel',strcat('Doppler shift freq. ' ,num2str(f_Doppler_t3(d)),'Hz'));
end