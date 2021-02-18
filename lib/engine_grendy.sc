Engine_Grendy : CroneEngine {
    var <synth;

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        synth = {
            arg out,
                pitch1 = 80, pitch2 = 120, shape1 = 0, shape2 = 0, slopLevel = 0, oscmix = 0,
                filterFreq = 500, filterRes = 3,
                lfoRate = 0.5, lfo2Rate = 8, lfo2Level = 1.0, lfoDepth = 500,
                panRate = 0.3, autoPan = 0, amp = 1;

            // oscillators
            var slop1 = Lag.ar(LFNoise0.ar(2) * slopLevel, 0.5);
            var slop2 = Lag.ar(LFNoise0.ar(2) * slopLevel, 0.5);

            var sq1 = Pulse.ar(pitch1 + slop1);
            var tri1 = Saw.ar(pitch1 + slop2);
            var osc1 = SelectX.ar(shape1, [sq1, tri1]);

            var sq2 = Pulse.ar(pitch2 + slop1);
            var tri2 = Saw.ar(pitch2 + slop2);
            var osc2 = SelectX.ar(shape2, [sq2, tri2]);

            // mixer
            var mix = LinXFade2.ar(osc1, osc2, oscmix);

            // lfo
            var lfo1 = Saw.kr(lfoRate, mul: 0.5, add: 0.5);
            var lfo2 = Pulse.kr(lfoRate * lfo2Rate);
            var lfo = Mix.kr([lfo1, (lfo2 * lfo2Level)]);

            // filter
            var filter = MoogFF.ar(mix, filterFreq + (lfo * lfoDepth), filterRes);

            // amplifier
            var panner = autoPan * (SinOsc.kr(panRate, mul: 0.2) + SinOsc.kr(panRate + 0.1, mul: 0.1));
            var final = Limiter.ar(filter * amp);
            
            Out.ar(out, Pan2.ar(final * amp, panner));
        }.play(args: [\out, context.out_b], target: context.xg);

        #[\pitch1, \pitch2, \oscmix, \slopLevel, \filterFreq, \filterRes, \lfoRate, \lfo2Level, \lfoDepth, \panRate, \autoPan, \amp].do({
            arg name;
            this.addCommand(name, "f", {
                arg msg;
                synth.set(name, msg[1]);
            });
        });
        
        #[\shape1, \shape2, \lfo2Rate].do({
            arg name;
            this.addCommand(name, "i", {
                arg msg;
                synth.set(name, msg[1]);
            });
        });
    }

    free {
        synth.free;
    }
}