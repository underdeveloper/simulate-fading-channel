function pc_equalised = power_control2(s_tx, ebno_db, n_ch, fad_ch, step_db, bit_delay, pc_limit)
arguments
    s_tx (1,:) double {mustBeNumeric};                                % Signal at transmitter
    ebno_db (1,1) double {mustBeNumeric,mustBeReal};                  % Eb/N0 ratio in dB
    n_ch (1,:) double {mustBeNumeric,mustBeEqualSize(n_ch,s_tx)};     % AWGN channel
    fad_ch (1,:) double {mustBeNumeric,mustBeEqualSize(fad_ch,s_tx)}; % Flat fading channel
    step_db (1,1) double {mustBeNumeric};                             % Power control step in dB
    bit_delay (1,1) double {mustBeNumeric,mustBeInteger};             % Delay between subsequent power control samples, in symbols
    pc_limit (1,1) double {mustBeNumeric,mustBeReal} = 10;            % Lower bound for power control
end
%POWER_CONTROL2 tries to wrangle a flat-faded signal kicking and screaming
%back into acceptable levels of power via power control technique.
%
%% Syntax
%
% power_control2(s_tx, ebno_db, n_ch, fad_ch, step_db, bit_delay, pc_limit)
%
%% Description
%
% power_control2(s_tx, ebno_db, n_ch, fad_ch, step_db, bit_delay, pc_limit)
% takes a signal, s_tx, and pushes it through a flat fading channel fad_ch
% with added AWGN noise n_ch and adjusts it each step of the way 
% with nudges of step_db size so that it does not go below pc_limit.
% bit_delay describes the delay between subsequent power control samples,
% usually gotten from (Data Rate / Power Control Sampling RatE)
%

data_length = length(s_tx);     % Length of data
vector = 1;                     % Power control vector

% Memory allocation
pc_symbols = zeros(1,data_length);
pc_raw = zeros(1,data_length);
pc_equalised = zeros(1,data_length);


for a = 1:data_length
    pc_symbols(a) = s_tx(a)*vector;
    pc_raw(a) = fad_ch(a)*pc_symbols(a) + ...
        10^(-ebno_db/20)*n_ch(a);
    pc_equalised(a) = pc_raw(a)/fad_ch(a);
    
    if (20*log10(abs(pc_equalised(a))) < pc_limit && mod(a,bit_delay)==0)
        vector = vector * 10^(step_db/20);
    elseif (20*log10(abs(pc_equalised(a))) > pc_limit && mod(a,bit_delay)==0)
        vector = vector * 10^(-step_db/20);
    end
end

end % Main function end

%  Validates equal size
function mustBeEqualSize(a,b)
    % Test for equal size
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid,msg))
    end
end