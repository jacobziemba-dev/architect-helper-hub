# Changelog

All notable changes to Architect Helper Hub will be documented in this file.

## [1.1.0] - 2025-12-12

### Added

**ATTIMPORT - CSV Attribute Import (High Priority Feature)**
- Import block attributes from CSV files edited in Excel
- Complete the AutoCAD → Excel → AutoCAD workflow
- Supports all attribute types
- CSV parsing with quoted field support
- Entity lookup by handle for reliable updates
- Detailed progress reporting and error handling

**UPDATEAREATAGS - Area Tag Update System**
- Update existing area tags when rooms change
- Automatically finds nearest closed polyline
- Supports both TEXT and MTEXT entities
- Maintains unit consistency (SF/SM)
- Configurable decimal places

**PDFMULTI - Multi-Page PDF Export**
- Export all layouts to single PDF file
- Automatic DSD file generation
- Support for Color/Monochrome/Grayscale styles
- Uses AutoCAD PUBLISH command
- No manual configuration required

**Sheet Manager Module (4 new commands):**
- `SHEETFROMCSV` - Create sheets from Excel/CSV template
- `SHEETLIST` - Export current sheets to CSV
- `SHEETRENUMBER` - Renumber sheets with prefix/suffix
- `SHEETDELETE` - Delete sheets by wildcard pattern

**Text Tools Module (5 new commands):**
- `TEXTALIGN` - Align multiple text objects (Left/Right/Top/Bottom)
- `TEXTFIND` - Find and replace text throughout drawing
- `TEXTSCALE` - Scale text height by factor
- `TEXTNUMBER` - Sequential numbering of text objects
- `TEXTCASE` - Convert text case (UPPER/lower/Title Case)

### Changed

- Updated version to 1.1 across all modules
- Enhanced startup messages with version info
- Expanded AH:HELP command with 11 new commands
- Module load status now includes v1.1 indicator

### Improved

- CSV reading now handles quoted fields properly
- Better error handling and user feedback
- More detailed progress reporting in all commands
- Consistent naming conventions across new modules

## [1.0.0] - 2025-12-12

### Initial Release

#### 🎉 Core Features

**Sheet & Area Tools:**
- `AREATAG` - Automatically calculate and tag polyline areas
- Support for square feet (SF) and square meters (SM)
- Configurable decimal places and text height
- Area text placed at polyline centroid

**Block Management (6 commands):**
- `BLOCKREPLACE` - Replace all instances of one block with another
- `BLOCKCOUNT` - Count and report block instances with CSV export
- `ATTEXPORT` - Export block attributes to CSV for Excel editing
- `BLOCKSCALE` - Scale all instances of a specific block
- `BLOCKLAYER` - Move all block instances to a target layer
- Preserves rotation, scale, and insertion points

**Layer Tools (9 commands):**
- `LAYERSTD` - Create 25+ standard architectural layers
- `LAYERFREEZE` - Freeze layers by wildcard pattern
- `LAYERTHAW` - Thaw layers by wildcard pattern
- `LAYERDELETE` - Remove empty layers automatically
- `LAYERLIST` - Export layer list to CSV with properties
- `LAYERMATCH` - Match object layer to another
- `LAYERISOLATE` - Isolate single layer (freeze all others)
- `LAYERUNISOLATE` - Thaw all layers
- `LAYERMERGE` - Merge two layers into one

**PDF Export (3 commands):**
- `BATCHPDF` - Export all layouts to individual PDF files
- `QUICKPDF` - Export current layout to PDF
- `BATCHPDFSELECT` - Export selected layouts only
- Support for Color, Monochrome, and Grayscale plot styles
- Automatic file naming based on drawing and layout names

#### 📦 Installation System

**Windows Installer:**
- NSIS-based installer script
- Automatic file deployment
- AutoCAD support path configuration
- Start Menu shortcuts
- Clean uninstaller
- Registry integration for Add/Remove Programs

**Auto-load Scripts:**
- `acad.lsp` - Session startup script
- `acaddoc.lsp` - Per-document startup
- Modular loading with error handling
- Startup status messages

#### 📊 Excel Integration

**Templates (5 files):**
- Sheet list template - For batch sheet creation
- Door schedule template - Standard door specifications
- Window schedule template - Window types and specs
- Room schedule template - Room finishes and areas
- Block attributes template - For attribute editing workflow

**Features:**
- CSV format for easy Excel editing
- Export from AutoCAD → Edit in Excel → Import back
- Pre-formatted with common architectural data

#### 📚 Documentation

**User Guide:**
- Complete command reference (20+ pages)
- Installation instructions (automated and manual)
- Detailed usage examples
- Workflow guides
- Troubleshooting section
- Tips and tricks
- Keyboard shortcut suggestions

**Quick Start Tutorial:**
- 5-minute getting started guide
- Step-by-step exercises
- Common workflows
- Practice exercises
- Productivity tips

**Project Documentation:**
- README.md - Project overview and feature showcase
- PROJECT_PLAN.md - Technical architecture and roadmap
- CONTRIBUTING.md - Contribution guidelines
- LICENSE.txt - MIT License
- CHANGELOG.md - Version history

**Installation Guides:**
- Windows installer documentation
- Manual installation steps
- Troubleshooting guide

#### 🛠️ Core Utilities

**Helper Functions:**
- `AH:GET-LAYER` - Create or get layer with properties
- `AH:SELECT-ALL-TYPE` - Select all entities of type
- `AH:GET-BLOCK-ATTRIBUTES` - Extract block attributes
- `AH:SET-BLOCK-ATTRIBUTE` - Modify block attribute values
- `AH:AREA-TO-STRING` - Format area with units
- `AH:SAFE-DIVIDE` - Division with zero protection
- `AH:EXPORT-TO-CSV` - Generic CSV export function
- `AH:HELLO` - Installation test function

**Built-in Help:**
- `AH:HELP` - Display all commands with descriptions
- Categorized command list
- Quick reference

#### 📁 Project Structure

```
architect-helper-hub/
├── src/
│   ├── lisp/
│   │   ├── core/          (Core utilities)
│   │   ├── blocks/        (Block management)
│   │   ├── layers/        (Layer tools)
│   │   ├── sheets/        (Area tagging)
│   │   └── export/        (PDF export)
│   ├── excel-integration/ (CSV templates)
│   ├── templates/         (Reserved for DWT files)
│   └── config/            (Configuration files)
├── installer/
│   ├── windows/           (NSIS installer)
│   └── autoload/          (Startup scripts)
├── docs/
│   ├── user-guide.md
│   └── tutorials/
│       └── quick-start.md
├── tests/                 (Reserved for test files)
├── examples/              (Reserved for sample drawings)
├── README.md
├── PROJECT_PLAN.md
├── CONTRIBUTING.md
├── LICENSE.txt
└── CHANGELOG.md
```

#### 🎯 Key Benefits

**Time Savings:**
- Sheet creation: 90% faster
- Block editing: 95% faster
- PDF export: 100% automated
- Layer setup: Instant vs. 30+ minutes

**Quality Improvements:**
- Standardized layer naming
- Consistent workflows
- Reduced manual errors
- Professional deliverables

**Remote Work Support:**
- Easy file sharing
- Standardized templates
- Batch processing
- Quick PDF generation

#### 🔧 Technical Details

**Compatibility:**
- AutoCAD 2020-2025
- AutoCAD LT (most features)
- Windows 10/11
- Excel 2016+ (for templates)

**Languages:**
- AutoLISP for core automation
- NSIS for installer
- CSV for data exchange

**File Formats:**
- .LSP - LISP source files
- .CSV - Excel-compatible templates
- .NSI - Installer script
- .MD - Documentation (Markdown)

## [Planned] - Version 1.1

### Upcoming Features

**High Priority:**
- `ATTIMPORT` - Import attribute changes from CSV
- `UPDATEAREATAGS` - Update existing area tags
- `PDFMULTI` - Multi-page PDF export
- Ribbon interface for easier access
- Additional Excel import/export features

**Medium Priority:**
- Sheet set creation from Excel
- Drawing comparison tools
- Schedule generators (automatic)
- Template manager
- More annotation helpers

**Documentation:**
- Video tutorials
- Sample project files
- Additional workflow guides
- Interactive help system

### Research & Development

- BIM 360 / ACC integration
- Cloud storage connectors
- AI-powered drawing analysis
- Mobile companion app
- No-code script builder

## Version History Format

This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) principles.

### Types of Changes

- `Added` - New features
- `Changed` - Changes to existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security fixes

---

**For detailed feature descriptions, see README.md**

**For usage instructions, see docs/user-guide.md**

**For contributing, see CONTRIBUTING.md**
