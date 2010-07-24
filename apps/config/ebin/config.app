{application, config,
    [{description, "Configuration manager for LoPECv2 - 
                     A distributed high performance low power cluster"},
    {vsn, "0.1"},
    {modules, [config]},
    {registered, [config_srv]},
    {applications, [kernel, stdlib]},
    {mod, {config, []}}
    ]}.
