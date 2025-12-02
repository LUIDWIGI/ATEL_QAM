function bits = qam_demodulator(symbols, params)
% QAM_DEMODULATOR - Demodulate 16-QAM symbols to bits
%
% Inputs:
%   symbols - Complex QAM symbols
%   params - System parameters structure
%
% Outputs:
%   bits - Recovered bit stream

M = params.modulation_order;  % 16
k = params.bits_per_symbol;   % 4

% Demodulate using 16-QAM
decimal_values = qamdemod(symbols, M, 'UnitAveragePower', true);

% Convert decimal to binary
bit_matrix = de2bi(decimal_values, k, 'left-msb');

% Reshape to column vector
bits = reshape(bit_matrix', [], 1);

end
