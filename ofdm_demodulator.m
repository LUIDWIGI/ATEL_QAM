function qam_symbols = ofdm_demodulator(ofdm_symbol, params)
% OFDM_DEMODULATOR - Perform FFT and extract data from subcarriers
%
% Inputs:
%   ofdm_symbol - Time-domain OFDM symbol
%   params - System parameters structure
%
% Outputs:
%   qam_symbols - Recovered QAM symbols from data subcarriers

qam_symbols = ofdmdemod(ofdm_symbol, params.num_subcarriers, ...
    params.cyclic_prefix_length, ...
    params.guardband_indices, ...
    params.pilot_indices, ...
    params.num_pilots); % What to do with pilots?

end
