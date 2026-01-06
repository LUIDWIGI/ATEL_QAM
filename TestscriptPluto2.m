clear; clc; close all;

i = pluto_initialize();

NsymFrame = 4096;
i.rx.SamplesPerFrame = NsymFrame * i.sps * 2;

% ----- QPSK test symbols and waveform -----
S = (1/sqrt(2)) * [ 1+1j; 1-1j; -1+1j; -1-1j ];
txSym  = repmat(S, NsymFrame/4, 1);
txWave = repelem(txSym, i.sps);

% ----- TX (TX constellation plot on left) -----
pluto_send(txWave, i, txSym);

% ----- RX (RX constellation plot on right) -----
[rx_time, rxSym] = pluto_receive(i); %#ok<NASGU>

release(i.tx);
release(i.rx);
