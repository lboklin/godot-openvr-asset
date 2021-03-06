extends ARVRController

signal controller_activated(controller)

export var pad_center_radius = 0.8
var ovr_render_model
var components = Array()
var ws = 0

enum PAD_REGION_PRESSED { NONE, UP, LEFT, DOWN, RIGHT, CENTER }

func _ready():
	# instance our render model object
	ovr_render_model = preload("res://addons/godot-openvr/OpenVRRenderModel.gdns").new()

	# hide to begin with
	visible = false

func apply_world_scale():
	var new_ws = ARVRServer.world_scale
	if (ws != new_ws):
		ws = new_ws
		$Controller_mesh.scale = Vector3(ws, ws, ws)

func load_controller_mesh(controller_name):
	if ovr_render_model.load_model(controller_name.substr(0, controller_name.length()-2)):
		return ovr_render_model

	if ovr_render_model.load_model("generic_controller"):
		return ovr_render_model

	return Mesh.new()

func _process(delta):
	if !get_is_active():
		visible = false
		return

	# always set our world scale, user may end up changing this
	apply_world_scale()

	if visible:
		return

	# became active? lets handle it...
	var controller_name = get_controller_name()
	print("Controller " + controller_name + " became active")

	# attempt to load a mesh for this
	$Controller_mesh.mesh = load_controller_mesh(controller_name)

	# make it visible
	visible = true
	emit_signal("controller_activated", self)

func pad_region_pressed():
	# button 14 is mapped to the thumb pad
	if not self.is_button_pressed(14):
		return NONE

	var x = self.get_joystick_axis(0)
	var y = self.get_joystick_axis(1)
	if Vector2(x, y).length() < self.pad_center_radius:
		return CENTER
	else:
		var ang = rad2deg(Vector2(x,y).normalized().rotated(deg2rad(-45)).angle())
		if ang < 0:
			ang += 360
		var quadrant = ceil(ang / 90)
		return quadrant
