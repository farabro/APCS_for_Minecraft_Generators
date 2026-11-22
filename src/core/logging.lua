_G.log = {}

if _G.config.logging.enabled then
	function _G.log.set_log_device(numb)
		if numb > _G.log.count_of_log_devices then
			return false
		else
			local log_device_proxy = component.proxy(_G.config.logging.log_devices[numb])
			
			-- Check that log directory is exists (if log directory is enabled)
			if _G.config.logging.log_directory.enabled then
				local path = ""
				
				for _, directory in ipairs(_G.config.logging.log_directory.directories) do
					path = path .. "/" .. directory
					
					if log_device_proxy.exists(path) then
						if not log_device_proxy.isDirectory(path) then -- if it's file
							log_device_proxy.remove(path)
							log_device_proxy.makeDirectory(path)
						end
					else -- if it's not exists
						log_device_proxy.makeDirectory(path)
					end
				end
			end
			
			_G.log.log_device = {numb, _G.config.logging.log_devices[numb], log_device_proxy}
			return true
		end
	end
	
	-- metatable
	setmetatable(
		_G.log,
		{
			__call = function(_, log_event, list_of_events)
				if type(log_event) ~= "table" or log_event == {} then return end
				local result = ""
				
				if list_of_events then
					for event = 1, #log_event do
						if log_event[event][2] >= _G.config.logging.log_lvl then
							result = result
								.. "[" .. tostring(log_event[event][1]) .. "] "
								.. "[" .. tostring(_G.config.logging.log_lvls_names[log_event[event][2]]) .. "] "
								.. tostring(log_event[event][3]) .. "\n"
						end
					end
				else
					if log_event[1] < _G.config.logging.log_lvl then return end
					result =
						"[" .. tostring(computer.uptime()) .. "] "
						.. "[" .. tostring(_G.config.logging.log_lvls_names[log_event[1]]) .. "] "
						.. tostring(log_event[2]) .. "\n"
				end
				
				if not result then return end
				
				local len_of_result = string.len(result)
				local new_log_size = _G.log.log_size + len_of_result
				local spaceLeft = _G.log.log_device[3].spaceTotal() - _G.log.log_device[3].spaceUsed()
				
				-- Check that we can begin log
				if (new_log_size > _G.config.logging.max_log_size and _G.config.logging.max_log_size ~= 0) or len_of_result > spaceLeft then
					if _G.log.count_of_log_devices == _G.log.log_device[1] then
						_G.log.set_log_device(1)
					else
						_G.log.set_log_device(_G.log.log_device[1]+1)
					end
					
					_G.log.log_device[3].remove(_G.log.path)
					_G.log.log_size = 0
				end
				
				-- write to a log file
				local handle = _G.log.log_device[3].open(_G.log.path, 'a')
				local ok = pcall(_G.log.log_device[3].write, handle, result)
				_G.log.log_device[3].close(handle)
				
				if ok then _G.log.log_size = new_log_size end -- set new log size (if write was successfully)
				
				-- send to syslog servers
				for _, addr in ipairs(_G.config.logging.syslog_servers_addrs) do
					pcall(_G.modules.remote.send, addr, result)
				end
			end,
		}
	)
	
	function _G.log.init()
		local init_log_events = {}
		
		-- config check
		if _G.config.logging.max_log_size ~= 0 then if _G.config.logging.max_log_size < 256 then error({"Err E-120: Max log size < 256", 120}) end end
		
		-- check that we have log device
		if not _G.config.logging.log_devices[1] then
			table.insert(init_log_events, {computer.uptime(), 4, "Log devices is not found, but logging is enabled"})
			
			_G.config.logging.log_devices[1] = _G.BootFilesystemAddr
			if _G.config.logging.log_lvl < 2 then
				_G.config.logging.log_lvl = 2
				table.insert(init_log_events, {computer.uptime(), 2, "Log lvl has been edited to 2"})
			end
			
			
			_G.config.logging.log_directory.enabled = true
			_G.config.logging.log_directory.directories = {"logs"}
			
			_G.config.logging.log_name = "reserve.log"
			
			table.insert(init_log_events, {computer.uptime(), 3, "We will use boot device for logging"})
		end
		
		-- set log path
		if _G.config.logging.log_directory.enabled then
			local path = ""
			
			for _, directory in ipairs(_G.config.logging.log_directory.directories) do
				path = path .. "/" .. directory
			end
			_G.log.path = path .. "/" .. _G.config.logging.log_name
		else
			_G.log.path = "/" .. _G.config.logging.log_name
		end
		
		-- set log device
		_G.log.count_of_log_devices = #_G.config.logging.log_devices
		_G.log.set_log_device(1)
		_G.log.log_size = _G.log.log_device[3].size(_G.log.path) -- if file isn't exists will be return 0, but we set 0 if file isn't exists or an error was occurred anyway
		
		log(init_log_events, true)
	end
	
	_G.log.init()
else
	-- metatable for disenabled logging
	
	setmetatable(
		_G.log,
		{
			__call = function(...) end,
		}
	)
end
