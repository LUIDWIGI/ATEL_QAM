function symbols = qam_modulator(bits, params)
% QAM_MODULATOR - Convert bits to 16-QAM symbols
%
% Inputs:
%   bits - Input bit stream (column vector)
%   params - System parameters structure
%
% Outputs:
%   symbols - Complex QAM symbols

M = params.modulation_order;  % 16
k = params.bits_per_symbol;   % 4

% Ensure bits length is multiple of k
num_symbols = floor(length(bits) / k);
bits = bits(1:num_symbols*k);

% Reshape bits into groups of k bits per symbol
bit_matrix = reshape(bits, k, num_symbols)';

% Convert each group of k bits to decimal
decimal_values = bi2de(bit_matrix, 'left-msb');

% Modulate using 16-QAM
symbols = qammod(decimal_values, M, 'UnitAveragePower', true);

% Ensure column vector output
symbols = symbols(:);

end
