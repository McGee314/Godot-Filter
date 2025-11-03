#!/usr/bin/env python3
"""
Phase 1 Terrain Integration Validation Script
Validates the Phase 1 implementation by checking file system and resource files
"""

import os
import sys
from pathlib import Path

def print_result(success, message):
    """Print a formatted test result"""
    if success:
        print(f"✅ {message}")
    else:
        print(f"❌ {message}")

def test_directory_structure():
    """Test that the terrain directory structure exists"""
    print("\n=== Testing Directory Structure ===")
    
    directories = [
        "Assets/Terrain",
        "Assets/Terrain/Papua",
        "Assets/Terrain/Tambora", 
        "Assets/Terrain/Shared",
        "Systems/Terrain"
    ]
    
    all_exist = True
    for dir_path in directories:
        exists = os.path.exists(dir_path)
        print_result(exists, f"Directory exists: {dir_path}")
        if not exists:
            all_exist = False
    
    return all_exist

def test_resource_files():
    """Test that the resource files exist"""
    print("\n=== Testing Resource Files ===")
    
    resource_files = [
        "Assets/Terrain/Papua/psx_assets.tres",
        "Assets/Terrain/Tambora/psx_assets.tres",
        "Systems/Terrain/PSXAssetPack.gd",
        "Systems/Terrain/TerrainManager.gd",
        "Systems/Terrain/PSXAssetManager.gd",
        "Systems/Terrain/TerrainMaterialFactory.gd"
    ]
    
    all_exist = True
    for file_path in resource_files:
        exists = os.path.exists(file_path)
        print_result(exists, f"Resource file exists: {file_path}")
        if not exists:
            all_exist = False
    
    return all_exist

def test_psx_assets():
    """Test that PSX assets exist"""
    print("\n=== Testing PSX Assets ===")
    
    psx_assets = [
        "Assets/PSX/PSX Nature/Models/FBX/tree_1.fbx",
        "Assets/PSX/PSX Nature/Models/FBX/stone_1.fbx",
        "Assets/PSX/PSX Nature/Models/FBX/grass_1.fbx",
        "Assets/PSX/PSX Nature/Models/FBX/pine_tree_n_1.fbx",
        "Assets/PSX/PSX Nature/Models/FBX/mushroom_n_1.fbx"
    ]
    
    valid_count = 0
    for asset_path in psx_assets:
        exists = os.path.exists(asset_path)
        print_result(exists, f"PSX asset exists: {os.path.basename(asset_path)}")
        if exists:
            valid_count += 1
    
    print(f"\nPSX Asset Summary: {valid_count}/{len(psx_assets)} assets found")
    return valid_count == len(psx_assets)

def test_terrain3d_addon():
    """Test that Terrain3D addon is present"""
    print("\n=== Testing Terrain3D Addon ===")
    
    addon_files = [
        "addons/terrain_3d/plugin.cfg",
        "addons/terrain_3d/terrain.gdextension",
        "addons/terrain_3d/README.md"
    ]
    
    all_exist = True
    for file_path in addon_files:
        exists = os.path.exists(file_path)
        print_result(exists, f"Addon file exists: {file_path}")
        if not exists:
            all_exist = False
    
    return all_exist

def test_test_files():
    """Test that test files exist"""
    print("\n=== Testing Test Files ===")
    
    test_files = [
        "Tests/test_terrain.tscn",
        "Tests/test_psx_assets.tscn",
        "Tests/test_phase1_terrain_integration.tscn",
        "Tests/test_terrain.gd",
        "Tests/test_psx_assets.gd",
        "Tests/test_phase1_terrain_integration.gd"
    ]
    
    all_exist = True
    for file_path in test_files:
        exists = os.path.exists(file_path)
        print_result(exists, f"Test file exists: {file_path}")
        if not exists:
            all_exist = False
    
    return all_exist

def validate_psx_asset_packs():
    """Validate PSX asset pack content"""
    print("\n=== Validating PSX Asset Packs ===")
    
    # Check Papua asset pack
    papua_pack = "Assets/Terrain/Papua/psx_assets.tres"
    if os.path.exists(papua_pack):
        with open(papua_pack, 'r') as f:
            content = f.read()
            if "region_name = \"Papua\"" in content:
                print_result(True, "Papua asset pack has correct region name")
            else:
                print_result(False, "Papua asset pack missing region name")
            
            if "tree_1.fbx" in content:
                print_result(True, "Papua asset pack contains tree assets")
            else:
                print_result(False, "Papua asset pack missing tree assets")
    else:
        print_result(False, "Papua asset pack file not found")
    
    # Check Tambora asset pack
    tambora_pack = "Assets/Terrain/Tambora/psx_assets.tres"
    if os.path.exists(tambora_pack):
        with open(tambora_pack, 'r') as f:
            content = f.read()
            if "region_name = \"Tambora\"" in content:
                print_result(True, "Tambora asset pack has correct region name")
            else:
                print_result(False, "Tambora asset pack missing region name")
            
            if "pine_tree_n_1.fbx" in content:
                print_result(True, "Tambora asset pack contains pine tree assets")
            else:
                print_result(False, "Tambora asset pack missing pine tree assets")
    else:
        print_result(False, "Tambora asset pack file not found")

def main():
    """Main validation function"""
    print("=== Phase 1 Terrain Integration Validation ===")
    print(f"Working directory: {os.getcwd()}")
    
    # Run all tests
    tests = [
        ("Directory Structure", test_directory_structure),
        ("Resource Files", test_resource_files),
        ("PSX Assets", test_psx_assets),
        ("Terrain3D Addon", test_terrain3d_addon),
        ("Test Files", test_test_files)
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test failed with error: {e}")
            results.append((test_name, False))
    
    # Validate PSX asset packs
    try:
        validate_psx_asset_packs()
    except Exception as e:
        print(f"❌ PSX asset pack validation failed with error: {e}")
    
    # Summary
    print("\n=== Phase 1 Validation Summary ===")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "PASSED" if result else "FAILED"
        print(f"{test_name}: {status}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 Phase 1 Terrain Integration VALIDATION PASSED!")
        print("Ready for Phase 2 development.")
        return 0
    else:
        print("⚠️ Phase 1 Terrain Integration VALIDATION FAILED!")
        print("Some issues need to be resolved before proceeding.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
