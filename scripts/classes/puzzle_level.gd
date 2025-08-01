# scripts/resources/puzzle_level.gd
extends Resource
class_name PuzzleLevel

@export var level_name: String
@export var description: String
@export var goal_pattern: Array[int]  # Array of notes that should be active
@export var bpm: int = 120
@export var max_score: int = 1000      # Starting score
@export var score_penalty: int = 100    # Points deducted per check
