@echo off
REM Quick Test Runner for Windows
REM Run this to execute headless tests quickly

echo === Quick Test Runner ===
echo.

REM Configuration
set GODOT_PATH=D:\Portable\Programming\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe
set PROJECT_PATH=D:\Projects\game-issat\Walking Simulator

echo Running headless tests...
echo.

REM Run core system tests
echo 1. Running Core System Tests...
"%GODOT_PATH%" --headless --script "%PROJECT_PATH%\Tests\Core_Systems\run_tests_cli.gd"

echo.
echo 2. Running Python Validation...
python "%PROJECT_PATH%\Tests\Validation_Scripts\validate_phase1.py"

echo.
echo ✅ All headless tests completed!
echo.
echo Note: For editor tests, open these files in Godot Editor:
echo   - Tests\Terrain3D\test_terrain3d_editor.tscn
echo   - Tests\PSX_Assets\test_psx_placement_editor.tscn
echo   - Tests\Phase1_Integration\test_phase1_integration_editor.tscn
echo.
pause
