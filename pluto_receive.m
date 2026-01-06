function [rx_time, rxSym] = pluto_receive(p)
    pause(0.5);
    p.rx();                 % flush
    r = p.rx();             % capture
    r = single(r);

    rx_time = r;            

    % ----- CFO estimate (QPSK 4th power) -----
    n  = (0:length(r)-1).';
    r4 = r.^4;
    ph = unwrap(angle(r4));
    dph = diff(ph);
    cfo = (p.basebandFs/(2*pi*4)) * mean(dph);
    fprintf("Estimated CFO: %.2f Hz\n", cfo);

    % CFO correction
    r = r .* exp(-1j*2*pi*cfo/p.basebandFs*n);

    % ----- Symbol timing (coarse) -----
    bestK = 1;
    bestPow = 0;
    for k = 1:p.sps
        rk = r(k:p.sps:end);
        pwr = mean(abs(rk).^2);
        if pwr > bestPow
            bestPow = pwr;
            bestK = k;
        end
    end
    rSym = r(bestK:p.sps:end);

    % ----- Constant phase + extra 45 degree shift -----
    if length(rSym) > 200
        rUse = rSym(200:end);
    else
        rUse = rSym;
    end
    phi = angle(mean(rUse.^4)) / 4;
    rSym = rSym .* exp(-1j*(phi + pi/4));

    % ----- Normalize for plotting (unit RMS) -----
    if length(rSym) > 200
        rUse2 = rSym(200:end);
    else
        rUse2 = rSym;
    end
    rxRms = sqrt(mean(abs(rUse2).^2));
    if rxRms > 0
        rSym = rSym / rxRms;
    end

    rxSym = rSym;

    % ----- RX constellation plot -----
    figure(1);
    subplot(1,2,2);
    plot(real(rSym), imag(rSym), '.', 'MarkerSize', 6);
    grid on; axis square;
    xlim([-1 1]); ylim([-1 1]);
    title("Received symbols");
    xlabel("In-Phase"); ylabel("Quadrature");
end
