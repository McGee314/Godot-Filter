# NPC Interaction Test Scene

This test scene isolates the player and NPC interaction system to verify that the reinteraction fix is working properly.

## Files

- `test_npc_interaction.tscn` - The test scene with player and NPC
- `TestNPC.gd` - Simplified NPC script for testing
- `test_npc_interaction_debug.gd` - Debug script to monitor the system

## How to Use

1. **Open the test scene**: Load `Tests/test_npc_interaction.tscn` in Godot
2. **Run the scene**: Press F5 or click the play button
3. **Follow the test instructions** that appear in the console

## Test Instructions

1. **Move around**: Use WASD to move the player (blue capsule)
2. **Approach the NPC**: Move towards the NPC (blue cylinder)
3. **Interact**: Press E when the interaction prompt appears
4. **Complete dialogue**: Press 1, 2, or 3 to respond to the NPC
5. **Test reinteraction**: Try to press E again immediately (should be blocked)
6. **Wait for cooldown**: Wait 3 seconds and try again (should work)
7. **Test flickering**: Move around while near the NPC (should not flicker)

## Expected Results

✅ **No flickering** when moving mouse or using WASD  
✅ **No reinteraction** for 3 seconds after dialogue ends  
✅ **Smooth interaction** with proper visual feedback  
✅ **Stable state management** with comprehensive logging  

## Debug Information

The debug script will show:
- Current interactable object
- Whether player is near an interactable
- Number of NPCs in range
- Nearest NPC
- Time since last interaction
- Interaction cooldown status

## Troubleshooting

If the test doesn't work as expected:

1. **Check console output** for error messages
2. **Verify collision layers** - Player should be on layer 1
3. **Check NPC group** - NPC should be in "npc" group
4. **Verify signals** - Area3D signals should be connected

## Key Features Tested

- **Area3D detection**: NPC detects player entering/exiting range
- **InteractionController**: Handles input and state management
- **Anti-flicker system**: Prevents rapid state changes
- **Cooldown system**: Prevents reinteraction for 3 seconds
- **Visual feedback**: NPC changes color when player is in range

## Integration with Main Game

Once this test passes, the same fixes can be applied to the main game:
- Update `InteractionController.gd` with the dual detection system
- Ensure all NPCs are in the "npc" group
- Verify collision layers are set correctly
