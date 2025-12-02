function ofdm_symbol = remove_cyclic_prefix(rx_signal, params)
% REMOVE_CYCLIC_PREFIX - Remove cyclic prefix from received signal
%
% Inputs:
%   rx_signal - Received signal with cyclic prefix
%   params - System parameters structure
%
% Outputs:
%   ofdm_symbol - OFDM symbol without cyclic prefix

cp_length = params.cyclic_prefix_length;

% Remove the first cp_length samples (the cyclic prefix)
ofdm_symbol = rx_signal(cp_length+1:end);

end
