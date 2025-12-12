;;;======================================================================
;;; ARCHITECT HELPER HUB - Text & Annotation Tools
;;; Description: Text manipulation and annotation helpers
;;; Version: 1.1
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:TEXTALIGN
;;; Description: Align multiple text objects
;;; Usage: Type TEXTALIGN at command line
;;;----------------------------------------------------------------------
(defun C:TEXTALIGN (/ ss alignType basePt baseX baseY count textEnt textData newPt)
  (princ "\n=== Text Align Tool ===")

  ;; Select text objects
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      ;; Get alignment type
      (initget "Left Right Top Bottom")
      (setq alignType (getkword "\nAlign [Left/Right/Top/Bottom] <Left>: "))
      (if (not alignType) (setq alignType "Left"))

      ;; Get base point
      (setq basePt (getpoint "\nSelect base point: "))

      (if basePt
        (progn
          (setq baseX (car basePt))
          (setq baseY (cadr basePt))
          (setq count 0)

          ;; Align each text object
          (repeat (sslength ss)
            (setq textEnt (ssname ss count))
            (setq textData (entget textEnt))
            (setq newPt (cdr (assoc 10 textData)))

            (cond
              ((= alignType "Left")
               (setq newPt (list baseX (cadr newPt)))
              )
              ((= alignType "Right")
               (setq newPt (list baseX (cadr newPt)))
              )
              ((= alignType "Top")
               (setq newPt (list (car newPt) baseY))
              )
              ((= alignType "Bottom")
               (setq newPt (list (car newPt) baseY))
              )
            )

            ;; Update text position
            (entmod (subst (cons 10 newPt) (assoc 10 textData) textData))
            (entupd textEnt)

            (setq count (1+ count))
          )

          (princ (strcat "\nAligned " (itoa count) " text objects"))
        )
        (princ "\nNo base point selected")
      )
    )
    (princ "\nNo text selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:TEXTFIND
;;; Description: Find and replace text in drawing
;;; Usage: Type TEXTFIND at command line
;;;----------------------------------------------------------------------
(defun C:TEXTFIND (/ searchText replaceText ss count textEnt textData oldText newText found)
  (princ "\n=== Text Find & Replace ===")

  (setq searchText (getstring T "\nFind what: "))
  (setq replaceText (getstring T "\nReplace with: "))

  (if (and searchText replaceText)
    (progn
      ;; Get all text
      (setq ss (ssget "_X" '((0 . "TEXT,MTEXT"))))

      (if ss
        (progn
          (setq count 0)
          (setq found 0)

          (repeat (sslength ss)
            (setq textEnt (ssname ss count))
            (setq textData (entget textEnt))
            (setq oldText (cdr (assoc 1 textData)))

            ;; Check if search text is in this text object
            (if (vl-string-search searchText oldText)
              (progn
                ;; Replace text
                (setq newText (vl-string-subst replaceText searchText oldText))

                ;; Update entity
                (entmod (subst (cons 1 newText) (assoc 1 textData) textData))
                (entupd textEnt)

                (princ (strcat "\n" oldText " → " newText))
                (setq found (1+ found))
              )
            )

            (setq count (1+ count))
          )

          (princ (strcat "\n\nSearched " (itoa count) " text objects"))
          (princ (strcat "\nReplaced " (itoa found) " instances"))
        )
        (princ "\nNo text found in drawing")
      )
    )
    (princ "\nInvalid input")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:TEXTSCALE
;;; Description: Scale text height by factor
;;; Usage: Type TEXTSCALE at command line
;;;----------------------------------------------------------------------
(defun C:TEXTSCALE (/ ss scaleFactor count textEnt textData oldHeight newHeight)
  (princ "\n=== Text Scale Tool ===")

  ;; Select text
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      (setq scaleFactor (getreal "\nEnter scale factor (e.g., 2.0 for double): "))

      (if (and scaleFactor (> scaleFactor 0))
        (progn
          (setq count 0)

          (repeat (sslength ss)
            (setq textEnt (ssname ss count))
            (setq textData (entget textEnt))
            (setq oldHeight (cdr (assoc 40 textData)))
            (setq newHeight (* oldHeight scaleFactor))

            ;; Update height
            (entmod (subst (cons 40 newHeight) (assoc 40 textData) textData))
            (entupd textEnt)

            (setq count (1+ count))
          )

          (princ (strcat "\nScaled " (itoa count) " text objects by " (rtos scaleFactor 2 2)))
        )
        (princ "\nInvalid scale factor")
      )
    )
    (princ "\nNo text selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:TEXTNUMBER
;;; Description: Number text objects sequentially
;;; Usage: Type TEXTNUMBER at command line
;;;----------------------------------------------------------------------
(defun C:TEXTNUMBER (/ ss prefix startNum count textEnt textData newText)
  (princ "\n=== Sequential Text Numbering ===")

  ;; Get settings
  (setq prefix (getstring T "\nEnter prefix (or press Enter for none): "))
  (setq startNum (getint "\nStarting number <1>: "))
  (if (not startNum) (setq startNum 1))

  ;; Select text in order
  (princ "\nSelect text objects in numbering order:")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      (setq count 0)

      (repeat (sslength ss)
        (setq textEnt (ssname ss count))
        (setq textData (entget textEnt))

        ;; Create new text
        (if (> (strlen prefix) 0)
          (setq newText (strcat prefix (itoa (+ startNum count))))
          (setq newText (itoa (+ startNum count)))
        )

        ;; Update text
        (entmod (subst (cons 1 newText) (assoc 1 textData) textData))
        (entupd textEnt)

        (princ (strcat "\n" newText))

        (setq count (1+ count))
      )

      (princ (strcat "\n\nNumbered " (itoa count) " text objects"))
    )
    (princ "\nNo text selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:TEXTCASE
;;; Description: Change text case (UPPER, lower, Title)
;;; Usage: Type TEXTCASE at command line
;;;----------------------------------------------------------------------
(defun C:TEXTCASE (/ ss caseType count textEnt textData oldText newText)
  (princ "\n=== Text Case Converter ===")

  ;; Select text
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      ;; Get case type
      (initget "Upper Lower Title")
      (setq caseType (getkword "\nCase type [Upper/Lower/Title] <Upper>: "))
      (if (not caseType) (setq caseType "Upper"))

      (setq count 0)

      (repeat (sslength ss)
        (setq textEnt (ssname ss count))
        (setq textData (entget textEnt))
        (setq oldText (cdr (assoc 1 textData)))

        (cond
          ((= caseType "Upper")
           (setq newText (strcase oldText T))
          )
          ((= caseType "Lower")
           (setq newText (strcase oldText nil))
          )
          ((= caseType "Title")
           (setq newText (AH:TITLE-CASE oldText))
          )
        )

        ;; Update text
        (entmod (subst (cons 1 newText) (assoc 1 textData) textData))
        (entupd textEnt)

        (setq count (1+ count))
      )

      (princ (strcat "\nConverted " (itoa count) " text objects to " caseType " case"))
    )
    (princ "\nNo text selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:TITLE-CASE
;;; Description: Convert string to Title Case
;;; Arguments: str - input string
;;; Returns: Title cased string
;;;----------------------------------------------------------------------
(defun AH:TITLE-CASE (str / words result word)
  (setq words (AH:SPLIT-STRING str " "))
  (setq result "")

  (foreach word words
    (if (> (strlen word) 0)
      (progn
        ;; Capitalize first letter, lowercase rest
        (setq word (strcat
          (strcase (substr word 1 1) T)
          (strcase (substr word 2) nil)
        ))

        (if (> (strlen result) 0)
          (setq result (strcat result " " word))
          (setq result word)
        )
      )
    )
  )

  result
)

;;;----------------------------------------------------------------------
;;; Function: AH:SPLIT-STRING
;;; Description: Split string by delimiter
;;; Arguments: str - input string
;;;           delim - delimiter character
;;; Returns: List of strings
;;;----------------------------------------------------------------------
(defun AH:SPLIT-STRING (str delim / result pos)
  (setq result '())

  (while (setq pos (vl-string-search delim str))
    (setq result (append result (list (substr str 1 pos))))
    (setq str (substr str (+ pos 2)))
  )

  (if (> (strlen str) 0)
    (setq result (append result (list str)))
  )

  result
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Text Tools loaded (v1.1)")
(princ "\n Commands: TEXTALIGN, TEXTFIND, TEXTSCALE, TEXTNUMBER, TEXTCASE")
(princ)

;;; End of text-tools.lsp
