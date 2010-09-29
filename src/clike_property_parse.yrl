%%
%% $Id: clike_property_parse.yrl,v 1.1.1.1 2002/10/04 00:00:00 svg Exp $
%%
%% $Log
%%
%%From original tacacs/config.c

%% <config> := <decls>
%% 
%% <decls> := <decl>*
%% 
%% <decl> := <bool_decl> decl_end
%%        |  <simple_decl> decl_end
%%        |  <struct_decl> decl_end
%%        |  <oprator_decl> decl_end

%% 
%% <bool_decl> := atom_string
%%             |  atom_string = bool
%% 
%% <simple_decl> := atom_string = <simple_values>
%% 
%% <oprator_decl> := operator <string_value>

%% <simple_value> := <string_value>
%%                |  integer_num
%%                |  float_num
%%                |  ipv4_address
%%                |  ipv4_netmask
%%                |  
%%     
%%<string_value> := atom_string
%%               |  string
%%	         |  substring <var_subst>
%%               |  <var_subst>
%%
%%<var_subst> := <var> r_brace
%%	      |  <var> substring <var_subst>
%%	      |  <var> substring
%%<var> := var_begin atom_string
%% 
%% <struct_decl> := <struct_name> <struct_attrs> <struct_body>
%% 	      |  <struct_name> <struct_body>
%% 
%% <struct_name> := atom_string
%% 
%% <struct_attrs> := <simple_values>
%% 
%% <struct_body> := { <decls> }

Nonterminals    '<config>'
                '<decls>'
                '<decl>'
		'<bool_decl>'
		'<simple_decl>'
		'<operator_decl>'
		'<simple_values>'
		'<simple_value>'
		'<string_value>'
		'<var_val>'
		'<var_subst>'
		'<struct_decl>'
		'<struct_name>'
		'<struct_attrs>'
		'<struct_body>'
		'<empty_decl>'.

Terminals      	bool
		decl_end
		operator
		assign_op   
		r_brace    
		l_brace     
		float_num
		integer_num
		ipv4_address
		ipv4_netmask
		atom_string
		substring
		string
		var_begin.

Rootsymbol '<config>'.

Endsymbol '$end'.

'<config>' -> '<decls>' : '$1'.

'<decls>' -> '<decl>' '<decls>' : add_value('$1', '$2').
'<decls>' -> '$empty' : [].

'<decl>' -> '<bool_decl>' decl_end : '$1'.
'<decl>' -> '<simple_decl>' decl_end : '$1'.
'<decl>' -> '<struct_decl>' decl_end : '$1'.
'<decl>' -> '<operator_decl>' decl_end : '$1'.
'<decl>' -> '<empty_decl>' : [].

'<empty_decl>' -> decl_end.

'<bool_decl>' -> atom_string : add_simple(value_of('$1'), true).
'<bool_decl>' -> atom_string assign_op bool :
		add_simple(value_of('$1'), value_of('$3')).
 
'<operator_decl>' -> operator '<string_value>'
	: add_op(value_of('$1'), '$2', line_of('$1')).

'<simple_decl>' -> atom_string assign_op '<simple_value>' '<simple_values>'
	: add_simple_list(value_of('$1'), ['$3'|'$4']).

'<simple_values>' -> '<simple_value>' '<simple_values>'
	: ['$1'|'$2'].

'<simple_values>' -> '$empty' : [].

'<simple_value>' -> '<string_value>' : '$1'.
'<simple_value>' -> integer_num  : value_of('$1').
'<simple_value>' -> float_num    : value_of('$1').
'<simple_value>' -> ipv4_address : value_of('$1').
'<simple_value>' -> ipv4_netmask : value_of('$1').

'<string_value>' -> string : value_of('$1').
'<string_value>' -> atom_string : value_of('$1').
'<string_value>' -> substring '<var_subst>' : value_of('$1') ++ '$2'.
'<string_value>' -> '<var_subst>' : '$1'.

'<var_subst>' -> '<var_val>' substring '<var_subst>'
		: '$1' ++ value_of('$2') ++ '$3'.
'<var_subst>' -> '<var_val>' substring : '$1' ++ value_of('$2').
'<var_subst>' -> '<var_val>' r_brace : '$1'.

'<var_val>' -> var_begin atom_string :
	var_value(list_to_atom(value_of('$2'))).

'<struct_decl>' -> '<struct_name>' '<struct_attrs>' '<struct_body>'
	: Val = add_struct('$1', '$2', '$3'),
	  pop_frame(),
	  Val.

'<struct_name>' -> atom_string
	: push_frame(),
	  value_of('$1').

'<struct_attrs>' -> '<simple_values>' : '$1'.

'<struct_body>' -> l_brace '<decls>' r_brace : '$2'.

Erlang code.

