function encoded_bits = channel_encoding(bits, params)
% channel_encoding - Convert bits to 16-QAM symbols
%
% Inputs:
%   bits - Input bit stream (params.input_height x params.input_width matrix)
%   params - System parameters structure
%
% Outputs:
%   encoded_bits - Encoded bit stream

% Resize input matrix with extra spaces for the parity bits
% resized_bits = zeros(params.input_height, params.input_width + params.parity_bits);
% resized_bits(1:params.input_height, 1:params.input_width) = bits;

% Convert to double (encode requires double, not integer types)
bits = double(bits);

encoded_bits = encode(bits, params.input_height, params.input_width, 'hamming/binary');

end