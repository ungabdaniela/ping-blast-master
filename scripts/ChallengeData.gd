extends Node

# Challenge types enumeration
enum ChallengeType {
	SCORE_ATTACK,
	SURVIVAL,
	ACCURACY,
	SPEED_RUN,
	COMBO_MASTER,
	BOSS_HUNTER
}

# Challenge difficulty levels
enum ChallengeDifficulty {
	EASY,
	MEDIUM,
	HARD,
	EXPERT
}

# Reward types
enum RewardType {
	COINS,
	POWERUP,
	COSMETIC,
	SCORE_MULTIPLIER
}

# Challenge data structure
class Challenge:
	var id: String
	var title: String
	var description: String
	var type: int
	var difficulty: int
	var target_value: int
	var current_progress: int = 0
	var reward_type: int
	var reward_amount: int
	var time_limit: int = 0  # in seconds, 0 for no limit
	var is_completed: bool = false
	var is_claimed: bool = false
	var expiration_date: String
	
	func _init(p_id: String, p_title: String, p_description: String, p_type: int, 
			   p_difficulty: int, p_target: int, p_reward_type: int, p_reward_amount: int, 
			   p_time_limit: int = 0):
		id = p_id
		title = p_title
		description = p_description
		type = p_type
		difficulty = p_difficulty
		target_value = p_target
		reward_type = p_reward_type
		reward_amount = p_reward_amount
		time_limit = p_time_limit
	
	func get_progress_percentage() -> float:
		return float(current_progress) / float(target_value) * 100.0
	
	func can_claim() -> bool:
		return is_completed and not is_claimed
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"title": title,
			"description": description,
			"type": type,
			"difficulty": difficulty,
			"target_value": target_value,
			"current_progress": current_progress,
			"reward_type": reward_type,
			"reward_amount": reward_amount,
			"time_limit": time_limit,
			"is_completed": is_completed,
			"is_claimed": is_claimed,
			"expiration_date": expiration_date
		}
	
	func from_dict(data: Dictionary):
		id = data.get("id", "")
		title = data.get("title", "")
		description = data.get("description", "")
		type = data.get("type", 0)
		difficulty = data.get("difficulty", 0)
		target_value = data.get("target_value", 0)
		current_progress = data.get("current_progress", 0)
		reward_type = data.get("reward_type", 0)
		reward_amount = data.get("reward_amount", 0)
		time_limit = data.get("time_limit", 0)
		is_completed = data.get("is_completed", false)
		is_claimed = data.get("is_claimed", false)
		expiration_date = data.get("expiration_date", "")

# Challenge templates
static func get_challenge_templates() -> Array:
	var templates = []
	
	# Score Attack Challenges
	templates.append({
		"id": "score_attack_easy",
		"title": "Score Novice",
		"description": "Reach 1000 points in a single game",
		"type": ChallengeType.SCORE_ATTACK,
		"difficulty": ChallengeDifficulty.EASY,
		"target": 1000,
		"reward_type": RewardType.COINS,
		"reward_amount": 50
	})
	
	templates.append({
		"id": "score_attack_medium",
		"title": "Score Master",
		"description": "Reach 5000 points in a single game",
		"type": ChallengeType.SCORE_ATTACK,
		"difficulty": ChallengeDifficulty.MEDIUM,
		"target": 5000,
		"reward_type": RewardType.COINS,
		"reward_amount": 100
	})
	
	# Survival Challenges
	templates.append({
		"id": "survival_easy",
		"title": "Survivor",
		"description": "Survive for 60 seconds",
		"type": ChallengeType.SURVIVAL,
		"difficulty": ChallengeDifficulty.EASY,
		"target": 60,
		"reward_type": RewardType.COINS,
		"reward_amount": 75
	})
	
	# Accuracy Challenges
	templates.append({
		"id": "accuracy_medium",
		"title": "Sharpshooter",
		"description": "Hit 20 balls without missing",
		"type": ChallengeType.ACCURACY,
		"difficulty": ChallengeDifficulty.MEDIUM,
		"target": 20,
		"reward_type": RewardType.POWERUP,
		"reward_amount": 1
	})
	
	# Speed Run Challenges
	templates.append({
		"id": "speed_run_hard",
		"title": "Speed Demon",
		"description": "Pop 30 balls as fast as possible",
		"type": ChallengeType.SPEED_RUN,
		"difficulty": ChallengeDifficulty.HARD,
		"target": 30,
		"reward_type": RewardType.COINS,
		"reward_amount": 150
	})
	
	# Combo Master Challenges
	templates.append({
		"id": "combo_expert",
		"title": "Combo King",
		"description": "Achieve a 10-hit combo",
		"type": ChallengeType.COMBO_MASTER,
		"difficulty": ChallengeDifficulty.EXPERT,
		"target": 10,
		"reward_type": RewardType.SCORE_MULTIPLIER,
		"reward_amount": 2
	})
	
	return templates

# Helper functions
static func get_challenge_type_name(type: int) -> String:
	match type:
		ChallengeType.SCORE_ATTACK: return "Score Attack"
		ChallengeType.SURVIVAL: return "Survival"
		ChallengeType.ACCURACY: return "Accuracy"
		ChallengeType.SPEED_RUN: return "Speed Run"
		ChallengeType.COMBO_MASTER: return "Combo Master"
		ChallengeType.BOSS_HUNTER: return "Boss Hunter"
		_: return "Unknown"

static func get_difficulty_name(difficulty: int) -> String:
	match difficulty:
		ChallengeDifficulty.EASY: return "Easy"
		ChallengeDifficulty.MEDIUM: return "Medium"
		ChallengeDifficulty.HARD: return "Hard"
		ChallengeDifficulty.EXPERT: return "Expert"
		_: return "Unknown"

static func get_reward_type_name(reward_type: int) -> String:
	match reward_type:
		RewardType.COINS: return "Coins"
		RewardType.POWERUP: return "Power-up"
		RewardType.COSMETIC: return "Cosmetic"
		RewardType.SCORE_MULTIPLIER: return "Score Multiplier"
		_: return "Unknown"
