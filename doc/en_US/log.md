Log is logging (Really!?).  
It is global table "log" (`_G.log`).  
You can call this table (It have meta-table).  

### Args
So... `log(event_log: table [, list_of_events: bool])`,  
Where:
- event_log -- Table. Log event have something stuff (without keys, only values)
	1. date, need only for events list (more on this below), otherwise will error. Just.. please, don't set it if log event isn't list of events. Number
	2. level, log level. Number (integer). In total, there are... a few levels:
		1. DEBUG (First level, 1)
		2. INFO (Second level, 2)
		3. WARNING (Third level, 3)
		4. CRITICAL (Fourth level, 4)
		5. ERROR (Fifth level, 5)
	3. Log message. Have main info. String
- list_of_events (optional) -- Bool. event_log is events list? If true, then in every event must be date; else, there is one log event

Examples:
- `log({2, "Successfully startup"})`
- `log({{0.7, 1, "TEST DEBUG MESSAGE"}, {1, 5, "TEST ERROR"}}, true)`