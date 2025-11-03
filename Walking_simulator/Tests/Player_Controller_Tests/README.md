# Player Controller Tests

**Date:** 2025-09-18  
**Status:** Organized  
**Purpose:** Centralized location for all Player Controller experimental and test files  

## 📁 **Folder Structure**

### **Movement_Tests/**
- Basic movement and physics tests
- Simple player movement implementations
- Movement speed and acceleration experiments

### **Jitter_Fix_Tests/**
- Jitter debugging and fix attempts
- Movement smoothness tests
- Physics stability experiments

### **Integration_Tests/**
- Integrated player controller tests
- Full feature integration experiments
- Controller refactoring attempts

### **Camera_Tests/**
- Camera system tests
- Complex camera behavior experiments
- Camera following and smoothness tests

### **Physics_Tests/**
- Physics system experiments
- Collision and gravity tests
- Complex physics behavior tests

### **Utilities/**
- Helper scripts and testing utilities
- Debug tools and test helpers
- Performance monitoring tools

## 🎯 **Purpose**

This folder contains all experimental Player Controller files that were moved from the main `Player Controller/` folder to keep the production code clean and organized.

## 📋 **File Categories**

### **Production Files (remain in Player Controller/)**
- `PlayerController.gd` - Main production controller
- `Player.tscn` - Main production scene
- `InteractionController.gd` - Production interaction system
- `InteractableObject.gd` - Production interactable system

### **Test/Experimental Files (moved here)**
- All test scenes and scripts
- Experimental implementations
- Debug utilities
- Performance testing tools

## 🔧 **Usage**

These test files are preserved for:
- Reference for future improvements
- Understanding evolution of the player controller
- Debugging similar issues in the future
- Learning from past experiments

## 📚 **Historical Context**

These files were created during the player controller development process, particularly when addressing:
- Movement jitter issues
- Physics stability problems
- Camera smoothness challenges
- Integration complexities

The files represent the iterative development process and contain valuable insights for future development.
