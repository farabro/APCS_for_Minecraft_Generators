_G.config = {
	mode = 1,
	modes_config = {
		Y_max = 60,
		Y_min = 45,
		gen_start = 60,
		gen_stop = 45,
		
		auto_search_FS = true,
		manual_FS_address_table = {},
		
		auto_search_ES = true,
		manual_ES_address_table = {},
	},
	
	auto_search_gens = true,
	manual_gens_address_table = {},
	
	reboot_with_err = true,
	time_sleep = 2.5,
	
	
	logging = {
		enabled = false,
		log_lvl = 2,
		
		log_devices = {},
		log_directory = {
			enabled = true,
			directories = {"logs"},
		},
		log_name = "gen_APCS.log",
		max_log_size = 0,
		
		syslog_servers_addrs = {},
		
		log_lvls_names = {
			"DBG",
			"INF",
			"WRN",
			"CRT",
			"ERR",
		},
	},
	
	
	-- SCADA
	
	
	output_to_display = false, -- Not currently in use
	lang = 1, -- Neither does it
	
	su = {"FaraBro"},
	users_can_use = {
		E = true,
		M = true,
		C = false,
		O = {
			E = false,
			M = true,
			O = true,
			R = false,
		},
	},
	
	remote = {
		encrypting = false,
		AES_keys = {},
		
		control_port = 4840,
		controller_port = 4841,
		
		authorized_mashines = {},
		unauthorized_mashines_can = {
			get_data = false,
			set_state = {
				E = false,
				M = false,
				C = false,
				R = false,
			},
			reset_state = {
				E = false,
				M = false,
				O = false,
			},
		},
	},
}
