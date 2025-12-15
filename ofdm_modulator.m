function ofdm_symbol = ofdm_modulator(qam_symbols, params)
% OFDM_MODULATOR - Map QAM symbols to subcarriers and perform IFFT
%
% Inputs:
%   qam_symbols - QAM modulated symbols
%   params - System parameters structure
%
% Outputs:
%   ofdm_symbol - Time-domain OFDM symbol

ofdm_symbol = ofdmmod(qam_symbols, params.num_subcarriers, ...
    params.cyclic_prefix_length, ...
    params.guardband_indices, ...
    params.pilot_indices, ...
    params.num_pilots); % What to do with pilots?


end
