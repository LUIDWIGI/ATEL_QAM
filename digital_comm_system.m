%% Digital Communication System - Main Script
% Authors: Jordi van Oosterwijk, Filip Maessen
% Based on system specification document
% MATLAB Version: 2025a

clear all;
close all;
clc;

%% System Parameters
params = struct();

% Modulation parameters
params.modulation_order = 16;           % 16-QAM
params.bits_per_symbol = log2(params.modulation_order);             % log2(16) = 4

% OFDM parameters
params.num_subcarriers = 128;             % Total subcarriers
params.num_guardbands = 11;              % Edge guardbands (3 total including DC)
params.num_dcbands = 3;
params.guardband_indices = [ 1:6, 63:65 , 124:128]'; % Guardband indices
params.num_pilots = 6; % Number of pilot carriers
params.pilot_indices = [-42, -25, -11, 11, 25, 42]'; % Pilot carrier indices
params.num_data_carriers = params.num_subcarriers - params.num_guardbands - 1; % 5 active carriers

% System parameters
params.bitwidth = 20;                   % Total bits per OFDM symbol
params.cyclic_prefix_length = 4;        % CP length (samples)

% Channel parameters
params.SNR_dB = 20;                     % Signal-to-noise ratio in dBsymbol

% Input dimensions
params.input_height = 63;
params.input_width = 63;

%% Generate Random Data
num_bits = params.input_height*params.input_width;
data_bits = randi([0 1], params.input_height, params.input_width);

fprintf('Generated %d random bits\n', num_bits);
% fprintf('Data bits: %s\n', num2str(data_bits'));

%% Transmitter Chain

% % 1. Channel Encoding (FEC - To Be Implemented)
% fprintf('\n--- Channel Encoding ---\n');
% encoded_bits = channel_encode(data_bits, params);
% fprintf('Encoded bits length: %d\n', length(encoded_bits));

% 2. Framing (To Be Implemented)
fprintf('\n--- Framing ---\n');
framed_bits = framing(data_bits, params);
fprintf('Framed bits length: %d\n', length(framed_bits));

% 3. QAM Modulation
fprintf('\n--- QAM Modulation ---\n');
qam_symbols = qam_modulator(framed_bits, params);
fprintf('Number of QAM symbols: %d\n', length(qam_symbols));

% Plot the constelation
scatterplot(qam_symbols)

% % 4. Pulse Shaping Filter
% fprintf('\n--- Pulse Shaping ---\n');
% pulse_shaped = pulse_shaping_filter(qam_symbols, params);
% fprintf('Pulse shaped signal length: %d\n', length(pulse_shaped));

% % 5. OFDM - IFFT with subcarrier mapping
% fprintf('\n--- OFDM (IFFT) ---\n');
% ofdm_symbol = ofdm_modulator(pulse_shaped, params);
% fprintf('OFDM symbol length: %d\n', length(ofdm_symbol));

% % 6. Add Cyclic Prefix
% fprintf('\n--- Adding Cyclic Prefix ---\n');
% tx_signal = add_cyclic_prefix(ofdm_symbol, params);
% fprintf('Transmitted signal length: %d\n', length(tx_signal));

%% Channel
fprintf('\n--- Channel Transmission ---\n');
rx_signal = channel_model(qam_symbols, params);
scatterplot(rx_signal)



% %% Receiver Chain

% % 1. Remove Cyclic Prefix
% fprintf('\n--- Removing Cyclic Prefix ---\n');
% rx_ofdm = remove_cyclic_prefix(rx_signal, params);

% % 2. FFT
% fprintf('\n--- OFDM Demodulation (FFT) ---\n');
% rx_freq = ofdm_demodulator(rx_ofdm, params);

% % 3. Equalization
% fprintf('\n--- Equalization ---\n');
% equalized = equalizer(rx_freq, params);

% % 4. Pulse Shaping Filter (Matched Filter)
% fprintf('\n--- Matched Filter ---\n');
% filtered = pulse_shaping_filter(equalized, params);

% 5. QAM Demodulation
fprintf('\n--- QAM Demodulation ---\n');
demod_bits = qam_demodulator(rx_signal, params);
fprintf('Demodulated bits length: %d\n', length(demod_bits));

% 6. Remove Framing
fprintf('\n--- Removing Framing ---\n');
deframed_bits = deframing(demod_bits, params);

% % 7. Channel Decoding
% fprintf('\n--- Channel Decoding ---\n');
% decoded_bits = channel_decode(deframed_bits, params);

%% Performance Evaluation
fprintf('\n=== Performance Evaluation ===\n');
num_errors = sum(data_bits ~= deframed_bits(1:length(data_bits)));
BER = num_errors / length(data_bits);

fprintf('Number of bit errors: %d\n', num_errors);
fprintf('Bit Error Rate (BER): %.4e\n', BER);

%% Visualization (TBI)

fprintf('\n=== Simulation Complete ===\n');
