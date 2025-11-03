# Tests Directory - Organized Structure

**Date:** 2025-08-28  
**Status:** ✅ RESTRUCTURED AND ORGANIZED

## Overview

The Tests directory has been reorganized into logical subfolders for better navigation, maintenance, and clarity. Each folder contains related test files with a specific purpose.

## Directory Structure

```
Tests/
├── Terrain3D/                    # Terrain3D addon tests
├── PSX_Assets/                   # PSX asset management tests
├── Phase1_Integration/           # Phase 1 integration tests
├── Input_Systems/                # Input handling and systems tests
├── NPC_Interaction/              # NPC and interaction tests
├── UI_Components/                # UI component tests
├── Validation_Scripts/           # Validation and verification scripts
├── Core_Systems/                 # Core game system tests
└── README.md                     # This file
```

## Folder Details

### 🏔️ **Terrain3D/**
**Purpose:** Tests for Terrain3D addon functionality
**Files:**
- `test_terrain3d_editor.tscn/gd` - Editor-based Terrain3D testing
- `test_terrain3d_addon.tscn/gd` - Basic addon functionality tests
- `test_terrain3d_reinstall.tscn/gd` - Addon reinstallation tests
- `test_terrain3d_simple.tscn/gd` - Simple addon validation
- `test_terrain3d_simple_check.gd` - Quick addon check
- `test_terrain.tscn/gd` - General terrain functionality

**Usage:** Run these tests to verify Terrain3D addon is working properly in the editor environment.

### 🎨 **PSX_Assets/**
**Purpose:** Tests for PSX-style asset management and placement
**Files:**
- `test_psx_assets.tscn/gd` - PSX asset pack validation
- `test_psx_placement_editor.tscn/gd` - Interactive asset placement testing

**Usage:** Test PSX asset loading, validation, and placement on terrain.

### 🔗 **Phase1_Integration/**
**Purpose:** Comprehensive Phase 1 integration testing
**Files:**
- `test_phase1_integration_editor.tscn/gd` - Complete Phase 1 validation with UI
- `test_phase1_simple.tscn/gd` - Basic Phase 1 component testing
- `test_phase1_terrain_integration.tscn/gd` - Terrain + PSX integration

**Usage:** Validate that all Phase 1 components work together properly.

### ⌨️ **Input_Systems/**
**Purpose:** Input handling and system tests
**Files:**
- `test_input_handling.tscn/gd` - Input system functionality
- `test_input_oop_pattern.tscn/gd` - Object-oriented input patterns
- `test_input_fix.gd` - Input system fixes

**Usage:** Test input handling, key bindings, and input system architecture.

### 👥 **NPC_Interaction/**
**Purpose:** NPC interaction and dialogue system tests
**Files:**
- `test_npc_interaction.tscn/gd` - Main NPC interaction testing
- `test_npc_interaction_debug.gd` - NPC interaction debugging
- `test_npc_interaction_fix.gd` - NPC interaction fixes
- `test_interaction_debug.gd` - General interaction debugging
- `test_phase0_interaction.tscn` - Phase 0 interaction tests
- `test_phase0_npc_dialogue.tscn` - NPC dialogue system tests

**Usage:** Test NPC interactions, dialogue systems, and interaction mechanics.

### 🖥️ **UI_Components/**
**Purpose:** User interface component tests
**Files:**
- `test_radar.tscn` - Basic radar functionality
- `test_simple_radar.tscn` - Simple radar implementation
- `test_themed_radar.tscn` - Themed radar components
- `test_splash_screen.tscn` - Splash screen testing
- `test_phase0_ui.tscn` - Phase 0 UI components

**Usage:** Test UI components, radar systems, and interface elements.

### ✅ **Validation_Scripts/**
**Purpose:** Automated validation and verification scripts
**Files:**
- `validate_phase1.py` - Python validation script for Phase 1
- `validate_phase0_scenes.gd` - Phase 0 scene validation
- `validate_phase3_scenes.gd` - Phase 3 scene validation

**Usage:** Automated testing and validation of project components.

### ⚙️ **Core_Systems/**
**Purpose:** Core game system tests
**Files:**
- `test_components.gd` - Component system testing
- `test_eventbus.gd` - Event bus system testing
- `test_enhanced_systems.gd` - Enhanced system functionality
- `test_cultural_systems.gd` - Cultural system testing
- `test_jump.gd` - Jump mechanics testing
- `test_is_inside_tree_fix.tscn/gd` - Tree traversal fixes

**Usage:** Test core game systems, event handling, and fundamental mechanics.

## Quick Navigation Guide

### For Terrain3D Testing:
```bash
# Open Terrain3D test in editor
Tests/Terrain3D/test_terrain3d_editor.tscn
```

### For PSX Asset Testing:
```bash
# Open PSX placement test
Tests/PSX_Assets/test_psx_placement_editor.tscn
```

### For Phase 1 Integration:
```bash
# Open comprehensive integration test
Tests/Phase1_Integration/test_phase1_integration_editor.tscn
```

### For Input System Testing:
```bash
# Open input handling test
Tests/Input_Systems/test_input_handling.tscn
```

### For NPC Interaction Testing:
```bash
# Open NPC interaction test
Tests/NPC_Interaction/test_npc_interaction.tscn
```

## Test Execution Guidelines

### 🖥️ **Headless Tests (Automated)**
**Environment:** Command line, CI/CD, automated scripts  
**Purpose:** Core logic, data structures, algorithms, pure functions  
**Execution:** `--headless` mode or command line

**Examples:**
- **Core Systems:** `Tests/Core_Systems/run_tests_cli.gd`
- **Validation Scripts:** `Tests/Validation_Scripts/validate_phase1.py`
- **Data Validation:** File system checks, resource loading

**Command Line:**
```bash
# Run headless tests
godot --headless --script Tests/Core_Systems/run_tests_cli.gd

# Run Python validation
python Tests/Validation_Scripts/validate_phase1.py
```

**Windows Batch Files:**
```batch
# Quick test execution
Tests\run_tests_quick.bat

# Interactive test menu
Tests\Core_Systems\run_tests_example.bat
```

### 🎮 **Editor Tests (Interactive)**
**Environment:** Godot Editor  
**Purpose:** UI components, addons, visual systems, interactive features  
**Execution:** Godot Editor with visual feedback

**Examples:**
- **Terrain3D tests** - Addon functionality testing
- **PSX asset tests** - Visual asset placement
- **Integration tests** - UI controls for interactive testing
- **Input systems** - Key bindings and interactions
- **NPC interactions** - Character behavior testing

**Editor Instructions:**
1. Open test scene in Godot Editor
2. Press F5 to run
3. Use UI controls for testing
4. Check Output panel for results

### 📋 **Test Classification Summary**

| Test Type | Location | Environment | Purpose |
|-----------|----------|-------------|---------|
| **Headless** | `Core_Systems/`, `Validation_Scripts/` | Command line | Core logic, data, algorithms |
| **Editor** | `Terrain3D/`, `PSX_Assets/`, `UI_Components/`, etc. | Godot Editor | Visual, interactive, addons |

**Key Principle:** Use headless tests for everything that doesn't require visual feedback or addon dependencies. Use editor tests for everything that does.

## File Naming Conventions

- **`test_*.tscn`** - Test scenes (can be opened in Godot Editor)
- **`test_*.gd`** - Test scripts (attached to scenes or standalone)
- **`validate_*.py`** - Python validation scripts
- **`validate_*.gd`** - GDScript validation scripts

## Maintenance Notes

### Adding New Tests:
1. **Identify the appropriate folder** based on test purpose
2. **Follow naming conventions** (test_*.tscn/gd)
3. **Update this README** if adding new categories
4. **Include documentation** in test files

### Moving Tests:
1. **Update scene references** if scenes reference other test files
2. **Check import paths** in scripts
3. **Update documentation** references

### Best Practices:
- **Keep tests focused** on specific functionality
- **Use descriptive names** for test files
- **Include clear documentation** in test scripts
- **Group related tests** in appropriate folders

## Legacy Files

Some files may remain in the root Tests folder if they don't fit into the current categories. These should be reviewed and either:
- Moved to appropriate subfolders
- Deleted if obsolete
- Categorized into new folders if needed

---

**Note:** This structure makes it much easier to find specific tests and maintain the testing codebase. Each folder has a clear purpose and contains related functionality.
