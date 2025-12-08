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

% % Ensure bits length is multiple of k
% num_symbols = floor(length(bits) / k);
% bits = bits(1:num_symbols*k);

% Check the lenght of the input
if mod(length(bits), k) ~= 0
    fprintf('Length of input ''bits'' (%d) must be a multiple of %d.', length(bits), k);
end

% 
% % Reshape bits into groups of k bits per symbol
% bit_matrix = reshape(bits, k, 4096)';
% 
% % Convert each group of k bits to decimal
% decimal_values = bi2de(bit_matrix, 'left-msb');

% Modulate using 16-QAM
symbols = qammod(bits, M, "InputType","bit");

% Ensure column vector output
symbols = symbols(:);

end
