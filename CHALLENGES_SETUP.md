# Daily Challenges Setup Guide

## Overview
This guide will help you set up the daily challenges system in your Ping Blast game.

## Quick Setup Steps

### 1. Add DailyChallengeManager to AutoLoad
1. Open Project Settings (Project → Project Settings)
2. Go to the AutoLoad tab
3. Add a new AutoLoad:
   - Path: `res://scripts/DailyChallengeManager.gd`
   - Name: `DailyChallengeManager`

### 2. Add ChallengeTracker to Game Scene
1. Open `scenes/Game.tscn`
2. Add a new Node (Node type) as a child of the root
3. Name it "ChallengeTracker"
4. Attach the script `res://scripts/ChallengeTracker.gd`

### 3. Update Scene References
The following scenes have been created and need to be linked:

- **DailyChallenges.tscn** - Main challenges display
- **ChallengeComplete.tscn** - Completion popup

### 4. Update Main Menu
The MainMenu.gd has been updated to include a challenges button. Ensure your MainMenu.tscn has:
- A button named "ChallengesButton" in the VBoxContainer
- The button will automatically connect to the challenges scene

## Testing the System

### Manual Testing
1. **Start the game** - Daily challenges should auto-generate
2. **Check Main Menu** - Look for the "Challenges" button
3. **Open Challenges** - Should display 3 daily challenges
4. **Play a game** - Progress should update automatically
5. **Complete a challenge** - Should show completion popup

### Debug Commands
You can use these debug commands in the console:
```gdscript
# Complete all active challenges (for testing)
get_node("/root/ChallengeTracker").debug_complete_all_challenges()

# Force reset challenges
get_node("/root/DailyChallengeManager").reset_daily_challenges()
```

## Challenge Types Available
- **Score Attack**: Reach target score
- **Survival**: Survive for X seconds
- **Accuracy**: Hit X balls without missing
- **Speed Run**: Pop X balls quickly
- **Combo Master**: Achieve X combo hits

## Reward System
- **Coins**: In-game currency
- **Power-ups**: Special abilities
- **Cosmetics**: Visual customizations
- **Score Multipliers**: Temporary score boosts

## File Structure
```
scripts/
├── DailyChallengeManager.gd    # Main challenge system
├── ChallengeData.gd          # Challenge definitions
├── ChallengeTracker.gd      # Progress tracking
├── DailyChallengesUI.gd     # Challenges UI controller
└── ChallengeCompletePopup.gd # Completion popup

scenes/
├── DailyChallenges.tscn     # Challenges display scene
└── ChallengeComplete.tscn   # Completion popup scene
```

## Troubleshooting

### Challenges not appearing
- Ensure DailyChallengeManager is in AutoLoad
- Check console for error messages
- Verify ChallengeTracker is added to Game.tscn

### Progress not updating
- Check that ChallengeTracker is properly connected to game events
- Verify challenge types match the tracking logic

### UI not displaying
- Ensure all scene files are in the correct locations
- Check font paths in UI scripts
- Verify button connections in MainMenu.tscn

## Next Steps
1. Test the system thoroughly
2. Add custom challenge templates
3. Implement reward redemption
4. Add challenge notifications
5. Create challenge history/stats
