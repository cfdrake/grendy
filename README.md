# grendy

a simple drone synth, grendel drone commander inspired

## Installation

[Download latest release](https://github.com/cfdrake/grendy/archive/master.zip) and copy into `~/dust/code`.

Or use Git:
```
<ssh into your Norns>
$ cd ~/dust/code
$ git clone git@github.com:cfdrake/grendy.git
```

Note that after installing you must `SYSTEM => RESET` your Norns before running this script, as it includes a new SuperCollider engine.

## Norns Script

The following controls are available for `grendy`:

- Key 2 randomizes OSC/MIXER section
- Key 3 randomizes FILTER/LFO section
- Enc 1, Enc 2, and Enc 3 controls filter frequency and oscillator frequencies
- Holding Key 1 + Enc 1, Enc 2, and Enc 3 controls filter resonance and LFO frequency/depth

Tweak more parameters from the `[PARAMETERS] => [EDIT]` page.

MIDI note input will round-robin set OSC1 and OSC2 frequency.

## Synth Architecture

- OSC: two oscillators, each crossfaded between square and triangle shapes
- MIXER: balance control between OSC1 and OSC2
- FILTER: Moog-modeled filter with cutoff and resonance control
- LFO: saw and click shapes, crossfaded, affecting filter cutoff with depth control
  - SAW: frequency control
  - CLICK: rate control (N times SAW frequency), pulse width control
- AMP: final volume control

## SuperCollider Engine

This script makes a new SuperCollider engine available, `Grendy`. Please see `lib/engine_grendy.sc` for the latest parameter definitions.
