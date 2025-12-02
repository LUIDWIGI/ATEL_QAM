function qam_symbols = ofdm_demodulator(ofdm_symbol, params)
% OFDM_DEMODULATOR - Perform FFT and extract data from subcarriers
%
% Inputs:
%   ofdm_symbol - Time-domain OFDM symbol
%   params - System parameters structure
%
% Outputs:
%   qam_symbols - Recovered QAM symbols from data subcarriers

N = params.num_subcarriers;
num_data = params.num_data_carriers;

% Perform FFT to convert to frequency domain
freq_domain = fft(ofdm_symbol, N);

% Normalize
freq_domain = freq_domain * sqrt(N);

% Extract data from the same subcarriers used in modulation
% Indices 2 to num_data+1
qam_symbols = freq_domain(2:num_data+1);

end
