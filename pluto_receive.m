function rxSym = pluto_receive(pluto_params, params)
    % Known pilots
    txPilots = ones(length(params.pilot_indices), 1);

    pause(0.2);
    pluto_params.rx(); pluto_params.rx();   % flush

    % Capture a two frames so you likely catch many OFDM symbols
    rx_time = complex(single([]));
    for k = 1:2
        rx_time = [rx_time; single(pluto_params.rx())];
    end

    % Coarse OFDM boundary via CP correlation
    startIdx = coarse_ofdm_sync_cp(rx_time, params.num_subcarriers, params.cyclic_prefix_length);
    rx = rx_time(startIdx:end);

    % Trim to whole OFDM symbols
    L = params.num_subcarriers + params.cyclic_prefix_length;
    numSyms = floor(length(rx) / L);
    rxSym = rx(1:numSyms*L);

    % FFT + pilot phase correction
    Xall = zeros(params.num_subcarriers, numSyms, "like", complex(1,1));
    cpe  = zeros(numSyms,1);

    for s = 1:numSyms
        i0 = (s-1)*L;

        sym_td = rxSym(i0 + params.cyclic_prefix_length + 1 : i0 + L);
        X = fftshift(fft(sym_td, params.num_subcarriers));

        % Pilot based CPE estimate
        rxP = X(params.pilot_indices);
        phi = angle(sum(rxP .* conj(txPilots)));
        cpe(s) = phi;

        Xc = X * exp(-1j*phi);
        Xall(:,s) = Xc;
    end
end

function startIdx = coarse_ofdm_sync_cp(rx, num_subcarriers, cyclic_prefix_length)

    maxSearch = length(rx) - (num_subcarriers + cyclic_prefix_length + 1);

    metric = zeros(maxSearch,1);
    for i = 1:maxSearch
        a = rx(i : i+cyclic_prefix_length-1);
        b = rx(i+num_subcarriers : i+num_subcarriers+cyclic_prefix_length-1);
        metric(i) = abs(sum(conj(a).*b));
    end

    [~, startIdx] = max(metric);
end
