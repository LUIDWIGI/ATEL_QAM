function pilots = pilot_utils(operation, params, varargin)
% PILOT_UTILS - Temporary pilot implementation for OFDM system
%
% Operations:
%   'generate' - Generate pilot symbols
%   'insert' - Insert pilots into data symbols
%   'extract' - Extract pilots from received symbols
%   'estimate' - Estimate channel response from pilots
%
% Inputs:
%   operation - String specifying the operation
%   params - System parameters structure
%   varargin - Additional inputs depending on operation
%
% Outputs:
%   pilots - Generated pilots or processed data
%
% Example usage:
%   pilot_symbols = pilot_utils('generate', params);
%   all_symbols = pilot_utils('insert', params, data_symbols, pilot_symbols);
%   H_est = pilot_utils('estimate', params, rx_pilots, tx_pilots);

    switch operation
        case 'generate'
            % Generate pseudorandom BPSK pilot symbols (+1/-1)
            % Using a fixed seed for reproducibility
            rng(42, 'twister'); % Fixed seed for known pilots
            pilots = 2*randi([0 1], params.num_pilots, 1) - 1;
            pilots = pilots * sqrt(2); % Normalize power
            
        case 'insert'
            % Insert pilots into data symbols
            % varargin{1} = data_symbols
            % varargin{2} = pilot_symbols
            if length(varargin) < 2
                error('Insert operation requires data_symbols and pilot_symbols');
            end
            data_symbols = varargin{1};
            pilot_symbols = varargin{2};
            
            % Create output vector
            total_carriers = params.num_subcarriers - length(params.guardband_indices);
            pilots = zeros(total_carriers, 1);
            
            % Calculate pilot positions (convert from centered to FFT indexing)
            pilot_pos = params.pilot_indices + (params.num_subcarriers/2 + 1);
            pilot_pos(pilot_pos > params.num_subcarriers) = pilot_pos(pilot_pos > params.num_subcarriers) - params.num_subcarriers;
            
            % Remove guardbands from pilot positions
            for i = 1:length(pilot_pos)
                pilot_pos(i) = pilot_pos(i) - sum(params.guardband_indices < pilot_pos(i));
            end
            
            % Insert pilots
            data_idx = 1;
            for i = 1:total_carriers
                if any(pilot_pos == i)
                    pilot_idx = find(pilot_pos == i);
                    pilots(i) = pilot_symbols(pilot_idx);
                else
                    if data_idx <= length(data_symbols)
                        pilots(i) = data_symbols(data_idx);
                        data_idx = data_idx + 1;
                    end
                end
            end
            
        case 'extract'
            % Extract pilot symbols from received OFDM symbols
            % varargin{1} = received_symbols (all subcarriers)
            if isempty(varargin)
                error('Extract operation requires received_symbols');
            end
            received_symbols = varargin{1};
            
            % Calculate pilot positions
            pilot_pos = params.pilot_indices + (params.num_subcarriers/2 + 1);
            pilot_pos(pilot_pos > params.num_subcarriers) = pilot_pos(pilot_pos > params.num_subcarriers) - params.num_subcarriers;
            
            % Remove guardbands from pilot positions
            for i = 1:length(pilot_pos)
                pilot_pos(i) = pilot_pos(i) - sum(params.guardband_indices < pilot_pos(i));
            end
            
            pilots = received_symbols(pilot_pos);
            
        case 'estimate'
            % Estimate channel response from pilots
            % varargin{1} = received_pilots
            % varargin{2} = transmitted_pilots
            if length(varargin) < 2
                error('Estimate operation requires received_pilots and transmitted_pilots');
            end
            rx_pilots = varargin{1};
            tx_pilots = varargin{2};
            
            % Simple channel estimation: H = Y/X
            H_pilots = rx_pilots ./ tx_pilots;
            
            % Interpolate to all data carriers
            pilot_pos = params.pilot_indices + (params.num_subcarriers/2 + 1);
            pilot_pos(pilot_pos > params.num_subcarriers) = pilot_pos(pilot_pos > params.num_subcarriers) - params.num_subcarriers;
            
            % Remove guardbands
            for i = 1:length(pilot_pos)
                pilot_pos(i) = pilot_pos(i) - sum(params.guardband_indices < pilot_pos(i));
            end
            
            total_carriers = params.num_subcarriers - length(params.guardband_indices);
            data_pos = setdiff(1:total_carriers, pilot_pos);
            
            % Linear interpolation
            pilots = interp1(pilot_pos, H_pilots, 1:total_carriers, 'linear', 'extrap').';
            
        case 'remove_data'
            % Remove pilot carriers and return only data symbols
            % varargin{1} = all_symbols (with pilots)
            if isempty(varargin)
                error('Remove_data operation requires all_symbols');
            end
            all_symbols = varargin{1};
            
            % Calculate pilot positions
            pilot_pos = params.pilot_indices + (params.num_subcarriers/2 + 1);
            pilot_pos(pilot_pos > params.num_subcarriers) = pilot_pos(pilot_pos > params.num_subcarriers) - params.num_subcarriers;
            
            % Remove guardbands from pilot positions
            for i = 1:length(pilot_pos)
                pilot_pos(i) = pilot_pos(i) - sum(params.guardband_indices < pilot_pos(i));
            end
            
            total_carriers = params.num_subcarriers - length(params.guardband_indices);
            data_pos = setdiff(1:total_carriers, pilot_pos);
            
            pilots = all_symbols(data_pos);
            
        otherwise
            error('Unknown operation: %s', operation);
    end
end
