-module (caster_inets_app).
-include_lib ("nitrogen/include/wf.hrl").

-export ([start/2, stop/0, do/1]).

-define (PORT, 8000).

start(_, _) ->
	riak:start(["riak.config"]),
	default_process_cabinet_handler:start(),
	inets:start(),
	{ok, Pid} = inets:start(httpd, [
		{port, ?PORT},
		{server_name, "nitrogen"},
		{server_root, "."},
		{document_root, "./wwwroot"},
		{modules, [?MODULE]},
		{mime_types, [{"css", "text/css"}, {"js", "text/javascript"}, {"html", "text/html"}]}
	]),
	link(Pid),
	{ok, Pid}.
	
stop() ->
	httpd:stop_service({any, ?PORT}),
	ok.
	
do(Info) ->
	RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
	ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
	nitrogen:init_request(RequestBridge, ResponseBridge),
	wf_handler:set_handler(named_route_handler, [
        % Modules...
        {"/", index},
        {"/view/", view},
        {"/img/", img},
        
        % Static directories...
        {"/nitrogen", static_file},
        {"/js", static_file},
        {"/images", static_file},
        {"/css", static_file}
    ]),
	nitrogen:run().
