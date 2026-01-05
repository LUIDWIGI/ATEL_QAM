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
            
            % Create output vector for all subcarriers (including guardbands)
            pilots = zeros(params.num_subcarriers, 1);
            
            % Insert pilots at their positions (params.pilot_indices are in 1-128 range)
            pilots(params.pilot_indices) = pilot_symbols;
            
            % Get data carrier indices (all non-guardband, non-pilot carriers)
            data_carrier_idx = setdiff(1:params.num_subcarriers, ...
                [params.guardband_indices; params.pilot_indices]);
            
            % Insert data symbols
            if length(data_symbols) <= length(data_carrier_idx)
                pilots(data_carrier_idx(1:length(data_symbols))) = data_symbols;
            else
                error('Too many data symbols for available carriers');
            end
            
        case 'extract'
            % Extract pilot symbols from received OFDM symbols
            % varargin{1} = received_symbols (all subcarriers including guardbands)
            if isempty(varargin)
                error('Extract operation requires received_symbols');
            end
            received_symbols = varargin{1};
            
            % Use pilot indices directly (params.pilot_indices are in 1-128 range)
            pilots = received_symbols(params.pilot_indices);
            
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
            H_pilots = rx_pilots ./ (tx_pilots + 1e-10);
            
            % Interpolate to all subcarriers (1:128) including guardbands
            % Use pilot indices directly (they're already in 1-128 range)
            pilots = interp1(params.pilot_indices, H_pilots, 1:params.num_subcarriers, 'linear', 'extrap').';
            
        case 'remove_data'
            % Remove pilot carriers and return only data symbols
            % varargin{1} = all_symbols (with pilots and guardbands)
            if isempty(varargin)
                error('Remove_data operation requires all_symbols');
            end
            all_symbols = varargin{1};
            
            % Get data carrier indices (all non-guardband, non-pilot carriers)
            data_pos = setdiff(1:params.num_subcarriers, ...
                [params.guardband_indices; params.pilot_indices]);
            
            pilots = all_symbols(data_pos);
            
        otherwise
            error('Unknown operation: %s', operation);
    end
end