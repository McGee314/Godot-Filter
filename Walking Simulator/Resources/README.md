# Resources Directory

*Organized: 2025-09-18*

## Overview

This directory contains all `.tres` and `.res` resource files organized by category for easy maintenance and reusability across the project.

## Directory Structure

```
Resources/
├── Audio/                          # 🎵 Audio resources (future)
├── Camera/                         # 📷 Camera configurations
│   ├── Scenes/                     # Scene-specific camera configs
│   │   ├── DefaultCameraConfig.tres
│   │   └── PapuaCameraConfig.tres
│   └── Presets/                    # Reusable camera presets (future)
├── Items/                          # 🎒 Game items and collectibles
│   ├── Cultural/                   # Cultural artifacts
│   │   ├── HistoricalDocument.tres
│   │   ├── SacredStone.tres
│   │   ├── TraditionalMask.tres
│   │   └── TribalOrnament.tres
│   ├── Geological/                 # Geological samples and data
│   │   ├── BatuDootomo.tres
│   │   ├── ClimateImpact.tres
│   │   ├── EruptionTimeline.tres
│   │   └── TamboraRockSample.tres
│   ├── Recipes/                    # Food and craft recipes
│   │   ├── BasoRecipe.tres
│   │   ├── LotekRecipe.tres
│   │   ├── SateRecipe.tres
│   │   └── SotoRecipe.tres
│   └── Tools/                      # Tools and implements
│       ├── AncientTool.tres
│       └── KapakPerunggu.tres
├── Materials/                      # 🎨 Material resources
│   ├── Objects/                    # Object materials
│   │   ├── PedestalMaterial.tres
│   │   └── TerrainMaterial.tres
│   ├── Terrain/                    # Terrain-specific materials (future)
│   └── UI/                         # UI materials (future)
├── NPCs/                          # 👥 NPC configurations (future)
├── Scenes/                        # 🎬 Scene-specific resources
│   └── 2025-09-03_sample_fbx_asset_pack.tres
├── Settings/                      # ⚙️ Game settings (future)
├── Terrain/                       # 🏔️ Terrain data
│   ├── Papua/                     # Papua region terrain
│   │   ├── heightmap.png
│   │   ├── heightmap.png.import
│   │   ├── terrain3d-01-01.res
│   │   ├── terrain3d-01_00.res
│   │   ├── terrain3d_00-01.res
│   │   └── terrain3d_00_00.res
│   ├── Shared/                    # Shared terrain assets (future)
│   └── Tambora/                   # Tambora region terrain (future)
└── Themes/                        # 🎨 UI themes and styles
    └── CulturalGameTheme.tres
```

## Migration Summary

### Files Moved:
- **Camera Configs**: 2 files moved from `Systems/Camera/Configs/`
- **Item Data**: 14 files moved from `Systems/Items/ItemData/` (organized by category)
- **Themes**: 1 file moved from `Assets/Themes/`
- **Materials**: 2 files moved from `Assets/Models/`
- **Terrain Data**: 6 files moved from `Scenes/IndonesiaTimur/terrain_data/`
- **Documentation**: 1 file moved from `docs/`

**Total**: 26 resource files organized

### Empty Directories Removed:
- `Systems/Camera/Configs/`
- `Systems/Items/ItemData/`
- `Assets/Themes/`
- `Scenes/IndonesiaTimur/terrain_data/`

## Using Resources

### With ResourceManager (Recommended)
```gdscript
# Load camera configuration
var camera_config = ResourceManager.load_camera_config("Papua")

# Load cultural item
var mask = ResourceManager.load_cultural_item("TraditionalMask")

# Load theme
var theme = ResourceManager.load_theme("CulturalGameTheme")
```

### Direct Loading
```gdscript
# Camera configuration
var config = load("res://Resources/Camera/Scenes/PapuaCameraConfig.tres")

# Cultural item
var item = load("res://Resources/Items/Cultural/TraditionalMask.tres")

# Theme
var theme = load("res://Resources/Themes/CulturalGameTheme.tres")
```

## Benefits

1. **🔍 Easy to Find**: All resources organized by logical categories
2. **🔄 Reusable**: Clear separation enables resource sharing between scenes
3. **📚 Maintainable**: Organized structure makes updates and maintenance simple
4. **🎯 Scalable**: Easy to add new resource types and categories
5. **👥 Team-Friendly**: Clear conventions for team collaboration

## Adding New Resources

1. **Determine Category**: Choose appropriate subdirectory
2. **Follow Naming**: Use PascalCase with descriptive names
3. **Use ResourceManager**: Add loading functions if needed
4. **Update Documentation**: Keep this README current

## File Naming Conventions

- **PascalCase**: `PapuaCameraConfig.tres`
- **Descriptive**: Include purpose and context
- **Consistent Suffixes**: `Config.tres`, `Material.tres`, `Data.tres`
- **No Spaces**: Use underscores if needed: `Traditional_Mask.tres`
