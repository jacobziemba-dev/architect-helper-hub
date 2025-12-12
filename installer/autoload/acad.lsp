;;;======================================================================
;;; ARCHITECT HELPER HUB - AutoCAD Startup Script
;;; Description: This file is loaded once per AutoCAD session
;;; Location: Place in AutoCAD Support File Search Path
;;;======================================================================

(defun S::STARTUP ()
  (princ "\n========================================")
  (princ "\n ARCHITECT HELPER HUB v1.0")
  (princ "\n========================================")

  ;; Load core utilities first
  (if (findfile "architect-helper/core/utils.lsp")
    (load "architect-helper/core/utils.lsp")
    (princ "\n Warning: Core utilities not found")
  )

  ;; Load modules
  (AH:LOAD-MODULE "sheets/auto-area-tag.lsp" "Auto Area Tag")
  (AH:LOAD-MODULE "blocks/block-manager.lsp" "Block Manager")
  (AH:LOAD-MODULE "layers/layer-tools.lsp" "Layer Tools")
  (AH:LOAD-MODULE "export/batch-pdf.lsp" "Batch PDF Export")

  (princ "\n========================================")
  (princ "\n Type AH:HELP for command list")
  (princ "\n========================================")
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:LOAD-MODULE
;;; Description: Load a LISP module with error handling
;;;----------------------------------------------------------------------
(defun AH:LOAD-MODULE (modulePath moduleName / fullPath)
  (setq fullPath (strcat "architect-helper/" modulePath))
  (if (findfile fullPath)
    (progn
      (load fullPath)
      (princ (strcat "\n [OK] " moduleName))
    )
    (princ (strcat "\n [MISSING] " moduleName))
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:HELP
;;; Description: Display help information
;;;----------------------------------------------------------------------
(defun C:AH:HELP ()
  (princ "\n")
  (princ "\n========================================")
  (princ "\n ARCHITECT HELPER HUB - Command List")
  (princ "\n========================================")
  (princ "\n")
  (princ "\n SHEET & AREA TOOLS:")
  (princ "\n   AREATAG         - Tag polylines with areas")
  (princ "\n   UPDATEAREATAGS  - Update existing area tags")
  (princ "\n")
  (princ "\n BLOCK TOOLS:")
  (princ "\n   BLOCKREPLACE    - Replace one block with another")
  (princ "\n   BLOCKCOUNT      - Count block instances")
  (princ "\n   ATTEXPORT       - Export attributes to CSV")
  (princ "\n   ATTIMPORT       - Import attributes from CSV")
  (princ "\n   BLOCKSCALE      - Scale all instances of a block")
  (princ "\n   BLOCKLAYER      - Move blocks to layer")
  (princ "\n")
  (princ "\n LAYER TOOLS:")
  (princ "\n   LAYERSTD        - Create standard layers")
  (princ "\n   LAYERFREEZE     - Freeze layers by pattern")
  (princ "\n   LAYERTHAW       - Thaw layers by pattern")
  (princ "\n   LAYERDELETE     - Delete empty layers")
  (princ "\n   LAYERLIST       - Export layer list to CSV")
  (princ "\n   LAYERMATCH      - Match object layer")
  (princ "\n   LAYERISOLATE    - Isolate selected layer")
  (princ "\n   LAYERUNISOLATE  - Thaw all layers")
  (princ "\n   LAYERMERGE      - Merge two layers")
  (princ "\n")
  (princ "\n PDF EXPORT:")
  (princ "\n   BATCHPDF        - Export all layouts to PDF")
  (princ "\n   QUICKPDF        - Export current layout")
  (princ "\n   BATCHPDFSELECT  - Export selected layouts")
  (princ "\n   PDFMULTI        - Multi-page PDF export")
  (princ "\n")
  (princ "\n========================================")
  (princ "\n For more info: architect-helper-hub.com")
  (princ "\n========================================")
  (princ)
)

;;; Auto-run startup function
(S::STARTUP)
(princ)

;;; End of acad.lsp
