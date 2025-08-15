extends Node

var scores_file = "user://leaderboards.json"
var max_scores = 10

# Structure of the leaderboard data:
# {
#   "scores": [
#     {"player_name": "Player1", "score": 1000},
#     {"player_name": "Player2", "score": 800},
#     etc...
#   ]
# }

func add_score(player_name: String, score: int) -> void:
	var scores = load_scores()
	
	# Check if player already exists
	var player_found = false
	for i in range(scores.size()):
		if scores[i].player_name == player_name:
			# Update score if new score is higher
			if score > scores[i].score:
				scores[i].score = score
			player_found = true
			break
	
	# Add new player if not found
	if not player_found:
		scores.append({"player_name": player_name, "score": score})
	
	# Sort scores in descending order
	scores.sort_custom(self, "sort_by_score")
	
	# Keep only the top scores
	if scores.size() > max_scores:
		scores.resize(max_scores)
	
	save_scores(scores)

func load_scores() -> Array:
	var scores = []
	var file = File.new()
	
	if file.file_exists(scores_file):
		file.open(scores_file, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		
		if data and "scores" in data:
			scores = data.scores
	
	return scores

func save_scores(scores: Array) -> void:
	var file = File.new()
	var data = {"scores": scores}
	file.open(scores_file, File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()

func get_high_score() -> int:
	var scores = load_scores()
	if scores.size() > 0:
		return scores[0].score
	return 0

func sort_by_score(a: Dictionary, b: Dictionary) -> bool:
	return a.score > b.score  # Sort in descending order
