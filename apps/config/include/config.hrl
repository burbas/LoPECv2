

-define(CONFIG_TAB_NAME, config_tab).
-define(CONFIG_FILEPATH, "").

%% The config-entry
-record(config_entry, {
	  key :: atom(),
	  value :: any()
		   }).
