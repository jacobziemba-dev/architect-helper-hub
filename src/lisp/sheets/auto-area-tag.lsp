;;;======================================================================
;;; ARCHITECT HELPER HUB - Auto Area Tag
;;; Description: Automatically calculate and tag areas of polylines
;;; Version: 1.1
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
;;; Description: Update existing area tags by finding nearest polyline
;;; Usage: Type UPDATEAREATAGS at command line
;;;----------------------------------------------------------------------
(defun C:UPDATEAREATAGS (/ ss units decimals count textEnt updated)
  (princ "\n=== Update Area Tags ===")

  ;; Get settings from user
  (initget "SF SM")
  (setq units (getkword "\nUnits [SF/SM] <SF>: "))
  (if (not units) (setq units "SF"))

  (setq decimals (getint "\nDecimal places <1>: "))
  (if (not decimals) (setq decimals 1))

  ;; Select text objects to update
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      (setq count 0)
      (setq updated 0)

      (repeat (sslength ss)
        (setq textEnt (ssname ss count))

        ;; Try to update this text with nearest polyline area
        (if (AH:UPDATE-SINGLE-AREA-TAG textEnt units decimals)
          (setq updated (1+ updated))
        )

        (setq count (1+ count))
      )

      (princ (strcat "\nProcessed " (itoa count) " text objects"))
      (princ (strcat "\nUpdated " (itoa updated) " area tags"))
    )
    (princ "\nNo text objects selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:UPDATE-SINGLE-AREA-TAG
;;; Description: Update a single text object with area from nearest polyline
;;; Arguments: textEnt - text entity to update
;;;           units - "SF" or "SM"
;;;           decimals - decimal places
;;; Returns: T if updated, nil if not
;;;----------------------------------------------------------------------
(defun AH:UPDATE-SINGLE-AREA-TAG (textEnt units decimals / textPt nearestPoly polyEnt area newText)
  ;; Get text location
  (setq textPt (cdr (assoc 10 (entget textEnt))))

  ;; Find nearest polyline
  (setq nearestPoly (AH:FIND-NEAREST-POLYLINE textPt))

  (if nearestPoly
    (progn
      (setq polyEnt nearestPoly)

      ;; Calculate area
      (setq area (vlax-curve-getArea polyEnt))

      ;; Convert units
      (if (= units "SF")
        (setq area (/ area 144.0))
        (setq area (* area 0.00064516))
      )

      ;; Create new text string
      (setq newText (AH:AREA-TO-STRING area units decimals))

      ;; Update text
      (AH:MODIFY-TEXT textEnt newText)

      (princ (strcat "\nUpdated to: " newText))
      T
    )
    (progn
      (princ "\nNo nearby polyline found")
      nil
    )
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:FIND-NEAREST-POLYLINE
;;; Description: Find the nearest closed polyline to a point
;;; Arguments: pt - reference point
;;; Returns: Entity name of nearest polyline or nil
;;;----------------------------------------------------------------------
(defun AH:FIND-NEAREST-POLYLINE (pt / ss minDist nearestEnt dist count ent entPt)
  (setq minDist 1e10)  ; Large number
  (setq nearestEnt nil)

  ;; Get all polylines
  (setq ss (ssget "_X" '((0 . "LWPOLYLINE,POLYLINE"))))

  (if ss
    (progn
      (setq count 0)
      (repeat (sslength ss)
        (setq ent (ssname ss count))

        ;; Check if polyline is closed
        (if (AH:IS-POLYLINE-CLOSED ent)
          (progn
            ;; Get centroid of polyline
            (setq entPt (AH:GET-CENTROID ent))

            ;; Calculate distance
            (setq dist (distance pt entPt))

            ;; Update if this is closer
            (if (< dist minDist)
              (progn
                (setq minDist dist)
                (setq nearestEnt ent)
              )
            )
          )
        )

        (setq count (1+ count))
      )
    )
  )

  nearestEnt
)

;;;----------------------------------------------------------------------
;;; Function: AH:IS-POLYLINE-CLOSED
;;; Description: Check if a polyline is closed
;;; Arguments: polyEnt - polyline entity
;;; Returns: T if closed, nil if not
;;;----------------------------------------------------------------------
(defun AH:IS-POLYLINE-CLOSED (polyEnt / entData closedFlag)
  (setq entData (entget polyEnt))

  ;; Check closed flag (bit 1 of DXF code 70)
  (setq closedFlag (cdr (assoc 70 entData)))

  (if closedFlag
    (= 1 (logand 1 closedFlag))
    nil
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:MODIFY-TEXT
;;; Description: Modify text content
;;; Arguments: textEnt - text entity
;;;           newText - new text string
;;;----------------------------------------------------------------------
(defun AH:MODIFY-TEXT (textEnt newText / entData textType)
  (setq entData (entget textEnt))
  (setq textType (cdr (assoc 0 entData)))

  (cond
    ;; Regular TEXT
    ((= textType "TEXT")
     (entmod (subst (cons 1 newText) (assoc 1 entData) entData))
     (entupd textEnt)
    )

    ;; MTEXT
    ((= textType "MTEXT")
     (entmod (subst (cons 1 newText) (assoc 1 entData) entData))
     (entupd textEnt)
    )
  )
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Auto Area Tag loaded (v1.1)")
(princ "\n Commands: AREATAG, UPDATEAREATAGS")
(princ)

;;; End of auto-area-tag.lsp
