// CroneEngine_Grendy
// SuperCollider engine for grendy

Engine_Grendy : CroneEngine {
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
	  // Setup synth variable
		synth = {
			arg out,
			  freq1 = 220, shape1 = 1,
			  freq2 = 220, shape2 = 1,
			  mix = 0,
			  ffreq = 440, fres = 1,
			  lfreq = 1, ldepth = 100, lshape = -1, cspeed = 1, cwidth = 0.2,
			  amp = 1;
			
			// OSC1: Tri/Pulse crossfaded
			var osc1 = XFade2.ar(LFTri.ar(freq1), Pulse.ar(freq1), shape1);
			
			// OSC2: Tri/Pulse crossfaded
			var osc2 = XFade2.ar(LFTri.ar(freq2), Pulse.ar(freq2), shape2);
			
			// MIXER: OSC1/OSC2 crossfaded
			var osc = XFade2.ar(osc1, osc2, mix);
			
			// LFO: Ramp/Click crossfaded
			// Changes from GDC:
			// - Pulse is not at same position of LFO cycle, undecided if this is worth investigating, it sounds nice as-is
			// - Does not have "inverted" LFO shape
			// - Adds ability to control pulse width of click signal
			// - Adds ability to additional click divisions other than 2/4/8/16 for more interesting rhythms
			var sr = SampleRate.ir;
			
	    var ramp = Phasor.ar(0, lfreq / sr, 0, 1);
	    var click = Pulse.ar(lfreq * cspeed, cwidth);
	    
	    var lfo = XFade2.ar(ramp, click, lshape);
	
			// FILTER: input from OSC
			var filter = MoogFF.ar(osc, ffreq + (lfo * ldepth), fres);
			
			// AMP: input from FILTER
			var final = filter * amp;
			
			// OUTPUT stage
			Out.ar(out, (final).dup);
		}.play(args: [\out, context.out_b], target: context.xg);

    // Setup Norns commands
		this.addCommand("freq1", "f", { arg msg;
			synth.set(\freq1, msg[1]);
		});
		
		this.addCommand("shape1", "f", { arg msg;
			synth.set(\shape1, msg[1]);
		});
		
		this.addCommand("freq2", "f", { arg msg;
			synth.set(\freq2, msg[1]);
		});
		
		this.addCommand("shape2", "f", { arg msg;
			synth.set(\shape2, msg[1]);
		});
		
		this.addCommand("mix", "f", { arg msg;
			synth.set(\mix, msg[1]);
		});
		
		this.addCommand("ffreq", "f", { arg msg;
			synth.set(\ffreq, msg[1]);
		});
		
		this.addCommand("fres", "f", { arg msg;
			synth.set(\fres, msg[1]);
		});
		
		this.addCommand("lfreq", "f", { arg msg;
			synth.set(\lfreq, msg[1]);
		});
		
		this.addCommand("ldepth", "f", { arg msg;
			synth.set(\ldepth, msg[1]);
		});
		
		this.addCommand("lshape", "f", { arg msg;
			synth.set(\lshape, msg[1]);
		});
		
		this.addCommand("cspeed", "f", { arg msg;
			synth.set(\cspeed, msg[1]);
		});
		
		this.addCommand("cwidth", "f", { arg msg;
			synth.set(\cwidth, msg[1]);
		});
		
		this.addCommand("amp", "f", { arg msg;
			synth.set(\amp, msg[1]);
		});
	}

	free {
		synth.free;
	}
}
