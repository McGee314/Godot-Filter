# Test Types and Execution Methods

**Date:** 2025-08-28  
**Status:** ✅ COMPREHENSIVE GUIDE  
**Purpose:** Differentiate between headless and editor-based tests

## Overview

Our project has different types of tests that require different execution environments. Understanding these differences is crucial for effective testing and CI/CD integration.

## Test Categories

### 🖥️ **Headless Tests (Automated)**
**Environment:** Command line, CI/CD, automated scripts  
**Purpose:** Core logic, data structures, algorithms, pure functions  
**Execution:** `--headless` mode or command line

### 🎮 **Editor Tests (Interactive)**
**Environment:** Godot Editor  
**Purpose:** UI components, addons, visual systems, interactive features  
**Execution:** Godot Editor with visual feedback

## Test Runner Files

### 1. **`run_tests.gd`** - Main Test Logic
**Purpose:** Contains the actual test functions  
**Environment:** Can run in both headless and editor  
**Content:** Core test functions for cultural systems, data validation, etc.

### 2. **`run_tests_cli.gd`** - Headless Execution Wrapper
**Purpose:** Command line entry point for headless testing  
**Environment:** Headless mode only  
**Usage:** `godot --headless --script Tests/Core_Systems/run_tests_cli.gd`

### 3. **`TestRunner.tscn`** - Editor Execution Wrapper
**Purpose:** Scene-based entry point for editor testing  
**Environment:** Godot Editor  
**Usage:** Open in editor and press F5

## Test Classification Guide

### ✅ **Headless-Compatible Tests**

#### **Core Systems (Pure Logic)**
- **Global State Management**
  - Session tracking
  - Artifact collection
  - Progress calculation
  - Data validation

- **Cultural Item System**
  - Object creation
  - Property validation
  - Data structure tests
  - Algorithm testing

- **Region Data**
  - Data structure validation
  - Content verification
  - Configuration testing

- **Session Progress**
  - Time calculations
  - Progress percentages
  - Remaining time logic

#### **Data Validation**
- **File System Checks**
  - Asset existence
  - File integrity
  - Path validation

- **Resource Loading**
  - Script loading
  - Resource validation
  - Configuration parsing

#### **Algorithm Testing**
- **Mathematical Functions**
  - Progress calculations
  - Time conversions
  - Statistical functions

- **Data Processing**
  - JSON parsing
  - Data transformation
  - Validation logic

### 🎮 **Editor-Required Tests**

#### **Addon Dependencies**
- **Terrain3D Addon**
  - Node creation
  - Property access
  - Method testing
  - Material assignment

- **GDExtensions**
  - Native library loading
  - Extension functionality
  - Platform-specific features

#### **Visual Systems**
- **UI Components**
  - Radar systems
  - Splash screens
  - Interface elements
  - Layout testing

- **3D Rendering**
  - Terrain visualization
  - Asset placement
  - Material rendering
  - Lighting systems

#### **Interactive Features**
- **Input Systems**
  - Key bindings
  - Mouse interactions
  - Touch controls
  - Input validation

- **NPC Interactions**
  - Dialogue systems
  - Interaction mechanics
  - Character behavior
  - Animation testing

## Execution Methods

### 🖥️ **Headless Execution**

#### **Command Line (Recommended for CI/CD)**
```bash
# Run all headless tests
godot --headless --script Tests/Core_Systems/run_tests_cli.gd

# Run specific test categories
godot --headless --script Tests/Validation_Scripts/validate_phase1.py

# Run with output redirection
godot --headless --script Tests/Core_Systems/run_tests_cli.gd > test_results.txt 2>&1
```

#### **Windows Batch Files**
```batch
# Quick test execution (Windows)
Tests\run_tests_quick.bat

# Interactive test menu (Windows)
Tests\Core_Systems\run_tests_example.bat
```

#### **Python Validation Scripts**
```bash
# Run Python validation
python Tests/Validation_Scripts/validate_phase1.py

# Run with specific parameters
python Tests/Validation_Scripts/validate_phase1.py --verbose
```

### 🎮 **Editor Execution**

#### **Scene-Based Testing**
```bash
# Open test scenes in editor
Tests/Terrain3D/test_terrain3d_editor.tscn
Tests/PSX_Assets/test_psx_placement_editor.tscn
Tests/Phase1_Integration/test_phase1_integration_editor.tscn
```

#### **Interactive Testing**
- Open scene in Godot Editor
- Press F5 to run
- Use UI controls for testing
- Check Output panel for results

## Test Organization by Type

### 📁 **Headless Tests Location**
```
Tests/
├── Core_Systems/           # Pure logic tests
│   ├── run_tests.gd       # Main test logic
│   ├── run_tests_cli.gd   # Headless wrapper
│   └── TestRunner.tscn    # Editor wrapper
└── Validation_Scripts/     # Automated validation
    ├── validate_phase1.py
    ├── validate_phase0_scenes.gd
    └── validate_phase3_scenes.gd
```

### 📁 **Editor Tests Location**
```
Tests/
├── Terrain3D/             # Addon-dependent tests
├── PSX_Assets/            # Visual asset tests
├── Phase1_Integration/    # Integration tests
├── Input_Systems/         # Interactive input tests
├── NPC_Interaction/       # Character interaction tests
└── UI_Components/         # Visual UI tests
```

## CI/CD Integration Strategy

### **Automated Pipeline**
```yaml
# Example GitHub Actions workflow
steps:
  - name: Run Headless Tests
    run: |
      godot --headless --script Tests/Core_Systems/run_tests_cli.gd
      
  - name: Run Validation Scripts
    run: |
      python Tests/Validation_Scripts/validate_phase1.py
      
  - name: Check Test Results
    run: |
      # Parse test output and fail if tests failed
```

### **Manual Testing Checklist**
```markdown
## Editor Tests (Manual)
- [ ] Terrain3D addon functionality
- [ ] PSX asset placement
- [ ] UI component behavior
- [ ] Input system responsiveness
- [ ] NPC interaction mechanics
- [ ] Visual rendering quality
```

## Best Practices

### **For Headless Tests:**
1. **Keep tests pure** - No visual dependencies
2. **Use descriptive output** - Clear pass/fail messages
3. **Handle errors gracefully** - Don't crash on failures
4. **Test edge cases** - Boundary conditions and error states
5. **Make tests fast** - Avoid unnecessary delays

### **For Editor Tests:**
1. **Provide clear instructions** - UI labels and help text
2. **Include visual feedback** - Status updates and progress indicators
3. **Test user workflows** - Complete interaction sequences
4. **Validate visual output** - Check rendering and appearance
5. **Document manual steps** - Clear testing procedures

### **For Both Types:**
1. **Use consistent naming** - Clear test function names
2. **Group related tests** - Logical test organization
3. **Provide clear documentation** - Purpose and usage instructions
4. **Handle cleanup** - Proper resource management
5. **Version control** - Track test changes with code

## Troubleshooting

### **Headless Test Issues:**
- **GDExtension loading fails** → Move to editor tests
- **Resource loading errors** → Check file paths and dependencies
- **Autoload not available** → Use fallback initialization
- **Platform differences** → Test on target platforms

### **Editor Test Issues:**
- **Addon not loaded** → Check plugin enablement
- **Visual glitches** → Test on different hardware
- **Performance issues** → Profile and optimize
- **User interaction problems** → Improve UI/UX

## Summary

| Test Type | Environment | Purpose | Execution |
|-----------|-------------|---------|-----------|
| **Headless** | Command line | Core logic, data, algorithms | `--headless` mode |
| **Editor** | Godot Editor | Visual, interactive, addons | Editor + F5 |

**Key Principle:** Use headless tests for everything that doesn't require visual feedback or addon dependencies. Use editor tests for everything that does.

---

**Result:** Clear separation of concerns allows for automated testing of core functionality while maintaining comprehensive visual and interactive testing in the editor environment.
