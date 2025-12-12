;;;======================================================================
;;; ARCHITECT HELPER HUB - Auto Area Tag
;;; Description: Automatically calculate and tag areas of polylines
;;; Version: 1.0
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:AREATAG
;;; Description: Main command - tag selected polylines with area
;;; Usage: Type AREATAG at command line, select polylines
;;;----------------------------------------------------------------------
(defun C:AREATAG (/ ss count ent area units decimals textHeight)
  (princ "\n=== Auto Area Tag ===")

  ;; Get settings from user
  (initget "SF SM")
  (setq units (getkword "\nUnits [SF/SM] <SF>: "))
  (if (not units) (setq units "SF"))

  (setq decimals (getint "\nDecimal places <1>: "))
  (if (not decimals) (setq decimals 1))

  (setq textHeight (getreal "\nText height <0.125>: "))
  (if (not textHeight) (setq textHeight 0.125))

  ;; Select polylines
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if ss
    (progn
      (setq count 0)
      (repeat (sslength ss)
        (setq ent (ssname ss count))
        (AH:TAG-POLYLINE-AREA ent units decimals textHeight)
        (setq count (1+ count))
      )
      (princ (strcat "\nTagged " (itoa count) " polylines with areas"))
    )
    (princ "\nNo polylines selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:TAG-POLYLINE-AREA
;;; Description: Calculate area and place text at centroid
;;; Arguments: polyEnt - polyline entity
;;;           units - "SF" or "SM"
;;;           decimals - decimal places for area
;;;           textHeight - height of text to create
;;;----------------------------------------------------------------------
(defun AH:TAG-POLYLINE-AREA (polyEnt units decimals textHeight / area centroid areaText)
  ;; Get area
  (setq area (vlax-curve-getArea polyEnt))

  ;; Convert to square feet if needed (assuming drawing units are inches)
  (if (= units "SF")
    (setq area (/ area 144.0))  ; Convert sq inches to sq feet
    (setq area (* area 0.00064516))  ; Convert sq inches to sq meters
  )

  ;; Get centroid for text placement
  (setq centroid (AH:GET-CENTROID polyEnt))

  ;; Create area text string
  (setq areaText (AH:AREA-TO-STRING area units decimals))

  ;; Place text
  (if centroid
    (progn
      (command "._TEXT" "_MC" centroid textHeight "0" areaText)
      (princ (strcat "\nArea: " areaText))
    )
    (princ "\nError: Could not get centroid")
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:GET-CENTROID
;;; Description: Get approximate centroid of a polyline
;;; Arguments: polyEnt - polyline entity
;;; Returns: (x y) point or nil
;;;----------------------------------------------------------------------
(defun AH:GET-CENTROID (polyEnt / bbox minPt maxPt)
  ;; Get bounding box
  (vla-getBoundingBox
    (vlax-ename->vla-object polyEnt)
    'minPt
    'maxPt
  )
  (setq minPt (vlax-safearray->list minPt))
  (setq maxPt (vlax-safearray->list maxPt))

  ;; Return center point
  (list
    (/ (+ (car minPt) (car maxPt)) 2.0)
    (/ (+ (cadr minPt) (cadr maxPt)) 2.0)
  )
)

;;;----------------------------------------------------------------------
;;; Function: C:UPDATEAREATAGS
;;; Description: Update existing area tags (placeholder for future)
;;; Usage: Type UPDATEAREATAGS at command line
;;;----------------------------------------------------------------------
(defun C:UPDATEAREATAGS ()
  (princ "\nUpdate Area Tags function - Coming in v1.1!")
  (princ)
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Auto Area Tag loaded - Type AREATAG to use")
(princ)

;;; End of auto-area-tag.lsp
