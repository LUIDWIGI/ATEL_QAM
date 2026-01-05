function eq_symbols = equalizer(rx_freq_domain, H_est, params)
    % Zero-Forcing equalization
    num_ofdm_symbols = size(rx_freq_domain, 2);
    eq_data = zeros(length(params.data_carrier_indices), num_ofdm_symbols);
    
    for k = 1:num_ofdm_symbols
        % Extract data subcarriers
        rx_data = rx_freq_domain(params.data_carrier_indices, k);
        H_data = H_est(params.data_carrier_indices, k);
        
        % Equalize (with small regularization to avoid division by zero)
        eq_data(:, k) = rx_data ./ (H_data + 1e-10);
    end
    
    % Reshape back to vector
    eq_symbols = eq_data(:);
end