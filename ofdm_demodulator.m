function qam_symbols = ofdm_demodulator(ofdm_symbol, params)
% OFDM_DEMODULATOR - Perform FFT and extract data from subcarriers
%
% Inputs:
%   ofdm_symbol - Time-domain OFDM symbol
%   params - System parameters structure
%
% Outputs:
%   qam_symbols - Recovered QAM symbols from data subcarriers

    % Calculate the OFDM symbol size per chunk
    ofdm_chunk_size = params.num_subcarriers + params.cyclic_prefix_length;
    num_chunks = floor(length(ofdm_symbol) / ofdm_chunk_size);

    % Generate known pilot symbols (same as transmitter)
    tx_pilots = pilot_utils('generate', params);

    % Process each chunk
    qam_symbols = [];
    for chunk_idx = 1:num_chunks
        % Extract OFDM chunk
        start_idx = (chunk_idx - 1) * ofdm_chunk_size + 1;
        end_idx = chunk_idx * ofdm_chunk_size;
        ofdm_chunk = ofdm_symbol(start_idx:end_idx);

        % OFDM demodulation with pilots for this chunk
        [chunk_symbols, rx_pilots] = ofdmdemod(ofdm_chunk, params.num_subcarriers, ...
            params.cyclic_prefix_length, ...
            params.cyclic_prefix_length, ...
            params.guardband_indices, ...
            params.pilot_indices);
        
        % Estimate channel from pilots
        H_pilots = rx_pilots ./ (tx_pilots + 1e-10);
        
        % Interpolate to get channel estimate for all data carriers
        data_indices = setdiff(1:params.num_subcarriers, ...
            [params.guardband_indices; params.pilot_indices]);
        H_data = interp1(params.pilot_indices, H_pilots, data_indices, 'linear', 'extrap').';
        
        % Equalize using MATLAB's ofdmEqualize function
        eq_symbols = ofdmEqualize(chunk_symbols, H_data, algorithm="zf");
        
        % Concatenate chunks
        qam_symbols = [qam_symbols; eq_symbols];
    end

    % Remove padding based on frame structure
    % Frame length is 4096 bits, convert to symbols based on modulation order
    frame_length = 4096; % bits per frame
    expected_symbols = frame_length / params.bits_per_symbol;
    
    if length(qam_symbols) > expected_symbols
        padding_removed = length(qam_symbols) - expected_symbols;
        qam_symbols = qam_symbols(1:expected_symbols);
        fprintf('OFDM Demodulator: Removed %d padded symbols (recovered %d symbols from %d chunks)\n', ...
            padding_removed, expected_symbols, num_chunks);
    else
        fprintf('OFDM Demodulator: Recovered %d QAM symbols from %d chunks\n', ...
            length(qam_symbols), num_chunks);
    end

end
