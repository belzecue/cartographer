tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCartoClipmapTransform

func _init():
	set_default_input_values([0, float(0), 2, Vector3(0, 1, 0)])

func _get_name():
	return "ClipmapTransform"

func _get_category():
	return "Cartographer"

func _get_description():
	return "Clipmap vertex transform node."

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "height"
		1:
			return "normal"
		2:
			return "vertex"

func _get_input_port_type(port):
	match port:
		0:
			return PORT_TYPE_SCALAR
		1:
			return PORT_TYPE_VECTOR
		2:
			return PORT_TYPE_VECTOR

func _get_output_port_count():
	return 4

func _get_output_port_name(port):
	match port:
		0:
			return "vertex"
		1:
			return "normal"
		2:
			return "tangent"
		3:
			return "binormal"

func _get_output_port_type(port):
	match port:
		0:
			return PORT_TYPE_VECTOR
		1:
			return PORT_TYPE_VECTOR
		2:
			return PORT_TYPE_VECTOR
		3:
			return PORT_TYPE_VECTOR

func _get_global_code(mode):
	return """
"""

func _get_code(input_vars, output_vars, mode, type):
	var io = {}
	for i in len(input_vars):
		io[_get_input_port_name(i) + "_in"] = input_vars[i]
	for i in len(output_vars):
		io[_get_output_port_name(i)] = output_vars[i]
	
	var tmpl = """// ClipmapTransform
//{height_in} = {uv}.x > 1.0 || {uv}.y > 1.0 ? 0.0 : {height_in};
//{height_in} = {uv}.x < 0.0 || {uv}.y < 0.0 ? 0.0 : {height_in};
{vertex} = {vertex_in};
{vertex}.y = {height_in};

{normal} = {normal_in};
{tangent} = vec3(0.0,0.0,-1.0) * ({normal}.x);
{tangent} += vec3(1.0,0.0,0.0) * ({normal}.y);
{tangent} += vec3(1.0,0.0,0.0) * ({normal}.z);
{tangent} = normalize({tangent});
{binormal} = vec3(0.0,-1.0,0.0) * abs({normal}.x);
{binormal} += vec3(0.0,0.0,-1.0) * abs({normal}.y);
{binormal} += vec3(0.0,-1.0,0.0) * abs({normal}.z);
{binormal} = normalize({binormal});

// Clipmap transforms
{normal} = (INV_CAMERA_MATRIX * vec4({normal}, 0.0)).xyz;
{binormal} = (INV_CAMERA_MATRIX * vec4({binormal}, 0.0)).xyz;
{tangent} = (INV_CAMERA_MATRIX * vec4({tangent}, 0.0)).xyz;
{vertex} = (INV_CAMERA_MATRIX * vec4({vertex}, 1.0)).xyz;
"""
	return tmpl.format(io)
