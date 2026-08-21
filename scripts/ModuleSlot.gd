extends Node2D
class_name ModuleSlot

enum SlotType {
	WEAPON,
	REACTOR,
	ENGINE,
	MISC
}

@export var slot_type: SlotType
var installed_module: BaseModule

func install_module(module: BaseModule):
	if installed_module:
		installed_module.queue_free()

	installed_module = module
	add_child(installed_module)

