function tx_signal = add_cyclic_prefix(ofdm_symbol, params)
% ADD_CYCLIC_PREFIX - Add cyclic prefix to OFDM symbol
%
% Inputs:
%   ofdm_symbol - Time-domain OFDM symbol
%   params - System parameters structure
%
% Outputs:
%   tx_signal - OFDM symbol with cyclic prefix

cp_length = params.cyclic_prefix_length;

% Take the last cp_length samples and prepend them
cyclic_prefix = ofdm_symbol(end-cp_length+1:end);

% Concatenate CP and OFDM symbol
tx_signal = [cyclic_prefix; ofdm_symbol];

end
