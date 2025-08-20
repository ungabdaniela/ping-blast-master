extends Node

func _ready():
    print("=== Daily Challenges Debug Tool ===")
    
    # Check if DailyChallengeManager is in AutoLoad
    var manager = get_node("/root/DailyChallengeManager")
    if manager:
        print("✅ DailyChallengeManager found in AutoLoad")
    else:
        print("❌ DailyChallengeManager NOT found in AutoLoad")
        print("   Go to Project → Project Settings → AutoLoad")
        print("   Add DailyChallengeManager with path: res://scripts/DailyChallengeManager.gd")
        return
    
    # Check challenge templates
    var templates = ChallengeData.get_challenge_templates()
    print("✅ Challenge templates loaded: ", templates.size())
    
    # Check active challenges
    var challenges = manager.get_active_challenges()
    print("✅ Active challenges: ", challenges.size())
    
    if challenges.size() == 0:
        print("🔄 Generating new challenges...")
        manager.generate_daily_challenges()
        challenges = manager.get_active_challenges()
        print("✅ New challenges generated: ", challenges.size())
    
    # List all active challenges
    print("\n=== Active Challenges ===")
    for challenge in challenges:
        print("📋 ", challenge.title)
        print("   Type: ", ChallengeData.get_challenge_type_name(challenge.type))
        print("   Progress: ", challenge.current_progress, "/", challenge.target_value)
        print("   Completed: ", challenge.is_completed)
        print("   Claimed: ", challenge.is_claimed)
        print("")

func _input(event):
    if event.is_action_pressed("ui_accept"):
        # Test challenge completion
        var manager = get_node("/root/DailyChallengeManager")
        if manager:
            for challenge in manager.get_active_challenges():
                if not challenge.is_completed:
                    manager.complete_challenge(challenge.id)
                    print("✅ Completed challenge: ", challenge.title)
                    break
