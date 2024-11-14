extends RigidBody3D


func _ready() -> void:
  print("Moving body ready")
  SimStateContext.register_sim_entity(self)


func sim_step() -> void:
  if %Area3D.has_overlapping_bodies():
    print("Moving body area has_overlapping_bodies, tick: ", SimStateContext._ctx_tick)
