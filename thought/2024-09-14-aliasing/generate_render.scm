(use-modules (ice-9 binary-ports))

(define 2pi (* 2 3.14159))
(define 2pi7/8 (* 2pi (/ 7.0 8.0)))
(define pi7/8 (* 3.14159 (/ 7.0 8.0)))
(define sinc-pi-7/8 (/ (sin pi7/8) pi7/8))

(define 2pi1/8 (* 2pi (/ 1.0 8.0)))
(define pi1/8 (* 3.14159 (/ 1.0 8.0)))
(define sinc-pi-1/8 (/ (sin pi1/8) pi1/8))

(define 2pi11/12 (* 2pi (/ 11.0 12.0)))

(define square
	(lambda (x)
		(* x x)))

(define sqrt1+sqr
	(lambda (x)
		(sqrt (+ 1 (square x)))))

(define-macro (scaled-ddx body)
	(letrec (
(dddx
	(lambda (body)
		(cond
		((eq? body `x) 1)
		((number? body) 0)
		((symbol? body) 0)
		((list? body)
			(let ((op (car body)))
				(cond
					((eq? op `cos)
						`(* (- (sin ,(cadr body))) ,(dddx (cadr body))))
					((eq? op `+)
						`(+ ,(dddx (cadr body)) ,(dddx (caddr body))))
					((eq? op `-)
						`(- ,(dddx (cadr body)) ,(dddx (caddr body))))
					((eq? op `*)
						`(+ (* ,(dddx (cadr body)) ,(caddr body)) (* ,(cadr body) ,(dddx (caddr body)))))
					(#t (error "unrecognized op in ddx: " body)))))
		(#t (error "unrecognized body in ddx: " body)))))
) `(/ ,body (sqrt1+sqr ,(dddx body)))))

(define sin-v1-1
	(lambda (x y b)
		(scaled-ddx
			(- y (cos (* 2pi7/8 x)))
			)))

(define sin-v1-2
	(lambda (x y b)
		(scaled-ddx
			(- y (* (cos (* 2pi7/8 x)) sinc-pi-7/8))
			)))

(define circ-1
	(lambda (x y cx b)
		(let ((cy (* (cos (* 2pi7/8 cx)) sinc-pi-7/8)))
			(/ 
				(min 0 (- 0.001 (square (- x cx)) (square (- y cy))))
				(max 0.000001 (sqrt (+ (square (* 2 (- x cx))) (square (* 2 (- y cy))))))
					))))

(define sin-v1-3
	(lambda (x y bs)
		(scaled-ddx
			(- y (* (cos (* 2pi1/8 x)) sinc-pi-7/8))
			)))

#|(define sin-v2-1
	(lambda (x y b)
		(- y (+ (sin (* 2pi7/8 (- x b))) (sin (* 2pi1/8 (- x b)))))))
(define sin-v2-2
	(lambda (x y b)
		(- y (+ 
				(* (sin (* 2pi7/8 (- x b))) sinc-pi-7/8)
				(* (sin (* 2pi1/8 (- x b))) sinc-pi-1/8)
				))))
(define sin-v2-3
	(lambda (x y b)
		(- y (+ 
				(* (sin (- 0 (* 2pi7/8 b) (* 2pi1/8 x))) sinc-pi-7/8)
				(* (sin (* 2pi1/8 (- x b))) sinc-pi-1/8)
				))))
(define circ-2
	(lambda (x y cx b)
		(let ((cy (+ 
						(* (sin (* 2pi7/8 (- cx b))) sinc-pi-7/8)
						(* (sin (* 2pi1/8 (- cx b))) sinc-pi-1/8)
						)))
			(/ 
				(min 0 (- 0.001 (square (- x cx)) (square (- y cy))))
				(max 0.000001 (sqrt (+ (square (* 2 (- x cx))) (square (* 2 (- y cy))))))
					))))|#

; (display (dddx `(- y (+ (cos (* 2pi7/8 (- x b))) (cos (* 2pi1/8 (- x b)))))))
;(display (dddx `(cos (* 2pi7/8 x))))

(define sin-v2-1
	(lambda (x y b)
		(scaled-ddx
			(- y (+ (cos (* 2pi7/8 (- x b))) (cos (* 2pi1/8 (- x b)))))
			;(sqrt1+sqr (+ (* 2pi7/8 (sin (* 2pi7/8 (- x b)))) (* 2pi1/8 (sin (* 2pi1/8 (- x b))))))
			;(sqrt1+sqr (ddx (- y (+ (cos (* 2pi7/8 (- x b))) (cos (* 2pi1/8 (- x b)))))))
			)))
(define sin-v2-2
	(lambda (x y b)
		(scaled-ddx (- y (+ 
				(* (cos (* 2pi7/8 (- x b))) sinc-pi-7/8)
				(* (cos (* 2pi1/8 (- x b))) sinc-pi-1/8)
				)))))
(define sin-v2-3
	(lambda (x y b)
		(scaled-ddx 
			(- y (+ 
				(* (cos (+ (* 2pi1/8 x) (* 2pi7/8 b) )) sinc-pi-7/8)
				(* (cos (* 2pi1/8 (- x b))) sinc-pi-1/8)
				)))))
(define circ-2
	(lambda (x y cx b)
		(let ((cy (+ 
						(* (cos (* 2pi7/8 (- cx b))) sinc-pi-7/8)
						(* (cos (* 2pi1/8 (- cx b))) sinc-pi-1/8)
						)))
			(/ 
				(min 0 (- 0.001 (square (- x cx)) (square (- y cy))))
				(max 0.000001 (sqrt (+ (square (* 2 (- x cx))) (square (* 2 (- y cy))))))
					))))

(define circ
	(lambda (x y t)
		(apply max (map
				(lambda (cx) (circ-1 x y cx t))
				(list -4 -3 -2 -1 0 1 2 3 4)))))

(define signal-static
	(lambda (x y t)
		(*
			(+ 0.5 (* 0.5 (cos (* 2pi7/8 x)) #|(cos (* 2pi11/12 y))|# ))
			(/ 300 (sqrt (+ (* x x) (* y y) (* 50 50))))
			)))

(define signal-dynamic
	(lambda (x y b)
		(*
			(+ 0.5 (* 0.25 (+ (cos (* 2pi7/8 (- x b))) (cos (* 2pi1/8 (- x b))) )))
			(/ 300 (sqrt (+ (* x x) (* y y) (* 50 50))))
			)))

(define (randc)
	(- (random 1.0) 0.5))

(define signal-static-sampler
	(lambda (cx cy b n)
		(if (zero? n)
			0
			(+
				(signal-dynamic (+ cx (randc)) (+ cy (randc)) b)
				(signal-static-sampler cx cy b (- n 1))))))

(define draw-sinousoids
	(lambda (file x y t)
		(let* (
				(px (- x 400))
				(py (- y 200))
				; (val1 (abs (sin-v2-1 px py t)))
				; (val2 (abs (sin-v2-2 px py t)))
				; (val3 (abs (sin-v2-3 px py t)))
				; (val4 (abs (circ px py t)))
				
				; (val1 (abs (sin-v1-1 px py t)))
				; (val2 (abs (sin-v1-2 px py t)))
				; (val3 (abs (sin-v1-3 px py t)))
				; (val4 (abs (circ px py t)))

				; (val1 (signal-static px py t))
				(val1 (/ (signal-static-sampler px py t 64) 64.0)) ; 512

				(v1 (inexact->exact (floor (* 255 (/ val1 (+ val1 1))))))
				; (v2 (if (< val2 0.01) 255 0))
				; (v3 (if (< val3 0.01) 255 0))
				; (v4 (if (< val4 0.02) 255 0))
				
				)
			(begin
				(put-u8 file v1)
				(put-u8 file v1)
				(put-u8 file v1)
				(if (and (= x 799) (= y 399))
					#t
					(if (= x 799)
						(draw-sinousoids file 0 (+ y 1) t)
						(draw-sinousoids file (+ x 1) y t)))))))

(define save-file
	(lambda (filename t)
		(let ((file (open-file filename "wb")))
			(begin
				; P6\n
				(put-u8 file 80)
				(put-u8 file 54)
				(put-u8 file 10)
				; 800 400 255\n
				(put-u8 file 56)
				(put-u8 file 48)
				(put-u8 file 48)
				(put-u8 file 32)

				(put-u8 file 52)
				(put-u8 file 48)
				(put-u8 file 48)
				(put-u8 file 32)

				(put-u8 file 50)
				(put-u8 file 53)
				(put-u8 file 53)
				(put-u8 file 10)

				(draw-sinousoids file 0 0 t)

				(close-port file)))))

; (save-file "output.ppm" 0.5)

(map
	(lambda (index)
		(save-file (string-append "output-" (number->string index) ".ppm") (* index 0.125)))
	(list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63)
	;(list 5)
	; (list 0 1 2 3 4 5 6 7 8 9 10 11 12)
	; (list 5 6 7 8 9 10 11 12)
	)