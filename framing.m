function framed_bits = framing(bits, params)
% channel_encoder - Convert bits to 16-QAM symbols
%
% Inputs:
%   bits - Input bit stream (column vector) 63*63
%   params - System parameters structure
%
% Outputs:
%   framed_bits - Framed bit stream

%% Frame specs
frame_length = 4096; % bits per frame
% Ensure `bits` is a column vector so slices have consistent shape
bits = bits(:);
% Basic length check to avoid indexing errors
if numel(bits) < 3969
    error('framing:InvalidInput','Input ''bits'' must contain at least 3969 elements.');
end
% range
% 0 - 25 Barker code 1 (2x13 bits)
barker_length1 = 13;
barker_code1 = comm.BarkerCode('Length', barker_length1, 'SamplesPerFrame', barker_length1);
barker_code1 = (step(barker_code1) + 1) / 2;

% 26 - 112 metedata (87 bits) (for now all zeros)
metadata = zeros(1, 87);

% 113 - 2128 first 32 blocks of 63 bits of data
data_block1 = bits(1:2016); % 32*63 = 2016 bits

% 2129 - 2142 barker code 2 (2x7 bits)
barker_length2 = 7;
barker_code2 = comm.BarkerCode('Length', barker_length2, 'SamplesPerFrame', barker_length2);
barker_code2 = (step(barker_code2) + 1) / 2;

% 2143 - 4096 remaining data bits 31 blocks of 63 bits of data
data_block2 = bits(2017:3969); % remaining bits (1953 bits = 31*63)
%% Framing
framed_bits = [barker_code1.', barker_code1.', metadata, data_block1.', ...
    barker_code2.', barker_code2.', data_block2.'];

framed_bits = framed_bits(:); % Ensure column vector output
end