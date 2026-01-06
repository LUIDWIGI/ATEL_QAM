function i = pluto_initialize()
    i.centerFreq = 1.5e9;
    i.symRate    = 2e4;
    i.sps        = 16;
    i.basebandFs = i.symRate * i.sps;
    i.txGain     = -10;

    i.rolloff    = 0.35;
    i.filterSpan = 10;
    i.rrcCoeff   = rcosdesign(i.rolloff, i.filterSpan, i.sps);

	% for send
    i.tx = sdrtx('Pluto', ...
        'CenterFrequency', i.centerFreq, ...
        'BasebandSampleRate', i.basebandFs, ...
        'Gain', i.txGain);
		
i.rx = sdrrx("Pluto", ...
    "CenterFrequency", i.centerFreq, ...
    "BasebandSampleRate", i.basebandFs, ...
    "SamplesPerFrame", 200000, ...   
    "OutputDataType", "single");


    i.tx.ShowAdvancedProperties = true;
end
