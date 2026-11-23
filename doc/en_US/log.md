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

## buffer
We recommendate use buffer (otherwise will be many lags).  
For this at this core module has "buffer" (*log.buffer*);  
You can use its! There small API:
- **log.buffer.add()** -- literally the image and likeness log(), but write at buffer! Doc of this log is upper
- **log.buffer.push()** -- push buffer. In other words, it calls log(log.buffer(), true) and reset buffer
- **log.buffer()** -- Return buffer

So, you often don’t need to push buffer, for you its do main scripts ([init](/src/init.lua) or [main](/src/main.lua) depending on the situation)

And... It's all! Yeah, just all.  

Examples:
- `log.buffer.add({4, "WOW, IT'S BUFFERED LOG!!"})`
- `log.buffer.add({{259, 4, "Your log message 1 there"}, {330, 2, "Your log message 2 there. So there are can be more events"}}, true)`
- `log.buffer.push()`
