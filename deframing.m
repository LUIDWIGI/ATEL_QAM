function deframed_bits = deframing(frame, params)
% channel_encoder - Convert bits to 16-QAM symbols
%
% Inputs:
%   Frame - Input frame (column vector) 4096
%   params - System parameters structure
%
% Outputs:
%   deframed_bits - Deframed bit stream (63*63)

%% Frame specs
frame_length = 4096; % bits per frame
% range
% 0 - 25 Barker code 1 (2x13 bits)
barker_length1 = 13;
barker_code1 = comm.BarkerCode('Length', barker_length1, 'SamplesPerFrame', barker_length1);
barker_code1 = (step(barker_code1) + 1) / 2;
barker1_required_correlation = 0.9;

% 2129 - 2142 barker code 2 (2x7 bits)
barker_length2 = 7;
barker_code2 = comm.BarkerCode('Length', barker_length2, 'SamplesPerFrame', barker_length2);
barker_code2 = (step(barker_code2) + 1) / 2;
barker2_required_correlation = 0.9;

%% Deframing
% Ensure frame is the correct length
if length(frame) ~= frame_length
    error('deframing:InvalidFrameLength', 'Frame must be exactly %d bits, got %d bits', frame_length, length(frame));
end

% Extract data bits directly (assuming perfect synchronization)
% Skip Barker codes and metadata, extract only data

% 113 - 2128 first 32 blocks of 63 bits of data (indices 113:2128)
data_block1 = frame(113:2128); % 2016 bits

% 2143 - 4096 remaining data bits 31 blocks of 63 bits of data (indices 2143:4095)
data_block2 = frame(2143:4095); % 1953 bits

% Combine data blocks
deframed_bits = [data_block1; data_block2];

% Reshape to match original input dimensions (63x63)
deframed_bits = reshape(deframed_bits, params.input_height, params.input_width);

end