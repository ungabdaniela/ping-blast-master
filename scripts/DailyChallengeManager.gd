extends Node

# Signal emitted when challenges are updated
signal challenges_updated
signal challenge_completed(challenge_id)
signal reward_claimed(challenge_id, reward)

# Constants
const CHALLENGES_FILE = "user://daily_challenges.json"
const CHALLENGES_RESET_HOUR = 0  # UTC hour for daily reset
const MAX_ACTIVE_CHALLENGES = 3

# Current active challenges
var active_challenges: Array = []
var challenge_templates: Array = []

func _ready():
	# Load challenge templates
	challenge_templates = ChallengeData.get_challenge_templates()
	
	# Load saved challenges
	load_challenges()
	
	# Check if we need to reset challenges
	check_daily_reset()
	
	# Generate new challenges if needed
	if active_challenges.size() == 0:
		generate_daily_challenges()

# Check if it's time for daily reset
func check_daily_reset():
	var now = OS.get_datetime_from_system()
	var last_reset = get_last_reset_time()
	
	if last_reset == null or should_reset_challenges(now, last_reset):
		reset_daily_challenges()
		save_last_reset_time(now)

# Determine if challenges should be reset
func should_reset_challenges(current_time: Dictionary, last_reset: Dictionary) -> bool:
	# Check if it's a new day (00:00 UTC)
	if current_time["day"] != last_reset["day"] or \
	   current_time["month"] != last_reset["month"] or \
	   current_time["year"] != last_reset["year"]:
		return true
	
	# Check if it's past reset hour
	if current_time["hour"] >= CHALLENGES_RESET_HOUR and \
	   last_reset["hour"] < CHALLENGES_RESET_HOUR:
		return true
	
	return false

# Generate new daily challenges
func generate_daily_challenges():
	active_challenges.clear()
	
	# Filter templates by difficulty for balanced selection
	var easy_challenges = []
	var medium_challenges = []
	var hard_challenges = []
	
	for template in challenge_templates:
		match template.difficulty:
			ChallengeData.ChallengeDifficulty.EASY:
				easy_challenges.append(template)
			ChallengeData.ChallengeDifficulty.MEDIUM:
				medium_challenges.append(template)
			ChallengeData.ChallengeDifficulty.HARD:
				hard_challenges.append(template)
	
	# Select balanced challenges
	var selected = []
	
	# Always include 1 easy challenge
	if easy_challenges.size() > 0:
		selected.append(easy_challenges[randi() % easy_challenges.size()])
	
	# Include 1 medium challenge
	if medium_challenges.size() > 0:
		selected.append(medium_challenges[randi() % medium_challenges.size()])
	
	# Include 1 hard challenge
	if hard_challenges.size() > 0:
		selected.append(hard_challenges[randi() % hard_challenges.size()])
	
	# Create challenge instances
	for template in selected:
		var challenge = ChallengeData.Challenge.new(
			template.id,
			template.title,
			template.description,
			template.type,
			template.difficulty,
			template.target,
			template.reward_type,
			template.reward_amount,
			template.time_limit
		)
		
		# Set expiration date (24 hours from now)
		var now = OS.get_datetime_from_system()
		var expiration = now.duplicate()
		expiration["day"] += 1
		challenge.expiration_date = "%04d-%02d-%02d" % [expiration["year"], expiration["month"], expiration["day"]]
		
		active_challenges.append(challenge)
	
	save_challenges()
	emit_signal("challenges_updated")

# Reset all challenges
func reset_daily_challenges():
	for challenge in active_challenges:
		challenge.current_progress = 0
		challenge.is_completed = false
		challenge.is_claimed = false
	
	generate_daily_challenges()

# Update challenge progress
func update_challenge_progress(challenge_id: String, progress: int):
	for challenge in active_challenges:
		if challenge.id == challenge_id:
			challenge.current_progress = min(progress, challenge.target_value)
			
			if challenge.current_progress >= challenge.target_value and not challenge.is_completed:
				challenge.is_completed = true
				emit_signal("challenge_completed", challenge_id)
			
			save_challenges()
			emit_signal("challenges_updated")
			break

# Complete a challenge
func complete_challenge(challenge_id: String):
	for challenge in active_challenges:
		if challenge.id == challenge_id:
			challenge.is_completed = true
			challenge.current_progress = challenge.target_value
			emit_signal("challenge_completed", challenge_id)
			save_challenges()
			emit_signal("challenges_updated")
			break

# Claim challenge reward
func claim_challenge_reward(challenge_id: String) -> bool:
	for challenge in active_challenges:
		if challenge.id == challenge_id and challenge.can_claim():
			# Apply reward based on type
			apply_reward(challenge.reward_type, challenge.reward_amount)
			
			challenge.is_claimed = true
			save_challenges()
			emit_signal("reward_claimed", challenge_id, challenge.reward_amount)
			emit_signal("challenges_updated")
			return true
	
	return false

# Apply reward to player
func apply_reward(reward_type: int, amount: int):
	match reward_type:
		ChallengeData.RewardType.COINS:
			# Add coins to player (implement coin system)
			pass
		ChallengeData.RewardType.POWERUP:
			# Add power-up to player inventory
			pass
		ChallengeData.RewardType.COSMETIC:
			# Unlock cosmetic item
			pass
		ChallengeData.RewardType.SCORE_MULTIPLIER:
			# Apply score multiplier for next game
			pass

# Get active challenges
func get_active_challenges() -> Array:
	return active_challenges

# Get completed but unclaimed challenges
func get_completed_challenges() -> Array:
	var completed = []
	for challenge in active_challenges:
		if challenge.is_completed and not challenge.is_claimed:
			completed.append(challenge)
	return completed

# Get challenge by ID
func get_challenge_by_id(challenge_id: String) -> ChallengeData.Challenge:
	for challenge in active_challenges:
		if challenge.id == challenge_id:
			return challenge
	return null

# Save challenges to file
func save_challenges():
	var data = {
		"challenges": []
	}
	
	for challenge in active_challenges:
		data["challenges"].append(challenge.to_dict())
	
	var file = File.new()
	file.open(CHALLENGES_FILE, File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()

# Load challenges from file
func load_challenges():
	active_challenges.clear()
	
	var file = File.new()
	if not file.file_exists(CHALLENGES_FILE):
		return
	
	file.open(CHALLENGES_FILE, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	
	if data and "challenges" in data:
		for challenge_data in data["challenges"]:
			var challenge = ChallengeData.Challenge.new("", "", "", 0, 0, 0, 0, 0)
			challenge.from_dict(challenge_data)
			active_challenges.append(challenge)

# Save last reset time
func save_last_reset_time(time: Dictionary):
	var file = File.new()
	file.open("user://last_challenge_reset.json", File.WRITE)
	file.store_string(JSON.print(time))
	file.close()

# Get last reset time
func get_last_reset_time() -> Dictionary:
	var file = File.new()
	if not file.file_exists("user://last_challenge_reset.json"):
		return null
	
	file.open("user://last_challenge_reset.json", File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	
	return data

# Check if player has completed a specific challenge type
func has_completed_challenge_type(challenge_type: int) -> bool:
	for challenge in active_challenges:
		if challenge.type == challenge_type and challenge.is_completed:
			return true
	return false

# Get total progress across all challenges
func get_total_progress() -> Dictionary:
	var total = {
		"total_challenges": active_challenges.size(),
		"completed_challenges": 0,
		"claimed_rewards": 0,
		"total_progress": 0.0
	}
	
	var total_progress = 0.0
	for challenge in active_challenges:
		if challenge.is_completed:
			total["completed_challenges"] += 1
		if challenge.is_claimed:
			total["claimed_rewards"] += 1
		total_progress += challenge.get_progress_percentage()
	
	total["total_progress"] = total_progress / max(active_challenges.size(), 1)
	
	return total
