;;;======================================================================
;;; ARCHITECT HELPER HUB - Core Utilities
;;; Description: Core utility functions used across all modules
;;; Version: 1.0
;;; Date: 2025-12-12
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: AH:HELLO
;;; Description: Test function to verify installation
;;; Usage: (AH:HELLO)
;;;----------------------------------------------------------------------
(defun AH:HELLO ()
  (alert "Architect Helper Hub is loaded successfully!\n\nReady to boost your productivity!")
  (princ "\nArchitect Helper Hub v1.0 - Loaded")
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:GET-LAYER
;;; Description: Create layer if it doesn't exist, return layer name
;;; Arguments: layerName (string) - name of layer to create
;;;           color (int) - AutoCAD color index
;;;           lineType (string) - linetype name
;;; Returns: Layer name (string)
;;; Usage: (AH:GET-LAYER "A-WALL" 7 "Continuous")
;;;----------------------------------------------------------------------
(defun AH:GET-LAYER (layerName color lineType / layerObj)
  (if (not (tblsearch "LAYER" layerName))
    (progn
      (command "._-LAYER" "_NEW" layerName "_COLOR" color layerName "_LTYPE" lineType layerName "")
      (princ (strcat "\nLayer created: " layerName))
    )
  )
  layerName
)

;;;----------------------------------------------------------------------
;;; Function: AH:SELECT-ALL-TYPE
;;; Description: Select all entities of a specific type
;;; Arguments: entityType (string) - DXF entity type (e.g., "LWPOLYLINE", "TEXT")
;;; Returns: Selection set or nil
;;; Usage: (setq ss (AH:SELECT-ALL-TYPE "LWPOLYLINE"))
;;;----------------------------------------------------------------------
(defun AH:SELECT-ALL-TYPE (entityType / ss)
  (setq ss (ssget "_X" (list (cons 0 entityType))))
  (if ss
    (progn
      (princ (strcat "\nFound " (itoa (sslength ss)) " " entityType " entities"))
      ss
    )
    (progn
      (princ (strcat "\nNo " entityType " entities found"))
      nil
    )
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:GET-BLOCK-ATTRIBUTES
;;; Description: Extract all attributes from a block reference
;;; Arguments: blockEnt (entity name) - block reference entity
;;; Returns: List of (tag . value) pairs
;;; Usage: (AH:GET-BLOCK-ATTRIBUTES (car (entsel "\nSelect block: ")))
;;;----------------------------------------------------------------------
(defun AH:GET-BLOCK-ATTRIBUTES (blockEnt / entData attList att)
  (setq entData (entget blockEnt))
  (setq attList '())

  (if (= (cdr (assoc 0 entData)) "INSERT")
    (progn
      (setq att (entnext blockEnt))
      (while (and att (= (cdr (assoc 0 (entget att))) "ATTRIB"))
        (setq attList
          (append attList
            (list (cons
              (cdr (assoc 2 (entget att)))  ; Tag
              (cdr (assoc 1 (entget att)))  ; Value
            ))
          )
        )
        (setq att (entnext att))
      )
    )
  )
  attList
)

;;;----------------------------------------------------------------------
;;; Function: AH:SET-BLOCK-ATTRIBUTE
;;; Description: Set attribute value in a block reference
;;; Arguments: blockEnt (entity name) - block reference
;;;           tagName (string) - attribute tag to modify
;;;           newValue (string) - new value for attribute
;;; Returns: T if successful, nil if not
;;; Usage: (AH:SET-BLOCK-ATTRIBUTE ent "SHEET-NO" "A-101")
;;;----------------------------------------------------------------------
(defun AH:SET-BLOCK-ATTRIBUTE (blockEnt tagName newValue / att found)
  (setq found nil)
  (setq att (entnext blockEnt))

  (while (and att (= (cdr (assoc 0 (entget att))) "ATTRIB"))
    (if (= (strcase (cdr (assoc 2 (entget att)))) (strcase tagName))
      (progn
        (entmod (subst (cons 1 newValue) (assoc 1 (entget att)) (entget att)))
        (entupd att)
        (setq found T)
      )
    )
    (setq att (entnext att))
  )
  found
)

;;;----------------------------------------------------------------------
;;; Function: AH:AREA-TO-STRING
;;; Description: Convert area value to formatted string
;;; Arguments: area (real) - area in square units
;;;           units (string) - "SF" for square feet, "SM" for square meters
;;;           decimals (int) - number of decimal places
;;; Returns: Formatted string
;;; Usage: (AH:AREA-TO-STRING 144.5 "SF" 1) -> "144.5 SF"
;;;----------------------------------------------------------------------
(defun AH:AREA-TO-STRING (area units decimals / formatStr)
  (setq formatStr (strcat "%." (itoa decimals) "f " units))
  (sprintf formatStr area)
)

;;;----------------------------------------------------------------------
;;; Function: AH:SAFE-DIVIDE
;;; Description: Divide two numbers safely (avoid division by zero)
;;; Arguments: numerator (real), denominator (real)
;;; Returns: Result or 0.0 if denominator is zero
;;;----------------------------------------------------------------------
(defun AH:SAFE-DIVIDE (numerator denominator)
  (if (and denominator (/= denominator 0.0))
    (/ numerator denominator)
    0.0
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:EXPORT-TO-CSV
;;; Description: Export list of data to CSV file
;;; Arguments: dataList (list of lists) - data to export
;;;           filePath (string) - full path to CSV file
;;; Returns: T if successful
;;; Usage: (AH:EXPORT-TO-CSV '(("A" "B") ("1" "2")) "c:/temp/data.csv")
;;;----------------------------------------------------------------------
(defun AH:EXPORT-TO-CSV (dataList filePath / file row item)
  (setq file (open filePath "w"))
  (if file
    (progn
      (foreach row dataList
        (setq item (car row))
        (princ item file)
        (foreach item (cdr row)
          (princ "," file)
          (princ item file)
        )
        (princ "\n" file)
      )
      (close file)
      (princ (strcat "\nData exported to: " filePath))
      T
    )
    (progn
      (princ "\nError: Could not create file")
      nil
    )
  )
)

;;;----------------------------------------------------------------------
;;; Message on load
;;;----------------------------------------------------------------------
(princ "\n========================================")
(princ "\n Architect Helper Hub - Core Utils")
(princ "\n Version 1.0")
(princ "\n Type (AH:HELLO) to test")
(princ "\n========================================")
(princ)

;;; End of utils.lsp
