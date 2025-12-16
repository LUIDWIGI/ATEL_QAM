# Digital Communication System - MATLAB Implementation

## Authors
- Jordi van Oosterwijk
- Filip Maessen

## Overview
This MATLAB implementation provides a complete digital communication system based on the ATEL specifications. The system implements a full transmitter and receiver chain with:

- 16-QAM modulation
- OFDM with 128 subcarriers (108 data, 6 pilot, 3 DC, 11 guard)
- Hamming (63,57) Forward Error Correction
- Row-Column Interleaving
- Frame structure with Barker code synchronization
- AWGN channel model
- Symbol rate: 25,000 symbols/sec
- Center frequency: 1.5 GHz

## System Specifications

### Modulation & OFDM
- **Modulation**: 16-QAM (4 bits per symbol)
- **Total Subcarriers**: 128
- **Data Carriers**: 108 (carrying actual data)
- **Pilot Carriers**: 6 (for channel estimation and phase tracking)
- **DC Carriers**: 3 (null carriers at center to reduce DC offset)
- **Guard Carriers**: 11 (to reduce interference with neighboring bands)
- **Pilot Indices**: [-42, -25, -11, 11, 25, 42]
- **Guard Indices**: [1:6, 63:65, 124:128]

### Forward Error Correction
- **FEC Type**: Hamming code
- **Hamming Type**: (63,57) - 63 bits output, 57 bits input
- **Parity Bits**: 6 bits per codeword
- **Interleaving**: Row-Column (63×63 matrix)

### Frame Structure
Total frame length: 4096 bits

| Bit Range   | Bit Amount | Usage                        |
|-------------|------------|------------------------------|
| 0 – 25      | 26         | Barker code (2×13 bits)      |
| 26 – 112    | 87         | Metadata                     |
| 113 – 2128  | 2016       | 32× data blocks (32×63 bits) |
| 2129 – 2142 | 14         | Barker code (2×7 bits)       |
| 2143 – 4095 | 1953       | 31× data blocks (31×63 bits) |

### Channel Parameters
- **Channel Type**: AWGN (Additive White Gaussian Noise)
- **SNR**: Configurable (default: 20 dB)
- **Cyclic Prefix**: 4 samples

### Input/Output
- **Input Dimensions**: 63×63 bits (3969 bits total)
- **After FEC Encoding**: 63×63 bits (with parity)
- **After Framing**: 4096 bits
- **After QAM Modulation**: 1024 symbols
- **After OFDM**: 10×128 symbols per frame

## File Structure

### Main Simulation
- `digital_comm_system.m` - Main simulation script

### Transmitter Chain
1. `channel_encoding.m` - Hamming (63,57) FEC encoding
2. `framing.m` - Frame structure with Barker codes and metadata
3. `qam_modulator.m` - 16-QAM modulation
4. `ofdm_modulator.m` - IFFT and subcarrier mapping
5. `add_cyclic_prefix.m` - Cyclic prefix addition

### Channel
- `channel_model.m` - AWGN channel simulation

### Receiver Chain
1. `remove_cyclic_prefix.m` - Cyclic prefix removal
2. `ofdm_demodulator.m` - FFT and subcarrier extraction
3. `equalizer.m` - Channel equalization
4. `qam_demodulator.m` - 16-QAM demodulation
5. `deframing.m` - Frame structure removal
6. `channel_decoding.m` - Hamming FEC decoding

### Currently Unused
- `pulse_shaping_filter.m` - Raised cosine pulse shaping (not in current signal path)

## Usage

### Basic Simulation
Run the main script in MATLAB:
```matlab
digital_comm_system
```

### Modifying Parameters
Edit the parameters in `digital_comm_system.m`:

```matlab
% Modulation parameters
params.modulation_order = 16;           % 16-QAM
params.bits_per_symbol = 4;             % log2(16) = 4

% OFDM parameters
params.num_subcarriers = 128;           % Total subcarriers
params.num_guardbands = 11;             % Edge guardbands
params.num_dcbands = 3;                 % DC carriers
params.num_pilots = 6;                  % Pilot carriers
params.num_data_carriers = 108;         % Data carriers

% Channel parameters
params.SNR_dB = 20;                     % Signal-to-noise ratio

% Input dimensions
params.input_height = 63;               % FEC codeword size
params.input_width = 63;                % Interleaving matrix size
```

### Required MATLAB Toolboxes
- Communications Toolbox (for QAM modulation/demodulation, OFDM, FEC)
- Signal Processing Toolbox (for filter design)

## Implementation Status

### ✅ Fully Implemented
- **16-QAM Modulation/Demodulation**: Complete implementation using MATLAB's `qammod`/`qamdemod`
- **Framing/Deframing**: Frame structure with dual Barker codes (13-bit and 7-bit) and metadata section
- **OFDM Modulation/Demodulation**: Using MATLAB's `ofdmmod`/`ofdmdemod` with proper subcarrier allocation
- **Cyclic Prefix**: Addition and removal (4 samples)
- **AWGN Channel**: Configurable SNR
- **BER Calculation**: Bit error rate computation

### 🚧 In Progress
- **Channel Encoding**: Hamming (63,57) implementation started
  - Function skeleton exists in `channel_encoding.m`
  - Uses MATLAB's `encode` function with 'hamming/binary' format
  - Input: 63×63 bit matrix → Output: 63×69 bit matrix (with 6 parity bits per row)
  
- **Channel Decoding**: Hamming (63,57) decoding started
  - Function skeleton exists in `channel_decoding.m`
  - Needs to properly decode and remove parity bits
  
- **Interleaving**: Row-Column interleaving for burst error protection
  - Specified in design (63×63 matrix transpose)
  - Not yet integrated into signal chain

- **Equalization**: Basic placeholder implementation
  - Currently performs simple amplitude normalization
  - Needs pilot-based channel estimation

### ⏸️ Not Started
- **Pulse Shaping**: Raised cosine filter implementation exists but not integrated
- **Advanced Channel Models**: Multipath fading, frequency-selective channels
- **Synchronization**: Frame detection using Barker code correlation
- **Pilot-Based Channel Estimation**: Using 6 pilot subcarriers

## Current Signal Flow

### Transmitter Path (Implemented)
1. **Data Generation**: Random 63×63 bit matrix (3969 bits)
2. **Framing**: Add Barker codes and metadata → 4096 bits
3. **QAM Modulation**: Convert to 1024 QAM-16 symbols
4. **Channel**: AWGN noise addition

### Receiver Path (Implemented)
1. **Channel**: Receive noisy signal
2. **QAM Demodulation**: Recover 4096 bits
3. **Deframing**: Extract 63×63 bit data
4. **BER Calculation**: Compare with original data

### Next Integration Steps
1. Add channel encoding before framing
2. Add interleaving between encoding and framing
3. Add OFDM modulation after QAM
4. Add cyclic prefix before channel
5. Implement full receiver chain in reverse order

## Output

The simulation currently produces:
1. **Console Output**:
   - Processing steps for each stage
   - Number of bit errors
   - Bit Error Rate (BER)

2. **Constellation Plots**:
   - Transmitted QAM-16 constellation (clean)
   - Received constellation (with AWGN noise)

## Verification & Testing

### Framing Verification ✅
The framing implementation has been verified by:
- Printing bit streams before and after framing
- Substituting data sections to visualize frame structure
- Confirming presence of Barker codes at correct positions
- Verifying 87-bit metadata section
- Confirming 4096-bit total frame length

See "Framing" section in the design document for visual verification.

### QAM Constellation ✅
- Figure 1 shows received constellation with noise
- Figure 2 shows clean transmitted constellation with 16 distinct points

### Expected BER Performance
- **High SNR (30 dB)**: Very low BER (~10⁻⁶ or better)
- **Medium SNR (20 dB)**: Low BER (~10⁻⁴ to 10⁻⁵)
- **Low SNR (5 dB)**: Higher BER (~10⁻² to 10⁻³)

## Next Steps

### Priority 1: Complete FEC Chain
1. **Fix Channel Encoding**:
   - Implement proper Hamming (63,57) encoding
   - Handle matrix dimensions correctly (63 rows, 57→63 bits per row)
   - Total: 63×63 = 3969 encoded bits

2. **Fix Channel Decoding**:
   - Implement proper Hamming (63,57) decoding
   - Remove parity bits correctly
   - Error correction capability: 1 bit per codeword

3. **Implement Interleaving**:
   - Row-column interleaving (matrix transpose)
   - Place between encoding and framing
   - Corresponding deinterleaving after deframing

### Priority 2: Complete OFDM Chain
1. **Integrate OFDM Modulation**:
   - Place after QAM modulation
   - 1024 QAM symbols → 10 OFDM symbols (102.4 symbols/OFDM, round to 108 data carriers)
   - Add 6 pilot symbols per OFDM symbol

2. **Add Cyclic Prefix**:
   - 4-sample cyclic prefix per OFDM symbol
   - Total: (128 + 4) × 10 = 1320 samples per frame

3. **Integrate OFDM Demodulation**:
   - Remove cyclic prefix
   - FFT to recover frequency-domain symbols
   - Extract data carriers (ignore pilots, guard, DC)

### Priority 3: Advanced Features
1. **Pilot-Based Channel Estimation**:
   - Insert known pilot symbols at specified indices
   - Estimate channel response using pilots
   - Interpolate for data carriers
   - Implement MMSE or zero-forcing equalization

2. **Frame Synchronization**:
   - Correlate received signal with Barker codes
   - Detect frame boundaries
   - Handle timing offsets

3. **BER vs SNR Curves**:
   - Sweep SNR from 0 to 30 dB
   - Plot BER performance
   - Compare theoretical vs simulated BER

4. **Advanced Channel Models**:
   - Multipath fading (Rayleigh/Rician)
   - Frequency-selective fading
   - Doppler effects for mobile scenarios

## Known Issues

1. **Channel Encoding Functions**: 
   - `channel_encoding.m` and `channel_decoding.m` have incomplete implementations
   - Need to properly handle Hamming (63,57) format

2. **Signal Chain Disconnected**:
   - OFDM modulation/demodulation not in current signal path
   - Pulse shaping filter not integrated
   - Interleaving not implemented

3. **Equalization**:
   - Current implementation is placeholder
   - No channel estimation
   - No pilot processing

4. **Synchronization**:
   - Assumes perfect timing
   - No frame detection
   - Barker codes inserted but not used for correlation

## Notes

- Current implementation focuses on proving individual blocks work
- Frame structure successfully verified with visual inspection
- QAM constellation properly forms 16-point grid
- OFDM functions exist but need integration into signal path
- System assumes perfect synchronization (no timing/frequency offset)
- Pilot carriers defined but not yet utilized for channel estimation

## References

- Digital Communications by John G. Proakis
- Communication Systems Engineering by John G. Proakis & Masoud Salehi
- OFDM Wireless Communications by Ye (Geoffrey) Li
- MATLAB Communications Toolbox Documentation
- MATLAB OFDM Documentation: `ofdmmod`, `ofdmdemod`
- IEEE 802.11 Standards (for OFDM implementation examples)

## Design Document

For complete system specifications and verification results, see:
`ATEL_Digital_block_design_and_progress.pdf`
