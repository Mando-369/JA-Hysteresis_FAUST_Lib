# Jiles-Atherton Hysteresis Model

## Overview
The Jiles-Atherton model simulates magnetic hysteresis in ferromagnetic materials. Unlike simple waveshapers (tanh, soft clip), it captures:
- Saturation with memory
- Hysteresis loops (different path up vs down)
- Level-dependent harmonic content
- Transient response characteristics

## Parameters

| Parameter | Symbol | Range | Effect |
|-----------|:------:|-------|--------|
| Saturation Magnetization | Ms | 200-800 kA/m | Lower = easier saturation |
| Anhysteretic Shape | a | 50-200 kA/m | Higher = softer knee |
| Coercivity | k | 20-100 kA/m | Loop width, affects harmonics |
| Mean Field Coupling | α | 0.5-3 × 10⁻³ | Domain coupling, transient response |
| Susceptibility | c | 0.05-0.5 | Reversibility, affects compression |

## Core Equations

### Langevin Function
```
L(x) = coth(x) - 1/x
```
Describes the ideal (anhysteretic) magnetization curve.

For small x: `L(x) ≈ x/3`

### Anhysteretic Magnetization
```
Man = Ms × L((H + α×M) / a)
```
The magnetization curve without hysteresis.

### Differential Equation
```
dM/dH = [(1-c) × δ × (Man-M) + c × dMan/dH] / [δ×k - α×(Man-M)]
```
Where:
- `δ` = sign of dH/dt (direction of field change)
- `H` = magnetic field strength
- `M` = magnetization

## Implementation Notes

### Numerical Stability
- Use `max(epsilon, denominator)` to avoid division by zero
- Clamp Langevin input for small values: `|x| < 0.0001` → use `x/3`
- Watch for denormals at very low signal levels

### DSP Integration
1. Input signal → scale to effective H field
2. Integrate dM/dH using sample-by-sample update
3. Output M represents magnetization (the saturated/hysteretic signal)

### Typical Starting Values (audio)
```
Ms = 350 kA/m
a = 120 kA/m
k = 60 kA/m
α = 1.5 × 10⁻³
c = 0.15
```

## Tuning Guide

| Want | Adjust |
|------|--------|
| Earlier saturation | ↓ Ms |
| Softer knee | ↑ a |
| More harmonics | ↑ k |
| Faster transients | ↑ α |
| More compression | ↓ c |
