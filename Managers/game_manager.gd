extends Node


var map : Node3D
var ui : Control
var astarHandler
var combatantParent : Node3D
#var mob_manager : MobManager
var mob_manager
var base_manager
var pan_camera
var tileCollisionShape : Shape3D
var waveHandler


var isGameTimeRunning : bool = true # implement this to stop base and game timer if needed
var gameTimerSpeed : float = 1.0
