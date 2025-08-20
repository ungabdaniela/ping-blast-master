# Daily Challenges Troubleshooting Guide

## Quick Diagnostic Steps

### 1. Check AutoLoad Configuration
**Issue**: DailyChallengeManager not in AutoLoad
**Solution**: 
1. Go to Project → Project Settings → AutoLoad
2. Verify `DailyChallengeManager` is added with path `res://scripts/DailyChallengeManager.gd`
3. Ensure it's enabled and has a valid node name

### 2. Verify File Paths
**Issue**: Missing or corrupted challenge files
**Solution**:
1. Check `user://daily_challenges.json` exists in user data
2. Check `user://last_challenge_reset.json` exists
3. Delete these files to force regeneration:
   - Windows: `%APPDATA%/Godot/app_userdata/[project_name]/`
   - Look for `daily_challenges.json` and `last_challenge_reset.json`

### 3. Test Daily Reset Function
**Issue**: Challenges not resetting daily
**Solution**:
```gdscript
# Add this debug code to DailyChallengeManager.gd
func _process(delta):
    if Input.is_key_pressed(KEY_F9):
        print("=== DEBUG: Daily Reset Check ===")
        print("Current time: ", OS.get_datetime_from_system())
        print("Last reset: ", get_last_reset_time())
        print("Should reset: ", should_reset_challenges(
            OS.get_datetime_from_system(), 
            get_last_reset_time() or {"year":1970,"month":1,"day":1}))
```

### 4. Check Challenge Generation
**Issue**: No challenges being generated
**Solution**:
```gdscript
# Add this debug code to DailyChallengeManager.gd
func _ready():
    print("=== DEBUG: Challenge Manager Ready ===")
    print("Templates loaded: ", challenge_templates.size())
    print("Active challenges: ", active_challenges.size())
    if active_challenges.size() == 0:
        print("Generating new challenges...")
        generate_daily_challenges()
```

### 5. Verify Signal Connections
**Issue**: UI not updating when challenges change
**Solution**:
1. Check DailyChallengesUI.gd connects to challenge_manager signals
2. Verify ChallengeTracker.gd connects to game events
3. Test signal emission with debug prints

### 6. Test Challenge Progress
**Issue**: Progress not updating
**Solution**:
```gdscript
# Add to Game.gd or relevant game script
func _on_score_updated(new_score):
    var challenge_manager = get_node("/root/DailyChallengeManager")
    for challenge in challenge_manager.get_active_challenges():
        if challenge.type == ChallengeData.ChallengeType.SCORE_ATTACK:
            challenge_manager.update_challenge_progress(challenge.id, new_score)
            print("Updated challenge: ", challenge.id, " progress: ", new_score)
```

## Step-by-Step Debug Process

### Step 1: Verify System Initialization
1. Run game and check console for:
   - "Challenge Manager Ready" messages
   - Number of templates loaded
   - Number of active challenges

### Step 2: Test Challenge Display
1. Open Daily Challenges scene
2. Check if challenges appear in UI
3. Verify challenge details are correct

### Step 3: Test Progress Tracking
1. Start a game
2. Score some points
3. Check if score attack challenges update
4. Look for debug prints showing progress updates

### Step 4: Test Completion
1. Complete a challenge objective
2. Check if challenge shows as completed
3. Test reward claiming

### Step 5: Test Daily Reset
1. Manually trigger reset (see debug code above)
2. Verify new challenges are generated
3. Check reset time is saved correctly

## Common Error Messages & Solutions

### "Challenge templates empty"
- **Cause**: ChallengeData.gd not returning templates
- **Fix**: Check ChallengeData.get_challenge_templates() returns data

### "No active challenges"
- **Cause**: Generation failed or file loading issue
- **Fix**: Delete user://daily_challenges.json to force regeneration

### "Progress not updating"
- **Cause**: ChallengeTracker not connected to game events
- **Fix**: Verify signal connections in ChallengeTracker.gd

### "UI not refreshing"
- **Cause**: Signal not reaching UI
- **Fix**: Check DailyChallengesUI.gd signal connections

## Quick Fix Script
Create a debug script to test the system:

```gdscript
# Create res://scripts/DebugChallenges.gd
extends Node

func _ready():
    var manager = get_node("/root/DailyChallengeManager")
    
    # Test 1: Check if manager exists
    if manager:
        print("✅ Challenge Manager found")
    else:
        print("❌ Challenge Manager not found")
        return
    
    # Test 2: Check templates
    var templates = ChallengeData.get_challenge_templates()
    print("✅ Templates loaded: ", templates.size())
    
    # Test 3: Check active challenges
    var challenges = manager.get_active_challenges()
    print("✅ Active challenges: ", challenges.size())
    
    # Test 4: Force generate if empty
    if challenges.size() == 0:
        manager.generate_daily_challenges()
        print("✅ Generated new challenges")
    
    # Test 5: List challenges
    for challenge in manager.get_active_challenges():
        print("Challenge: ", challenge.title, " Progress: ", challenge.get_progress_percentage(), "%")
```

## Contact Support
If issues persist after following this guide:
1. Provide console output from debug steps
2. Share your DailyChallengeManager.gd modifications
3. Include any error messages from the debugger
