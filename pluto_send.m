function pluto_send(txWaveform, p, txSymbols)
    txWaveform = txWaveform(:);

    m = max(abs(txWaveform));
    if m > 0
        txWaveform = txWaveform / m;
    end
    txWaveform = 0.25 * txWaveform;   % backoff

    if nargin >= 3 && ~isempty(txSymbols)
        figure(1);
        subplot(1,2,1);
        plot(real(txSymbols(:)), imag(txSymbols(:)), '.', 'MarkerSize', 6);
        grid on; axis square;
        xlim([-1 1]); ylim([-1 1]);
        title("Transmitted symbols");
        xlabel("In-Phase"); ylabel("Quadrature");
    end

    transmitRepeat(p.tx, single(txWaveform));
end
