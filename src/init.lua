local ok, result = pcall(function()
	_G.APCSVERSION = "2.1.0"
	
	_G.log_buffer = {}
	_G.BootFilesystemAddr = computer.getBootAddress()
	_G.BootFilesystem = component.proxy(BootFilesystemAddr)
	
	function _G.copy(uncopied_table)
		local copied_table
		
		if type(uncopied_table) == 'table' then
			copied_table = {}
			for index, key, value in ipairs(uncopied_table) do
				key = key or index
				copied_table[key] = _G.copy(value)
			end
		else
			copied_table = uncopied_table
		end
		
		return copied_table
	end
	
	function _G.loadfile(file)
		local handle = assert(BootFilesystem.open(file))
		local buffer = ""
		repeat
			local data = BootFilesystem.read(handle, 2048)
			buffer = buffer .. (data or "")
		until not data
		BootFilesystem.close(handle)
		
		local result, code_error = load(buffer, file)
		if result then
			return result
		else
			error({"Err E-000: " .. code_error, 000}, 0)
		end
	end
	
	loadfile("/core/config.lua")(loadfile)
	loadfile("/core/tags.lua")(loadfile)
	loadfile("/core/logging.lua")(loadfile)
	
	function _G.set_value_for_every_element(n_table, value)
		for _ = 1, #n_table do
			n_table[n_table[1]] = value
			table.remove(n_table, 1)
		end
		
		return n_table
	end
	
	-- Creating Hash Tables for O(1)
	_G.config.su = set_value_for_every_element(_G.config.su, true) -- SU
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Initializing drivers tools"})
	loadfile("/core/drivers_tools.lua")(loadfile)
	_G.drivers = {
		gen = {},
		FS = {},
		ES = {},
	}
	_G.libs = {}
	_G.modules = {}
	
	local function do_dir(path)
		for _, file in ipairs(BootFilesystem.list(path)) do
			loadfile(path .. "/" .. file)(loadfile)
		end
	end
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Loading drivers"})
	do_dir("/drivers")
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Loading libs"})
	do_dir("/libs")
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Loading modules"})
	do_dir("/modules")
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Initializing libs"})
	for APCS_lib in pairs(_G.libs) do
		if _G.libs[APCS_lib].init then _G.libs[APCS_lib].init() end
	end
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Initializing drivers"})
	for driver_type in pairs(_G.drivers) do
		if _G.drivers[driver_type].init then
			_G.drivers[driver_type].init()
		else
			for driver_name in pairs(_G.drivers[driver_type]) do
				if _G.drivers[driver_type][driver_name].init then
					_G.drivers[driver_type][driver_name].init()
				end
			end
		end
	end
	
	table.insert(_G.log_buffer, {computer.uptime(), 1, "Initializing modules"})
	for APCS_module in pairs(_G.modules) do
		if _G.modules[APCS_module].init then _G.modules[APCS_module].init() end
	end
	
	_G.tags.state = "O"
	table.insert(_G.log_buffer, {computer.uptime(), 2, "Successfully startup"})
	log(_G.log_buffer, true)
	_G.log_buffer = nil
	
	local ok, result = pcall(function()
		loadfile("/main.lua")(loadfile)
	end)
	
	if not ok then
		computer.beep(1000, 0.2)
		
		local err = {}
		if type(result) == "table" then
			err = result
		else
			err[1] = "ERR E-000: Unkown ERR (" .. tostring(result) .. ")"
			err[2] = 000
		end
		
		_G.log_buffer = {}
		table.insert(_G.log_buffer,
			{
				computer.uptime(),
				5,
				"An error"
					.. err[2] == 000 or "" and " (" .. tostring(err[2]) .. ")"
					.. " has been occurred at main cycle"
					.. err[2] == 000 or "\n\t" .. err[1] and ""
			}
		)
		
		if _G.config.reboot_with_err then
			table.insert(_G.log_buffer, {computer.uptime(), 4, "Rebooting now..."})
			log(_G.log_buffer, true)
			
			computer.shutdown(true)
		else
			log(_G.log_buffer, true)
			error({err[1], err[2]}, 0)
		end
	end
end)

if not ok then
	computer.beep(500, 0.2)
	
	local err = {}
	if type(result) == "table" then
		err = result
	else
		err[1] = "ERR E-000: Unkown ERR (" .. tostring(result) .. ")"
		err[2] = 000
	end
	
	error(err[1], 0)
else
	computer.shutdown()
end
