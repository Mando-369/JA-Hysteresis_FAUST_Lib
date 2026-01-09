## Jiles-Atherton Hysteresis Library for GRAME Faust

### Project Goal
Create a physics-based magnetic hysteresis library (`jahysteresis.lib`) for GRAME Faust following official contribution guidelines.

### Library Info
- **Name**: `jahysteresis.lib`
- **Prefix**: `ja`
- **Version**: 1.0.0

### Files
| File | Description |
|------|-------------|
| `jahysteresis.lib` | Main library file |
| `transformer.dsp` | Example using `ja.processor_stereo_ui` |

### Library Functions

#### Core
- `ja.hysteresis(Ms, a, alpha, k, c)` - Core hysteresis with 4x substeps

#### Processors
- `ja.processor(Ms, a, alpha, k, c, drive, trim)` - Mono with gain staging
- `ja.processor_stereo(...)` - Stereo version

#### UI Wrappers
- `ja.processor_ui` - Mono with full UI
- `ja.processor_stereo_ui` - Stereo with full UI

### J-A Parameters

| Param | Name | Range | Default | Effect |
|-------|------|-------|---------|--------|
| `Ms` | Saturation | 100-1000 | 380 | Max magnetization |
| `a` | Anhysteretic | 100-2000 | 720 | Curve shape |
| `k` | Coercivity | 50-1000 | 380 | Loop width |
| `alpha` | Coupling | 0.001-0.1 | 0.015 | Feedback |
| `c` | Reversibility | 0-1 | 0.25 | Irreversible ratio |

### Usage
```faust
import("stdfaust.lib");
ja = library("jahysteresis.lib");

// Stereo processor with UI
process = ja.processor_stereo_ui;

// Custom parameters
process = ja.processor(380, 720, 0.015, 380, 0.25, ba.db2linear(10), 1);
```

### Testing
```bash
# Compile test
faust transformer.dsp

# Function test
faust -pn hysteresis_test jahysteresis.lib

# Build plugin
faust2juce transformer.dsp
```

### Progress Reports
- Session reports go in `progress/NNNN_YYYY_MM_DD_report.md`
- Create new report for bug fixes and changes

### Reference
- GRAME contribution guide: `documentation/Contributing - Faust Libraries.pdf`
- Template: `examples/compressors.lib`
