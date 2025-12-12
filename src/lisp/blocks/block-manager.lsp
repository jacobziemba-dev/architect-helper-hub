;;;======================================================================
;;; ARCHITECT HELPER HUB - Block Manager
;;; Description: Batch operations for blocks and attributes
;;; Version: 1.1
;;; Dependencies: core/utils.lsp
;;;======================================================================

;;;----------------------------------------------------------------------
;;; Function: C:BLOCKREPLACE
;;; Description: Replace all instances of one block with another
;;; Usage: Type BLOCKREPLACE at command line
;;;----------------------------------------------------------------------
(defun C:BLOCKREPLACE (/ oldName newName ss count ent entData insertPt rotation scale)
  (princ "\n=== Block Replace Tool ===")

  ;; Get block names
  (setq oldName (getstring T "\nEnter block name to replace: "))
  (setq newName (getstring T "\nEnter replacement block name: "))

  (if (and oldName newName
           (tblsearch "BLOCK" oldName)
           (tblsearch "BLOCK" newName))
    (progn
      ;; Select all instances of old block
      (setq ss (ssget "_X" (list (cons 0 "INSERT") (cons 2 oldName))))

      (if ss
        (progn
          (setq count 0)
          (repeat (sslength ss)
            (setq ent (ssname ss count))
            (setq entData (entget ent))

            ;; Get insertion point, rotation, and scale
            (setq insertPt (cdr (assoc 10 entData)))
            (setq rotation (cdr (assoc 50 entData)))
            (setq scale (cdr (assoc 41 entData)))

            ;; Delete old block
            (entdel ent)

            ;; Insert new block
            (command "._-INSERT" newName insertPt scale scale rotation)

            (setq count (1+ count))
          )
          (princ (strcat "\nReplaced " (itoa count) " instances of " oldName " with " newName))
        )
        (princ (strcat "\nNo instances of " oldName " found"))
      )
    )
    (princ "\nError: One or both block names not found")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:BLOCKCOUNT
;;; Description: Count instances of each block in drawing
;;; Usage: Type BLOCKCOUNT at command line
;;;----------------------------------------------------------------------
(defun C:BLOCKCOUNT (/ ss count blockList blockName idx foundItem)
  (princ "\n=== Block Count Report ===\n")

  ;; Get all block inserts
  (setq ss (ssget "_X" '((0 . "INSERT"))))

  (if ss
    (progn
      (setq blockList '())
      (setq count 0)

      ;; Count each block
      (repeat (sslength ss)
        (setq blockName (cdr (assoc 2 (entget (ssname ss count)))))

        ;; Check if block already in list
        (setq foundItem (assoc blockName blockList))
        (if foundItem
          (setq blockList
            (subst
              (cons blockName (1+ (cdr foundItem)))
              foundItem
              blockList
            )
          )
          (setq blockList (cons (cons blockName 1) blockList))
        )
        (setq count (1+ count))
      )

      ;; Print results
      (princ "\nBlock Name                    Count")
      (princ "\n-------------------------------------")
      (foreach item (reverse blockList)
        (princ (strcat "\n" (car item)
                      (substr "                              " 1 (- 30 (strlen (car item))))
                      (itoa (cdr item))))
      )
      (princ (strcat "\n\nTotal blocks: " (itoa (length blockList))))

      ;; Optionally export to CSV
      (initget "Yes No")
      (if (= "Yes" (getkword "\nExport to CSV? [Yes/No] <No>: "))
        (AH:EXPORT-BLOCK-COUNT blockList)
      )
    )
    (princ "\nNo blocks found in drawing")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: AH:EXPORT-BLOCK-COUNT
;;; Description: Export block count to CSV file
;;;----------------------------------------------------------------------
(defun AH:EXPORT-BLOCK-COUNT (blockList / filePath dataList)
  (setq filePath (getfiled "Save Block Count" "" "csv" 1))
  (if filePath
    (progn
      (setq dataList (cons '("Block Name" "Count") '()))
      (foreach item blockList
        (setq dataList (append dataList (list (list (car item) (itoa (cdr item))))))
      )
      (AH:EXPORT-TO-CSV dataList filePath)
    )
  )
)

;;;----------------------------------------------------------------------
;;; Function: C:ATTEXPORT
;;; Description: Export all block attributes to CSV
;;; Usage: Type ATTEXPORT at command line
;;;----------------------------------------------------------------------
(defun C:ATTEXPORT (/ blockName ss filePath dataList count ent attrs header)
  (princ "\n=== Attribute Export Tool ===")

  ;; Get block name to export
  (setq blockName (getstring T "\nEnter block name (or * for all): "))

  ;; Select blocks
  (if (= blockName "*")
    (setq ss (ssget "_X" '((0 . "INSERT"))))
    (setq ss (ssget "_X" (list (cons 0 "INSERT") (cons 2 blockName))))
  )

  (if ss
    (progn
      ;; Get file path
      (setq filePath (getfiled "Save Attributes" "" "csv" 1))

      (if filePath
        (progn
          (setq dataList '())
          (setq count 0)

          ;; Collect all attributes
          (repeat (sslength ss)
            (setq ent (ssname ss count))
            (setq attrs (AH:GET-BLOCK-ATTRIBUTES ent))

            ;; Create header from first block
            (if (= count 0)
              (progn
                (setq header '("Block Name" "Handle"))
                (foreach att attrs
                  (setq header (append header (list (car att))))
                )
                (setq dataList (cons header dataList))
              )
            )

            ;; Add row data
            (setq rowData (list
              (cdr (assoc 2 (entget ent)))  ; Block name
              (cdr (assoc 5 (entget ent)))  ; Handle
            ))
            (foreach att attrs
              (setq rowData (append rowData (list (cdr att))))
            )
            (setq dataList (append dataList (list rowData)))

            (setq count (1+ count))
          )

          ;; Export to CSV
          (AH:EXPORT-TO-CSV dataList filePath)
          (princ (strcat "\nExported " (itoa count) " blocks to " filePath))
        )
      )
    )
    (princ "\nNo blocks found")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:ATTIMPORT
;;; Description: Import attribute changes from CSV
;;; Usage: Type ATTIMPORT at command line
;;;----------------------------------------------------------------------
(defun C:ATTIMPORT (/ filePath csvData header row handle ent count updated failed)
  (princ "\n=== Attribute Import Tool ===")

  ;; Get CSV file
  (setq filePath (getfiled "Select CSV File" "" "csv" 0))

  (if filePath
    (progn
      ;; Read CSV file
      (setq csvData (AH:READ-CSV filePath))

      (if csvData
        (progn
          (setq header (car csvData))  ; First row is header
          (setq count 0)
          (setq updated 0)
          (setq failed 0)

          ;; Process each data row (skip header)
          (foreach row (cdr csvData)
            (setq count (1+ count))

            ;; Get handle (should be second column)
            (if (>= (length row) 2)
              (progn
                (setq handle (cadr row))  ; Handle is in second column

                ;; Try to get entity by handle
                (setq ent (handent handle))

                (if ent
                  (progn
                    ;; Update attributes
                    (if (AH:UPDATE-BLOCK-ATTRIBUTES ent header row)
                      (progn
                        (setq updated (1+ updated))
                        (princ (strcat "\n[" (itoa count) "] Updated: " handle))
                      )
                      (progn
                        (setq failed (1+ failed))
                        (princ (strcat "\n[" (itoa count) "] Failed to update: " handle))
                      )
                    )
                  )
                  (progn
                    (setq failed (1+ failed))
                    (princ (strcat "\n[" (itoa count) "] Entity not found: " handle))
                  )
                )
              )
              (princ (strcat "\n[" (itoa count) "] Skipped: Invalid row format"))
            )
          )

          (princ "\n\n=== Import Summary ===")
          (princ (strcat "\nTotal rows: " (itoa count)))
          (princ (strcat "\nUpdated: " (itoa updated)))
          (princ (strcat "\nFailed: " (itoa failed)))
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
;;; Function: AH:READ-CSV
;;; Description: Read CSV file and return list of rows
;;; Arguments: filePath - full path to CSV file
;;; Returns: List of lists (each row is a list of strings)
;;;----------------------------------------------------------------------
(defun AH:READ-CSV (filePath / file line dataList row item inQuote char)
  (setq dataList '())
  (setq file (open filePath "r"))

  (if file
    (progn
      ;; Read each line
      (while (setq line (read-line file))
        (setq row '())
        (setq item "")
        (setq inQuote nil)
        (setq i 1)

        ;; Parse line character by character
        (while (<= i (strlen line))
          (setq char (substr line i 1))

          (cond
            ;; Handle quoted fields
            ((= char "\"")
             (setq inQuote (not inQuote))
            )

            ;; Handle comma (field separator)
            ((and (= char ",") (not inQuote))
             (setq row (append row (list item)))
             (setq item "")
            )

            ;; Regular character
            (T
             (setq item (strcat item char))
            )
          )

          (setq i (1+ i))
        )

        ;; Add last item
        (setq row (append row (list item)))
        (setq dataList (append dataList (list row)))
      )

      (close file)
      dataList
    )
    nil
  )
)

;;;----------------------------------------------------------------------
;;; Function: AH:UPDATE-BLOCK-ATTRIBUTES
;;; Description: Update block attributes from CSV row
;;; Arguments: ent - block entity
;;;           header - list of column names
;;;           row - list of values
;;; Returns: T if successful, nil if failed
;;;----------------------------------------------------------------------
(defun AH:UPDATE-BLOCK-ATTRIBUTES (ent header row / success idx tagName value)
  (setq success T)
  (setq idx 0)

  ;; Skip first two columns (Block Name, Handle)
  (setq idx 2)

  ;; Update each attribute
  (while (< idx (length header))
    (setq tagName (nth idx header))
    (setq value (nth idx row))

    ;; Only update if we have both tag and value
    (if (and tagName value (> (strlen tagName) 0))
      (progn
        ;; Try to set the attribute
        (if (not (AH:SET-BLOCK-ATTRIBUTE ent tagName value))
          (setq success nil)
        )
      )
    )

    (setq idx (1+ idx))
  )

  success
)

;;;----------------------------------------------------------------------
;;; Function: C:BLOCKSCALE
;;; Description: Scale all instances of a block
;;; Usage: Type BLOCKSCALE at command line
;;;----------------------------------------------------------------------
(defun C:BLOCKSCALE (/ blockName scaleFactor ss count ent)
  (princ "\n=== Block Scale Tool ===")

  (setq blockName (getstring T "\nEnter block name to scale: "))
  (setq scaleFactor (getreal "\nEnter scale factor: "))

  (if (and blockName scaleFactor (> scaleFactor 0))
    (progn
      (setq ss (ssget "_X" (list (cons 0 "INSERT") (cons 2 blockName))))

      (if ss
        (progn
          (setq count 0)
          (repeat (sslength ss)
            (setq ent (ssname ss count))
            (command "._SCALE" ent "" (cdr (assoc 10 (entget ent))) scaleFactor)
            (setq count (1+ count))
          )
          (princ (strcat "\nScaled " (itoa count) " instances of " blockName))
        )
        (princ (strcat "\nNo instances of " blockName " found"))
      )
    )
    (princ "\nInvalid input")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Function: C:BLOCKLAYER
;;; Description: Move all instances of a block to a specific layer
;;; Usage: Type BLOCKLAYER at command line
;;;----------------------------------------------------------------------
(defun C:BLOCKLAYER (/ blockName layerName ss count ent)
  (princ "\n=== Block Layer Tool ===")

  (setq blockName (getstring T "\nEnter block name: "))
  (setq layerName (getstring T "\nEnter target layer: "))

  (if (and blockName layerName (tblsearch "LAYER" layerName))
    (progn
      (setq ss (ssget "_X" (list (cons 0 "INSERT") (cons 2 blockName))))

      (if ss
        (progn
          (setq count 0)
          (repeat (sslength ss)
            (setq ent (ssname ss count))
            (command "._CHANGE" ent "" "_P" "_LA" layerName "")
            (setq count (1+ count))
          )
          (princ (strcat "\nMoved " (itoa count) " blocks to layer " layerName))
        )
        (princ (strcat "\nNo instances of " blockName " found"))
      )
    )
    (princ "\nInvalid block name or layer not found")
  )
  (princ)
)

;;;----------------------------------------------------------------------
;;; Load message
;;;----------------------------------------------------------------------
(princ "\n Block Manager loaded (v1.1)")
(princ "\n Commands: BLOCKREPLACE, BLOCKCOUNT, ATTEXPORT, ATTIMPORT, BLOCKSCALE, BLOCKLAYER")
(princ)

;;; End of block-manager.lsp
