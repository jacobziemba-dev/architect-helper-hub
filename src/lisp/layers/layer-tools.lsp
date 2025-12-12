;;;======================================================================
;;; ARCHITECT HELPER HUB - Layer Tools
;;; Description: Layer management and standardization utilities
;;; Version: 1.0
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:LAYERSTD
;;; Description: Create standard architectural layers
;;; Usage: Type LAYERSTD at command line
;;;----------------------------------------------------------------------
(defun C:LAYERSTD (/ layerDefs)
  (princ "\n=== Create Standard Layers ===")

  ;; Define standard architectural layers
  ;; Format: (name color linetype)
  (setq layerDefs
    '(
      ;; Architectural layers
      ("A-WALL" 7 "Continuous")
      ("A-WALL-DEMO" 1 "HIDDEN")
      ("A-DOOR" 3 "Continuous")
      ("A-WIND" 4 "Continuous")
      ("A-GLAZ" 6 "Continuous")
      ("A-FLOR" 8 "Continuous")
      ("A-CEIL" 9 "Continuous")
      ("A-ROOF" 5 "Continuous")
      ("A-STAIR" 2 "Continuous")
      ("A-FURN" 8 "Continuous")
      ("A-EQPM" 7 "Continuous")
      ("A-COLS" 3 "Continuous")
      ("A-GRID" 8 "CENTER")

      ;; Annotation layers
      ("A-ANNO-TEXT" 7 "Continuous")
      ("A-ANNO-DIMS" 3 "Continuous")
      ("A-ANNO-NOTE" 2 "Continuous")
      ("A-ANNO-KEYN" 1 "Continuous")
      ("A-ANNO-SYMB" 5 "Continuous")

      ;; Area/Room layers
      ("A-AREA-IDEN" 4 "Continuous")
      ("A-AREA-PATT" 8 "Continuous")

      ;; Detail layers
      ("A-DETL" 7 "Continuous")
      ("A-DETL-PATT" 9 "Continuous")
    )
  )

  ;; Create each layer
  (setq count 0)
  (foreach layerDef layerDefs
    (AH:GET-LAYER (nth 0 layerDef) (nth 1 layerDef) (nth 2 layerDef))
    (setq count (1+ count))
  )

  (princ (strcat "\n" (itoa count) " standard layers created"))
  (princ "\nNote: Existing layers were not modified")
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERFREEZE
;;; Description: Freeze layers by wildcard pattern
;;; Usage: Type LAYERFREEZE at command line
;;;----------------------------------------------------------------------
(defun C:LAYERFREEZE (/ pattern layerTable layerName count)
  (princ "\n=== Freeze Layers by Pattern ===")
  (princ "\nExample patterns: X-*, *-DEMO, A-WALL-*")

  (setq pattern (getstring T "\nEnter layer pattern to freeze: "))

  (if pattern
    (progn
      (setq count 0)
      (setq layerTable (tblnext "LAYER" T))

      (while layerTable
        (setq layerName (cdr (assoc 2 layerTable)))

        ;; Check if layer matches pattern
        (if (wcmatch layerName pattern)
          (progn
            (command "._-LAYER" "_FREEZE" layerName "")
            (princ (strcat "\nFroze: " layerName))
            (setq count (1+ count))
          )
        )

        (setq layerTable (tblnext "LAYER"))
      )

      (princ (strcat "\n" (itoa count) " layer(s) frozen"))
    )
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERTHAW
;;; Description: Thaw layers by wildcard pattern
;;; Usage: Type LAYERTHAW at command line
;;;----------------------------------------------------------------------
(defun C:LAYERTHAW (/ pattern layerTable layerName count)
  (princ "\n=== Thaw Layers by Pattern ===")
  (princ "\nExample patterns: X-*, *-DEMO, A-WALL-*")

  (setq pattern (getstring T "\nEnter layer pattern to thaw: "))

  (if pattern
    (progn
      (setq count 0)
      (setq layerTable (tblnext "LAYER" T))

      (while layerTable
        (setq layerName (cdr (assoc 2 layerTable)))

        ;; Check if layer matches pattern
        (if (wcmatch layerName pattern)
          (progn
            (command "._-LAYER" "_THAW" layerName "")
            (princ (strcat "\nThawed: " layerName))
            (setq count (1+ count))
          )
        )

        (setq layerTable (tblnext "LAYER"))
      )

      (princ (strcat "\n" (itoa count) " layer(s) thawed"))
    )
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERDELETE
;;; Description: Delete empty layers (no objects on them)
;;; Usage: Type LAYERDELETE at command line
;;;----------------------------------------------------------------------
(defun C:LAYERDELETE (/ layerTable layerName count ss currentLayer)
  (princ "\n=== Delete Empty Layers ===")

  (setq currentLayer (getvar "CLAYER"))
  (setq count 0)
  (setq layerTable (tblnext "LAYER" T))

  (while layerTable
    (setq layerName (cdr (assoc 2 layerTable)))

    ;; Don't delete current layer or layer 0
    (if (and (/= layerName "0")
             (/= layerName currentLayer))
      (progn
        ;; Check if layer has any objects
        (setq ss (ssget "_X" (list (cons 8 layerName))))

        (if (not ss)
          (progn
            (command "._-LAYER" "_DELETE" layerName "_Yes" "")
            (princ (strcat "\nDeleted empty layer: " layerName))
            (setq count (1+ count))
          )
        )
      )
    )

    (setq layerTable (tblnext "LAYER"))
  )

  (princ (strcat "\n" (itoa count) " empty layer(s) deleted"))
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERLIST
;;; Description: Export layer list to CSV
;;; Usage: Type LAYERLIST at command line
;;;----------------------------------------------------------------------
(defun C:LAYERLIST (/ filePath dataList layerTable layerName color frozen locked)
  (princ "\n=== Export Layer List ===")

  (setq filePath (getfiled "Save Layer List" "" "csv" 1))

  (if filePath
    (progn
      (setq dataList '(("Layer Name" "Color" "Frozen" "Locked" "On")))
      (setq layerTable (tblnext "LAYER" T))

      (while layerTable
        (setq layerName (cdr (assoc 2 layerTable)))
        (setq color (itoa (cdr (assoc 62 layerTable))))

        ;; Check frozen status (bit 1 of flag)
        (setq frozen (if (= 1 (logand 1 (cdr (assoc 70 layerTable)))) "Yes" "No"))

        ;; Check locked status (bit 4 of flag)
        (setq locked (if (= 4 (logand 4 (cdr (assoc 70 layerTable)))) "Yes" "No"))

        ;; Check on/off status (negative color = off)
        (setq onOff (if (< (cdr (assoc 62 layerTable)) 0) "Off" "On"))

        (setq dataList
          (append dataList
            (list (list layerName color frozen locked onOff))
          )
        )

        (setq layerTable (tblnext "LAYER"))
      )

      (AH:EXPORT-TO-CSV dataList filePath)
    )
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERMATCH
;;; Description: Match selected object's layer to another object
;;; Usage: Type LAYERMATCH at command line
;;;----------------------------------------------------------------------
(defun C:LAYERMATCH (/ sourceEnt targetEnt sourceLayer)
  (princ "\n=== Layer Match Tool ===")

  (setq sourceEnt (car (entsel "\nSelect object to match: ")))
  (setq targetEnt (car (entsel "\nSelect object to change: ")))

  (if (and sourceEnt targetEnt)
    (progn
      (setq sourceLayer (cdr (assoc 8 (entget sourceEnt))))
      (command "._CHANGE" targetEnt "" "_P" "_LA" sourceLayer "")
      (princ (strcat "\nChanged layer to: " sourceLayer))
    )
    (princ "\nSelection error")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERISOLATE
;;; Description: Isolate selected layer (freeze all others)
;;; Usage: Type LAYERISOLATE at command line
;;;----------------------------------------------------------------------
(defun C:LAYERISOLATE (/ ent targetLayer layerTable layerName)
  (princ "\n=== Layer Isolate Tool ===")

  (setq ent (car (entsel "\nSelect object on layer to isolate: ")))

  (if ent
    (progn
      (setq targetLayer (cdr (assoc 8 (entget ent))))
      (setq layerTable (tblnext "LAYER" T))

      (while layerTable
        (setq layerName (cdr (assoc 2 layerTable)))

        ;; Freeze all layers except target
        (if (/= layerName targetLayer)
          (command "._-LAYER" "_FREEZE" layerName "")
        )

        (setq layerTable (tblnext "LAYER"))
      )

      (princ (strcat "\nIsolated layer: " targetLayer))
      (princ "\nUse LAYERTHAW * to restore all layers")
    )
    (princ "\nNo object selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERUNISOLATE
;;; Description: Thaw all layers
;;; Usage: Type LAYERUNISOLATE at command line
;;;----------------------------------------------------------------------
(defun C:LAYERUNISOLATE ()
  (princ "\n=== Thawing All Layers ===")
  (command "._-LAYER" "_THAW" "*" "")
  (princ "\nAll layers thawed")
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:LAYERMERGE
;;; Description: Merge one layer into another
;;; Usage: Type LAYERMERGE at command line
;;;----------------------------------------------------------------------
(defun C:LAYERMERGE (/ sourceLayer targetLayer ss count ent)
  (princ "\n=== Layer Merge Tool ===")

  (setq sourceLayer (getstring T "\nEnter source layer name (will be deleted): "))
  (setq targetLayer (getstring T "\nEnter target layer name: "))

  (if (and sourceLayer targetLayer
           (tblsearch "LAYER" sourceLayer)
           (tblsearch "LAYER" targetLayer)
           (/= sourceLayer "0"))
    (progn
      ;; Move all objects from source to target layer
      (setq ss (ssget "_X" (list (cons 8 sourceLayer))))

      (if ss
        (progn
          (setq count 0)
          (repeat (sslength ss)
            (setq ent (ssname ss count))
            (command "._CHANGE" ent "" "_P" "_LA" targetLayer "")
            (setq count (1+ count))
          )

          ;; Delete source layer
          (command "._-LAYER" "_DELETE" sourceLayer "_Yes" "")

          (princ (strcat "\nMoved " (itoa count) " objects from " sourceLayer " to " targetLayer))
          (princ (strcat "\nDeleted layer: " sourceLayer))
        )
        (princ "\nNo objects on source layer - deleting layer")
        (command "._-LAYER" "_DELETE" sourceLayer "_Yes" "")
      )
    )
    (princ "\nInvalid layer names or cannot merge Layer 0")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Layer Tools loaded")
(princ "\n Commands: LAYERSTD, LAYERFREEZE, LAYERTHAW, LAYERDELETE, LAYERLIST")
(princ "\n           LAYERMATCH, LAYERISOLATE, LAYERUNISOLATE, LAYERMERGE")
(princ)

;;; End of layer-tools.lsp
