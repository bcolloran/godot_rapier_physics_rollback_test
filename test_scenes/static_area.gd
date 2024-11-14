extends Area3D

func _ready() -> void:
  SimStateContext.register_sim_entity(self)

func sim_step() -> void:
  if has_overlapping_bodies():
    print("Static test area has_overlapping_bodies, tick: ", SimStateContext._ctx_tick)
