# recall.el
Emacs edit history navigator using popup.el

#Installation / Usage
You must have popup.el installed, then just add to init.el:
```
(add-to-list 'load-path "~/path-to-recall")
(require 'recall)
(add-hook 'change-major-mode-hook 'recall-mode)
```

#Screenshot:
![Preview](/screenshot.png?raw=true "Preview")

#Commands
* recall - displays popup with last edits, selecting one moves cursor to its position
* recall-remember - adds current place to list manually

#Default shortcuts:
* C-x r - recall
* C-x C-r - recall-remember

#Customization:
* Enter customize->convenience->Recall Group