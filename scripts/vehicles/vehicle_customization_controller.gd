class_name VehicleCustomizationController
extends Node

## Attach this script to the VehicleBody3D root or to a direct child controller node.
## It updates four VehicleWheel3D nodes only when the requested ride height changes,
## keeping _physics_process cheap for Android devices.

@export var vehicle_body: VehicleBody3D
@export var wheels: Array[VehicleWheel3D] = []
@export var air_suspension: AirSuspensionSettings
@export var air_suspension_enabled: bool = false

## 0.0 = slammed stance, 1.0 = maximum ride height.
var _ride_height := 0.55

@export_range(0.0, 1.0, 0.01) var ride_height: float = 0.55:
	set(value):
		_ride_height = clampf(value, 0.0, 1.0)
		if is_node_ready():
			_apply_air_suspension(false)
	get:
		return _ride_height

const HEIGHT_EPSILON := 0.002
const MIN_SLEEP_SPEED := 0.15

var _applied_height := -1.0
var _scrape_factor := 0.0

func _ready() -> void:
	if vehicle_body == null:
		vehicle_body = get_parent() as VehicleBody3D
	if wheels.is_empty() and vehicle_body != null:
		_find_wheels(vehicle_body)
	_apply_air_suspension(true)

func _physics_process(delta: float) -> void:
	if not air_suspension_enabled or vehicle_body == null or air_suspension == null:
		return

	# Only continuous effect: cheap bottom-scrape/low-stance damping.
	# Wheel parameter writes are intentionally not done every frame.
	if _scrape_factor > 0.0 and vehicle_body.linear_velocity.length_squared() > MIN_SLEEP_SPEED * MIN_SLEEP_SPEED:
		var downforce := Vector3.DOWN * air_suspension.scrape_downforce * _scrape_factor
		vehicle_body.apply_central_force(downforce)
		vehicle_body.linear_velocity *= maxf(0.0, 1.0 - air_suspension.scrape_velocity_damping * _scrape_factor * delta)

func purchase_air_suspension() -> void:
	air_suspension_enabled = true
	_apply_air_suspension(true)

func set_ride_height(value: float) -> void:
	_ride_height = clampf(value, 0.0, 1.0)
	if not is_node_ready():
		return
	_apply_air_suspension(false)

func raise_height(step: float = 0.05) -> void:
	set_ride_height(ride_height + step)

func lower_height(step: float = 0.05) -> void:
	set_ride_height(ride_height - step)

func _apply_air_suspension(force_update: bool) -> void:
	if not air_suspension_enabled or air_suspension == null:
		return
	if not force_update and absf(ride_height - _applied_height) < HEIGHT_EPSILON:
		return

	_applied_height = ride_height
	var low_ratio := 1.0 - smoothstep(0.0, air_suspension.low_height_threshold, ride_height)
	_scrape_factor = low_ratio

	var rest_length := lerpf(air_suspension.min_rest_length, air_suspension.max_rest_length, ride_height)
	var travel := lerpf(air_suspension.min_travel, air_suspension.max_travel, ride_height)
	var stiffness := lerpf(air_suspension.base_stiffness, air_suspension.low_height_stiffness, low_ratio)
	var compression := lerpf(air_suspension.base_compression, air_suspension.low_height_compression, low_ratio)
	var relaxation := lerpf(air_suspension.base_relaxation, air_suspension.low_height_relaxation, low_ratio)

	for wheel in wheels:
		if wheel == null:
			continue
		wheel.suspension_rest_length = rest_length
		wheel.suspension_travel = travel
		wheel.suspension_stiffness = stiffness
		wheel.damping_compression = compression
		wheel.damping_relaxation = relaxation

func _find_wheels(root: Node) -> void:
	for child in root.get_children():
		var wheel := child as VehicleWheel3D
		if wheel != null:
			wheels.append(wheel)
		else:
			_find_wheels(child)
