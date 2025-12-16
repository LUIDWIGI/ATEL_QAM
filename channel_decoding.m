function decoded_bits = channel_decoding(bits, params)
% channel_decode - Convert bits from encoded stream back to original
%
% Inputs:
%   bits - Input bit stream (params.input_height x (params.input_width + params.parity_bits) matrix)
%   params - System parameters structure
%
% Outputs:
%   decoded_bits - Decoded bit stream

% Decode using the same parameters as encoding
decoded_bits = decode(bits, params.input_height, params.input_width, 'hamming/binary');

% Reshape back to original dimensions
% decoded_bits = decoded_bits(:, 1:params.input_width);

end