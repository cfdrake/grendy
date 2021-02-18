-- ~ grendy 2 ~
-- a simple drone synth
-- by: @cfd90
--
-- grendel drone commander
-- inspired
--
-- KEY 2 prev page
-- KEY 3 next page
-- ENC 1/2/3 page params

local ez = include "lib/ezscript"

engine.name = "Grendy"

ez.pages = {
  { name = "oscillators",     e1 = "slop",   e2 = "pitch1",     e3 = "pitch2" },
  { name = "oscillators",     e1 = "oscmix", e2 = "shape1",     e3 = "shape2" },
  { name = "filter",          e1 = nil,      e2 = "filterFreq", e3 = "filterRes" },
  { name = "lfo",             e1 = nil,      e2 = "lfoRate",    e3 = "lfo2Rate"},
  { name = "lfo",             e1 = nil,      e2 = "lfo2Level",  e3 = "lfoDepth"},
  { name = "output",          e1 = "amp",    e2 = "panRate",    e3 = "autoPan" }
}

function init()
  params:add_group("GRENDY", 19)
  params:add_separator("oscillators")
  
  params:add_control("pitch1", "1 freq", controlspec.new(30, 500, 'exp', 0.01, 60, 'hz', 1/500))
  params:set_action("pitch1", function(x) engine.pitch1(x) end)
  
  params:add_option("shape1", "1 shape", {"square", "saw"}, 1)
  params:set_action("shape1", function(x) engine.shape1(x - 1) end)
  
  params:add_control("pitch2", "2 freq", controlspec.new(30, 500, 'exp', 0.01, 90, 'hz', 1/500))
  params:set_action("pitch2", function(x) engine.pitch2(x) end)
  
  params:add_option("shape2", "2 shape", {"square", "saw"}, 1)
  params:set_action("shape2", function(x) engine.shape2(x - 1) end)
  
  params:add_taper("oscmix", "* mix", 0, 1, 0.5, 0.1, "")
  params:set_action("oscmix", function(x) engine.oscmix((x * 2) - 1) end)
  
  params:add_control("slop", "* slop", controlspec.new(0, 1, 'lin', 0.01, 0.1, '', 0.01))
  params:set_action("slop", function(x) engine.slopLevel(x) end)
  
  params:add_separator("filter")
  
  params:add_control("filterFreq", "freq", controlspec.new(100, 8000, 'exp', 0.01, 300, '', 10/8000))
  params:set_action("filterFreq", function(x) engine.filterFreq(x) end)
  
  params:add_control("filterRes", "q", controlspec.new(1, 3, 'lin', 0.01, 2, ''))
  params:set_action("filterRes", function(x) engine.filterRes(x) end)
  
  params:add_separator("lfo")
  
  params:add_control("lfoRate", "1 rate", controlspec.new(0, 1, 'lin', 0.01, 0.1, '', 0.01))
  params:set_action("lfoRate", function(x) engine.lfoRate(x) end)
  
  local rates = {2, 4, 8, 16}
  params:add_option("lfo2Rate", "2 rate", rates, 1)
  params:set_action("lfo2Rate", function(x) engine.lfo2Rate(rates[x]) end)
  
  params:add_control("lfo2Level", "2 level", controlspec.new(0, 1, 'lin', 0.01, 0.5, '', 0.01))
  params:set_action("lfo2Level", function(x) engine.lfo2Level(x) end)
  
  params:add_control("lfoDepth", "* depth", controlspec.new(0, 500, 'lin', 0.01, 200, '', 0.01))
  params:set_action("lfoDepth", function(x) engine.lfoDepth(x) end)
  
  params:add_separator("output")
  
  params:add_taper("panRate", "pan rate", 0.1, 1, 0.1, 0.1, "")
  params:set_action("panRate", function(x) engine.panRate(x) end)
  
  params:add_taper("autoPan", "pan amt", 0.0, 1, 0, 0.1, "")
  params:set_action("autoPan", function(x) engine.autoPan(x) end)
  
  params:add_taper("amp", "volume", 0.0, 1, 1, 0.1, "")
  params:set_action("amp", function(x) engine.amp(x) end)

  params:read()
  params:bang()
end