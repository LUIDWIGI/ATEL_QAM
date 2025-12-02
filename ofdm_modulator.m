function ofdm_symbol = ofdm_modulator(qam_symbols, params)
% OFDM_MODULATOR - Map QAM symbols to subcarriers and perform IFFT
%
% Inputs:
%   qam_symbols - QAM modulated symbols
%   params - System parameters structure
%
% Outputs:
%   ofdm_symbol - Time-domain OFDM symbol

N = params.num_subcarriers;           % Total subcarriers (8)
num_data = params.num_data_carriers;  % Active data carriers (5)

% Initialize frequency domain vector with zeros
freq_domain = zeros(N, 1);

% Subcarrier mapping:
% Index 1: DC (null carrier) = 0
% Indices 2-3: Lower guardband = 0
% Indices 4-8: Data carriers (5 carriers)
% Note: Due to symmetry requirements, we use lower half

% Take first num_data symbols
data_symbols = qam_symbols(1:min(num_data, length(qam_symbols)));

% Pad with zeros if needed
if length(data_symbols) < num_data
    data_symbols = [data_symbols; zeros(num_data - length(data_symbols), 1)];
end

% Map to subcarriers (skip DC and guardbands)
% Place data in indices 2 to num_data+1
freq_domain(2:num_data+1) = data_symbols;

% Create Hermitian symmetry for real IFFT output (optional)
% For now, use complex IFFT
% freq_domain(N:-1:N-num_data+2) = conj(data_symbols(1:end-1));

% Perform IFFT to convert to time domain
ofdm_symbol = ifft(freq_domain, N);

% Normalize
ofdm_symbol = ofdm_symbol / sqrt(N);

end
