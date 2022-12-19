function processed_signal = power_control(received_signal, symbol_rate, limit, control_power, control_sample_rate)
arguments
    received_signal (1,:) double {mustBeNumeric} % One-dimensional series of data (symbols) received by Rx, in Watts
    symbol_rate double {mustBeNumeric} % Symbol rate, in sps
    limit double {mustBeNumeric} % Power limit to where the control would bring signal back up again were it to dip below, in dBmW
    control_power double {mustBeNumeric} % How much the power control has control over the signal, in dBmW
    control_sample_rate double {mustBeNumeric} % Power control sampling rate, in Hz, must be larger than symbol_rate!

end
%     intermediate_signal = repelem(received_signal,floorDiv(control_sample_rate,symbol_rate));
    processed_signal = received_signal;
    limit_num = 10^(-3+(limit/10)); % in Watts
    iterate_limit = floorDiv(control_sample_rate,symbol_rate);

    for m = 1:length(received_signal)
        iterations = 1;
%         disp(['Currently being processed: ' num2str(received_signal(m)) ' (' num2str(10*log10(abs(processed_signal(m))/1e-3)) ' dBm)'])
        while (abs(processed_signal(m)) < limit_num && iterations <= iterate_limit)
%             disp(['Iteration: ' num2str(iterations) ', at ' num2str(10*log10(abs(processed_signal(m))/1e-3))]);
            processed_signal(m) = abs(processed_signal(m)) * 10^(control_power/10) * exp(1i*angle(processed_signal(m)));
            % note an *increase* in X dBm is the same as an increase in X
            % dBW, they're both dB.
%             processed_signal(m) =
%             10^(3+((10*log10(abs(processed_signal(m))/1e-3) + ...
%             control_power)/10)) * exp(angle(processed_signal(m))); % this
%             didnt work
            iterations = iterations + 1;
        end
    end