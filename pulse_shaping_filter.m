function filtered_signal = pulse_shaping_filter(signal, params)
% PULSE_SHAPING_FILTER - Apply pulse shaping to limit bandwidth
%
% Inputs:
%   signal - Input signal (QAM symbols or received signal)
%   params - System parameters structure
%
% Outputs:
%   filtered_signal - Pulse-shaped signal
%
% Note: Uses raised cosine filter for pulse shaping

% Raised cosine filter parameters
rolloff = 0.25;              % Roll-off factor
span = 6;                    % Filter span in symbols
sps = 4;                     % Samples per symbol (oversampling factor)

% Create raised cosine filter
rrc_filter = rcosdesign(rolloff, span, sps, 'sqrt');

% For transmitter: upsample and filter
if length(signal) <= params.num_data_carriers
    % Upsample the signal
    upsampled = upsample(signal, sps);
    
    % Apply filter
    filtered_signal = filter(rrc_filter, 1, upsampled);
    
    % Normalize
    filtered_signal = filtered_signal / max(abs(filtered_signal));
else
    % For receiver: just apply matched filter
    filtered_signal = filter(rrc_filter, 1, signal);
    
    % Downsample to symbol rate
    filtered_signal = downsample(filtered_signal, sps);
    
    % Take only the valid symbols
    delay = span / 2;
    filtered_signal = filtered_signal(delay+1:end);
end

end
