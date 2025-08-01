extends Node

class_name PuzzleLevelState

enum States {LOADING, PLAY, PAUSED, WIN, LOSE}
var state: States = 0

func GetState() -> States:
	return state
	
func SetState(new_state: States):
	state = new_state
