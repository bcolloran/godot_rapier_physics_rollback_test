extends Node

var _entities := {}
var _last_snapshot_tick := 0
var _ctx_tick := 0

var _rapier_bytes := PackedByteArray()

@onready var _space_rid := get_viewport().world_3d.space
@onready var _fixed_delta: float = 1.0 / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")


func _ready() -> void:
  print("SimStateContext ready")
  PhysicsServer3D.space_set_active(get_viewport().world_3d.space, false)
  SimStateContext.initial_snapshot()


func set_context_tick(t: int) -> void:
  _ctx_tick = t

func step_all_sim_entities() -> void:
  RapierPhysicsServer3D.space_step(_space_rid, _fixed_delta)
  RapierPhysicsServer3D.space_flush_queries(_space_rid)
  for entity in _entities.values():
    entity.sim_step()

func _rollback_rapier() -> void:
  RapierPhysicsServer3D.import_binary(_space_rid, _rapier_bytes)

func initial_snapshot() -> void:
  _snapshot_inner(0)

func snapshot(t: int) -> void:
  if t > _last_snapshot_tick:
    _snapshot_inner(t)

func _snapshot_inner(t):
    _last_snapshot_tick = t
    _rapier_bytes = RapierPhysicsServer3D.export_binary(_space_rid)

func restore_last_snapshot() -> int:
  _rollback_rapier()
  return _last_snapshot_tick

func register_sim_entity(entity: Node) -> void:
  print("registering entity: ", entity)
  _entities[entity.get_instance_id()] = entity
