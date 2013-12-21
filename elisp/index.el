(let* ((dir "posts")
       (files (directory-files dir t "^[^\\.][^#].*\\.org$" t))
       entries)
  (dolist (file files)
    (let* ((path (concat dir "/" (file-name-nondirectory file)))
           (git-date (date-to-time (magit-git-string "log" "-1" "--format=%ci" file)))
           (env (org-combine-plists (org-babel-with-temp-filebuffer file (org-export-get-environment)))))
      (plist-put env :path path)
      (plist-put env :git-date git-date)
      (push env entries)))
  (dolist (entry (sort entries (lambda (a b) (time-less-p (plist-get b :git-date) (plist-get a :git-date)))))
    (princ
     (format "* [[file:%s][%s]]\n\n%s\n\nLast update: %s\n\n"
             (plist-get entry :path)
             (car (plist-get entry :title))
             (plist-get entry :description)
             (format-time-string "%Y-%m-%d %H:%M" (plist-get entry :git-date))))
    ))
