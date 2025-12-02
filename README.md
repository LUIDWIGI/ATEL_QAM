# Digital Communication System - MATLAB Implementation

## Authors
- Jordi van Oosterwijk (4841190)
- Filip Maessen

## Overview
This MATLAB implementation provides a starting point for a digital communication system based on the specifications in your design document. The system implements:

- 16-QAM modulation
- OFDM with 8 subcarriers (5 active data carriers)
- Pulse shaping with raised cosine filters
- Cyclic prefix addition/removal
- AWGN channel model
- Full transmitter and receiver chain

## System Specifications
- **Modulation**: 16-QAM (4 bits per symbol)
- **OFDM Subcarriers**: 8 total (5 data, 3 null/guard)
- **Bitwidth**: 20 bits per OFDM symbol
- **Cyclic Prefix**: 4 samples
- **Channel**: AWGN with configurable SNR

## File Structure
```
digital_comm_system.m       - Main simulation script
channel_encode.m            - FEC encoding (placeholder)
add_framing.m               - Frame structure addition (placeholder)
qam_modulator.m             - 16-QAM modulation
pulse_shaping_filter.m      - Raised cosine pulse shaping
ofdm_modulator.m            - IFFT and subcarrier mapping
add_cyclic_prefix.m         - Cyclic prefix addition
channel_model.m             - AWGN channel simulation
remove_cyclic_prefix.m      - Cyclic prefix removal
ofdm_demodulator.m          - FFT and subcarrier extraction
equalizer.m                 - Channel equalization (placeholder)
qam_demodulator.m           - 16-QAM demodulation
remove_framing.m            - Frame structure removal (placeholder)
channel_decode.m            - FEC decoding (placeholder)
```

## Usage

### Basic Simulation
Simply run the main script in MATLAB:
```matlab
digital_comm_system
```

### Modifying Parameters
Edit the parameters in the main script:
```matlab
params.modulation_order = 16;      % Change modulation order
params.num_subcarriers = 8;        % Change number of subcarriers
params.SNR_dB = 20;                % Change SNR (in dB)
params.cyclic_prefix_length = 4;   % Change CP length
```

### Required MATLAB Toolboxes
- Communications Toolbox (for QAM modulation/demodulation)
- Signal Processing Toolbox (for filter design)

## Implementation Status

### ✅ Implemented
- 16-QAM modulation/demodulation
- OFDM modulation/demodulation with IFFT/FFT
- Pulse shaping with raised cosine filters
- Cyclic prefix addition/removal
- AWGN channel model
- Basic equalization
- BER calculation
- Visualization plots

### 🚧 To Be Implemented (Marked as TBD in specifications)
- **FEC Method**: Forward Error Correction encoding/decoding
  - Options: Hamming codes, Reed-Solomon, LDPC, Turbo codes
  - Files: `channel_encode.m`, `channel_decode.m`
  
- **Framing**: Frame structure for synchronization and metadata
  - Preamble, headers, CRC
  - Files: `add_framing.m`, `remove_framing.m`

- **Advanced Channel Models**: Multipath fading, frequency-selective channels
  - File: `channel_model.m`

- **Channel Estimation**: Pilot-based channel estimation for equalization
  - File: `equalizer.m`

## Output
The simulation produces:
1. Console output showing processing steps and BER
2. Figure with 6 subplots:
   - Transmitted signal spectrum
   - 16-QAM constellation (TX)
   - Received constellation (after equalization)
   - Time-domain transmitted signal
   - Time-domain received signal
   - Bit comparison (original vs decoded)

## Next Steps

1. **Implement FEC**:
   - Choose a FEC method (e.g., convolutional codes with Viterbi decoding)
   - Update `channel_encode.m` and `channel_decode.m`

2. **Add Framing**:
   - Design frame structure with preamble for synchronization
   - Implement in `add_framing.m` and `remove_framing.m`

3. **Improve Channel Model**:
   - Add multipath fading
   - Implement frequency-selective channel

4. **Enhance Equalization**:
   - Add pilot symbols for channel estimation
   - Implement MMSE or zero-forcing equalization

5. **BER vs SNR Curve**:
   - Run simulation over range of SNR values
   - Plot BER performance

## Testing
To verify the system is working:
1. Run with high SNR (e.g., 30 dB) - should have very low BER
2. Run with low SNR (e.g., 5 dB) - will have higher BER
3. Check constellation plots - should see clear 16-QAM structure

## Notes
- The pulse shaping filter currently uses 4x oversampling
- OFDM subcarrier mapping places data in bins 2-6 (bin 1 is DC, bins 7-8 are guards)
- The cyclic prefix helps mitigate ISI from multipath (when implemented)
- Current implementation assumes perfect synchronization

## References
- Digital Communications by John G. Proakis
- OFDM Wireless Communications by Ye (Geoffrey) Li
- MATLAB Communications Toolbox Documentation
