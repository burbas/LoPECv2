%%%-------------------------------------------------------------------
%%% @author Niclas Axelsson <niclas@burbas.se>
%%% @doc
%%%
%%% @end
%%% Created : 24 Jul 2010 by Niclas Axelsson
%%%-------------------------------------------------------------------
-module(config_srv).

-behaviour(gen_server).
-include("include/config.hrl").

%% API
-export([
	 start_link/0,
	 get_config/1,
	 set_config/2,
	 save_to_disc/1,
	 read_from_disc/1
	]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {
	  config_tab
	 }).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({global, ?SERVER}, ?MODULE, [], []).

%%--------------------------------------------------------------------
%% @doc
%% Gets a value, associated with Key, from the config server.
%%
%% @spec get_config(Key::atom) -> ok
%% @end
%%--------------------------------------------------------------------
-spec get_config(Key::atom) -> ok.
get_config(Key) ->
    gen_server:call({global, ?SERVER}, {get_config, {Key}}).

%%--------------------------------------------------------------------
%% @doc
%% Inserts new, or update, entry in the config server.
%%
%% @spec set_config(Key::atom(), Value::any()) -> ok
%% @end
%%--------------------------------------------------------------------
-spec set_config(Key::atom(), Value::any()) -> ok.
set_config(Key, Value) ->
    gen_server:call({global, ?SERVER}, {set_config, {Key, Value}}).

%%--------------------------------------------------------------------
%% @doc
%% Saves the config database to disc. The file is human readable and
%% can be edited manually.
%%
%% @spec save_to_disc(Filename::string()) -> ok | {error, Reason::string()}
%% @end
%%--------------------------------------------------------------------
-spec save_to_disc(Filename::string()) -> ok | {error, Reason::string()}.
save_to_disc(Filename) ->
    gen_server:call({global, ?SERVER}, {save_to_disc, {Filename}}).

%%--------------------------------------------------------------------
%% @doc
%% Reads a file from disc that save_to_disc/1 have produced and inserts
%% the entrys into the database.
%%
%% @spec read_from_disc(Filename::string) -> ok | {error, Reason::string()}
%% @end
%%--------------------------------------------------------------------
-spec read_from_disc(Filename::string) -> ok | {error, Reason::string()}.
read_from_disc(Filename) -> 
    gen_server:call({global, ?SERVER}, {read_from_disc, {Filename}}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    %% We create an ets-table to store all our config parameters in
    ConfigTab = ets:new(?CONFIG_TAB_NAME, [{keypos, #config_entry.key}]),
    
    {ok, #state{config_tab = ConfigTab}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({get_config, {Key}}, _From, State = #state{config_tab = ConfigTab}) ->
    %% Just grab the result from the ets-table and reply it
    Result = ets:match(ConfigTab, #config_entry{key=Key, value='$1', _='_'}),
    {reply, Result, State};
handle_call({set_config, {Key, Value}}, _From, State = #state{config_tab = ConfigTab}) ->
    ets:insert(ConfigTab, #config_entry{key=Key, value=Value}),
    {reply, ok, State};
handle_call({save_to_disc, {Filename}}, _From, State = #state{config_tab = ConfigTab}) ->
    OutputList = ets:tab2list(ConfigTab),
    FilePath = ?CONFIG_FILEPATH,
    Reply = file:write_file(FilePath++"/"++Filename, io_lib:fwrite("~p.\n",[OutputList])),
    {reply, Reply, State};
handle_call({read_from_disc, {Filename}}, _From, State = #state{config_tab=ConfigTab}) ->
    FilePath = ?CONFIG_FILEPATH,
    case file:consult(FilePath++"/"++Filename) of
	{ok, [Result]} ->
	    ets:insert(ConfigTab, Result),
	    {reply, ok, State};
	{error, Reason} ->
	    {reply, {error, Reason}, State}
    end;
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
