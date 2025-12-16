function ofdm_symbol = ofdm_modulator(qam_symbols, params)
% OFDM_MODULATOR - Map QAM symbols to subcarriers and perform IFFT
%
% Inputs:
%   qam_symbols - QAM modulated symbols
%   params - System parameters structure
%
% Outputs:
%   ofdm_symbol - Time-domain OFDM symbol

% Chunk size for processing
chunk_size = 108;
num_symbols = length(qam_symbols);

% Calculate number of chunks and padding needed
num_full_chunks = floor(num_symbols / chunk_size);
remainder = mod(num_symbols, chunk_size);

if remainder > 0
    % Pad with zeros to complete the final chunk
    padding_needed = chunk_size - remainder;
    qam_symbols = [qam_symbols; zeros(padding_needed, 1)];
    num_chunks = num_full_chunks + 1;
    fprintf('OFDM Modulator: Padded with %d zeros (remainder was %d)\n', padding_needed, remainder);
else
    num_chunks = num_full_chunks;
end

% Generate pilot symbols using temporary pilot implementation
pilots = pilot_utils('generate', params);

% Process each chunk
ofdm_symbol = [];
for chunk_idx = 1:num_chunks
    % Extract chunk
    start_idx = (chunk_idx - 1) * chunk_size + 1;
    end_idx = chunk_idx * chunk_size;
    chunk_symbols = qam_symbols(start_idx:end_idx);
    
    % OFDM modulation with pilots for this chunk
    chunk_ofdm = ofdmmod(chunk_symbols, params.num_subcarriers, ...
        params.cyclic_prefix_length, ...
        params.guardband_indices, ...
        params.pilot_indices, ...
        pilots);
    
    % Concatenate chunks
    ofdm_symbol = [ofdm_symbol; chunk_ofdm];
end

end
