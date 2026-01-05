% function H_est = estimate_channel(rx_freq_domain, pilot_indices, pilot_symbols)
%     % rx_freq_domain: [128 × num_ofdm_symbols] after FFT
% 
%     num_ofdm_symbols = size(rx_freq_domain, 2);
%     H_est = zeros(128, num_ofdm_symbols);
% 
%     for k = 1:num_ofdm_symbols
%         % Extract received pilots
%         rx_pilots = rx_freq_domain(pilot_indices, k);
% 
%         % Estimate channel at pilot locations
%         H_pilots = rx_pilots ./ pilot_symbols;
% 
%         % Interpolate to all subcarriers (linear interpolation)
%         H_est(:, k) = interp1(pilot_indices, H_pilots, 1:128, 'linear', 'extrap');
%     end
% end