%% Digital Communication System - Main Script
% Authors: Jordi van Oosterwijk, Filip Maessen
% Based on system specification document
% MATLAB Version: 2025a

clear all;
close all;
clc;

%% System Parameters
params = struct();
pluto_params = pluto_initialize();

% Modulation parameters
params.modulation_order = 4;           % 4-QAM
params.bits_per_symbol = log2(params.modulation_order);             % log2(16) = 4

% Error correction parameters
params.parity_bits = 6;

% OFDM parameters
params.num_subcarriers = 128;             % Total subcarriers
params.num_guardbands = 11;              % Edge guardbands (3 total including DC)
params.num_dcbands = 3;
params.guardband_indices = [ 1:6, 63:65 , 124:128]'; % Guardband indices
params.num_pilots = 6; % Number of pilot carriers
params.pilot_indices = [44, 61, 75, 89, 103, 120]'; % Pilot carrier indices (1-128 range)
params.num_data_carriers = params.num_subcarriers - params.num_guardbands - 1; % 5 active carriers
params.data_carrier_indices = setdiff((1:params.num_subcarriers)', ...
    [params.guardband_indices; 65]); % Exclude guardbands and DC

% System parameters
params.bitwidth = 20;                   % Total bits per OFDM symbol
params.cyclic_prefix_length = 4;        % CP length (samples)

% Raised Cosine Filter Parameters
rollOff = 0.2; % Roll-off factor 0.2
filterSpanInSymbols = 10; % Filter span in symbols 10
outputSamplesPerSymbol = 8; % Oversampling factor 8
txFilt = comm.RaisedCosineTransmitFilter( ...
    'RolloffFactor',rollOff, ...
    'FilterSpanInSymbols',filterSpanInSymbols, ...
    'OutputSamplesPerSymbol',outputSamplesPerSymbol);
rxFilt = comm.RaisedCosineReceiveFilter( ...
    'RolloffFactor',rollOff, ...
    'FilterSpanInSymbols',filterSpanInSymbols, ...
    'InputSamplesPerSymbol',outputSamplesPerSymbol, ...
    'DecimationFactor',outputSamplesPerSymbol);

% Channel parameters
params.SNR_dB = 27;                     % Signal-to-noise ratio in dBsymbol

% Input dimensions
params.input_height = 63;
params.input_width = 57;

%% File params

fileName = "bee_movie_script.txt";
% Load the loremIpsum txt file
dataFilePath = fullfile(fileparts(mfilename('fullpath')), fileName);
fileID_ = fopen(dataFilePath, 'r');
if fileID_ == -1
    error('File not found. Check the file path: %s', dataFilePath);
end
params.input_file_bytes = fread(fileID_, '*uint8')';
params.input_file_bits = de2bi(params.input_file_bytes, 8, 'left-msb')';
fclose(fileID_);
fprintf('Loaded loremIpsum.txt successfully. File size: %d bytes\n', length(params.input_file_bits));


%% Generate Random Data
params.num_bits = params.input_height*params.input_width;
params.num_bytes = ceil(params.num_bits / 8);

% Ensure input_file_bits is a column vector
params.input_file_bits = params.input_file_bits(:);

params.num_frames = ceil(length(params.input_file_bits) / params.num_bits);
if length(params.input_file_bits) < params.num_frames * params.num_bits
    % Pad with zeros if not enough bits
    params.input_file_bits = [params.input_file_bits; zeros(params.num_frames * params.num_bits - length(params.input_file_bits), 1)];
end

% params.num_frames = 1;

% For every frame
for f = 1:params.num_frames
    fprintf('Frame %d/%d\n', f, params.num_frames);

    % Read data bits for this frame
    data_bits = params.input_file_bits((f-1)*params.num_bits + 1 : min(f*params.num_bits, length(params.input_file_bits)));
    
    % Overwrite with random bits for testing
    % data_bits = randi([0 1], params.num_bits, 1);
    % convert to column vector
    data_bits = data_bits(:);

    fprintf('Generated %d random bits\n', params.num_bits);
    % fprintf('Data bits: %s\n', num2str(data_bits'));

    %% Transmitter Chain

    % 1. Channel Encoding (FEC)
    fprintf('\n--- Channel Encoding ---\n');
    encoded_bits = channel_encoding(data_bits, params);
    fprintf('Encoded bits length: %d\n', length(encoded_bits));

    % Convert to 63*63 array and swap row and columns
    encoded_bits = reshape(encoded_bits, params.input_width + params.parity_bits, params.input_height)';
    % Go back to column vector
    encoded_bits = encoded_bits(:);

    % 2. Framing 
    fprintf('\n--- Framing ---\n');
    framed_bits = framing(encoded_bits, params);
    fprintf('Framed bits length: %d\n', length(framed_bits));

    % 3. QAM Modulation
    fprintf('\n--- QAM Modulation ---\n');
    qam_symbols = qam_modulator(framed_bits, params);
    fprintf('Number of QAM symbols: %d\n', length(qam_symbols));

    % ofdm_symbol = txFilt(qam_symbols);

    % 4. OFDM Mod
    fprintf('\n--- OFDM (IFFT) ---\n');
    ofdm_symbol = ofdm_modulator(qam_symbols, params);
    fprintf('OFDM symbol length: %d\n', length(ofdm_symbol));


    % Artificial noise commented out
    fprintf('\n--- Channel Transmission ---\n');
    %rx_signal = channel_model(ofdm_symbol, params);

    % % SEND SIGNAL
    pluto_send(ofdm_symbol, pluto_params);
    % 
    % % RECEIVE SIGNAL
    rx_signal = pluto_receive(pluto_params, params);

    % rx_qam_symbols = rxFilt(rx_signal);

    %% Receiver Chain

    % 1. OFDM Demodulation (with integrated equalization)
    fprintf('\n--- OFDM Demodulation & Equalization ---\n');
    rx_qam_symbols = ofdm_demodulator(rx_signal, params);
    fprintf('Recovered QAM symbols: %d\n', length(rx_qam_symbols));

    %ax = gca;
    %ax.XLim = [-3 3];
    %ax.YLim = [-3 3];
    %axis square;
    %grid on;

    %scatterplot(rx_qam_symbols)

    % 2. QAM Demodulation
    fprintf('\n--- QAM Demodulation ---\n');
    demod_bits = qam_demodulator(rx_qam_symbols, params);
    fprintf('Demodulated bits length: %d\n', length(demod_bits));

    % 6. Remove Framing
    fprintf('\n--- Removing Framing ---\n');
    deframed_bits = deframing(demod_bits, params);
    fprintf('Deframed bits length: %d\n', length(deframed_bits));

    % Convert to 63x63 matrix and swap rows and columns back
    deframed_bits = reshape(deframed_bits, params.input_height, params.input_width + params.parity_bits)';
    deframed_bits = deframed_bits(:);

    % 7. Channel Decoding
    fprintf('\n--- Channel Decoding ---\n');
    decoded_bits = channel_decoding(deframed_bits, params);
    fprintf('Decoded bits length: %d\n', length(decoded_bits));

    % Frame performance
    num_bit_errors = sum(data_bits(:) ~= decoded_bits(:));
    fprintf('Number of bit errors in this frame: %d\n', num_bit_errors);

    % Write output bits to received array
    if f == 1
        received_bits = decoded_bits;
    else
        received_bits = [received_bits; decoded_bits];
    end

end % End of frame loop

%% Performance Evaluation
fprintf('\n=== Performance Evaluation ===\n');
num_errors = sum(params.input_file_bits(:) ~= received_bits(:));
BER = num_errors / numel(params.input_file_bits);

fprintf('Number of bit errors: %d\n', num_errors);
fprintf('Bit Error Rate (BER): %.4e\n', BER);

%% Visualization (TBI)


% Ensure received_bits is a column vector
received_bits = received_bits(:);

% Determine how many bits to use (original input size or truncate to received size)
num_bits_to_reconstruct = min(length(received_bits), length(params.input_file_bits));

% Pad to make full bytes if needed
if mod(num_bits_to_reconstruct, 8) ~= 0
    fprintf('Padding received bits to make full bytes for file reconstruction...\n');
    padding_needed = 8 - mod(num_bits_to_reconstruct, 8);
    % Actually pad the received_bits array
    received_bits = [received_bits; zeros(padding_needed, 1)];
    num_bits_to_reconstruct = num_bits_to_reconstruct + padding_needed;
else
    fprintf('Converting received bits to bytes for file reconstruction...\n');
end

reconstructedBytes = bi2de(reshape(received_bits(1:num_bits_to_reconstruct), 8, []).', 'left-msb');

% Save reconstructed file
    outputPath = fullfile(strcat('received_', fileName));
    fileIDout = fopen(outputPath, 'w');
    if fileIDout ~= -1
        fwrite(fileIDout, char(reconstructedBytes'), 'char');
        fclose(fileIDout);
        fprintf('Reconstructed file saved to: %s\n', outputPath);
        fprintf('Reconstructed file size: %d bytes\n', length(reconstructedBytes));
    else
        error('Could not create output file');
    end

fprintf('\n=== Simulation Complete ===\n');
