_G.modules.physical = {}
_G.tags.physical = {
	keyboard = {
		keys = {
			[18] = "E",
			[19] = "R",
			[24] = "O",
			[46] = "C",
			[50] = "M",
		},
	},
}

function _G.modules.physical.process_keyboard_act(event)
	_G.set_state(
		_G.tags.physical.keyboard.keys[event[4]],
		event[5],
		_G.config.physical.users_can.set_state,
		_G.config.physical.users_can.reset_state,
		_G.config.physical.su
	)
end

function _G.modules.physical.init()
	_G.config.physical.su = set_value_for_every_element(_G.config.physical.su, true)
end
