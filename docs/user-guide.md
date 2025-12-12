# Architect Helper Hub - User Guide

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Sheet & Area Tools](#sheet--area-tools)
4. [Block Management](#block-management)
5. [Layer Tools](#layer-tools)
6. [PDF Export](#pdf-export)
7. [Excel Integration](#excel-integration)
8. [Troubleshooting](#troubleshooting)
9. [Tips & Tricks](#tips--tricks)

---

## Installation

### Automated Installation (Recommended)

1. Download `ArchitectHelper_Setup_v1.0.exe`
2. Double-click the installer
3. Follow the installation wizard
4. Restart AutoCAD
5. Verify installation by typing `AH:HELP` at the command line

### Manual Installation

1. **Copy Files:**
   - Extract ZIP to a permanent location (e.g., `C:\ArchitectHelper\`)

2. **Add Support Path:**
   - In AutoCAD: `Tools → Options → Files`
   - Select `Support File Search Path`
   - Click `Add` and browse to the installation folder
   - Click `OK`

3. **Load Startup Script:**
   - Copy `acad.lsp` to:
     ```
     %APPDATA%\Autodesk\UserDataCache\[Your AutoCAD Version]\AutoCAD\
     ```

4. **Restart AutoCAD**

---

## Getting Started

### First Launch

After installation, when you start AutoCAD, you should see:

```
========================================
 ARCHITECT HELPER HUB v1.0
========================================
 [OK] Core Utilities
 [OK] Auto Area Tag
 [OK] Block Manager
 [OK] Layer Tools
 [OK] Batch PDF Export
========================================
```

### Getting Help

Type `AH:HELP` at the command line to see a list of all available commands.

Type `(AH:HELLO)` to test if the core utilities are loaded.

---

## Sheet & Area Tools

### AREATAG - Automatic Area Tagging

**Purpose:** Automatically calculate and tag room/space areas

**Usage:**
1. Type `AREATAG` at command line
2. Choose units (SF for square feet, SM for square meters)
3. Choose decimal places (0, 1, or 2)
4. Enter text height
5. Select polylines representing rooms
6. Areas are calculated and text is placed at centroids

**Example:**
```
Command: AREATAG
Units [SF/SM] <SF>: SF
Decimal places <1>: 1
Text height <0.125>: 0.125
Select polylines: [Select room boundaries]
Tagged 15 polylines with areas
```

**Tips:**
- Ensure room boundaries are closed polylines
- Use consistent units throughout the project
- Store area tags on a dedicated layer (e.g., A-AREA-IDEN)

### UPDATEAREATAGS

**Purpose:** Update existing area tags (Coming in v1.1)

---

## Block Management

### BLOCKREPLACE - Replace Blocks

**Purpose:** Replace all instances of one block with another

**Usage:**
1. Type `BLOCKREPLACE`
2. Enter the block name to replace
3. Enter the replacement block name
4. All instances are automatically replaced

**Example:**
```
Command: BLOCKREPLACE
Enter block name to replace: OLD-DOOR
Enter replacement block name: NEW-DOOR
Replaced 47 instances of OLD-DOOR with NEW-DOOR
```

**Tips:**
- Block rotation and scale are preserved
- Attributes are not automatically transferred (use ATTIMPORT for that)
- Test on a copy of your drawing first

### BLOCKCOUNT - Count Block Instances

**Purpose:** Generate a report of all blocks in the drawing

**Usage:**
1. Type `BLOCKCOUNT`
2. Review the on-screen report
3. Optionally export to CSV

**Example Output:**
```
Block Name                    Count
-------------------------------------
DOOR-TYPE-A                   23
DOOR-TYPE-B                   18
WINDOW-DBL-HUNG              45
WINDOW-CASEMENT              12

Total blocks: 4
Export to CSV? [Yes/No] <No>:
```

**Use Cases:**
- Material takeoffs
- QA/QC checks
- Cost estimating
- Block library management

### ATTEXPORT - Export Attributes

**Purpose:** Export block attributes to CSV for editing in Excel

**Usage:**
1. Type `ATTEXPORT`
2. Enter block name (or * for all blocks)
3. Choose save location
4. CSV file is created with all attributes

**Workflow:**
```
AutoCAD → ATTEXPORT → Edit in Excel → ATTIMPORT → AutoCAD
```

**CSV Format:**
```
Block Name,Handle,DOOR-NO,WIDTH,HEIGHT,MATERIAL
DOOR,1A2B3C,101,3-0,7-0,WOOD
DOOR,2B3C4D,102,3-0,7-0,METAL
```

**Tips:**
- Don't modify the Handle column (used for re-import)
- Save as CSV format when editing
- Use Excel's find/replace for bulk changes

### ATTIMPORT - Import Attributes

**Purpose:** Import attribute changes from CSV (Coming in v1.1)

### BLOCKSCALE - Scale Blocks

**Purpose:** Scale all instances of a specific block

**Usage:**
```
Command: BLOCKSCALE
Enter block name to scale: FURNITURE-CHAIR
Enter scale factor: 1.5
Scaled 23 instances of FURNITURE-CHAIR
```

### BLOCKLAYER - Move Blocks to Layer

**Purpose:** Move all instances of a block to a specific layer

**Usage:**
```
Command: BLOCKLAYER
Enter block name: DOOR-SYM
Enter target layer: A-DOOR
Moved 45 blocks to layer A-DOOR
```

---

## Layer Tools

### LAYERSTD - Create Standard Layers

**Purpose:** Automatically create a full set of standard architectural layers

**Usage:**
1. Type `LAYERSTD`
2. Standard layers are created instantly

**Layers Created:**
- **Walls:** A-WALL, A-WALL-DEMO
- **Openings:** A-DOOR, A-WIND, A-GLAZ
- **Architecture:** A-FLOR, A-CEIL, A-ROOF, A-STAIR
- **Furnishings:** A-FURN, A-EQPM
- **Structure:** A-COLS, A-GRID
- **Annotation:** A-ANNO-TEXT, A-ANNO-DIMS, A-ANNO-NOTE, etc.
- **Areas:** A-AREA-IDEN, A-AREA-PATT
- **Details:** A-DETL, A-DETL-PATT

**Tips:**
- Run this command at the start of new projects
- Existing layers are not modified
- Customize colors in the source LISP file if needed

### LAYERFREEZE / LAYERTHAW - Freeze/Thaw by Pattern

**Purpose:** Freeze or thaw multiple layers using wildcard patterns

**Usage:**
```
Command: LAYERFREEZE
Enter layer pattern to freeze: X-*
Froze: X-SITE-TOPO
Froze: X-SITE-UTIL
Froze: X-SURVEY
3 layer(s) frozen
```

**Pattern Examples:**
- `X-*` - All layers starting with "X-"
- `*-DEMO` - All demo layers
- `A-WALL-*` - All wall-related layers
- `*TEMP*` - Any layer containing "TEMP"

**Common Uses:**
- Freeze all xref layers: `X-*`
- Freeze demo work: `*-DEMO`
- Isolate annotations: Freeze `*`, Thaw `A-ANNO-*`

### LAYERDELETE - Delete Empty Layers

**Purpose:** Remove layers with no objects on them

**Usage:**
```
Command: LAYERDELETE
Deleted empty layer: TEMP-LAYER
Deleted empty layer: OLD-LAYOUT
7 empty layer(s) deleted
```

**Safety:**
- Current layer is never deleted
- Layer 0 is never deleted
- Only affects layers with zero objects

### LAYERLIST - Export Layer List

**Purpose:** Export complete layer list to CSV

**Usage:**
1. Type `LAYERLIST`
2. Choose save location
3. CSV file contains: name, color, frozen, locked, on/off status

**Use Cases:**
- Documentation
- Layer standard comparison
- Quality control
- Template creation

### LAYERMATCH - Match Layer

**Purpose:** Match one object's layer to another

**Usage:**
```
Command: LAYERMATCH
Select object to match: [Pick object on target layer]
Select object to change: [Pick object to change]
Changed layer to: A-WALL
```

**Tip:** Faster than Properties palette for single changes

### LAYERISOLATE / LAYERUNISOLATE

**Purpose:** Work on one layer by freezing all others

**Usage:**
```
Command: LAYERISOLATE
Select object on layer to isolate: [Pick object]
Isolated layer: A-WALL
Use LAYERTHAW * to restore all layers

Command: LAYERUNISOLATE
All layers thawed
```

### LAYERMERGE - Merge Layers

**Purpose:** Combine two layers into one

**Usage:**
```
Command: LAYERMERGE
Enter source layer name (will be deleted): A-WALL-OLD
Enter target layer name: A-WALL
Moved 134 objects from A-WALL-OLD to A-WALL
Deleted layer: A-WALL-OLD
```

**Warning:** Source layer is permanently deleted!

---

## PDF Export

### BATCHPDF - Export All Layouts

**Purpose:** Export all layouts to individual PDF files

**Usage:**
1. Type `BATCHPDF`
2. Select output folder
3. Choose plot style (Color/Monochrome/Grayscale)
4. Wait for export to complete
5. Optionally open folder

**Output:**
```
DrawingName_Layout1.pdf
DrawingName_Layout2.pdf
DrawingName_Layout3.pdf
...
```

**Settings:**
- Uses DWG to PDF.pc3 plotter
- Respects layout page setup
- Includes all layouts except Model

### QUICKPDF - Export Current Layout

**Purpose:** Quickly export the current layout to PDF

**Usage:**
1. Switch to desired layout tab
2. Type `QUICKPDF`
3. Choose save location and filename
4. PDF is created
5. Optionally open PDF

**Tip:** Fastest way to create a single PDF for review

### BATCHPDFSELECT - Export Selected Layouts

**Purpose:** Export only specific layouts

**Usage:**
```
Command: BATCHPDFSELECT

Available Layouts:
  1. A-101
  2. A-102
  3. A-201
  4. A-202

Enter layout names separated by commas
(or press Enter to export all layouts)
Layouts: A-101,A-201

Select output folder: [Browse]
Plot style [Color/Monochrome/Grayscale] <Color>: Color

Exported: A-101
Exported: A-201

2 PDF files created
```

### PDFMULTI - Multi-Page PDF

**Purpose:** Create a single PDF with multiple layouts (Coming in v1.1)

---

## Excel Integration

### Using Excel Templates

The installation includes several Excel/CSV templates:

1. **sheet-list-template.csv**
   - Sheet number, name, file, category
   - Use for batch sheet creation

2. **door-schedule-template.csv**
   - Door marks, sizes, materials, hardware
   - Edit in Excel, import to AutoCAD

3. **window-schedule-template.csv**
   - Window types, sizes, glazing specs

4. **room-schedule-template.csv**
   - Room numbers, names, areas, finishes

5. **block-attributes-template.csv**
   - Block names, handles, attribute values

### Workflow: Edit Blocks in Excel

1. **Export from AutoCAD:**
   ```
   Command: ATTEXPORT
   Enter block name: DOOR
   ```

2. **Edit in Excel:**
   - Open exported CSV
   - Make bulk changes (e.g., update all door materials)
   - Save as CSV

3. **Import to AutoCAD:**
   ```
   Command: ATTIMPORT
   Select CSV file: [Browse to edited file]
   ```
   (Coming in v1.1)

### Creating Schedules

1. Use ATTEXPORT to extract block data
2. Open in Excel
3. Format as schedule table
4. Add formulas, totals, formatting
5. Save or print
6. Optionally insert as table in AutoCAD

---

## Troubleshooting

### Tools Don't Load

**Symptom:** Commands not recognized

**Solutions:**
1. Check command line for error messages during startup
2. Verify support file search path includes installation folder
3. Type `(AH:HELLO)` to test core utilities
4. Reload manually: `(load "architect-helper/autoload/acad.lsp")`

### Commands Return Errors

**Common Issues:**

**"Unknown command"**
- Module didn't load - check startup messages
- Type `AH:HELP` to see available commands

**"No objects found"**
- Check layer visibility
- Check object type (e.g., AREATAG needs polylines)
- Use QSELECT to verify objects exist

**"Layer not found"**
- Verify layer name spelling
- Use LAYERLIST to export all layer names

### PDF Export Issues

**"Plotter not found"**
- Install DWG to PDF.pc3 plotter
- Or modify script to use different plotter

**"Invalid page setup"**
- Ensure layouts have valid page setups
- Use Page Setup Manager to configure

**PDFs are blank**
- Check plot area setting
- Verify objects are on printable layers
- Check plot styles

### Excel Integration Issues

**CSV won't open**
- Verify file saved as CSV, not XLSX
- Check file path has no special characters
- Try opening in Notepad to verify format

**Import doesn't work** (v1.1 feature)
- Verify Handle column is intact
- Don't add/remove rows (only edit values)
- Save as CSV format

---

## Tips & Tricks

### Productivity Tips

1. **Create Keyboard Shortcuts:**
   - In AutoCAD: `Tools → Customize → Edit Program Parameters (acad.pgp)`
   - Add shortcuts like:
     ```
     AT, AREATAG
     BC, BLOCKCOUNT
     QP, QUICKPDF
     ```

2. **Use Tool Palettes:**
   - Create a palette with buttons for common commands
   - Drag and drop LISP commands to palette

3. **Batch Processing:**
   - Use Script Recorder for repetitive tasks
   - Combine multiple commands in scripts

### Layer Management Strategy

1. **Start with LAYERSTD** on all new projects
2. **Freeze xrefs** with `LAYERFREEZE X-*`
3. **Isolate for editing** with `LAYERISOLATE`
4. **Clean up regularly** with `LAYERDELETE`
5. **Document standards** with `LAYERLIST`

### Block Workflow

1. **Count before editing:** `BLOCKCOUNT`
2. **Export to Excel:** `ATTEXPORT`
3. **Make bulk changes** in Excel
4. **Import back:** `ATTIMPORT` (v1.1)
5. **Verify with:** `BLOCKCOUNT`

### PDF Export Best Practices

1. **Set up layouts properly** before export
2. **Use BATCHPDF** for full sets
3. **Use QUICKPDF** for quick reviews
4. **Choose Monochrome** for construction documents
5. **Use Color** for presentations
6. **Create naming convention:** `ProjectName_SheetNumber.pdf`

### Area Tagging Workflow

1. **Verify polylines are closed**
2. **Run AREATAG** with consistent units
3. **Place on dedicated layer** (A-AREA-IDEN)
4. **Update when plans change** (v1.1)
5. **Export totals** for code compliance

---

## Keyboard Shortcuts Reference

### Suggested Custom Shortcuts

Add to acad.pgp:

```
; Architect Helper Hub Commands
AH, AH:HELP
AT, AREATAG
BR, BLOCKREPLACE
BC, BLOCKCOUNT
AE, ATTEXPORT
LS, LAYERSTD
LF, LAYERFREEZE
LT, LAYERTHAW
LI, LAYERISOLATE
LU, LAYERUNISOLATE
QP, QUICKPDF
BP, BATCHPDF
```

---

## Command Quick Reference

| Command | Purpose | Common Use |
|---------|---------|------------|
| `AREATAG` | Tag polyline areas | Room area calculations |
| `BLOCKREPLACE` | Replace blocks | Design changes |
| `BLOCKCOUNT` | Count block instances | Material takeoffs |
| `ATTEXPORT` | Export attributes | Edit in Excel |
| `BLOCKSCALE` | Scale all blocks | Size adjustments |
| `BLOCKLAYER` | Move blocks to layer | Layer organization |
| `LAYERSTD` | Create standard layers | New project setup |
| `LAYERFREEZE` | Freeze by pattern | Hide xrefs/temps |
| `LAYERTHAW` | Thaw by pattern | Restore layers |
| `LAYERDELETE` | Delete empty layers | Cleanup |
| `LAYERLIST` | Export layer list | Documentation |
| `LAYERMATCH` | Match object layer | Quick layer change |
| `LAYERISOLATE` | Isolate one layer | Focus editing |
| `LAYERMERGE` | Merge two layers | Consolidation |
| `BATCHPDF` | Export all layouts | Full sheet set |
| `QUICKPDF` | Export current layout | Single sheet |
| `BATCHPDFSELECT` | Export selected | Partial set |

---

## Support & Resources

### Getting Help

- **Built-in Help:** Type `AH:HELP` for command list
- **Documentation:** Check `docs` folder
- **Templates:** See `excel-templates` folder
- **Website:** architect-helper-hub.com
- **GitHub:** github.com/your-repo/architect-helper-hub

### Reporting Issues

When reporting bugs, include:
1. AutoCAD version
2. Command that failed
3. Error message (if any)
4. Steps to reproduce

### Feature Requests

We welcome suggestions! Submit via:
- GitHub Issues
- Email: support@architect-helper-hub.com

---

## Version History

### v1.0 (2025-12-12)
- Initial release
- Core utilities
- Auto area tagging
- Block management (6 commands)
- Layer tools (9 commands)
- PDF export (3 commands)
- Excel templates

### Planned for v1.1
- Attribute import from CSV
- Update area tags command
- Multi-page PDF export
- Additional templates
- Ribbon interface
- Video tutorials

---

**Thank you for using Architect Helper Hub!**

We hope these tools save you time and make your work more enjoyable.
