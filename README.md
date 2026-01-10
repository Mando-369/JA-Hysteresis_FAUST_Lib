# hysteresis.lib

Magnetic hysteresis library for GRAME Faust. Official prefix: `hy`

## What is Jiles-Atherton Hysteresis?

The Jiles-Atherton (J-A) model is a physics-based description of ferromagnetic hysteresis. It models how magnetic materials "remember" their magnetization history, producing the characteristic nonlinear behavior found in transformers, tape machines, and inductors.

Unlike simple waveshapers (tanh, soft-clip), J-A hysteresis is **state-dependent** - the output depends not just on the current input but on the magnetic history. This creates:
- Asymmetric saturation curves
- Different behavior for rising vs falling signals
- Frequency-dependent harmonic content
- Subtle compression and "iron" coloration

## Parameters

| Parameter | Description | Effect |
|-----------|-------------|--------|
| `Ms` | Saturation magnetization | Maximum output level |
| `a` | Anhysteretic shape | Controls curve steepness |
| `k` | Coercivity | Hysteresis loop width |
| `alpha` | Mean-field coupling | Domain interaction strength |
| `c` | Reversibility | Ratio of reversible magnetization |

## Capabilities

- Physics-based magnetic saturation with memory
- 4x oversampled substeps with Hermite interpolation for transient accuracy
- Smooth, alias-free nonlinear processing
- Suitable for transformer, tape, and inductor emulation
- Real-time capable

## Limitations

- **Not a complete transformer model** - no inductance, capacitance, or frequency response shaping (use external EQ)
- **Simplified physics** - uses tanh approximation for Langevin function
- **Single-rate** - no bias oscillator (for tape bias, see dedicated tape libraries)
- **Parameter ranges tuned for audio** - not scientifically calibrated to specific materials

## Usage

```faust
import("stdfaust.lib");
hy = library("hysteresis.lib");

// Stereo processor with UI
process = hy.ja_processor_stereo_ui;

// Core function only
process = _ : hy.ja_hysteresis(380, 720, 0.015, 380, 0.25) : _;
```

## Functions

| Function | Description |
|----------|-------------|
| `hy.ja_hysteresis(Ms,a,alpha,k,c)` | Core hysteresis, no gain staging |
| `hy.ja_processor(Ms,a,alpha,k,c,drive,trim)` | With drive, normalization, DC block |
| `hy.ja_processor_stereo(...)` | Stereo version |
| `hy.ja_processor_ui` | Mono with UI controls |
| `hy.ja_processor_stereo_ui` | Stereo with UI controls |

## References

- Jiles, D.C. & Atherton, D.L. (1986). "Theory of ferromagnetic hysteresis." *Journal of Magnetism and Magnetic Materials*, 61(1-2), 48-60.
- [Wikipedia: Jiles-Atherton Model](https://en.wikipedia.org/wiki/Jiles-Atherton_model)

## License

LGPL-2.1 with FAUST exception (see hysteresis.lib header)

## Author

Thomas Mandolini
