# Faust Quick Reference

## Syntax Used in This Project

### Operators
| Operator | Meaning | Example |
|----------|---------|---------|
| `:` | Sequential composition | `a : b` (output of a → input of b) |
| `,` | Parallel composition | `a , b` (a and b side by side) |
| `<:` | Split | `_ <: a, b` (one input to multiple) |
| `:>` | Merge | `a, b :> _` (multiple to one, summed) |
| `~` | Feedback | `f ~ g` (output of f fed back through g) |
| `'` | Unit delay | `x'` (previous sample of x) |

### Core Patterns

**Feedback loop:**
```faust
process = loop ~ _
with {
    loop(prev) = new_value;
};
```

**Parallel stereo:**
```faust
process = par(i, 2, mono_processor);
```

**Conditional select:**
```faust
select2(condition, if_false, if_true)
```

### UI Elements

**Horizontal slider:**
```faust
hslider("label", default, min, max, step)
```

**Vertical slider:**
```faust
vslider("label", default, min, max, step)
```

**Menu:**
```faust
nentry("label [style:menu{'Option1':0;'Option2':1}]", default, min, max, step)
```

**Grouping:**
```faust
group = "v:[0]GROUP NAME";  // vertical group, order 0
hslider("%group/[0]Parameter", ...)
```

### stdfaust.lib Functions Used

| Function | Library | Purpose |
|----------|---------|---------|
| `fi.highpass(order, fc)` | filters | High-pass filter |
| `fi.lowpass(order, fc)` | filters | Low-pass filter |
| `fi.resonbp(fc, Q, gain)` | filters | Resonant bandpass |
| `fi.dcblocker` | filters | Remove DC offset |
| `ba.db2linear(db)` | basics | dB to linear gain |
| `ma.PI` | maths | π constant |
| `ma.SR` | maths | Sample rate |

### Common Idioms

**Safe division:**
```faust
result = numerator / max(epsilon, denominator);
```

**Clamped range:**
```faust
value_clamped = max(min_val, min(max_val, value));
```

**With block for local definitions:**
```faust
function(x) = output
with {
    intermediate = x * 2;
    output = intermediate + 1;
};
```
