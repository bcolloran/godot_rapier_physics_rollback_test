extends Node3D

enum ADVANCE_KIND {
  NO_ROLLBACK,
  FIXED_FWD_BACK
}

@export var advance_kind := ADVANCE_KIND.NO_ROLLBACK


var _sim_advance_loops = 0
var _num_physics_steps_executed: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  PhysicsServer3D.space_set_active(get_viewport().world_3d.space, false)
  SimStateContext.initial_snapshot()


func _physics_process(_delta: float) -> void:
  if advance_kind == ADVANCE_KIND.NO_ROLLBACK:
    advance_sim_no_rollback()
  elif advance_kind == ADVANCE_KIND.FIXED_FWD_BACK:
    advance_sim_fixed_forward_and_back()
  else:
    assert(false, "unknown advance kind")
  _sim_advance_loops += 1


func advance_sim_no_rollback() -> void:
  var first_new_step = _num_physics_steps_executed + 1
  var step_range_limit = first_new_step + 1
  var ticks = range(first_new_step, step_range_limit)

  # print(
  #   "NO ROLLBACK---- advancement loops:", _sim_advance_loops,
  #   "  first_new_step: ", _num_physics_steps_executed,
  #   "  step_range_limit step: ", step_range_limit,
  #   "  sim ticks: ", ticks
  # )
  
  for t in ticks:
    SimStateContext.set_context_tick(t)
    SimStateContext.step_all_sim_entities()
    _num_physics_steps_executed = t


func advance_sim_fixed_forward_and_back() -> void:
  var last_snapshot_tick = SimStateContext.restore_last_snapshot()
  var next_snapshot_tick = last_snapshot_tick + 1
  var target_step = next_snapshot_tick + 5
  var ticks = range(last_snapshot_tick + 1, target_step)

  # print(
  #   "FIXED FWD/BACK -- advancement loops: ", _sim_advance_loops,
  #   "  last_snapshot_tick: ", last_snapshot_tick,
  #   "  target_step: ", target_step,
  #   "  sim ticks: ", ticks
  # )

  for t in ticks:
    SimStateContext.set_context_tick(t)
    SimStateContext.step_all_sim_entities()
    if t == next_snapshot_tick:
      SimStateContext.snapshot(t)