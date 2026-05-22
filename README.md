# Hexagone

Hexagone is a cosy 3D medieval hex-tile city builder made in Godot. Players draw cards from an infinite weighted deck, then place the matching terrain, building, or decoration onto a growing 3D hex grid. The game focuses on relaxed creativity, spatial planning, and steady progression instead of punishment-heavy resource management.

## Project Details

- **Course:** COSC3072 / COSC3073 Game Studio 1
- **Team:** SGS_Tut01_NhatQuang_Team02
- **Tutor:** Nhat-Quang Tran
- **Engine:** Godot Engine 4.6.1 stable
- **Language:** GDScript
- **Platform:** Windows
- **Main scene:** `res://Hexagone_Title_Screen/title_screen.tscn`
- **Primary asset pack:** KayKit Medieval Hexagon Pack

## Team Members

- Truong Quoc Tien (S4051679)
- Ehrbar Robin (S4229638)
- Zhang Jiasheng (S4051417)

## Gameplay Summary

The player begins with a small grass hex tile floating in an empty world. From there, they draw cards and place the corresponding 3D hex tiles or objects to build a medieval realm. The card deck uses weighted random selection, so common foundation tiles appear often while advanced buildings and special objects are rarer.

Progression is based on successful placement. Each valid placement rewards XP, and milestone levels unlock more card types. There are no bankruptcy, starvation, or citizen revolt failure states; the challenge comes from adapting to the cards drawn and arranging the world in a satisfying way.

## Controls

| Input | Action |
|---|---|
| Left Mouse Button | Select a card, drag a card, and place a tile or object |
| Right Mouse Button | Cancel the current selection or placement preview |
| Mouse Movement | Aim the placement cursor over the 3D hex grid |
| Mouse Wheel | Zoom the camera |
| WASD / Arrow Keys | Move or pan the camera |
| Draw Deck Button | Draw new cards into the player's hand |
| Restart Button | Restart the current run |
| Exit Button | Return to the title screen or exit the game |

## Repository Structure

```text
hexagone/
|-- assets/                         Shared UI, water shader, source assets, and imported models
|-- Draw_Cards/                     Card scenes, card data resources, deck logic, and hand logic
|-- Hexagone_Title_Screen/          Title screen scene, fonts, music, video, and menu scripts
|-- KayKit_Medieval_Hexagon_Pack_1.0_FREE/
|                                   External medieval hexagon asset pack
|-- maps/                           JSON map data used for testing/demo purposes
|-- project/
|   |-- autoload/                   Global music manager
|   |-- data/                       Example data files
|   |-- scenes/                     Main gameplay, world, and UI scenes
|   |-- scripts/                    Core gameplay, card, grid, and manager scripts
|-- tests/                          Test folder
|-- project.godot                   Godot project configuration
|-- export_presets.cfg              Windows export preset
|-- README.md                       Project instructions
```

## Important Source Files

| File | Purpose |
|---|---|
| `Draw_Cards/Deck.gd` | Handles card drawing and weighted random selection |
| `Draw_Cards/PlayerHand.gd` | Manages the player's hand and maximum card count |
| `Draw_Cards/Card.gd` | Handles card UI interaction and selection |
| `project/scenes/main/control.gd` | Main gameplay control, placement, progression, and UI logic |
| `project/scenes/main/tutorial_overlay.gd` | Step-by-step tutorial overlay and UI highlighting |
| `project/scripts/grid/hex_grid.gd` | Hex coordinate and grid helper logic |
| `assets/water/water.gdshader` | Custom water shader for river/coast visual polish |
| `Hexagone_Title_Screen/title_screen.gd` | Title screen menu flow |

## How to Run From Source

1. Install **Godot Engine 4.6.1 stable** for Windows.
2. Clone or download this repository.
3. Open Godot.
4. Click **Import**.
5. Select the repository's `project.godot` file.
6. Open the project.
7. Press **F5** or click **Run Project**.
8. The game starts at the title screen. Click **Start Game** to enter the main gameplay scene.

No manual compile step is needed when running the game inside the Godot editor.

## Playable Windows Build

A compiled Windows build is provided in:

```text
builds/windows/Hexagone.exe
```

To play the build:

1. Open the `builds/windows/` folder.
2. Run `Hexagone.exe`.
3. Keep `Hexagone.pck` in the same folder as the executable if it is generated as a separate file.

## How to Create the Windows Build

The repository includes a Windows export preset. To recreate the build from source:

1. Open the project in Godot 4.6.1.
2. Go to **Project > Export**.
3. Select the **Windows Desktop** preset.
4. Export the project to:

```text
builds/windows/Hexagone.exe
```

Command-line export can also be run from the repository root:

```powershell
& "C:\Users\robin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe" --headless --path . --export-release "Windows Desktop" "builds/windows/Hexagone.exe"
```

## Build Notes

- The project was developed and tested on Windows.
- The project currently does not include a save/load system, so there is no separate save data folder.
- The game uses Godot's import cache. If assets appear missing after cloning, open the project in Godot and allow the editor to reimport resources.
- If exporting fails because export templates are missing, install the Godot 4.6.1 export templates from **Editor > Manage Export Templates**.

## External Tools And Resources

- Godot Engine 4.6.1 stable
- GDScript
- KayKit Medieval Hexagon Pack
- Blender 5.1.1
- Visual Studio Code
- GitHub
- ChatGPT image generation for card artwork
- Gemini image generation for card artwork

## Credits

Hexagone was created for Game Studio 1 as a team project by SGS_Tut01_NhatQuang_Team02. External assets and tools are credited in the project report references section.
