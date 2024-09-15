(use-modules (ice-9 binary-ports))

(define file (open-output-file "out.ppm"))

(define draw-sinousoids
	(lambda (x y)
		`(255 255 255)))

; P6\n
(put-u8 file 80)
(put-u8 file 54)
(put-u8 file 10)
; 100 100 255\n
(put-u8 file 49)
(put-u8 file 48)
(put-u8 file 48)
(put-u8 file 32)

(put-u8 file 49)
(put-u8 file 48)
(put-u8 file 48)
(put-u8 file 32)

(put-u8 file 50)
(put-u8 file 53)
(put-u8 file 53)
(put-u8 file 10)



(close-port file)
