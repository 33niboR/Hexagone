# Hexagone

Initial GitHub project structure for **Hexagone**, a cosy medieval hex-tile builder built in Godot.

This starter is organised around your proposed gameplay loop:
- draw a small hand of random cards
- place hex tiles onto a growing island grid
- unlock stronger tile/building variants through milestones
- keep the codebase modular so the team can work in parallel

This setup is aligned with the course deliverable requiring both a playable build and documented source code with README/install instructions. fileciteturn0file0

## Recommended stack
- **Engine:** Godot 4.x for easier 3D asset import and better FBX workflow
- **Version control:** Git + GitHub
- **Large binary handling:** Git LFS only if your repo becomes too large

## Suggested repository layout
```text
hexagone/
├── .github/
│   └── workflows/
│       └── godot-ci.yml
├── addons/
├── assets/
│   ├── source/
│   │   ├── KayKit_Medieval_Hexagon_Pack_1.0_FREE.zip
│   │   └── kaykit/
│   │       └── LICENSE.txt
│   ├── models/
│   ├── materials/
│   ├── textures/
│   ├── ui/
│   └── audio/
├── docs/
│   ├── diagrams/
│   ├── references/
│   └── screenshots/
├── project/
│   ├── autoload/
│   ├── data/
│   ├── scenes/
│   │   ├── cards/
│   │   ├── main/
│   │   ├── tiles/
│   │   ├── ui/
│   │   └── world/
│   └── scripts/
│       ├── cards/
│       ├── core/
│       ├── grid/
│       ├── managers/
│       ├── ui/
│       └── utils/
├── tests/
├── .gitattributes
├── .gitignore
├── project.godot
└── README.md
```

## Team workflow
Use branches by feature area:
- `feature/grid-placement`
- `feature/card-system`
- `feature/milestones`
- `feature/ui-hand`
- `feature/asset-integration`

## First implementation order
1. Create a 1-tile test scene and confirm scale/origin of imported KayKit models.
2. Build the axial hex grid placement system.
3. Add card data resources and random draw.
4. Instantiate tile scenes from card selections.
5. Add milestone unlocks.
6. Polish camera, hover, placement preview, and cosy feedback.

## Asset integration plan
Keep the original pack in `assets/source/` and import only the models you actually use into the Godot project folders.

Recommended first-pass mapping:
- Base tile: `hex_grass.fbx`
- Water boundary: `hex_water.fbx`
- Coast edge variants: `hex_coast_*.fbx`
- Nature cards: trees, hills, mountains
- Settlement cards: house, farm/grain, market, tavern, church, castle

## Minimal scenes to create first
- `project/scenes/main/main.tscn`
- `project/scenes/world/world.tscn`
- `project/scenes/tiles/hex_tile.tscn`
- `project/scenes/cards/card_view.tscn`
- `project/scenes/ui/hud.tscn`

## Autoload singletons
Add these later in Godot Project Settings > Autoload:
- `GameManager.gd`
- `CardManager.gd`
- `TileCatalog.gd`

## What to commit to GitHub
Commit:
- source code
- scene files
- lightweight configs/data/resources
- documentation
- only the subset of art assets you really use

Avoid committing:
- `.godot/`
- exported builds unless required for release
- temporary imports/cache
- huge unused asset folders

## Next step after cloning this starter
1. Create a fresh Godot project in this repo root.
2. Copy `project.godot` if needed or let Godot generate it.
3. Import a single hex tile from the KayKit pack.
4. Make sure one tile snaps correctly at world origin.
5. Push the repo to GitHub.
