-- ~~ grendy ~~
-- a simple drone synth
-- grendel drone commander inspired
-- v1.1.0 @cfd90
--
-- KEY2: randomize OSC/MIXER
-- KEY3: randomize FILTER/LFO
--
-- ENC1: FILTER freq
-- ENC2: OSC1 freq
-- ENC3: OSC2 freq
-- ENC4: AMP
--
-- KEY1+ENC1: FILTER res
-- KEY1+ENC2: LFO freq
-- KEY1+ENC3: LFO depth
--
-- Further tweak parameters via [EDIT] page
--
-- MIDI input round-robin sets OSC1 and OSC2 freq

music = require 'musicutil'

engine.name = "Grendy"

local viewport = {
  width = 128,
  height = 64
}

------
------ STATE
------

local shift = false
local midiFirstOsc = true

------
------ INITIALIZATION
------

function init()
  print("unleashing grendy...")
  setup_params()
  setup_midi()
end

function setup_params()
  -- OSC1
  params:add_separator()
  params:add_control("freq1", "osc1 freq", controlspec.new(20, 720, 'exp', 0.5, 220, 'hz'))
  params:set_action("freq1", function(x) engine.freq1(x) end)
  
  params:add_control("shape1", "osc1 shape [tri → sqr]", controlspec.new(-1, 1, 'lin', 0.01, 1, ''))
  params:set_action("shape1", function(x) engine.shape1(x) end)
  
  -- OSC2
  params:add_separator()
  params:add_control("freq2", "osc2 freq", controlspec.new(20, 720, 'exp', 0.5, 220, 'hz'))
  params:set_action("freq2", function(x) engine.freq2(x) end)
  
  params:add_control("shape2", "osc2 shape [tri → sqr]", controlspec.new(-1, 1, 'lin', 0.01, 1, ''))
  params:set_action("shape2", function(x) engine.shape2(x) end)
  
  -- MIXER
  params:add_separator()
  params:add_control("mix", "osc mix [osc1 → osc2]", controlspec.new(-1, 1, 'lin', 0.1, 0, ''))
  params:set_action("mix", function(x) engine.mix(x) end)
  
  -- FILTER
  params:add_separator()
  params:add_control("ffreq", "filter frequency", controlspec.new(20, 2000, 'exp', 0.5, 440, 'hz'))
  params:set_action("ffreq", function(x) engine.ffreq(x) end)
  
  params:add_control("fres", "filter res", controlspec.new(0, 4, 'lin', 0.1, 1, ''))
  params:set_action("fres", function(x) engine.fres(x) end)
  
  -- LFO
  params:add_separator()
  params:add_control("lfreq", "lfo frequency", controlspec.new(0.1, 20, 'lin', 0.1, 0.1, 'hz'))
  params:set_action("lfreq", function(x) engine.lfreq(x) end)
  
  params:add_control("cspeed", "lfo click rate", controlspec.new(1, 16, 'lin', 1, 1, 'x'))
  params:set_action("cspeed", function(x) engine.cspeed(x) end)
  
  params:add_control("cwidth", "lfo click width", controlspec.new(0.1, 0.9, 'lin', 0.1, 0.2, ''))
  params:set_action("cwidth", function(x) engine.cwidth(x) end)
  
  params:add_control("lshape", "lfo shape [ramp → click]", controlspec.new(-1, 1, 'lin', 0.1, -1, ''))
  params:set_action("lshape", function(x) engine.lshape(x) end)
  
  params:add_control("ldepth", "lfo depth", controlspec.new(0, 1000, 'lin', 0.1, 0, ''))
  params:set_action("ldepth", function(x) engine.ldepth(x) end)

  -- AMP
  params:add_separator()
  params:add_control("amp", "amp", controlspec.new(0, 1, 'lin', 0.01, 1, ''))
  params:set_action("amp", function(x) engine.amp(x) end)
end

function setup_midi()
  m = midi.connect()

  m.event = function(data)
    local d = midi.to_msg(data)
    
    if d.type == "note_on" then
      -- Round-robin set OSC1 and OSC2
      hz = music.note_num_to_freq(d.note)

      if midiFirstOsc then
        params:set("freq1", hz)
      else
        params:set("freq2",  hz)
      end
      
      -- set AMP with note velocity
      params:set("amp", d.vel / 127)

      midiFirstOsc = not midiFirstOsc
    end

    redraw()
  end
end

------
------ INPUT
------

function key(n, z)
  -- Shift key
  if n == 1 then
    if z > 0 then
      shift = true
    else
      shift = false
    end
    
    redraw()
  end
  
  -- Parameter randomization
  if n == 2 and z == 1 then
    randomize_osc()
  elseif n == 3 and z == 1 then
    randomize_filter()
  end

  redraw()
end

function enc(n, d)
  if shift then
    -- SHIFT mode
    -- Control filter res, LFO freq, LFO depth
    if n == 1 then
      params:delta("fres", d)
    elseif n == 2 then
      params:delta("lfreq", d)
    elseif n == 3 then
      params:delta("ldepth", d)
    end
  else
    -- REGULAR mode
    -- Control filter freq, OSC1 freq, OSC2 freq
    if n == 1 then
      params:delta("ffreq", d)
    elseif n == 2 then
      params:delta("freq1", d)
    elseif n == 3 then
      params:delta("freq2", d)
    end
  end

  if (#norns.encoders.accel == 4) then
    if n == 4 then
      params:delta("amp", d)
    end
  end
  
  redraw()
end

------
------ DRAWING
------

function redraw()
  screen.clear()

  -- Encoder documentation
  if shift then
    screen.move(0, 10)
    screen.level(2)
    screen.text("[E1] ")
    screen.level(10)
    screen.move(viewport.width * .2, 10)
    screen.text("filter res")
    screen.move(viewport.width * .7, 10)
    screen.text(params:get("fres"))

    screen.move(0, 18)
    screen.level(2)
    screen.text("[E2] ")
    screen.level(10)
    screen.move(viewport.width * .2, 18)
    screen.text("lfo freq")
    screen.move(viewport.width * .7, 18)
    screen.text(params:get("lfreq") .. " hz")

    screen.move(0, 26)
    screen.level(2)
    screen.text("[E3] ")
    screen.level(10)
    screen.move(viewport.width * .2, 26)
    screen.text("lfo depth")
    screen.move(viewport.width * .7, 26)
    screen.text(params:get("ldepth"))
  else
    screen.move(0, 10)
    screen.level(2)
    screen.text("[E1] ")
    screen.level(10)
    screen.move(viewport.width * .2, 10)
    screen.text("filter freq")
    screen.move(viewport.width * .7, 10)
    screen.text(params:get("ffreq") .. " hz")

    screen.move(0, 18)
    screen.level(2)
    screen.text("[E2] ")
    screen.level(10)
    screen.move(viewport.width * .2, 18)
    screen.text("osc1 freq")
    screen.move(viewport.width * .7, 18)
    screen.text(params:get("freq1") .. " hz")

    screen.move(0, 26)
    screen.level(2)
    screen.text("[E3] ")
    screen.level(10)
    screen.move(viewport.width * .2, 26)
    screen.text("osc2 freq")
    screen.move(viewport.width * .7, 26)
    screen.text(params:get("freq2") .. " hz")
  end
  
  screen.move(0, 34)
  screen.level(2)
  if (#norns.encoders.accel == 4) then
    screen.text("[E4] ")
  end
  screen.level(10)
  screen.move(viewport.width * .2, 34)
  screen.text("amp")
  screen.move(viewport.width * .7, 34)
  screen.text(params:get("amp"))

  -- Key documentation
  if not shift then
    screen.move(0, 44)
    screen.level(2)
    screen.text("[K1] ")
    screen.level(10)
    screen.move(viewport.width * .2, 44)
    screen.text("hold, toggle page 2")
  else
    screen.move(viewport.width * .5, 44)
    screen.level(2)
    screen.text_center("see params page for more")
  end
  
  screen.move(0, 52)
  screen.level(2)
  screen.text("[K2] ")
  screen.level(10)
  screen.move(viewport.width * .2, 52)
  screen.text("randomize OSC/MIXER")
  
  screen.move(0, 60)
  screen.level(2)
  screen.text("[K3] ")
  screen.level(10)
  screen.move(viewport.width * .2, 60)
  screen.text("randomize FILTER/LFO")
  
  screen.update()
end

------
------ HELPERS
------

function randomize_osc()
  params:set("freq1", 20 + (math.random() * (720 - 20)))
  params:set("shape1", (math.random() * 2) - 1)
  params:set("freq2", 20 + (math.random() * (720 - 20)))
  params:set("shape2", (math.random() * 2) - 1)
  params:set("mix", (math.random() * 2) - 1)
end

function randomize_filter()
  params:set("ffreq", 20 + (math.random() * (2000 - 20)))
  params:set("fres", math.random() * 3.5)  -- Don't go to 4, don't want to blast the user's ear with self-oscillation...
  params:set("cspeed", 1 + (math.random() * (16 - 1)))
  params:set("cwidth", 0.1 + (math.random() * (1 - 0.1)))
  params:set("lshape", (math.random() * 2) - 1)
  params:set("ldepth", math.random() * 1000)
end

