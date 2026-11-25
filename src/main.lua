-- Pre-Cycle Actions

-- Var
local mode
local ok
local result
local elements_count
local all_storage
local all_max_storage
local all_storage_for_gen
local all_max_storage_for_gen
local disactivated_state
local event = {}
local gens_in_E_state = {}
local gens_in_M_state = {}

-- Func

function _G.stop_all_gens()
	log.buffer.add({2, "Send signal to stop all gens"})
	for gen_driver in pairs(_G.drivers.gen) do
		local elements_count = #_G.tags.gen[gen_driver].elements
		for gen_index = 1, elements_count do
			_G.drivers.gen[gen_driver].set_throttle(gen_index, 0)
			_G.drivers.gen[gen_driver].stop(gen_index)
			_G.tags.gen[gen_driver].data[gen_index].state = "S"
		end
	end
	log.buffer.add({2, "Stop signal has been sended to all gens"})
end

function _G.stop_gen(gen_driver, gen_index) 
	local ok = pcall(_G.drivers.gen[gen_driver].stop, gen_index)
	if ok then
		_G.tags.gen[gen_driver].data[gen_index].state = "S"
		log.buffer.add({1, "Stop signal has been sended to generator (" .. gen_driver .. ") #" .. tostring(gen_index)})
	else
		log.buffer.add({5, "Stop signal hasn't been sended to generator (" .. gen_driver .. ") #" .. tostring(gen_index)})
	end
end

function _G.start_gen(gen_driver, gen_index)
	local ok = pcall(_G.drivers.gen[gen_driver].start, gen_index)
	if ok then
		_G.tags.gen[gen_driver].data[gen_index].state = "W"
		log.buffer.add({1, "Start signal has been sended to generator (" .. gen_driver .. ") #" .. tostring(gen_index)})
	else
		log.buffer.add({5, "Start signal hasn't been sended to generator (" .. gen_driver .. ") #" .. tostring(gen_index)})
	end
end

function _G.check_perms(doing, user, perm_table, su_table)
	if su_table[user] then
		return true
	else
		return perm_table[doing]
	end
end

function _G.reset_gen_state(gen_driver, gen_index)
	if _G.tags.gen[gen_driver].data[gen_index].working == true then
		_G.tags.gen[gen_driver].data[gen_index].state = "W"
	elseif _G.tags.gen[gen_driver].data[gen_index].working == false then
		_G.tags.gen[gen_driver].data[gen_index].state = "S"
	end
end

function _G.set_state(state, user, perm_table, perm_reset_table, su_table)
	if _G.tags.state ~= "E" then
		if state == "E" and _G.check_perms("E", user, perm_table, su_table) then
			_G.tags.state = "E"
			log.buffer.add({4, "Emergency mode has been activated by " .. user})
			_G.stop_all_gens()
			computer.beep(500)
		elseif state == "M" and _G.tags.state ~= "M" and _G.check_perms("M", user, perm_table, su_table) then
			_G.tags.state = "M"
			log.buffer.add({4, "Manual mode has been activated by " .. user})
			computer.beep(1000)
		elseif state == "C" and _G.check_perms("C", user, perm_table, su_table) then
			log.buffer.add({4, "Shutdown has been activated by " .. user})
			_G.stop_all_gens()
			computer.beep(1000, 0.2)
			computer.shutdown()
		elseif state == "R" and _G.check_perms("R", user, perm_table, su_table) then
			log.buffer.add({4, "Reboot has been activated by " .. user})
			_G.stop_all_gens()
			computer.beep(2000, 0.5)
			computer.shutdown(true)
		end
	end
	if state == "O" and _G.check_perms(_G.tags.state, user, perm_reset_table, su_table) then
		disactivated_state = _G.tags.state
		if disactivated_state == "O" then
			if _G.check_perms("E", user, perm_reset_table, su_table) then
				for gen in pairs(gens_in_E_state) do
					_G.reset_gen_state(gen[1], gen[2])
				end
				gens_in_E_state = {}
			end
			
			if _G.check_perms("M", user, perm_reset_table, su_table) then
				for gen in pairs(gens_in_M_state) do
					_G.reset_gen_state(gen[1], gen[2])
				end
				gens_in_M_state = {}
			end
			
			disactivated_state = "Individial Generators"
		else 
			_G.tags.state = "O"
		end
		log.buffer.add({4, disactivated_state .. " State has been disactivated by " .. user})
		disactivated_state = nil
		computer.beep(1500)
	end
end

-- Main Cycle

local ok_main, result_main = pcall(function()
	local start_cycle_time = computer.uptime()
	local time_now
	local time_sleep = _G.config.time_sleep
	while true do
		if event.n then
			if event[1] == "key_up" then
				_G.modules.physical.process_keyboard_act(event)
			elseif event[1] == "modem_message" then
				_G.modules.remote.process_message(event)
			end
		end
		
		time_now = computer.uptime()
		time_elpased = time_now - start_cycle_time
		if time_elpased >= time_sleep then
			start_cycle_time = time_now
			
			
			if _G.config.mode == 1 then
				all_storage = {}
				all_max_storage = {}
				for FS_driver in pairs(_G.drivers.FS) do
					FS_count = #_G.tags.FS[FS_driver].elements
					if FS_count > 0 then
						for FS_index = 1, FS_count do
							_G.drivers.FS[FS_driver].get_data(FS_index)
							all_max_storage[_G.tags.FS[FS_driver].data[FS_index].fluid_type] = all_max_storage[_G.tags.FS[FS_driver].data[FS_index].fluid_type] or 0 + _G.tags.FS[FS_driver].data[FS_index].max_fluid
							all_storage[_G.tags.FS[FS_driver].data[FS_index].fluid_type] = all_storage[_G.tags.FS[FS_driver].data[FS_index].fluid_type] or 0 + _G.tags.FS[FS_driver].data[FS_index].fluid
						end
					end
				end
			elseif _G.config.mode == 2 then
				all_storage = 0
				all_max_storage = 0
				for ES_driver in pairs(_G.drivers.ES) do
					ES_count = #_G.tags.ES[ES_driver].elements
					if ES_count > 0 then
						for ES_index = 1, ES_count do
							_G.drivers.ES[ES_driver].get_data(ES_index)
							all_max_storage = all_max_storage + _G.tags.ES[ES_driver].data[ES_index].max_power
							all_storage = all_storage + _G.tags.ES[ES_driver].data[ES_index].power
						end
					end
				end
			end
			
			
			for gen_driver in pairs(_G.drivers.gen) do
				elements_count = #_G.tags.gen[gen_driver].elements
				if elements_count > 0 then
					for gen_index = 1, elements_count do
						local ok, result = pcall(_G.drivers.gen[gen_driver].get_data, gen_index)
						if not ok then
							if _G.tags.gen[gen_driver].data[gen_index].known_data ~= false then
								log.buffer.add({5, "Get Generator (" .. gen_driver .. ") #" .. tostring(gen_index) .. " Data Error: " .. (result or "Unkown")})
								_G.tags.gen[gen_driver].data[gen_index].known_data = false
								
								_G.tags.gen[gen_driver].data[gen_index].state = "E"
								if result == "no such component" then
									log.buffer.add({4, "Generator informational line hasn't signal"})
								else
									log.buffer.add({4, "Attempt to initiate an E-STOP..."})
									local ok, result = pcall(_G.drivers.gen[gen_driver].stop, gen_index)
									if ok then
										log.buffer.add({2, "E-STOP has been successfully (that’s not certain). Working status may be unkown anyway"})
									else
										log.buffer.add({5, "E-STOP has been unsuccessfully"})
									end
								end
							end
						else
							if _G.tags.gen[gen_driver].data[gen_index].known_data == false then
								log.buffer.add({2, "We have generator (" .. gen_driver .. ") #" .. tostring(gen_index) .. " informational line again"})
							end
							
							_G.tags.gen[gen_driver].data[gen_index].known_data = true
							
							if _G.tags.state == "E" or _G.tags.gen[gen_driver].data[gen_index].state == "E" then
								if _G.tags.gen[gen_driver].data[gen_index].working then
									_G.drivers.gen[gen_driver].stop(gen_index)
									log.buffer.add({3, "Generator (" .. gen_driver .. ") #" .. tostring(gen_index) .. " has been manually started, but mode now is Emergency. We E-Stopped the gen"})
								end
								_G.tags.gen[gen_driver].data[gen_index].state = "S"
							else
								-- Generator State
								if _G.tags.gen[gen_driver].data[gen_index].state == nil then
									_G.reset_gen_state(gen_driver, gen_index)
								elseif _G.tags.gen[gen_driver].data[gen_index].working == true and _G.tags.gen[gen_driver].data[gen_index].state == "S" then
									log.buffer.add({4, "Generator (" .. gen_driver .. ") #" .. tostring(gen_index) .. " state set to E"})
									log.buffer.add({1, "GENERATOR DATA\n  working: " .. tostring(_G.tags.gen[gen_driver].data[gen_index].working) .. "\n  state (was): " .. (_G.tags.gen[gen_driver].data[gen_index].state or "unkown")})
									_G.tags.gen[gen_driver].data[gen_index].state = "E"
									table.insert(gens_in_E_state, {gen_driver, gen_index})
								end
								
								if _G.tags.gen[gen_driver].data[gen_index].state ~= "M" and _G.tags.state ~= "M" then
									-- PID Mode
									mode = _G.tags.gen[gen_driver].data[gen_index].mode or _G.config.mode
									if mode == 1 then
										all_storage_for_gen = all_storage[_G.tags.gen[gen_driver].data[gen_index].fluid_type]
										all_max_storage_for_gen = all_max_storage[_G.tags.gen[gen_driver].data[gen_index].fluid_type]
									elseif mode == 2 then
										all_storage_for_gen = all_storage
										all_max_storage_for_gen = all_max_storage
									end
									
									-- PID
									ok, result = pcall(_G.modules.pid.control[mode], gen_driver, gen_index, all_storage_for_gen, all_max_storage_for_gen)
									if not ok then
										log.buffer.add({5, "PID Error: " .. result})
										if _G.tags.gen[gen_driver].data[gen_index].working then
											stop_gen(gen_driver, gen_index)
											log.buffer.add({4, "E-STOP Gen (" .. gen_driver .. ") #" .. tostring(gen_index)})
										end
									end
								end
							end
						end
					end
				end
			end
			log.buffer.push()
		end
		
		event = table.pack(computer.pullSignal(time_sleep-time_elpased))
	end
end)

log.buffer.add({4, "!!! PANIC !!!\n   We exited from main cycle"})
pcall(log.buffer.push)
_G.stop_all_gens()
if not ok_main then
	error(result_main)
end
