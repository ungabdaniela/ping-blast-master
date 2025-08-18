extends Node

# Game session tracking variables
var session_start_time: int = 0
var session_score: int = 0
var balls_hit: int = 0
var balls_missed: int = 0
var consecutive_hits: int = 0
var max_consecutive_hits: int = 0
var balls_popped: int = 0
var game_start_time: float = 0.0
var is_tracking: bool = false

# References
var challenge_manager: Node
var game_node: Node

func _ready():
	# Get reference to challenge manager
	challenge_manager = get_node("/root/DailyChallengeManager")
	
	# Connect to game signals
	connect_to_game_signals()

# Connect to game events
func connect_to_game_signals():
	# Find game node
	var root = get_tree().get_root()
	game_node = root.get_child(root.get_child_count() - 1)
	
	if game_node and game_node.has_method("_on_Ball_add_score"):
		# Connect to score events
		if game_node.has_node("CanvasLayer/HUD"):
			var hud = game_node.get_node("CanvasLayer/HUD")
			hud.connect("score_updated", self, "_on_score_updated")
		
		# Connect to ball events
		if game_node.has_node("."):
			game_node.connect("ball_hit", self, "_on_ball_hit")
			game_node.connect("ball_missed", self, "_on_ball_missed")
			game_node.connect("ball_popped", self, "_on_ball_popped")
			game_node.connect("game_started", self, "_on_game_started")
			game_node.connect("game_ended", self, "_on_game_ended")

# Start tracking for a new game session
func start_tracking():
	session_start_time = OS.get_unix_time()
	session_score = 0
	balls_hit = 0
	balls_missed = 0
	consecutive_hits = 0
	max_consecutive_hits = 0
	balls_popped = 0
	game_start_time = OS.get_time_dict_from_system()["unix"]
	is_tracking = true

# Stop tracking at end of game session
func stop_tracking():
	is_tracking = false
	process_challenge_completion()
	
	# Reset tracking variables
	session_start_time = 0
	session_score = 0
	balls_hit = 0
	balls_missed = 0
	consecutive_hits = 0
	max_consecutive_hits = 0
	balls_popped = 0

# Update score tracking
func _on_score_updated(new_score: int):
	if not is_tracking:
		return
	
	session_score = new_score
	
	# Update score attack challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.SCORE_ATTACK:
			challenge_manager.update_challenge_progress(challenge.id, session_score)

# Track ball hits
func _on_ball_hit():
	if not is_tracking:
		return
	
	balls_hit += 1
	consecutive_hits += 1
	max_consecutive_hits = max(max_consecutive_hits, consecutive_hits)
	
	# Update accuracy challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.ACCURACY:
			challenge_manager.update_challenge_progress(challenge.id, consecutive_hits)
	
	# Update combo challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.COMBO_MASTER:
			challenge_manager.update_challenge_progress(challenge.id, max_consecutive_hits)

# Track ball misses
func _on_ball_missed():
	if not is_tracking:
		return
	
	balls_missed += 1
	consecutive_hits = 0  # Reset combo on miss

# Track ball pops
func _on_ball_popped():
	if not is_tracking:
		return
	
	balls_popped += 1
	
	# Update speed run challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.SPEED_RUN:
			challenge_manager.update_challenge_progress(challenge.id, balls_popped)

# Game started
func _on_game_started():
	start_tracking()

# Game ended
func _on_game_ended():
	stop_tracking()

# Process challenge completion at end of game
func process_challenge_completion():
	var game_duration = OS.get_unix_time() - session_start_time
	
	# Check survival challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.SURVIVAL:
			if game_duration >= challenge.target_value:
				challenge_manager.complete_challenge(challenge.id)
	
	# Check score attack challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.SCORE_ATTACK:
			if session_score >= challenge.target_value:
				challenge_manager.complete_challenge(challenge.id)
	
	# Check accuracy challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.ACCURACY:
			if balls_missed == 0 and balls_hit >= challenge.target_value:
				challenge_manager.complete_challenge(challenge.id)
	
	# Check speed run challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.SPEED_RUN:
			if balls_popped >= challenge.target_value:
				challenge_manager.complete_challenge(challenge.id)
	
	# Check combo challenges
	for challenge in challenge_manager.get_active_challenges():
		if challenge.type == ChallengeData.ChallengeType.COMBO_MASTER:
			if max_consecutive_hits >= challenge.target_value:
				challenge_manager.complete_challenge(challenge.id)

# Get current session stats
func get_session_stats() -> Dictionary:
	return {
		"session_score": session_score,
		"balls_hit": balls_hit,
		"balls_missed": balls_missed,
		"accuracy": float(balls_hit) / max(balls_hit + balls_missed, 1) * 100.0,
		"max_consecutive_hits": max_consecutive_hits,
		"balls_popped": balls_popped,
		"session_duration": OS.get_unix_time() - session_start_time
	}

# Manual trigger for testing
func debug_complete_all_challenges():
	for challenge in challenge_manager.get_active_challenges():
		challenge_manager.complete_challenge(challenge.id)
