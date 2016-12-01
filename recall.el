;;; recall --- Recall - Edit history navigation for Emacs
;;; Commentary:
;;; Code:

(require 'cl)
(require 'popup)

(defgroup recall-group nil
  "Recall."
  :group 'convenience)

(defcustom recall-capacity 8
  "Max numbers of places to remember."
  :type 'integer
  :group 'recall-group)

(defcustom recall-distance 300
  "Max ignore distance threshold."
  :type 'integer
  :group 'recall-group)

(defvar recall--memory '())
(defvar recall--current-point -1)
(defvar recall--current-buffer nil)

(defun recall--ignore-this-place (buffer)
  (string= " " (substring (buffer-name buffer) 0 1)))

(defun recall--need-to-remember ()
  (or (and (eq recall--current-buffer (current-buffer))
           (> (abs (- recall--current-point (point))) recall-distance))
      (and (not (recall--ignore-this-place (current-buffer)))
           (not (eq recall--current-buffer (current-buffer))))))

(defun recall--cleanup-invalid ()
  (setq recall--memory (remove-if (lambda (e) (eq nil (marker-buffer e)))
                                  recall--memory)))

(defun recall--rembember ()
  (add-to-list 'recall--memory (point-marker))
  (when (> (length recall--memory) recall-capacity)
    (set-marker (car(last recall--memory)) nil nil)
    (nbutlast recall--memory 1))
  (setq recall--current-point (point))
  (setq recall--current-buffer (current-buffer)))

(defun recall--trim-string (string)
  "Remove white spaces in beginning and ending of STRING.
White space here is any of: space, tab, emacs newline (line feed, ASCII 10)."
(replace-regexp-in-string "\\`[ \t\n]*" "" (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defun recall--recall-name (place)
  (with-current-buffer (marker-buffer place)
    (save-excursion
      (goto-char (marker-position place))
      (concat
       (buffer-name (current-buffer))
       "("
       (number-to-string (line-number-at-pos (marker-position place)))
       "): "
       (recall--trim-string
        (buffer-substring-no-properties (max (progn (beginning-of-line) (point)) (- (marker-position place) 35))
                                        (min (progn (end-of-line) (point)) (+ (marker-position place) 35))))))))

(defun recall--popupize (place)
  (popup-make-item (recall--recall-name place) :value place))

(defun recall--recall (place)
  (switch-to-buffer (marker-buffer place))
  (goto-char (marker-position place)))

(defun recall--self-insert-hook ()
  (when (recall--need-to-remember)
              (recall--rembember)))

(add-hook 'post-self-insert-hook 'recall--self-insert-hook)
;;(remove-hook 'post-self-insert-hook 'recall--self-insert-hook)

(defun recall ()
  (interactive)
  (recall--cleanup-invalid)
  (recall--recall (popup-menu* (mapcar 'recall--popupize recall--memory)
                               :scroll-bar t
                               :isearch t)))

(defun recall-remember ()
  (interactive)
  (recall--rembember))

;;//- mode definition -
(define-minor-mode recall-mode
  "Recall - Edit history navigation for Emacs"
  :lighter " recall"
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-x r") 'recall)
            (define-key map (kbd "C-x C-r") 'recall-remember)
            map))

(provide 'recall)
;;; recall.el ends here
