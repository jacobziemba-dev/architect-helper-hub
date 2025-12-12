# Quick Start Tutorial - Architect Helper Hub

## 5-Minute Getting Started Guide

This tutorial will get you productive with Architect Helper Hub in just 5 minutes!

---

## Step 1: Verify Installation (30 seconds)

1. **Open AutoCAD**

2. **Look for startup message:**
   ```
   ========================================
    ARCHITECT HELPER HUB v1.0
   ========================================
   ```

3. **Test with:**
   ```
   Command: AH:HELLO
   ```

   You should see: "Architect Helper Hub is loaded successfully!"

✅ **Success!** Tools are installed and ready to use.

---

## Step 2: Create Standard Layers (1 minute)

Let's set up your drawing with professional layer standards.

1. **Type:**
   ```
   Command: LAYERSTD
   ```

2. **Watch the magic happen:**
   ```
   Layer created: A-WALL
   Layer created: A-DOOR
   Layer created: A-WIND
   ...
   25 standard layers created
   ```

3. **Verify:** Open the Layer Properties Manager (LA) and see all your new layers!

**What you learned:** LAYERSTD creates a complete set of architectural layers in seconds.

---

## Step 3: Tag Room Areas (2 minutes)

Now let's automatically calculate and tag room areas.

**Setup:**
1. Draw a few closed polylines (representing rooms)
2. Or open a drawing with room boundaries

**Execute:**
1. **Type:**
   ```
   Command: AREATAG
   ```

2. **Answer prompts:**
   ```
   Units [SF/SM] <SF>: SF ↵
   Decimal places <1>: 1 ↵
   Text height <0.125>: 0.125 ↵
   Select polylines: [Select all room boundaries]
   ```

3. **See results:**
   - Each polyline now has area text at its center
   - Format: "145.5 SF" or similar

**What you learned:** AREATAG instantly calculates areas and places formatted text.

---

## Step 4: Count Your Blocks (1 minute)

See how many of each block type you have.

1. **Type:**
   ```
   Command: BLOCKCOUNT
   ```

2. **Review report:**
   ```
   Block Name                    Count
   -------------------------------------
   DOOR-3068                     12
   WINDOW-4050                   8
   FURNITURE-CHAIR               24

   Total blocks: 3
   ```

3. **Optionally export:**
   ```
   Export to CSV? [Yes/No] <No>: Yes ↵
   ```
   Save to your project folder for record-keeping.

**What you learned:** BLOCKCOUNT generates instant inventory reports.

---

## Step 5: Export to PDF (1 minute)

Create PDFs of all your layouts with one command.

1. **Type:**
   ```
   Command: BATCHPDF
   ```

2. **Select output folder:**
   - Browse to your project folder
   - Click OK

3. **Choose plot style:**
   ```
   Plot style [Color/Monochrome/Grayscale] <Color>: Monochrome ↵
   ```

4. **Watch progress:**
   ```
   Exported: A-101
   Exported: A-102
   Exported: A-201

   3 PDF files created
   ```

5. **Open folder:**
   ```
   Open output folder? [Yes/No] <Yes>: Yes ↵
   ```

**What you learned:** BATCHPDF exports all layouts in seconds, no clicking through plot dialogs!

---

## 🎉 Congratulations!

You've completed the quick start tutorial and learned:

✅ How to verify installation
✅ Creating standard layers automatically
✅ Tagging room areas
✅ Counting blocks
✅ Batch PDF export

---

## What's Next?

### Explore More Commands

Type `AH:HELP` to see all 20+ available commands.

### Try These Next:

**Block Management:**
- `BLOCKREPLACE` - Replace all instances of one block
- `ATTEXPORT` - Export block attributes to Excel

**Layer Tools:**
- `LAYERFREEZE X-*` - Freeze all xref layers
- `LAYERISOLATE` - Work on one layer only
- `LAYERDELETE` - Remove empty layers

**PDF Tools:**
- `QUICKPDF` - Export just the current layout
- `BATCHPDFSELECT` - Export only selected layouts

### Read the Full User Guide

See `docs/user-guide.md` for complete documentation of all features.

### Check Out Excel Templates

Located in `excel-templates/` folder:
- Sheet list template
- Door schedule template
- Window schedule template
- Room schedule template

---

## Common Workflows

### Workflow 1: New Project Setup

```
1. LAYERSTD           (Create standard layers)
2. [Draw floor plan]
3. AREATAG            (Tag all rooms)
4. BLOCKCOUNT         (Inventory check)
5. QUICKPDF           (Export for review)
```

### Workflow 2: Design Change

```
1. BLOCKREPLACE       (Update door type)
2. AREATAG            (Update room areas)
3. ATTEXPORT          (Export for schedule update)
4. BATCHPDF           (Create updated PDFs)
```

### Workflow 3: Drawing Cleanup

```
1. LAYERDELETE        (Remove empty layers)
2. LAYERFREEZE *-OLD  (Hide old layers)
3. BLOCKCOUNT         (Verify block inventory)
4. LAYERLIST          (Document layer setup)
```

### Workflow 4: Sheet Set Export

```
1. BATCHPDFSELECT     (Select sheets to export)
2. Choose Monochrome  (For construction docs)
3. [Review PDFs]
4. [Upload to project portal]
```

---

## Tips for Success

### 💡 Tip 1: Create Keyboard Shortcuts

Edit `acad.pgp` and add shortcuts like:
```
AT, AREATAG
BC, BLOCKCOUNT
QP, QUICKPDF
LS, LAYERSTD
```

Now just type `AT` instead of `AREATAG`!

### 💡 Tip 2: Use Consistently

Make these commands part of your daily workflow:
- Start every project with `LAYERSTD`
- Use `AREATAG` whenever you draw room boundaries
- Run `BLOCKCOUNT` before submitting drawings
- Use `BATCHPDF` instead of manual plotting

### 💡 Tip 3: Customize for Your Office

Edit the LISP files to:
- Add your office's specific layers
- Change default text heights
- Modify PDF naming conventions
- Add custom block types

### 💡 Tip 4: Combine with Excel

Export data for powerful editing:
```
ATTEXPORT → Edit in Excel → ATTIMPORT (v1.1)
```

---

## Troubleshooting Quick Fixes

**Commands not working?**
```
(AH:HELLO)           ; Test if loaded
AH:HELP              ; See available commands
```

**Need to reload?**
```
(load "architect-helper/autoload/acad.lsp")
```

**Want to see what's happening?**
- Watch the command line for feedback
- All commands provide progress messages

---

## Practice Exercise

Try this complete workflow:

1. **Open a new drawing**

2. **Create layers:**
   ```
   Command: LAYERSTD
   ```

3. **Draw 3-4 room polylines** (any size)

4. **Tag the areas:**
   ```
   Command: AREATAG
   Units: SF
   Decimals: 0
   Height: 0.125
   Select all polylines
   ```

5. **Insert some blocks** (doors, windows, furniture)

6. **Count them:**
   ```
   Command: BLOCKCOUNT
   Export to CSV
   ```

7. **Create a layout** with viewport showing your plan

8. **Export to PDF:**
   ```
   Command: QUICKPDF
   ```

**Time Goal:** Complete this in under 10 minutes!

---

## Getting Help

- **In AutoCAD:** Type `AH:HELP`
- **User Guide:** See `docs/user-guide.md`
- **Website:** architect-helper-hub.com
- **Support:** support@architect-helper-hub.com

---

## Ready to Master It?

Move on to the full **User Guide** for:
- Detailed command references
- Advanced workflows
- Excel integration
- Tips & tricks
- Troubleshooting

**Happy drafting! 🏗️📐**
