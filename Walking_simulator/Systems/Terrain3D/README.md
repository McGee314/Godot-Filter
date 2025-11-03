# Terrain3D System

A modular, SOLID-principle-based terrain system for the Indonesian Cultural Heritage game.

## Architecture

This system follows SOLID principles to create reusable, maintainable terrain controllers:

### Core Components

#### `Terrain3DBaseController` (Abstract Base Class)
- **Single Responsibility**: Manages terrain operations
- **Open/Closed**: Can be extended for different terrain types without modification
- **Liskov Substitution**: Concrete implementations can replace the base class
- **Interface Segregation**: Provides minimal, focused interface
- **Dependency Inversion**: Depends on abstractions, not concrete implementations

#### `Terrain3DPapuaController` (Concrete Implementation)
- Implements Papua-specific terrain behavior
- Handles Papua asset pack loading and management
- Places tropical vegetation, trees, and forest floor assets

#### `Terrain3DControllerFactory` (Factory Pattern)
- Creates appropriate terrain controllers based on terrain type
- Supports: PAPUA, TAMBORA, JAVA_BARAT
- Handles signal connections and initialization

#### `Terrain3DController` (Facade)
- Main interface for scenes to interact with terrain system
- Delegates operations to appropriate concrete controllers
- Maintains backward compatibility

## Folder Structure

```
Systems/Terrain3D/
├── Core/                           # Core system classes
│   ├── Terrain3DBaseController.gd  # Abstract base class
│   ├── Terrain3DPapuaController.gd # Papua implementation
│   ├── Terrain3DControllerFactory.gd # Factory pattern
│   ├── Terrain3DController.gd      # Main facade
│   └── Terrain3DInitializer.gd     # Terrain initialization
├── Scenes/                         # Terrain-related scenes
│   └── Terrain3DAssets.tscn        # Asset management scene
├── Tools/                          # Development tools
│   ├── Terrain3DEditor.gd          # Editor tools
│   └── Terrain3DEditor.tscn        # Editor scene
└── README.md                       # This file
```

## Usage

### In Scene Files
```gdscript
# The scene automatically creates the appropriate controller
var terrain_controller = get_node("TerrainController")
# terrain_controller.place_assets_near_player(30.0)
# terrain_controller.clear_all_assets()
```

### Creating New Terrain Types
1. Create a new class extending `Terrain3DBaseController`
2. Implement the required abstract methods:
   - `_get_terrain_type()` - Return terrain type name
   - `_get_asset_pack_path()` - Return asset pack path
   - `_place_assets_around_position()` - Implement asset placement logic
3. Add the new type to `Terrain3DControllerFactory.TerrainType` enum
4. Add creation logic in the factory

### Example: Tambora Controller
```gdscript
extends Terrain3DBaseController
class_name Terrain3DTamboraController

func _get_terrain_type() -> String:
    return "Tambora"

func _get_asset_pack_path() -> String:
    return "res://Assets/Terrain/Tambora/volcanic_assets.tres"

func _place_assets_around_position(center: Vector3, radius: float) -> int:
    # Implement Tambora-specific asset placement
    return 0
```

## Benefits

1. **Reusability**: Same system works for all terrain types
2. **Maintainability**: Clear separation of concerns
3. **Extensibility**: Easy to add new terrain types
4. **Testability**: Each component can be tested independently
5. **SOLID Compliance**: Follows all SOLID principles

## Migration from Old System

The old Papua-specific controller has been refactored into this new system:
- `PapuaScene_TerrainController.gd` → `Terrain3DPapuaController.gd`
- All functionality preserved through the new architecture
- Scene files updated to use new system paths

## Future Enhancements

- Tambora volcanic terrain controller
- Java Barat urban terrain controller
- Terrain generation algorithms
- Asset streaming system
- Performance optimization tools
