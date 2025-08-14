extends Control

onready var scores_list = $ScoresList

func _ready():
    # Replace with actual leaderboard fetch logic
    var leaderboard = get_node("/root/SilentWolf/Scores/Leaderboard")
    var scores = leaderboard.get_top_scores()
    for score in scores:
        scores_list.add_item(str(score["rank"]) + ". " + score["player_name"] + " - " + str(score["score"]))
