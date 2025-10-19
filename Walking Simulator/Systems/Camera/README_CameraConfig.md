# Camera Configuration System

## Overview

The Camera Configuration System provides a flexible, reusable way to define and manage different camera views across multiple scenes. It uses Godot's resource system to store camera configurations that can be easily customized without touching code.

## Components

### 1. CameraViewConfig (Resource)
Defines a single camera view with all its parameters:
- **Spring Length**: Distance from camera pivot
- **Pivot Offset**: Position relative to player
- **Pivot Rotation**: Camera angle (pitch, yaw, roll)
- **Key Binding**: Which key activates this view
- **Collision Settings**: SpringArm3D collision behavior

### 2. CameraSceneConfig (Resource)
Contains multiple camera views for a specific scene:
- **Player View**: Default third-person view
- **Far Side View**: High overview/strategic view
- **Canopy View**: Above-ground level view
- **Custom Views**: Additional custom camera angles

### 3. SimpleCameraManager (Node)
Manages camera switching and applies configurations:
- Loads configuration resources
- Handles input for camera switching
- Applies settings to SpringArm3D system
- Provides debug logging

## Usage

### Adding Camera System to a Scene

1. **Add SimpleCameraManager node** to your scene
2. **Configure the manager**:
   ```gdscript
   # In inspector or code:
   camera_config = preload("res://Systems/Camera/Configs/PapuaCameraConfig.tres")
   # OR
   config_file_path = "res://Systems/Camera/Configs/YourSceneConfig.tres"
   ```

### Creating Custom Camera Configurations

1. **Create new CameraSceneConfig resource**:
   ```
   Systems/Camera/Configs/YourSceneConfig.tres
   ```

2. **Configure views in Godot Inspector**:
   - Set scene name and description
   - Configure Player View, Far Side View, Canopy View
   - Add custom views if needed
   - Set key bindings (KEY_1, KEY_2, KEY_3, etc.)

### Example Configuration Values

#### Player View (Normal third-person)
```
Spring Length: 7.0
Pivot Offset: (0, 2.5, 0)
Pivot Rotation: (-15°, 0°, 0°)
Key Binding: KEY_1
```

#### Far Side View (Strategic overview)
```
Spring Length: 50.0
Pivot Offset: (0, 30.0, 0) 
Pivot Rotation: (-45°, 45°, 0°)
Key Binding: KEY_2
```

#### Canopy View (Above forest level)
```
Spring Length: 15.0
Pivot Offset: (0, 20.0, 0)
Pivot Rotation: (-60°, 0°, 0°)
Key Binding: KEY_3
```

## Available Configurations

### Pre-made Configurations
- **PapuaCameraConfig.tres**: Optimized for Papua terrain exploration
- **DefaultCameraConfig.tres**: General-purpose camera setup

### Creating New Configurations

1. **Duplicate existing config**:
   ```
   Right-click PapuaCameraConfig.tres → Duplicate
   Rename to YourSceneConfig.tres
   ```

2. **Customize in Inspector**:
   - Update scene name/description
   - Adjust spring lengths for scene scale
   - Modify pivot offsets for terrain height
   - Change pivot rotations for desired angles

## Integration with Existing Scenes

### For Scenes with SpringArm3D Setup
The system works directly with existing Player/CameraPivot/SpringArm3D hierarchies:
```
Player (CharacterBody3D)
└── CameraPivot (Node3D)
    └── SpringArm3D
        └── Camera3D
```

### For Scenes without SpringArm3D
You'll need to restructure your camera setup to use SpringArm3D for compatibility.

## Debugging

The system provides comprehensive logging:
- **Configuration loading**: Shows which config file is loaded
- **Available views**: Lists all configured camera views and key bindings
- **View switching**: Logs when cameras switch between modes
- **Configuration details**: Shows applied SpringArm3D settings

## Benefits

1. **Reusable**: Same camera system across multiple scenes
2. **Configurable**: No code changes needed for camera adjustments
3. **Maintainable**: Centralized camera configuration management
4. **Scalable**: Easy to add new camera views
5. **Debug-friendly**: Comprehensive logging for troubleshooting

## File Structure
```
Systems/Camera/
├── SimpleCameraManager.gd          # Main camera manager
├── CameraViewConfig.gd             # Single view configuration
├── CameraSceneConfig.gd            # Scene camera configuration
├── Configs/
│   ├── PapuaCameraConfig.tres      # Papua scene config
│   ├── DefaultCameraConfig.tres    # Default config
│   └── YourSceneConfig.tres        # Your custom config
└── README_CameraConfig.md          # This documentation
```
