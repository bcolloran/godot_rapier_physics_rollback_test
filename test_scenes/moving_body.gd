extends RigidBody3D

var _overlap_ticks = {}

func _ready() -> void:
  SimStateContext.register_sim_entity(self)

func sim_step() -> void:
  if %Area3D.has_overlapping_bodies():
    print("Moving body area has_overlapping_bodies, tick: ", SimStateContext._ctx_tick)
    _overlap_ticks[SimStateContext._ctx_tick] = true
  
  # at 100 ticks, print out the overlap ticks
  if SimStateContext._ctx_tick > 40:
    var ticks = _overlap_ticks.keys()
    ticks.sort()
    print("Moving body area overlap ticks: ", ticks)
