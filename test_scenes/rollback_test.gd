extends Node3D

enum ADVANCE_KIND {
  ONE_STEP_NO_ROLLBACK,
  MULTISTEP_NO_ROLLBACK,
  FIXED_FWD_BACK
}

@export var advance_kind := ADVANCE_KIND.ONE_STEP_NO_ROLLBACK


var _gd_physics_process_steps = 0
var _num_physics_steps_executed: int = 0


func _ready() -> void:
  PhysicsServer3D.space_set_active(get_viewport().world_3d.space, false)
  # Note: we take an initial snapshot at tick 0, 
  # and we start computing new states at tick 1
  SimStateContext.initial_snapshot()


func _physics_process(_delta: float) -> void:
  if advance_kind == ADVANCE_KIND.ONE_STEP_NO_ROLLBACK:
    advance_sim_one_step_no_rollback()
  elif advance_kind == ADVANCE_KIND.MULTISTEP_NO_ROLLBACK:
    advance_sim_multistep_no_rollback()
  elif advance_kind == ADVANCE_KIND.FIXED_FWD_BACK:
    advance_sim_fixed_forward_and_back()
  else:
    assert(false, "unknown advance kind")
  _gd_physics_process_steps += 1

  if _num_physics_steps_executed > 45:
    get_tree().paused = true


func advance_sim_one_step_no_rollback() -> void:
  var new_tick = _num_physics_steps_executed + 1
  print(
    "ONE_STEP_NO_ROLLBACK; _gd_physics_process_steps:", _gd_physics_process_steps,
    "  sim tick: ", new_tick
  )
  SimStateContext.set_context_tick(new_tick)
  SimStateContext.step_all_sim_entities()
  _num_physics_steps_executed = new_tick

func advance_sim_multistep_no_rollback() -> void:
  var first_new_step = _num_physics_steps_executed + 1
  var step_range_limit = first_new_step + 3
  var ticks = range(first_new_step, step_range_limit)

  print(
    "MULTISTEP_NO_ROLLBACK; _gd_physics_process_steps:", _gd_physics_process_steps,
    "  first_new_step: ", first_new_step,
    "  step_range_limit step: ", step_range_limit,
    "  sim ticks: ", ticks
  )
  
  for t in ticks:
    SimStateContext.set_context_tick(t)
    SimStateContext.step_all_sim_entities()
    _num_physics_steps_executed = t


func advance_sim_fixed_forward_and_back() -> void:
  var last_snapshot_tick = SimStateContext.restore_last_snapshot()
  var next_snapshot_tick = last_snapshot_tick + 1
  var target_step = next_snapshot_tick + 5
  var ticks = range(last_snapshot_tick + 1, target_step)

  print(
    "FIXED_FWD_BACK; _gd_physics_process_steps: ", _gd_physics_process_steps,
    "  last_snapshot_tick: ", last_snapshot_tick,
    "  target_step: ", target_step,
    "  sim ticks: ", ticks
  )

  for t in ticks:
    SimStateContext.set_context_tick(t)
    SimStateContext.step_all_sim_entities()
    if t == next_snapshot_tick:
      SimStateContext.snapshot(t)
    _num_physics_steps_executed = t