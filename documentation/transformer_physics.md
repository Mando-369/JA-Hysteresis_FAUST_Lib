# Transformer Physics Reference

## Core Formulas

### Primary Inductance (L1)
```
L1 = (μr × μ0 × N1² × A_core) / l_core
```
- `μ0` = 1.2566e-6 H/m (permeability of free space)
- `μr` = relative permeability (1000-10000 for audio transformers)
- `N1` = primary turns
- `A_core` = core cross-section area (m²)
- `l_core` = magnetic path length (m)

**Effect:** Higher L1 → better bass extension

### DC Resistance (R_dc)
```
R_dc = ρ × (N1 × mean_turn_length) / wire_area
```
- `ρ` = 1.68e-8 Ω·m (copper resistivity)
- `mean_turn_length` = π × bobbin_diameter
- `wire_area` = π × (wire_diameter/2)²

**Effect:** Higher R_dc → more warmth/coloration

### Leakage Inductance (L_leak)
```
L_leak = L1 × (1 - k)
```
- `k` = coupling factor (0.92-0.995)
- Tight interleaved windings → k ≈ 0.995
- Separated windings → k ≈ 0.92

**Effect:** Higher L_leak → HF roll-off, darker sound

### Quality Factor (Q)
```
Q = (ω × L1) / R_dc
```
- `ω` = 2π × frequency

**Effect:** Higher Q → sharper resonance peak

## Parameter Relationships

| Control | L1 | R_dc | L_leak | C_dist |
|---------|:--:|:----:|:------:|:------:|
| ↑ N1 (turns) | ↑↑ | ↑ | ↑↑ | ↑ |
| ↑ Core area | ↑ | — | ↑ | — |
| ↑ μr | ↑ | — | ↑ | — |
| ↓ Wire diameter | — | ↑ | — | ↓ |
| ↓ Coupling k | — | — | ↑ | — |

## Physical Units

| Parameter | Unit | Typical Range |
|-----------|------|---------------|
| L1 | Henries (H) | 10-2000 H |
| R_dc | Ohms (Ω) | 50-5000 Ω |
| L_leak | Henries (H) | 0.01-10 H |
| C_dist | Farads (F) | 10-500 pF |
| C_mutual | Farads (F) | 1-50 pF |

## Reference Designs

| Type | N1 | Core Area | μr | Result |
|------|:--:|:---------:|:--:|--------|
| Budget | 500 | 1.5 cm² | 2000 | Low L1, limited bass |
| Industry | 2000 | 4.5 cm² | 4000 | High L1, extended bass |
| A9J Vintage | 1800 | 3.8 cm² | 3000 | L1≈1400H, R_dc≈4100Ω |
