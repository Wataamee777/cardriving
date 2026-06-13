class_name AirSuspensionSettings
extends Resource

## Lightweight air-suspension tuning data for a VehicleBody3D.
## Values are in Godot meters and VehicleWheel3D force units.

@export_range(0.04, 0.60, 0.005, "or_greater") var min_rest_length: float = 0.10
@export_range(0.04, 0.80, 0.005, "or_greater") var max_rest_length: float = 0.36
@export_range(0.02, 0.60, 0.005, "or_greater") var min_travel: float = 0.06
@export_range(0.02, 0.80, 0.005, "or_greater") var max_travel: float = 0.24

@export_range(1.0, 120.0, 0.5, "or_greater") var base_stiffness: float = 28.0
@export_range(1.0, 180.0, 0.5, "or_greater") var low_height_stiffness: float = 68.0
@export_range(0.1, 16.0, 0.1, "or_greater") var base_compression: float = 4.6
@export_range(0.1, 20.0, 0.1, "or_greater") var low_height_compression: float = 8.8
@export_range(0.1, 16.0, 0.1, "or_greater") var base_relaxation: float = 5.2
@export_range(0.1, 20.0, 0.1, "or_greater") var low_height_relaxation: float = 9.6

## Normalized height threshold where stance/grounding behavior starts.
@export_range(0.0, 0.5, 0.01) var low_height_threshold: float = 0.18
## Extra downward force used to simulate underbody scraping at very low height.
@export_range(0.0, 12000.0, 50.0, "or_greater") var scrape_downforce: float = 2600.0
## Linear damping applied while scraping to remove bounce cheaply.
@export_range(0.0, 4.0, 0.05, "or_greater") var scrape_velocity_damping: float = 0.85
