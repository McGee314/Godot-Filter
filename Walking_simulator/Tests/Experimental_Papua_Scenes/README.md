# Experimental Papua Scenes

This folder contains experimental and testing versions of Papua scene implementations that are not part of the main game flow.

## Folder Structure

### Terrain3D_Experiments/
Contains experimental terrain development tools:
- `PapuaScene_Terrain3DEditor.gd` - Editor tools for Terrain3D development
- `PapuaScene_Terrain3DEditor.tscn` - Editor scene for Terrain3D development
- `PapuaScene_TerrainAssets.tscn` - Terrain asset management scene (experimental)

**Note**: Core production files have been moved to `Scenes/IndonesiaTimur/`:
- `PapuaScene_Terrain3D.tscn` - Main production scene
- `PapuaScene_TerrainController.gd` - Core terrain control logic
- `PapuaScene_Terrain3D_Initializer.gd` - Core terrain initialization
- `terrain_data/` - Essential terrain resources

### Performance_Testing/
Contains performance monitoring and testing tools:
- `PapuaScene_FPSDisplay.gd` - FPS monitoring script

### Scene_Variations/
Contains alternative scene implementations:
- `PapuaScene_Fixed.tscn` - Fixed version of Papua scene (alternative implementation)

## Usage

These files are experimental and should not be referenced in the main game. They serve as:
- Testing grounds for new features
- Performance analysis tools
- Alternative implementation approaches
- Development artifacts

## Notes

- **Main production Papua scenes** are in `Scenes/IndonesiaTimur/`:
  - `PapuaScene_Terrain3D.tscn` - Main Terrain3D-based scene (primary production scene)
  - `PapuaScene.tscn` - Alternative basic scene implementation
  - `PapuaScene_TerrainController.gd` - Core terrain control logic
  - `PapuaScene_Terrain3D_Initializer.gd` - Core terrain initialization script
  - `terrain_data/` - Essential terrain heightmap and resource data
- **Experimental files** in this folder are for development and testing purposes only
- These experimental files may contain outdated or incomplete implementations
- Use for reference only when developing new features
