;;;======================================================================
;;; ARCHITECT HELPER HUB - Sheet Manager
;;; Description: Sheet set creation and management from Excel
;;; Version: 1.1
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:SHEETFROMCSV
;;; Description: Create sheet set from CSV/Excel file
;;; Usage: Type SHEETFROMCSV at command line
;;;----------------------------------------------------------------------
(defun C:SHEETFROMCSV (/ csvPath csvData header row sheetNo sheetName dwgFile count created)
  (princ "\n=== Create Sheets from CSV ===")
  (princ "\nExpected CSV format:")
  (princ "\nSheet Number, Sheet Name, Drawing File, Category, Notes")

  ;; Get CSV file
  (setq csvPath (getfiled "Select Sheet List CSV" "" "csv" 0))

  (if csvPath
    (progn
      ;; Read CSV file (use function from block-manager.lsp)
      (setq csvData (AH:READ-CSV csvPath))

      (if csvData
        (progn
          (setq header (car csvData))  ; First row is header
          (setq count 0)
          (setq created 0)

          (princ "\n\nProcessing sheets...")

          ;; Process each data row (skip header)
          (foreach row (cdr csvData)
            (setq count (1+ count))

            (if (>= (length row) 3)
              (progn
                (setq sheetNo (car row))
                (setq sheetName (cadr row))
                (setq dwgFile (caddr row))

                (princ (strcat "\n[" (itoa count) "] " sheetNo " - " sheetName))

                ;; Create layout for this sheet
                (if (AH:CREATE-SHEET sheetNo sheetName dwgFile)
                  (setq created (1+ created))
                )
              )
              (princ (strcat "\n[" (itoa count) "] Skipped: Invalid row format"))
            )
          )

          (princ "\n\n=== Summary ===")
          (princ (strcat "\nTotal rows: " (itoa count)))
          (princ (strcat "\nSheets created: " (itoa created)))
          (princ "\n\nDone!")
        )
        (princ "\nError: Could not read CSV file")
      )
    )
    (princ "\nNo file selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:CREATE-SHEET
;;; Description: Create a new layout/sheet
;;; Arguments: sheetNo - sheet number
;;;           sheetName - descriptive name
;;;           dwgFile - source drawing file (optional)
;;; Returns: T if successful, nil if failed
;;;----------------------------------------------------------------------
(defun AH:CREATE-SHEET (sheetNo sheetName dwgFile / layoutName)
  ;; Create layout name from sheet number
  (setq layoutName sheetNo)

  ;; Check if layout already exists
  (if (not (tblsearch "LAYOUT" layoutName))
    (progn
      ;; Create new layout
      (command "._LAYOUT" "_NEW" layoutName)

      (princ (strcat " - Created layout: " layoutName))
      T
    )
    (progn
      (princ " - Layout already exists")
      nil
    )
  )
)

;;;----------------------------------------------------------------------
;;; Function: C:SHEETLIST
;;; Description: Export current sheet set to CSV
;;; Usage: Type SHEETLIST at command line
;;;----------------------------------------------------------------------
(defun C:SHEETLIST (/ layouts filePath dataList count layoutName)
  (princ "\n=== Export Sheet List ===")

  ;; Get all layouts
  (setq layouts (layoutlist))

  (if layouts
    (progn
      ;; Get save location
      (setq filePath (getfiled "Save Sheet List" "" "csv" 1))

      (if filePath
        (progn
          ;; Create header
          (setq dataList '(("Sheet Number" "Sheet Name" "Layout Tab" "Created")))

          (setq count 0)
          (foreach layoutName layouts
            (setq count (1+ count))
            (setq dataList
              (append dataList
                (list (list
                  layoutName              ; Sheet number (use layout name)
                  layoutName              ; Sheet name
                  layoutName              ; Layout tab
                  "Yes"                   ; Created status
                ))
              )
            )
          )

          ;; Export to CSV
          (AH:EXPORT-TO-CSV dataList filePath)
          (princ (strcat "\nExported " (itoa count) " sheets to " filePath))
        )
        (princ "\nNo file selected")
      )
    )
    (princ "\nNo layouts found in drawing")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:SHEETRENUMBER
;;; Description: Renumber sheets with prefix/suffix
;;; Usage: Type SHEETRENUMBER at command line
;;;----------------------------------------------------------------------
(defun C:SHEETRENUMBER (/ layouts prefix startNum count layoutName newName)
  (princ "\n=== Renumber Sheets ===")

  (setq prefix (getstring T "\nEnter prefix (e.g., A-): "))
  (setq startNum (getint "\nEnter starting number <100>: "))
  (if (not startNum) (setq startNum 100))

  (setq layouts (layoutlist))

  (if layouts
    (progn
      (setq count 0)

      (princ "\n\nRenaming layouts...")

      (foreach layoutName layouts
        ;; Create new name
        (setq newName (strcat prefix (itoa (+ startNum count))))

        ;; Rename layout
        (command "._LAYOUT" "_RENAME" layoutName newName)

        (princ (strcat "\n" layoutName " → " newName))

        (setq count (1+ count))
      )

      (princ (strcat "\n\nRenamed " (itoa count) " layouts"))
    )
    (princ "\nNo layouts found")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:SHEETDELETE
;;; Description: Delete multiple sheets by pattern
;;; Usage: Type SHEETDELETE at command line
;;;----------------------------------------------------------------------
(defun C:SHEETDELETE (/ pattern layouts count layoutName)
  (princ "\n=== Delete Sheets by Pattern ===")
  (princ "\nExample patterns: TEMP*, *-OLD, TEST-*")

  (setq pattern (getstring T "\nEnter sheet pattern to delete: "))

  (if pattern
    (progn
      (setq layouts (layoutlist))
      (setq count 0)

      (princ "\n\nDeleting layouts...")

      (foreach layoutName layouts
        ;; Check if layout matches pattern
        (if (wcmatch layoutName pattern)
          (progn
            (command "._LAYOUT" "_DELETE" layoutName)
            (princ (strcat "\nDeleted: " layoutName))
            (setq count (1+ count))
          )
        )
      )

      (princ (strcat "\n\nDeleted " (itoa count) " layouts"))
    )
    (princ "\nNo pattern entered")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Sheet Manager loaded (v1.1)")
(princ "\n Commands: SHEETFROMCSV, SHEETLIST, SHEETRENUMBER, SHEETDELETE")
(princ)

;;; End of sheet-manager.lsp
