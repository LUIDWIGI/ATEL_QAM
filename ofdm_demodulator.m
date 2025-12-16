function qam_symbols = ofdm_demodulator(ofdm_symbol, params)
% OFDM_DEMODULATOR - Perform FFT and extract data from subcarriers
%
% Inputs:
%   ofdm_symbol - Time-domain OFDM symbol
%   params - System parameters structure
%
% Outputs:
%   qam_symbols - Recovered QAM symbols from data subcarriers

% Chunk size for processing (must match modulator)
chunk_size = 108;

% Calculate the OFDM symbol size per chunk
ofdm_chunk_size = params.num_subcarriers + params.cyclic_prefix_length;
num_chunks = floor(length(ofdm_symbol) / ofdm_chunk_size);

% Generate known pilot symbols (same as transmitter)
pilots = pilot_utils('generate', params);

% Process each chunk
qam_symbols = [];
for chunk_idx = 1:num_chunks
    % Extract OFDM chunk
    start_idx = (chunk_idx - 1) * ofdm_chunk_size + 1;
    end_idx = chunk_idx * ofdm_chunk_size;
    ofdm_chunk = ofdm_symbol(start_idx:end_idx);

    symOffset = params.cyclic_prefix_length;
    
    % OFDM demodulation with pilots for this chunk
    [chunk_symbols, rx_pilots] = ofdmdemod(ofdm_chunk, params.num_subcarriers, ...
        params.cyclic_prefix_length, ...
        symOffset, ...
        params.guardband_indices, ...
        params.pilot_indices);
    
    % (Optional) Process received pilots for channel estimation or synchronization
    % For this implementation, we assume perfect channel, so we skip this step.
    
    % Concatenate chunks
    qam_symbols = [qam_symbols; chunk_symbols];
end

% Remove padding to return to original size of 1024
% (Last chunk was padded from 52 to 108, so remove 56 symbols)
original_size = 1024;
if length(qam_symbols) > original_size
    qam_symbols = qam_symbols(1:original_size);
    fprintf('OFDM Demodulator: Trimmed %d padded symbols to restore original size of %d\n', ...
        length(qam_symbols) - original_size + (length(qam_symbols) > original_size) * (length(qam_symbols) - original_size), original_size);
end

end
