# Terrain3D Research

This folder contains experimental and research-oriented terrain generation functions that are separated from the main production terrain controller.

## Purpose

These functions are kept separate to:
- Avoid cluttering the main terrain controller
- Allow for experimental terrain generation research
- Maintain clean separation between production and research code
- Enable future terrain generation experiments without affecting main functionality

## Files

### `Terrain3DResearch.gd`
Contains experimental terrain generation functions that respond to keys 1, 2, 3, 4:

- **KEY_1**: `generate_basic_terrain()` - Generate basic terrain heightmap
- **KEY_2**: `generate_terrain_from_noise_layers()` - Generate complex terrain using multiple noise layers
- **KEY_3**: `generate_terrain_from_hand_painted()` - Generate terrain from hand-painted heightmap
- **KEY_4**: `generate_terrain_from_image()` - Generate terrain from image file

## Usage

To use these research functions:
1. Add the `Terrain3DResearch.gd` script to a node in your scene
2. The script will automatically handle keys 1-4 for terrain generation
3. These functions are separate from the main terrain controller

## Notes

- These functions are experimental and may not work with the current Terrain3D setup
- They are intended for research and development purposes
- The main terrain controller now uses only demo terrain data as requested
- Production terrain features (F, P, C, 5-9, H) remain in the main controller
