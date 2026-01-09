// =============================================================================
// TRANSFORMER - J-A Hysteresis with EQ Shaping
// =============================================================================
// Simplified model: Pre-EQ -> J-A Core -> Post-EQ (inverse)
// Drive frequencies harder into saturation, then compensate
// =============================================================================

import("stdfaust.lib");
ja = library("jahysteresis.lib");

declare name "Transformer";
declare author "Thomas Mandolini";
declare version "1.0";

// =============================================================================
// UI GROUPS
// =============================================================================

ui(x) = vgroup("[0]TRANSFORMER", x);
top_row(x) = ui(hgroup("[1]EQ & CORE", x));
pre_eq_group(x) = top_row(hgroup("[0]Pre-EQ", x));
ja_group(x) = top_row(hgroup("[1]Core Material", x));
drive_group(x) = ui(hgroup("[2]Drive and Mix", x));

// =============================================================================
// PRE-EQ CONTROLS
// =============================================================================

// Low Shelf
ls_freq = pre_eq_group(vslider("[0]LS Freq", 80, 20, 400, 1));
ls_gain = pre_eq_group(vslider("[1]LS Gain dB", 0, -12, 12, 0.1));

// Mid Bell
mid_freq = pre_eq_group(vslider("[2]Mid Freq", 1500, 200, 8000, 10));
mid_q = pre_eq_group(vslider("[3]Mid Q", 0.38, 0.3, 3.0, 0.01));
mid_gain = pre_eq_group(vslider("[4]Mid Gain dB", 0, -12, 12, 0.1));

// High Shelf
hs_freq = pre_eq_group(vslider("[5]HS Freq", 12000, 2000, 20000, 100));
hs_gain = pre_eq_group(vslider("[6]HS Gain dB", 0, -12, 12, 0.1));

// EQ Scale
eq_scale = pre_eq_group(vslider("[7]EQ Scale %", 100, 0, 200, 1)) / 100.0;

// =============================================================================
// J-A CORE CONTROLS
// =============================================================================

a_param = ja_group(vslider("[0]Anhysteretic a", 720, 100, 2000, 1));
k_param = ja_group(vslider("[1]Coercivity k", 380, 50, 1000, 1));
alpha_param = ja_group(vslider("[2]Alpha coupling", 0.015, 0.001, 0.1, 0.001));
c_param = ja_group(vslider("[3]Reversibility c", 0.25, 0.0, 1.0, 0.01));

// =============================================================================
// DRIVE AND MIX CONTROLS
// =============================================================================

input_gain = drive_group(vslider("[0]Input Gain dB", 0, -20, 20, 0.1)) : ba.db2linear;
ja_calibration = drive_group(vslider("[1]JA Calibration dB", -50, -60, 60, 0.1)) : ba.db2linear;
saturation_drive = drive_group(vslider("[2]Drive", 0, -50, 50, 0.1)) : ba.db2linear : si.smoo;
Ms = drive_group(vslider("[3]Saturation", 380, 100, 1000, 1)) : si.smoo;
drive_comp = 1.0 / max(0.001, saturation_drive);

// Small-signal normalization: J-A gain ≈ c * Ms / a, normalize by inverse
ja_norm = a_param / max(0.01, c_param * Ms);
ja_trim = drive_group(vslider("[4]Output Trim dB", 0, -20, 20, 0.1)) : ba.db2linear;

inverse_amt = drive_group(vslider("[5]Inverse EQ %", 100, 0, 100, 1)) / 100.0;
mix = drive_group(vslider("[6]Wet/Dry Mix", 100, 0, 100, 1)) / 100.0;
output_gain = drive_group(vslider("[7]Output Gain dB", 0, -20, 20, 0.1)) : ba.db2linear;

// =============================================================================
// EQ PROCESSORS
// =============================================================================

// Scaled gains for pre-EQ (dB * scale)
ls_gain_scaled = ls_gain * eq_scale;
mid_gain_scaled = mid_gain * eq_scale;
hs_gain_scaled = hs_gain * eq_scale;

// Inverse gains for post-EQ (negative of scaled, then by inverse amount)
ls_gain_inv = -ls_gain_scaled * inverse_amt;
mid_gain_inv = -mid_gain_scaled * inverse_amt;
hs_gain_inv = -hs_gain_scaled * inverse_amt;

// Pre-EQ chain (SVF filters - all take dB gains)
pre_eq = fi.svf.ls(ls_freq, 0.707, ls_gain_scaled)
       : fi.svf.bell(mid_freq, mid_q, mid_gain_scaled)
       : fi.svf.hs(hs_freq, 0.707, hs_gain_scaled);

// Post-EQ chain (inverse)
post_eq = fi.svf.ls(ls_freq, 0.707, ls_gain_inv)
        : fi.svf.bell(mid_freq, mid_q, mid_gain_inv)
        : fi.svf.hs(hs_freq, 0.707, hs_gain_inv);

// DC Blocker
dc_blocker = fi.SVFTPT.HP2(7.0, 0.7071);

// =============================================================================
// SIGNAL CHAIN
// =============================================================================

input_stage = _ * input_gain;

wet_chain = (_ * saturation_drive * ja_calibration)
          : pre_eq
          : ja.hysteresis(Ms, a_param, alpha_param, k_param, c_param)
          : (_ * ja_norm)
          : dc_blocker
          : post_eq
          : (_ * ja_trim * drive_comp / ja_calibration);

dry_chain = _;

mix_stage = _ <: (wet_chain : _ * mix), (dry_chain : _ * (1.0 - mix)) :> _;

output_stage = _ * output_gain;

// =============================================================================
// COMPLETE TRANSFORMER
// =============================================================================

transformer = input_stage : mix_stage : output_stage;

// =============================================================================
// STEREO PROCESSING
// =============================================================================

process = par(i, 2, transformer);
