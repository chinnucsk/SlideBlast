-module (name_dialog_element).
-include_lib ("nitrogen/include/wf.hrl").
-include ("caster.hrl").
-compile(export_all).

%% Custom element to display a lightbox asking for the user's name.

% Required for a custom element.
reflect() -> record_info(fields, name_dialog).

% Executes when the element is rendered.
render_element(_Record) ->
    wf:wire(okButton, nameTextBox, #validate { validators=[
        #is_required { text="Required." }
    ]}),
    #lightbox { id=name_lightbox, style="display: none;", body=[
        #panel { class=name_dialog, body=[
            #image { image="/images/SlideBlastLogoSmall.png" },
            #p{},
            "Enter your name:",
            #p{},
            #textbox { id=nameTextBox, next=okButton },
            #p{},
            #button { id=okButton, text="OK", postback=ok, delegate=?MODULE }
        ]}
    ]}.
 
% Show the lightbox, and don't change slides in response to keyboard events.
show() ->
    wf:wire(name_lightbox, #show {}),
    wf:wire(nameTextBox, "obj('me').focus(); obj('me').select();"),
    wf:wire("disableSlideControls();").
    
% OK button was pressed. 
% Hide the lightbox and send our name to the attendee comet process.
event(ok) ->
    wf:wire("enableSlideControls();"),
    wf:wire(name_lightbox, #hide {  }),
    Name = wf:q(nameTextBox),
    Pid = view:server_get(attendee_comet_pid),
    Pid!{set_name, Name}.

    
