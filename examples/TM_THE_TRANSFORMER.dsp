// =============================================================================
// THE TRANSFORMER - J-A Hysteresis with EQ Shaping
// =============================================================================
// Simplified model: Pre-EQ -> J-A Core -> Post-EQ (inverse)
// Drive frequencies harder into saturation, then compensate
// =============================================================================

import("stdfaust.lib");

declare name "THE-TRANSFORMER";
declare author "Thomas Mandolini";
declare version "9.3";

// Safe max frequency for filters (prevents NaN at low sample rates)
nyquist_safe = 0.49 * ma.SR;

// =============================================================================
// JILES-ATHERTON HYSTERESIS (4x cascaded substeps for transient accuracy)
// =============================================================================

ja_core(Ms, a, alpha, k, c) = ja_hysteresis
with {
    Ms_safe = max(Ms, 1e-6);
    a_norm = a / Ms_safe;
    k_norm = k / Ms_safe;
    inv_a_norm = 1.0 / max(a_norm, 1e-9);
    sigma = 1e-3;
    diff_scale = 3.0;

    // Single J-A substep: M_prev, H_prev, H_target -> M_new
    ja_substep(M_prev, H_prev, H_target) = M_new
    with {
        dH = H_target - H_prev;
        He = H_target + alpha * M_prev;

        x_man = He * inv_a_norm;
        Man_e = ma.tanh(x_man);
        Man_e2 = Man_e * Man_e;
        dMan_dH = (1.0 - Man_e2) * inv_a_norm;

        diff = Man_e - M_prev;
        diff_clamped = diff / (1.0 + abs(diff) * diff_scale);

        dir = ba.if(dH >= 0.0, 1.0, -1.0);
        pin = dir * k_norm - alpha * diff_clamped;
        inv_pin = 1.0 / (pin + sigma);

        denom = 1.0 - c * alpha * dMan_dH;
        inv_denom = 1.0 / (denom + 1e-9);
        dMdH = (c * dMan_dH + diff_clamped * inv_pin) * inv_denom;
        dM_step = dMdH * dH;

        M_unclamped = M_prev + dM_step;
        M_new = max(-1.0, min(1.0, M_unclamped));
    };

    // 4x cascaded substeps with cubic Hermite interpolation
    // Uses H history for smooth tangent-matched curve between samples
    ja_hysteresis(H_in) = (loop ~ (_, _, _)) : (_, !, !)
    with {
        loop(M_prev, H_prev, H_prev_prev) = M4, H_in, H_prev
        with {
            // Tangent estimation (Catmull-Rom style)
            dH_prev = H_prev - H_prev_prev;  // tangent at start
            dH_in = H_in - H_prev;           // tangent at end

            // Hermite cubic: p(t) = h00*p0 + h10*m0 + h01*p1 + h11*m1
            // Precomputed coefficients for t = 0.25, 0.5, 0.75
            H1 = 0.84375*H_prev + 0.140625*dH_prev + 0.15625*H_in - 0.046875*dH_in;
            H2 = 0.5*H_prev + 0.125*dH_prev + 0.5*H_in - 0.125*dH_in;
            H3 = 0.15625*H_prev + 0.046875*dH_prev + 0.84375*H_in - 0.140625*dH_in;
            H4 = H_in;

            // Cascaded substeps
            M1 = ja_substep(M_prev, H_prev, H1);
            M2 = ja_substep(M1, H1, H2);
            M3 = ja_substep(M2, H2, H3);
            M4 = ja_substep(M3, H3, H4);
        };
    };
};

// =============================================================================
// UI GROUPS
// =============================================================================

ui(x) = vgroup("[0]THE-TRANSFORMER", x);
top_row(x) = ui(hgroup("[1]EQ & CORE", x));
pre_eq_group(x) = top_row(hgroup("[0]Pre-EQ", x));
ja_group(x) = top_row(hgroup("[1]Core Material", x));
bottom_row(x) = ui(hgroup("[2]DEPTH & DRIVE", x));
dw_group(x) = bottom_row(hgroup("[0]Depth Warp", x));
drive_group(x) = bottom_row(hgroup("[1]Drive and Mix", x));

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

// =============================================================================
// DEPTH WARP (post-transformer saturation)
// =============================================================================

// Controls
dw_enable = dw_group(checkbox("[0]Enable"));
dw_drive = dw_group(vslider("[1]Drive dB", -4.5, -12, 24, 0.1)) : ba.db2linear;
dw_depth = dw_group(vslider("[2]Depth", 0.2, 0, 0.80, 0.01));
dw_focus = dw_group(vslider("[3]Focus", 0.44, 0.05, 0.60, 0.01));
dw_sharp = dw_group(vslider("[4]Sharpness", 0.2, 0, 1, 0.01));
dw_skew = dw_group(vslider("[5]Skew", 0.05, -0.5, 0.5, 0.01));
dw_mix = dw_group(vslider("[6]Mix", 1.0, 0, 1, 0.01));

// Core functions
dw_sinSoft(x) = sin((ma.PI/2.0) * x);

dw_centerWarp(x, a, c, sharp) = x * (1.0 - a * exp(-phi))
with {
    t = abs(x) / (c + 1e-9);
    t2 = t * t;
    t4 = t2 * t2;
    phi = (1.0 - sharp) * t2 + sharp * t4;
};

dw_skewIt(x, sk) = x + sk * x * x;

dw_core(x) = dw_sinSoft(ma.tanh(dw_skewIt(dw_centerWarp(ma.tanh(x * dw_drive), dw_depth, dw_focus, dw_sharp), dw_skew)));

// Processor with bypass and mix (auto-compensate for drive)
dw_comp = 1.0 / max(0.001, dw_drive);
dw_trim = ba.db2linear(-1.9);
dw_process = _ <: (dw_core * dw_comp * dw_trim * dw_mix), (_ * (1.0 - dw_mix)) :> _;
depth_warp = _ <: _, dw_process : select2(dw_enable);

// DC Blocker
dc_blocker = fi.SVFTPT.HP2(7.0, 0.7071);

// =============================================================================
// SIGNAL CHAIN
// =============================================================================

input_stage = _ * input_gain;

wet_chain = (_ * saturation_drive * ja_calibration)
          : pre_eq
          : ja_core(Ms, a_param, alpha_param, k_param, c_param)
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

transformer = input_stage : mix_stage : depth_warp : output_stage;

// =============================================================================
// STEREO PROCESSING
// =============================================================================

process = par(i, 2, transformer);
