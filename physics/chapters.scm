(include "generator.scm")

(define single-chapter-html
	(lambda (number)
		(string-append "<p><a href=\"/physics/" (lesson-html number) "/\">Chapter " (number->string number) ": " (lesson-title number) "</a></p>\n")))

(define chapters
	(string-append
		(physics-with-danno-html-header -999)

		"<h2>Chapters:</h2>"

		(apply string-append (map single-chapter-html (list 0 1 2 3 4 5)))

		(para "General changelog:")
		(ulist
			"2024 Jan 30: Add chapters 0 through 3"
			"2024 Feb 4: Add chapters 4 and 5, add labels to all of the graph axes, changed subscript times to be more consistent")

		physics-with-danno-html-footer))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file "index.html")))
    (begin
        ; (write-string lesson1 file)
        (put-string file chapters)
        (close-port file)))