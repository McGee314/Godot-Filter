# Input Handling Test - Isolating `!is_inside_tree()` Error

## Overview
This test is designed to isolate and reproduce the `_push_unhandled_input_internal: Condition "!is_inside_tree()" is true` error that occurs in the NPC dialog system.

## Problem Description
The error occurs when input events are pushed to nodes that are no longer part of the scene tree. This typically happens when:
1. Nodes are freed/removed before input processing is complete
2. Timers continue to fire after nodes are destroyed
3. Input handling doesn't properly check node validity

## Test Files
- `test_input_handling.tscn` - Simple test scene
- `test_input_handling.gd` - Test script with isolated input handling
- `README_input_handling_test.md` - This documentation

## Test Scenarios

### 1. Basic Input Handling
- Tests if input handling works correctly when node is in tree
- Verifies input consumption works properly
- Checks timer lifecycle management

### 2. Node Lifecycle Testing
- Tests what happens when nodes are removed from tree
- Verifies proper cleanup of timers
- Checks for `!is_inside_tree()` conditions

### 3. Timer Lifecycle Testing
- Creates temporary timers to test cleanup
- Verifies timer callbacks handle invalid nodes properly
- Tests timer destruction during node removal

## How to Run the Test

1. **Load the Test Scene**:
   ```
   Open: Tests/test_input_handling.tscn
   ```

2. **Run the Test**:
   - Press F5 or click "Play Scene"
   - Watch the output console for debug messages
   - Press Enter key to test input handling
   - Click the test button to trigger timer tests

3. **Expected Behavior**:
   - No `!is_inside_tree()` errors
   - Proper cleanup messages in console
   - Input handling works without crashes

## Debug Output

The test will output detailed information about:
- Node lifecycle events (`_ready`, `_exit_tree`, `_notification`)
- Timer creation and destruction
- Input handling attempts
- Node validity checks

## Common Issues to Look For

### 1. Timer Cleanup Issues
```
TestInputHandling: WARNING - Node is not in tree!
```
This indicates a timer is still firing after the node is removed.

### 2. Input Handling After Node Removal
```
_push_unhandled_input_internal: Condition "!is_inside_tree()" is true
```
This is the main error we're trying to isolate.

### 3. Missing Cleanup
```
TestInputHandling: Node no longer valid or not in tree
```
This indicates improper node lifecycle management.

## Fixing the Issues

### 1. Proper Timer Cleanup
```gdscript
func _exit_tree():
    if input_timer and is_instance_valid(input_timer):
        input_timer.stop()
        input_timer.queue_free()
```

### 2. Input Validity Checks
```gdscript
func _test_input_handling():
    if not is_inside_tree():
        return  # Don't process input if not in tree
```

### 3. Timer Callback Safety
```gdscript
temp_timer.timeout.connect(func():
    if is_instance_valid(self) and is_inside_tree():
        # Process timer callback
    else:
        # Clean up and exit
        if is_instance_valid(temp_timer):
            temp_timer.queue_free()
)
```

## Applying Fixes to Main Code

Once the test identifies the specific issue, apply similar fixes to:
- `Systems/NPCs/CulturalNPC.gd` - Dialog input handling
- Timer cleanup in typewriter animation
- Input consumption in dialog system

## Test Results Logging

The test creates detailed logs to help identify:
- When nodes enter/exit the tree
- When timers are created/destroyed
- When input handling attempts occur
- Any `!is_inside_tree()` conditions

## Next Steps

1. Run the test and observe the output
2. Identify specific timing of the `!is_inside_tree()` error
3. Apply targeted fixes to the main dialog system
4. Re-test to ensure the error is resolved

---

**Test Created**: 2025-08-28  
**Purpose**: Isolate input handling lifecycle issues  
**Status**: Ready for testing
