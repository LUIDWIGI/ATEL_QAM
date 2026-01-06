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

% Channel parameters
params.SNR_dB = 27;                     % Signal-to-noise ratio in dBsymbol

% Input dimensions
params.input_height = 63;
params.input_width = 57;

%% Generate Random Data
num_bits = params.input_height*params.input_width;
data_bits = randi([0 1], params.input_height, params.input_width);

fprintf('Generated %d random bits\n', num_bits);
% fprintf('Data bits: %s\n', num2str(data_bits'));

%% Transmitter Chain

% 1. Channel Encoding (FEC - To Be Implemented)
fprintf('\n--- Channel Encoding ---\n');
encoded_bits = channel_encoding(data_bits, params);
fprintf('Encoded bits length: %d\n', length(encoded_bits));

% 2. Framing (To Be Implemented)
fprintf('\n--- Framing ---\n');
framed_bits = framing(encoded_bits, params);
fprintf('Framed bits length: %d\n', length(framed_bits));

% 3. QAM Modulation
fprintf('\n--- QAM Modulation ---\n');
qam_symbols = qam_modulator(framed_bits, params);
fprintf('Number of QAM symbols: %d\n', length(qam_symbols));

% 5. OFDM Mod
fprintf('\n--- OFDM (IFFT) ---\n');
ofdm_symbol = ofdm_modulator(qam_symbols, params);
fprintf('OFDM symbol length: %d\n', length(ofdm_symbol));

%% Artificial noise commented out
%fprintf('\n--- Channel Transmission ---\n');
%rx_signal = channel_model(ofdm_symbol, params);

% SEND SIGNAL
pluto_send(ofdm_symbol, pluto_params);

% RECEIVE SIGNAL
rx_signal = pluto_receive(pluto_params);


%% Receiver Chain

% 1. OFDM Demodulation (with integrated equalization)
fprintf('\n--- OFDM Demodulation & Equalization ---\n');
rx_qam_symbols = ofdm_demodulator(rx_signal, params);
fprintf('Recovered QAM symbols: %d\n', length(rx_qam_symbols));

ax = gca;
ax.XLim = [-3 3];
ax.YLim = [-3 3];
axis square;
grid on;


% 2. QAM Demodulation
fprintf('\n--- QAM Demodulation ---\n');
demod_bits = qam_demodulator(rx_qam_symbols, params);
fprintf('Demodulated bits length: %d\n', length(demod_bits));

% 6. Remove Framing
fprintf('\n--- Removing Framing ---\n');
deframed_bits = deframing(demod_bits, params);

% 7. Channel Decoding
fprintf('\n--- Channel Decoding ---\n');
decoded_bits = channel_decoding(deframed_bits, params);

%% Performance Evaluation
fprintf('\n=== Performance Evaluation ===\n');
num_errors = sum(data_bits(:) ~= decoded_bits(:));
BER = num_errors / numel(data_bits);

fprintf('Number of bit errors: %d\n', num_errors);
fprintf('Bit Error Rate (BER): %.4e\n', BER);

%% Visualization (TBI)

fprintf('\n=== Simulation Complete ===\n');
