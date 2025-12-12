# Contributing to Architect Helper Hub

Thank you for your interest in contributing to Architect Helper Hub! This project aims to make AutoCAD more productive for architects through automation and better workflows.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **AutoCAD Version** (e.g., AutoCAD 2024)
2. **Operating System** (e.g., Windows 11)
3. **Command** that caused the issue
4. **Steps to reproduce**
5. **Expected behavior**
6. **Actual behavior**
7. **Error messages** (if any)

### Suggesting Features

We welcome feature suggestions! Please create an issue with:

1. **Use case** - What problem does it solve?
2. **Proposed solution** - How would it work?
3. **Examples** - Show us what you're envisioning
4. **Alternatives** - Other ways to solve this?

### Contributing Code

#### Getting Started

1. **Fork the repository**
2. **Clone your fork:**
   ```bash
   git clone https://github.com/your-username/architect-helper-hub.git
   ```
3. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Development Setup

1. **Install AutoCAD** (2020 or later)
2. **Install Python** (for Excel integration)
3. **Install NSIS** (for building installer)
4. **Copy files** to AutoCAD support folder for testing

#### Coding Standards

**LISP Code:**
- Use descriptive function names
- Prefix functions with `AH:` (e.g., `AH:GET-LAYER`)
- Prefix commands with `C:` (e.g., `C:AREATAG`)
- Include detailed header comments
- Add inline comments for complex logic
- Follow existing indentation style
- Test on multiple AutoCAD versions if possible

**File Organization:**
```
src/lisp/
  core/         - Core utilities used by other modules
  blocks/       - Block-related tools
  layers/       - Layer management
  sheets/       - Sheet and area tools
  export/       - Export/PDF tools
  annotations/  - Annotation helpers (future)
```

**Documentation:**
- Update user guide for new commands
- Add examples and use cases
- Include screenshots/diagrams if helpful
- Update quick start tutorial if relevant

#### Testing

Before submitting:

1. **Test your code** in AutoCAD
2. **Test edge cases:**
   - Empty drawings
   - Missing layers
   - Invalid input
   - Large datasets
3. **Verify error handling**
4. **Check compatibility** with different AutoCAD versions
5. **Test installer** (if modified)

#### Submitting Changes

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add feature: description of feature"
   ```

2. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request:**
   - Clear title describing the change
   - Detailed description of what changed and why
   - Reference any related issues
   - Include screenshots/examples if applicable

## Areas Where We Need Help

### High Priority

- **Attribute Import** - Import block attributes from CSV
- **Multi-page PDF** - Export to single PDF file
- **Update Area Tags** - Update existing area tags when rooms change
- **Ribbon Interface** - Create AutoCAD ribbon tab
- **Sheet Set Integration** - Better sheet set management

### Medium Priority

- **Drawing Comparison** - Compare two drawing versions
- **Schedule Generators** - Auto-generate door/window/room schedules
- **Template Manager** - Manage reusable templates
- **Batch Processing** - Process multiple drawings
- **3D PDF Export** - Export 3D models to PDF

### Documentation

- **Video Tutorials** - Screen recordings of common workflows
- **Sample Projects** - Example drawings showing features
- **FAQs** - Common questions and solutions
- **Translations** - Localize documentation

### Testing

- **AutoCAD LT Testing** - Verify compatibility
- **AutoCAD 2020-2024** - Test across versions
- **Network Deployments** - Test in corporate environments
- **Performance Testing** - Test with large drawings

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Focus on what's best for the community
- Accept constructive criticism gracefully
- Help others learn and grow

### Not Acceptable

- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Unprofessional conduct

## Development Tips

### LISP Development

**Useful References:**
- [AutoLISP Developer's Guide](https://help.autodesk.com/view/OARX/2025/ENU/?guid=GUID-A0E9D801-8BE9-4BF1-85E8-3807E15F3B71)
- [Visual LISP IDE](https://help.autodesk.com/view/OARX/2025/ENU/?guid=GUID-49AAEA0E-C422-48C4-87F0-52FCA491BF2C)

**Testing Quickly:**
```lisp
; Load a single file for testing
(load "C:/path/to/your-file.lsp")

; Test your function
(C:YOURCOMMAND)
```

**Debugging:**
```lisp
; Print debug messages
(princ "\nDEBUG: Variable value is: ")
(princ variableName)

; Check if variable is nil
(if variableName
  (princ "\nVariable is set")
  (princ "\nVariable is nil")
)
```

### Testing Installer

```batch
REM Compile NSIS script
"C:\Program Files (x86)\NSIS\makensis.exe" install.nsi

REM Test installation
ArchitectHelper_Setup_v1.0.exe /S

REM Test uninstallation
"%APPDATA%\Autodesk\ApplicationPlugins\ArchitectHelper\Uninstall.exe" /S
```

## Git Workflow

### Branch Naming

- `feature/feature-name` - New features
- `bugfix/issue-description` - Bug fixes
- `docs/what-changed` - Documentation updates
- `refactor/what-changed` - Code refactoring

### Commit Messages

**Good:**
```
Add BLOCKROTATE command for batch rotation
Fix layer freeze not working with wildcard patterns
Update user guide with ATTEXPORT examples
```

**Not Good:**
```
fixes
update
changes
```

### Pull Request Guidelines

1. **One feature per PR** - Keep changes focused
2. **Update documentation** - If you add features, document them
3. **Test before submitting** - Make sure it works
4. **Describe changes clearly** - Help reviewers understand
5. **Be responsive** - Address review feedback promptly

## Questions?

- **GitHub Issues** - Ask publicly so others can learn too
- **Email** - support@architect-helper-hub.com
- **Documentation** - Check existing docs first

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Thanked in release notes
- Credited in documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping make AutoCAD better for architects! 🏗️**
