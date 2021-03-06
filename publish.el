;; publish.el --- Publish org-mode project on Gitlab Pages
;; Author: Sachin Patil, Liwen Knight-Zhang

;;; Commentary:
;; This script will convert the org-mode files in this directory into
;; html.

;;; Code:
(require 'package)
(package-initialize)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-refresh-contents)
(package-install 'htmlize)
(package-install 'org-plus-contrib)
(package-install 'ox-reveal)

(require 'org)
(require 'ox-publish)
(require 'ox-reveal)

;; setting to nil, avoids "Author: x" at the bottom
(setq org-export-with-section-numbers nil
      org-export-with-smart-quotes t
      org-export-with-toc nil)

(defvar psachin-date-format "%b %d, %Y")

(setq org-html-divs '((preamble "header" "top")
                      (content "main" "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format psachin-date-format
      org-html-checkbox-type 'html
      org-html-html5-fancy t
      org-html-validation-link t
      org-html-doctype "html5"
      org-html-htmlize-output-type 'css
      org-src-fontify-natively t)


(defvar psachin-website-html-head
  "<link rel='apple-touch-icon' sizes='180x180' href='/apple-touch-icon.png'>
<link rel='icon' type='image/png' sizes='32x32' href='/favicon-32x32.png'>
<link rel='icon' type='image/png' sizes='16x16' href='/favicon-16x16.png'>
<link rel='manifest' href='/site.webmanifest'>
<meta name='msapplication-TileColor' content='#da532c'>
<meta name='theme-color' content='#ffffff'>

<link rel='preconnect' href='https://fonts.gstatic.com' crossorigin />
<link href='https://fonts.googleapis.com/css2?family=Average+Sans&family=Goudy+Bookletter+1911&display=swap' rel='stylesheet' />
<link rel='stylesheet' href='/css/site.css?v=2' type='text/css'/>
<link rel='stylesheet' href='/css/syntax-coloring.css' type='text/css'/>")

(defun psachin-website-html-preamble (plist)
  "PLIST: An entry."
  ;; Skip adding subtitle to the post if :KEYWORDS don't have 'post' has a
  ;; keyword
  (when (string-match-p "post" (format "%s" (plist-get plist :keywords)))
    (plist-put plist
	       :subtitle (format "Published on %s"
				 (org-export-get-date plist psachin-date-format))))

  ;; Below content will be added anyways
"<div class='intro'>
  <img src='/images/about/profile.png' alt='Liwen Knight-Zhang' class='no-border'/>
  <h1>Liwen Knight-Zhang</h1>
  <p>Emacser, Coder, Husband & Lifelong Learner</p>
</div>

<div class='nav'>
  <ul>
    <li><a href='/'><i class='icon-home-outline'></i> Home</a></li>
    <li><a href='/about'><i class='icon-user'></i> About</a></li>
    <!--<li><a href='http://github.com/lwkz'><i class='icon-github'></i> GitHub</a><li>-->
    <li><a href='/index.xml'><i class='icon-rss-outline'></i> RSS</a><li>
    <!--<li><a href='https://www.twitter.com'><i class='icon-twitter'></i> Twitter</a></li>-->
  </ul>
</div>")

(defvar psachin-website-html-postamble
  "<div class='footer'>
    <p>Copyright © 2011-2020 Liwen Knight-Zhang</p>
    <p>Last updated on %C</p>
    <p>Published with %c <i class='icon-emo-thumbsup'></i>
</div>")

(defvar site-attachments
  (regexp-opt '("jpg" "jpeg" "gif" "png" "svg"
                "eot" "ttf" "woff" "woff2" "ico" "cur"
                "css" "js" "html" "pdf" "txt" "xml" "webmanifest"))
  "File types that are published as static files.")


(defun psachin/org-sitemap-format-entry (entry style project)
  "Format posts with author and published data in the index page.
ENTRY: file-name
STYLE:
PROJECT: `posts in this case."
  (cond ((not (directory-name-p entry))
         (format "[[file:%s][%s]]
                 #+HTML: <p class='pubdate'>%s</p>"
                 entry
                 (org-publish-find-title entry project)
                 (format-time-string psachin-date-format
                                     (org-publish-find-date entry project))))
        ((eq style 'tree) (file-name-nondirectory (directory-file-name entry)))
        (t entry)))


(defun psachin/org-reveal-publish-to-html (plist filename pub-dir)
  "Publish an org file to reveal.js HTML Presentation.
FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.  Returns output file name."
  (let ((org-reveal-root "http://cdn.jsdelivr.net/reveal.js/3.0.0/"))
    (org-publish-org-to 'reveal filename ".html" plist pub-dir)))

(setq org-publish-project-alist
      `(("posts"
         :base-directory "posts"
         :base-extension "org"
         :recursive t
         :publishing-function org-html-publish-to-html
         :publishing-directory "./public"
         :exclude ,(regexp-opt '("README.org" "draft"))
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Articles"
         :sitemap-format-entry psachin/org-sitemap-format-entry
         :sitemap-style list
         :sitemap-sort-files anti-chronologically
         :html-link-home "/"
         :html-link-up "/"
         :html-head-include-scripts t
         :html-head-include-default-style nil
         :html-head ,psachin-website-html-head
         :html-preamble psachin-website-html-preamble
         :html-postamble ,psachin-website-html-postamble)
        ("about"
         :base-directory "about"
         :base-extension "org"
         :exclude ,(regexp-opt '("README.org" "draft"))
         :index-filename "index.org"
         :recursive nil
         :publishing-function org-html-publish-to-html
         :publishing-directory "./public/about"
         :html-link-home "/"
         :html-link-up "/"
         :html-head-include-scripts t
         :html-head-include-default-style nil
         :html-head ,psachin-website-html-head
         :html-preamble psachin-website-html-preamble
         :html-postamble ,psachin-website-html-postamble)
        ("sites-assets"
         :base-directory "./site-assets"
         :base-extension ,site-attachments
         :publishing-directory "./public"
         :publishing-function org-publish-attachment
         :recursive t)
        ("css"
         :base-directory "./css"
         :base-extension ,site-attachments
         :publishing-directory "./public/css"
         :publishing-function org-publish-attachment
         :recursive t)
        ("font"
         :base-directory "./font"
         :base-extension ,site-attachments
         :publishing-directory "./public/font"
         :publishing-function org-publish-attachment
         :recursive t)
        ("images"
         :base-directory "./images"
         :base-extension ,site-attachments
         :publishing-directory "./public/images"
         :publishing-function org-publish-attachment
         :recursive t)
        ("assets"
         :base-directory "./assets"
         :base-extension ,site-attachments
         :publishing-directory "./public/assets"
         :publishing-function org-publish-attachment
         :recursive t)
        ("rss"
         :base-directory "posts"
         :base-extension "org"
         :html-link-home "http://example.com/"
         :rss-link-home "http://example.com/"
         :html-link-use-abs-url t
         :rss-extension "xml"
         :publishing-directory "./public"
         :publishing-function (org-rss-publish-to-rss)
         :section-number nil
         :exclude ".*"
         :include ("index.org")
         :table-of-contents nil)
        ("all" :components ("posts" "about" "css" "font" "sites-assets" "images" "assets" "rss"))))

(provide 'publish)
;;; publish.el ends here
