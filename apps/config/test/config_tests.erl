-compile(export_all).
 
-module(config_tests).
-include_lib("eunit/include/eunit.hrl").

 setup() ->
    [
     config_srv:start_link()
    ].

teardown(_) ->
    [
     file:delete("test")
    ].



config_test_() ->
    {setup,
     fun setup/0,
     fun teardown/1,
     [
      ?_assertEqual(config_srv:set_config(test, "This is a test"), ok),
      ?_assertEqual(config_srv:get_config(test), [["This is a test"]]),
      ?_assertEqual(config_srv:save_to_disc("test"), ok),
      ?_assertEqual(config_srv:set_config(test, "Overwritten key"), ok),
      ?_assertEqual(config_srv:read_from_disc("test"), ok),
      ?_assertEqual(config_srv:get_config(test), [["This is a test"]])
     ]
    }.

