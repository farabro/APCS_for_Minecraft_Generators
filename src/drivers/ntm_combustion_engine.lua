_G.tags.gen.ntm_combustion_engine = {
	data = {},
	elements = {},
}
_G.drivers.gen.ntm_combustion_engine = {}

function _G.drivers.gen.ntm_combustion_engine.get_data(element)
	local throttle
	
	-- Get gen data
	throttle,
		_G.tags.gen.ntm_combustion_engine.data[element].working,
		_,
		_,
		_G.tags.gen.ntm_combustion_engine.data[element].fluid,
		_G.tags.gen.ntm_combustion_engine.data[element].max_fluid,
		_G.tags.gen.ntm_combustion_engine.data[element].fluid_type
		
		= _G.tags.gen.ntm_combustion_engine.elements[element].getInfo()
	
	-- Parse data (if need)
	_G.tags.gen.ntm_combustion_engine.data[element].throttle = throttle*10//3
end

function _G.drivers.gen.ntm_combustion_engine.set_throttle(element, throttle)
	_G.tags.gen.ntm_combustion_engine.elements[element].setThrottle(throttle//10*3)
end

function _G.drivers.gen.ntm_combustion_engine.start(element)
	_G.tags.gen.ntm_combustion_engine.elements[element].start()
end


function _G.drivers.gen.ntm_combustion_engine.stop(element)
	_G.tags.gen.ntm_combustion_engine.elements[element].stop()
end

function _G.drivers.gen.ntm_combustion_engine.init()
	_G.tags.gen.ntm_combustion_engine.elements, _G.tags.gen.ntm_combustion_engine.data = _G.drivers_tools.get_components("ntm_combustion_engine", "gen")
end
