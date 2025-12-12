;;;======================================================================
;;; ARCHITECT HELPER HUB - Batch PDF Export
;;; Description: Batch export layouts and sheets to PDF
;;; Version: 1.1
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:BATCHPDF
;;; Description: Export all layouts to PDF files
;;; Usage: Type BATCHPDF at command line
;;;----------------------------------------------------------------------
(defun C:BATCHPDF (/ outputFolder dwgName layouts layoutName pdfName colorMode)
  (princ "\n=== Batch PDF Export ===")

  ;; Get output folder
  (setq outputFolder (getfiled "Select Output Folder" "" "" 4))

  (if outputFolder
    (progn
      ;; Get drawing name without extension
      (setq dwgName (getvar "DWGNAME"))
      (setq dwgName (substr dwgName 1 (- (strlen dwgName) 4)))

      ;; Ask for color mode
      (initget "Color Monochrome Grayscale")
      (setq colorMode (getkword "\nPlot style [Color/Monochrome/Grayscale] <Color>: "))
      (if (not colorMode) (setq colorMode "Color"))

      ;; Get all layouts
      (setq layouts (layoutlist))
      (setq count 0)

      (princ "\n\nExporting PDFs...")

      ;; Export each layout
      (foreach layoutName layouts
        (setq pdfName (strcat outputFolder "/" dwgName "_" layoutName ".pdf"))

        ;; Set layout current
        (command "._LAYOUT" "_SET" layoutName)

        ;; Plot to PDF
        (AH:PLOT-TO-PDF layoutName pdfName colorMode)

        (princ (strcat "\nExported: " layoutName))
        (setq count (1+ count))
      )

      (princ (strcat "\n\n" (itoa count) " PDF files created in:"))
      (princ (strcat "\n" outputFolder))

      ;; Ask to open folder
      (initget "Yes No")
      (if (= "Yes" (getkword "\nOpen output folder? [Yes/No] <Yes>: "))
        (command "._EXPLORER" outputFolder)
      )
    )
    (princ "\nNo folder selected")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:PLOT-TO-PDF
;;; Description: Plot a single layout to PDF
;;; Arguments: layoutName - name of layout to plot
;;;           pdfPath - full path for output PDF
;;;           colorMode - "Color", "Monochrome", or "Grayscale"
;;;----------------------------------------------------------------------
(defun AH:PLOT-TO-PDF (layoutName pdfPath colorMode / ctbFile)
  ;; Determine CTB file based on color mode
  (cond
    ((= colorMode "Monochrome") (setq ctbFile "monochrome.ctb"))
    ((= colorMode "Grayscale") (setq ctbFile "grayscale.ctb"))
    (T (setq ctbFile "None"))
  )

  ;; Execute plot command
  (command "._-PLOT" "_Yes"  ; Detailed plot configuration? Yes
           layoutName        ; Layout name
           "DWG To PDF.pc3"  ; Plotter name
           ""                ; Paper size (use layout setting)
           "_I"              ; Inches
           "_L"              ; Landscape
           "_N"              ; Plot upside down? No
           "_E"              ; Plot area: Extents
           "1=1"             ; Scale
           "_C"              ; Center plot? Yes
           "_Y"              ; Use plot styles? Yes
           ctbFile           ; Plot style table
           "_Y"              ; Plot with lineweights? Yes
           "_N"              ; Scale lineweights? No
           "_N"              ; Plot paperspace objects? No
           pdfPath           ; Output file name
           "_Y"              ; Save changes to layout? Yes
           "_N"              ; Proceed with plot? No (batch mode)
  )
)

;;;----------------------------------------------------------------------
;;; Function: C:QUICKPDF
;;; Description: Export current layout to PDF
;;; Usage: Type QUICKPDF at command line
;;;----------------------------------------------------------------------
(defun C:QUICKPDF (/ pdfPath currentLayout dwgName)
  (princ "\n=== Quick PDF Export ===")

  (setq currentLayout (getvar "CTAB"))

  (if (/= currentLayout "Model")
    (progn
      ;; Generate default filename
      (setq dwgName (getvar "DWGPREFIX"))
      (setq pdfPath (strcat dwgName currentLayout ".pdf"))

      ;; Ask user for save location
      (setq pdfPath (getfiled "Save PDF" pdfPath "pdf" 1))

      (if pdfPath
        (progn
          (AH:PLOT-TO-PDF currentLayout pdfPath "Color")
          (princ (strcat "\nPDF created: " pdfPath))

          ;; Ask to open PDF
          (initget "Yes No")
          (if (= "Yes" (getkword "\nOpen PDF? [Yes/No] <No>: "))
            (command "._SHELL" pdfPath)
          )
        )
        (princ "\nCanceled")
      )
    )
    (princ "\nPlease switch to a layout (not Model space)")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:BATCHPDFSELECT
;;; Description: Export selected layouts to PDF
;;; Usage: Type BATCHPDFSELECT at command line
;;;----------------------------------------------------------------------
(defun C:BATCHPDFSELECT (/ outputFolder allLayouts selectedLayouts layoutName
                           response pdfName dwgName count colorMode)
  (princ "\n=== Batch PDF Export (Selected) ===")

  ;; Get all layouts
  (setq allLayouts (layoutlist))

  (if allLayouts
    (progn
      ;; Display available layouts
      (princ "\n\nAvailable Layouts:")
      (setq count 1)
      (foreach layoutName allLayouts
        (princ (strcat "\n  " (itoa count) ". " layoutName))
        (setq count (1+ count))
      )

      ;; Let user select layouts
      (princ "\n\nEnter layout names separated by commas")
      (princ "\n(or press Enter to export all layouts)")
      (setq response (getstring T "\nLayouts: "))

      ;; Parse selection
      (if (or (not response) (= response ""))
        (setq selectedLayouts allLayouts)
        ;; Simple parsing - split by comma
        (setq selectedLayouts (AH:PARSE-COMMA-LIST response))
      )

      ;; Get output folder
      (setq outputFolder (getfiled "Select Output Folder" "" "" 4))

      (if outputFolder
        (progn
          ;; Get color mode
          (initget "Color Monochrome Grayscale")
          (setq colorMode (getkword "\nPlot style [Color/Monochrome/Grayscale] <Color>: "))
          (if (not colorMode) (setq colorMode "Color"))

          ;; Get drawing name
          (setq dwgName (getvar "DWGNAME"))
          (setq dwgName (substr dwgName 1 (- (strlen dwgName) 4)))

          (setq count 0)
          (princ "\n\nExporting PDFs...")

          ;; Export each selected layout
          (foreach layoutName selectedLayouts
            (if (member layoutName allLayouts)
              (progn
                (setq pdfName (strcat outputFolder "/" dwgName "_" layoutName ".pdf"))
                (command "._LAYOUT" "_SET" layoutName)
                (AH:PLOT-TO-PDF layoutName pdfName colorMode)
                (princ (strcat "\nExported: " layoutName))
                (setq count (1+ count))
              )
              (princ (strcat "\nSkipped (not found): " layoutName))
            )
          )

          (princ (strcat "\n\n" (itoa count) " PDF files created"))
        )
        (princ "\nNo folder selected")
      )
    )
    (princ "\nNo layouts found in drawing")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:PARSE-COMMA-LIST
;;; Description: Parse comma-separated string into list
;;; Arguments: str - comma-separated string
;;; Returns: List of strings
;;;----------------------------------------------------------------------
(defun AH:PARSE-COMMA-LIST (str / result item pos)
  (setq result '())

  ;; Simple parsing - split by comma
  (while (setq pos (vl-string-search "," str))
    (setq item (substr str 1 pos))
    (setq item (vl-string-trim " " item))  ; Remove spaces
    (if (> (strlen item) 0)
      (setq result (append result (list item)))
    )
    (setq str (substr str (+ pos 2)))
  )

  ;; Add last item
  (setq str (vl-string-trim " " str))
  (if (> (strlen str) 0)
    (setq result (append result (list str)))
  )

  result
)

;;;----------------------------------------------------------------------
;;; Function: C:PDFMULTI
;;; Description: Export all layouts to a single multi-page PDF
;;; Usage: Type PDFMULTI at command line
;;;----------------------------------------------------------------------
(defun C:PDFMULTI (/ pdfPath dwgName dwgPath layouts dsdPath colorMode)
  (princ "\n=== Multi-Page PDF Export ===")

  ;; Get drawing info
  (setq dwgPath (getvar "DWGPREFIX"))
  (setq dwgName (getvar "DWGNAME"))

  ;; Get PDF save location
  (setq pdfPath (getfiled "Save PDF" (strcat dwgPath dwgName ".pdf") "pdf" 1))

  (if pdfPath
    (progn
      ;; Ask for color mode
      (initget "Color Monochrome Grayscale")
      (setq colorMode (getkword "\nPlot style [Color/Monochrome/Grayscale] <Color>: "))
      (if (not colorMode) (setq colorMode "Color"))

      ;; Get all layouts
      (setq layouts (layoutlist))

      (if layouts
        (progn
          (princ (strcat "\nFound " (itoa (length layouts)) " layouts"))
          (princ "\nCreating DSD file...")

          ;; Create DSD file
          (setq dsdPath (strcat (getvar "TEMPPREFIX") "ah-multipage.dsd"))

          (if (AH:CREATE-DSD-FILE dsdPath layouts pdfPath colorMode)
            (progn
              (princ "\nPublishing to PDF...")

              ;; Execute PUBLISH command with DSD file
              (command "._-PUBLISH" dsdPath)

              (princ "\n\nMulti-page PDF export started")
              (princ (strcat "\nOutput: " pdfPath))
              (princ "\nCheck command line for PUBLISH progress")
            )
            (princ "\nError: Could not create DSD file")
          )
        )
        (princ "\nNo layouts found in drawing")
      )
    )
    (princ "\nCanceled")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:CREATE-DSD-FILE
;;; Description: Create a DSD (Drawing Set Description) file for PUBLISH
;;; Arguments: dsdPath - path for DSD file
;;;           layouts - list of layout names
;;;           pdfPath - output PDF path
;;;           colorMode - "Color", "Monochrome", or "Grayscale"
;;; Returns: T if successful, nil if failed
;;;----------------------------------------------------------------------
(defun AH:CREATE-DSD-FILE (dsdPath layouts pdfPath colorMode / file dwgPath dwgName ctbFile count)
  (setq file (open dsdPath "w"))

  (if file
    (progn
      (setq dwgPath (strcat (getvar "DWGPREFIX") (getvar "DWGNAME")))
      (setq dwgName (getvar "DWGNAME"))

      ;; Determine CTB file
      (cond
        ((= colorMode "Monochrome") (setq ctbFile "monochrome.ctb"))
        ((= colorMode "Grayscale") (setq ctbFile "grayscale.ctb"))
        (T (setq ctbFile ""))
      )

      ;; Write DSD file header
      (princ "[DWF6Version]\nVer=1\n" file)
      (princ "[DWF6MinorVersion]\nMinorVer=1\n" file)

      ;; Password (none)
      (princ "[DWF6Sheet Password]\nPassword=\n" file)
      (princ "[DWF6Sheet Password Prompt]\nPromptForPassword=FALSE\n" file)

      ;; Sheet set details
      (princ (strcat "[DWF6SheetSet]\nName=" dwgName "\n") file)
      (princ "NoOfCopies=1\n" file)
      (princ "PlotType=6\n" file)  ; PDF
      (princ "PublishTo=1\n" file)
      (princ "SaveSheetSet=FALSE\n" file)

      ;; PDF settings
      (princ (strcat "[Target Device]\nType=6\nPWD=\nName=" pdfPath "\n") file)

      ;; Sheet data section
      (setq count 0)
      (foreach layoutName layouts
        (princ (strcat "[DWF6Sheet:" (itoa count) "]\n") file)
        (princ (strcat "DWG=" dwgPath "\n") file)
        (princ (strcat "Layout=" layoutName "\n") file)
        (princ "Setup=\n" file)
        (princ (strcat "OriginalSheetPath=" dwgPath "\n") file)
        (princ "Has Plot Port=0\n" file)
        (princ "Has3DDWF=0\n" file)

        (setq count (1+ count))
      )

      ;; Setup details for each sheet
      (setq count 0)
      (foreach layoutName layouts
        (princ (strcat "[Setup:" (itoa count) "]\n") file)
        (princ "Plotter=DWG To PDF.pc3\n" file)
        (princ "PlotStyle=\n" file)

        (if (> (strlen ctbFile) 0)
          (princ (strcat "StyleSheet=" ctbFile "\n") file)
          (princ "StyleSheet=\n" file)
        )

        (setq count (1+ count))
      )

      (close file)
      T
    )
    nil
  )
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Batch PDF Export loaded (v1.1)")
(princ "\n Commands: BATCHPDF, QUICKPDF, BATCHPDFSELECT, PDFMULTI")
(princ)

;;; End of batch-pdf.lsp
