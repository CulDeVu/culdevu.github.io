
(define DEFAULT-DT (/ 1 2048))
(define sim-max-time 8)

(define caddddr
    (lambda (x)
        (car (cdr (cdr (cdr (cdr x)))))))

(define repeat
    (lambda (num a)
        (if (eq? num 0)
            '()
            (cons a (repeat (- num 1) a)))))

; Applies args to a list of funcs, one at a time
; (mapall (func1 func2) a b) -> ((func1 a b) (func2 a b))
(define mapall
    (lambda (funcs . args)
        (if (nil? funcs)
            '()
            (cons
                (apply (car funcs) args)
                (apply mapall (cons (cdr funcs) args))))))

(define inexact
    (lambda (x) 
        (exact->inexact x)))
(define num3-helper
    (lambda (str n)
        (if (nil? str)
            '()
            (if (eq? n 0)
                '()
                (if (eq? (car str) #\.)
                    (cons (car str) (num3-helper (cdr str) 1))
                    (cons (car str) (num3-helper (cdr str) (- n 1))))))))
(define num3-helper-2
    (lambda (str)
        (if (nil? str)
            '()
            (if (eq? (car str) #\.)
                '()
                (cons (car str) (num3-helper-2 (cdr str)))))))
(define leftpad
    (lambda (str n)
        (string-append (list->string (repeat (- n (string-length str)) #\0)) str)))
; (define num3-helper
;     (lambda (str n)
;         (if (nil? str)
;             '()
;             (cons (car str) (num3-helper (cdr str) (- n 1))))))
; (define dec2
;     (lambda (x)
;         (/ (round (* x 1024)) 1024)))
; (define num3
;     (lambda (x)
;         (list->string (num3-helper (string->list (number->string (dec2 x))) 99999))))
; (sim-graphs-2 sim01 get-time-2-history get-pos-history)
(define num3
    (lambda (x)
        (if (>= x 0)
            (string-append 
                (list->string (num3-helper-2 (string->list (number->string (floor x)))))
                "."
                (leftpad (list->string (num3-helper-2 (string->list (number->string (* (- x (floor x)) 1000))))) 3))
            (string-append
                (list->string (num3-helper-2 (string->list (number->string (ceiling x)))))
                "."
                (leftpad (list->string (num3-helper-2 (string->list (number->string (* (- (ceiling x) x) 1000))))) 3))
            )))
(define num3'
    (lambda (x)
       (number->string x)))

(define reverse
    (lambda (a)
        (if (nil? a)
            '()
            (append (reverse (cdr a)) (list (car a))))))

(define length2 
    (lambda (l accum) 
        (if (nil? l)
            accum
            (length2 (cdr l) (+ accum 1)))))
(define length 
    (lambda (l) (length2 l 0)))

(define index
    (lambda (l ind)
        (if (nil? l)
            (error "index OOB")
            (if (eq? ind 0)
                (car l)
                (index (cdr l) (- ind 1)))
            )))

(define count-reverse
    (lambda (num)
        (if (eq? num 0)
            '()
            (cons (- num 1) (count-reverse (- num 1))))))

(define take-every-nth
    (lambda (l n c)
        (if (nil? l)
            '()
            (if (eq? c 0)
                (cons (car l) (take-every-nth (cdr l) n (- n 1)))
                (take-every-nth (cdr l) n (- c 1))))))

(define foldr
    (lambda (f l)
        (if (nil? (cdr l))
            (car l)
            (f (car l) (foldr f (cdr l))))))

(define interleave
    (lambda (l item)
        (if (nil? (cdr l))
            (list (car l))
            (cons (car l) (cons item (interleave (cdr l) item))))))

(define pow
    (lambda (x n)
        (foldr * (repeat n x))))
(define square
    (lambda (x)
        (pow x 2)))

(define downsamp-sm
    (lambda (x)
        (reverse (take-every-nth x 128 0))))

(define list-truncate
    (lambda (l n)
        (if (eq? n 0)
            '()
            (cons (car l) (list-truncate (cdr l) (- n 1))))))

; (define transpose
;   (lambda (mat)
;       ))

; sim-object object stuff
(define make-sim-object
    (lambda (m v p)
        (list m v p)))
(define get-sim-object-mass
    (lambda (o) (car o)))
(define get-sim-object-vel
    (lambda (o) (cadr o)))
(define get-sim-object-pos
    (lambda (o) (caddr o)))

(define get-sim-object-rad
    (lambda (o)
        (sqrt (get-sim-object-mass o))))

; sim-frame object stuff
(define make-sim-frame
    (lambda (all-objs time)
        (cons (inexact time) all-objs)))
(define sim-frame-all-objs
    (lambda (sim-frame)
        (cdr sim-frame)))
(define sim-frame-time
    (lambda (sim-frame)
        (car sim-frame)))
#|(define make-sim-frame
    (lambda (all-objs time)
        all-objs))
(define sim-frame-get-all-objs
    (lambda (sim-frame)
        sim-frame))|#

(define make-sim-spawn
    (lambda (. objs)
        (list (make-sim-frame objs 0))))
(define make-sim
    (lambda (new-sim-frame old-sim)
        (cons new-sim-frame old-sim)))
(define sim-get-newest-frame
    (lambda (sim)
        (car sim)))
(define sim-get-all-older-frames
    (lambda (sim)
        (cdr sim)))
(define sim-get-frame-at-time
    (lambda (sim time)
        '()))
(define sim-get-all-newest-objects
    (lambda (sim)
        (sim-frame-all-objs (sim-get-newest-frame sim))))
(define sim-object
    (lambda (sim obj-number)
        (index (sim-get-all-newest-objects sim) obj-number)))
(define sim-get-num-objects
    (lambda (sim)
        (length (sim-frame-all-objs (sim-get-newest-frame sim)))))

(define collision-force
    (lambda (curr other)
        (let* 
            (
                (curr-pos (get-sim-object-pos curr))
                (curr-rad (get-sim-object-rad curr))
                (other-pos (get-sim-object-pos other))
                (other-rad (get-sim-object-rad other))
                (pos-diff (/ (- curr-pos other-pos) (+ curr-rad other-rad))))
            (if (or (eq? curr-pos other-pos) (>= (abs (- other-pos curr-pos)) (+ curr-rad other-rad)))
                0
                ; (/ 1 (- curr-pos other-pos))
                ; (/ 0.0833333 (pow pos-diff 5))
                (* (- (/ 0.125 (pow (abs pos-diff) 5)) 0.125) (/ pos-diff (abs pos-diff)))
                ))))
(define calc-forces-singular
    (lambda (obj all-objs)
        (apply + (map collision-force (repeat (length all-objs) obj) all-objs))))
(define calc-forces-1
    (lambda (objs all-objs)
        (if (nil? objs)
            '()
            (cons (calc-forces-singular (car objs) all-objs) (calc-forces-1 (cdr objs) all-objs)))))
(define calc-forces
    (lambda (all-objs)
        (calc-forces-1 all-objs all-objs)))

(define advance-sim-1
    (lambda (objs forces dt)
        (if (nil? objs)
            '()
            (let* 
                (
                    (obj (car objs))
                    (force' (car forces))
                    (mass (get-sim-object-mass obj))
                    (dvel' (* (/ force' mass) dt))
                    (vel' (inexact (+ (get-sim-object-vel obj) dvel')))
                    (dpos' (* vel' dt))
                    (pos' (inexact (+ (get-sim-object-pos obj) dpos'))))
                (cons (make-sim-object mass vel' pos') (advance-sim-1 (cdr objs) (cdr forces) dt))))))
(define advance-sim
    (lambda (objs-history forces dt)
        (cons (advance-sim-1 (car objs-history) forces dt) objs-history)))

(define sim-with-dt
    (lambda (old-sim dt)
        (let (
            (all-objs (sim-frame-all-objs (sim-get-newest-frame old-sim)))
            (time (sim-frame-time (sim-get-newest-frame old-sim))))
            (if (> time sim-max-time)
                old-sim
                ; (sim (advance-sim objs (calc-forces objs) DEFAULT-DT) (+ time DEFAULT-DT)))))
                (sim-with-dt
                    (make-sim 
                        (make-sim-frame
                            (advance-sim-1 all-objs (calc-forces all-objs) dt)
                            (+ time dt))
                        old-sim)
                    dt)))))

(define sim
    (lambda (objs)
        (sim-with-dt objs DEFAULT-DT)))

; (define sim-history-get-num-objects
;     (lambda (sim-history)
;         (length (car sim-history))))


; (define get-object-param-at-time
;   (lambda (sim-history f obj-number time)
;       ))
; (define get-time-history
;     (lambda (sim-history)
;         (let ((times-dt (lambda (x) (inexact (* x dt)))))
;             (map times-dt (count-reverse (length sim-history))))))

; (define get-time-history
;     (lambda (sim-history obj-number)
;         (let ((times-dt (lambda (x) (inexact (* x DEFAULT-DT)))))
;             (map times-dt (count-reverse (length sim-history))))))
; (define get-time-history
;     (lambda (sim obj-number)
;         (if (nil? sim)
;             '()
;             (begin (display (length sim)) (display "\n") (cons
;                 (sim-frame-time (sim-get-newest-frame sim))
;                 (get-time-history (sim-get-all-older-frames sim) obj-number))))))
(define get-time-history
    (lambda (sim obj-number)
        (map (lambda (frame) (sim-frame-time frame)) sim)))
; (define get-time-history
;     (lambda (sim obj-number)
;         (map (lambda (frame) (get-sim-object-pos (index (sim-frame-all-objs frame) obj-number))) sim)))

(define get-pos-history
    (lambda (sim obj-number)
        (if (nil? sim)
            '()
            (cons
                (get-sim-object-pos (index (sim-get-all-newest-objects sim) obj-number))
                (get-pos-history (sim-get-all-older-frames sim) obj-number)))))
(define get-vel-history
    (lambda (sim obj-number)
        (if (nil? sim)
            '()
            (cons
                (get-sim-object-vel (index (sim-get-all-newest-objects sim) obj-number))
                (get-vel-history (sim-get-all-older-frames sim) obj-number)))))
(define get-force-history
    (lambda (sim obj-number)
        (if (nil? (sim-get-all-older-frames sim))
            (list 0)
            (cons
                (let* (
                    (frame-curr (sim-get-newest-frame sim))
                    (frame-old (sim-get-newest-frame (sim-get-all-older-frames sim)))
                    (state-curr (sim-get-all-newest-objects sim))
                    (state-old (sim-get-all-newest-objects (sim-get-all-older-frames sim)))
                    (vel-curr (get-sim-object-vel (index state-curr obj-number)))
                    (vel-old (get-sim-object-vel (index state-old obj-number)))
                    (time-curr (sim-frame-time frame-curr))
                    (time-old (sim-frame-time frame-old))
                    (dt (- time-curr time-old))
                    (mass (get-sim-object-mass (index state-curr obj-number))))
                    (* (/ (- vel-curr vel-old) dt) mass))
                (get-force-history (sim-get-all-older-frames sim) obj-number)))))
(define get-p-history
    (lambda (sim obj-number)
        (if (nil? sim)
            '()
            (cons
                (* (get-sim-object-vel (sim-object sim obj-number)) (get-sim-object-mass (sim-object sim obj-number)))
                (get-p-history (sim-get-all-older-frames sim) obj-number)))))
(define get-ke-history
    (lambda (sim-history obj-number)
        (if (nil? sim-history)
            '()
            (let ((obj (index (sim-get-all-newest-objects sim-history) obj-number)))
                (cons
                    (* 0.5 (get-sim-object-vel obj) (get-sim-object-vel obj) (get-sim-object-mass obj))
                    (get-ke-history (cdr sim-history) obj-number))))))


(define get-sim-object-force
    (lambda (frame-prv frame-next obj-number)
        (let* (
            (obj-prv (index (sim-frame-all-objs frame-prv) obj-number))
            (obj-next (index (sim-frame-all-objs frame-next) obj-number))
            (vel-prv (get-sim-object-vel obj-prv))
            (vel-next (get-sim-object-vel obj-next))
            (mass (get-sim-object-mass obj-prv))
            (dt (- (sim-frame-time frame-next) (sim-frame-time frame-prv))))
            (* (/ (- vel-next vel-prv) dt) mass))))
(define get-sim-object-dpos
    (lambda (frame-prv frame-next obj-number)
        (let* (
            (obj-prv (index (sim-frame-all-objs frame-prv) obj-number))
            (obj-next (index (sim-frame-all-objs frame-next) obj-number))
            (pos-prv (get-sim-object-pos obj-prv))
            (pos-next (get-sim-object-pos obj-next)))
            (- pos-next pos-prv))))

(define get-pos-at-time
    (lambda (sim obj-number time)
        (if (nil? sim)
            (error "time out of bounds")
            (if (< (abs (- time (sim-frame-time (sim-get-newest-frame sim)))) 0.00001)
                (get-sim-object-pos (sim-object sim obj-number))
                (get-pos-at-time (sim-get-all-older-frames sim) obj-number time)))))
(define get-ke-at-time
    (lambda (sim obj-number time)
        (if (nil? sim)
            (error "time out of bounds")
            (let* (
                (frame (sim-get-newest-frame sim))
                (obj (index (sim-frame-all-objs frame) obj-number))
                (mass (get-sim-object-mass obj))
                (vel (get-sim-object-vel obj)))
                (if (< (abs (- time (sim-frame-time frame))) 0.00001)
                    (* 0.5 mass vel vel)
                    (get-ke-at-time (sim-get-all-older-frames sim) obj-number time))))))
; (define get-integral-force-dpos-at-time
;     (lambda (sim obj-number time)
;         (if (nil? (cdr sim))
;             0
;             (let* (
;                 (frame (sim-get-newest-frame sim))
;                 (frame-prv (sim-get-newest-frame (sim-get-all-older-frames sim)))
;                 (obj (index (sim-frame-all-objs frame) obj-number))
;                 (force (get-sim-object-force frame-prv frame obj-number)))
;                 (+ 
;                     (* (get-sim-object-force frame-prv frame obj-number) (get-sim-object-dpos frame-prv frame obj-number))
;                     (get-integral-force-dpos-at-time (sim-get-all-older-frames sim) obj-number time))))))

; (define get-integral-helper
;     (lambda (xs ys)
;         (if (nil? (cdr xs))
;             0
;             (+
;                 (begin (display (car ys)) (display " ") (display (car xs)) (display " ") (display (cadr xs)) (display " ") (display (length xs)) (display "\n") (* (car ys) (- (cadr xs) (car xs))))
;                 (get-integral-helper (cdr xs) (cdr ys))))))

; Will return a list that is one less than the source list
(define history-to-dhistory
    (lambda (l)
        (if (nil? (cdr l))
            '()
            (cons
                (- (cadr l) (car l))
                (history-to-dhistory (cdr l))))))

; NOTE: does not actually calculate force*dpos integral
; TODO: really need to clean this shit up.
(define get-integral-dvel-2
    (lambda (sim obj-number)
        (let* (
            (vel-history (reverse (get-vel-history sim obj-number)))
            (dvel (history-to-dhistory vel-history)))
            (apply + (map square dvel)))))
        ; (get-integral-helper (get-pos-history sim obj-number) (get-force-history sim obj-number))))





; (display 
;     (take-every-nth
;         (reverse 
;             (get-pos-history
;                 (sim (list (list (make-sim-object 1 1 0) (make-sim-object 1 0 4))) 0)
;                 1))
;         128 0))
; (display "\n")




(define svg-colors (list "red" "green" "blue"))
(define svg-integral-colors (list "rgba(255,0,0,0.5)" "rgba(0,255,0,0.5)" "rgba(0,0,255,0.5)"))
; (define get-sim-history-colors
;     (lambda (sim-history)
;         (if (eq? (length (car sim-history)) 2)
;             (list "red" "green")
;             (error "unsupported number of objects in sim"))))


(define sim-vis-ball-svg
    (lambda (dimensions)
        (let (
            (vert-rad (car dimensions))
            (horiz-left (cadr dimensions))
            (horiz-right (caddr dimensions)))
            (string-append
                ; "M" (num3 horiz-right) " 0"
                ; "A" (num3 horiz-right) " " (num3 vert-rad) " 0 0 1 " (number->string 0) " " (num3 vert-rad)
                ; "A" (num3 horiz-left) " " (num3 vert-rad) " 0 0 1 -" (num3 horiz-left) " " (number->string 0)
                ; "A" (num3 horiz-left) " " (num3 vert-rad) " 0 0 1 " (number->string 0) " -" (num3 vert-rad)
                ; "A" (num3 horiz-right) " " (num3 vert-rad) " 0 0 1 " (num3 horiz-right) " " (number->string 0)
                "M" "0 -" (num3 vert-rad)
                "A" (num3 horiz-right) " " (num3 vert-rad) " 0 0 1 " "0 " (num3 vert-rad)
                "A" (num3 horiz-left) " " (num3 vert-rad) " 0 0 1 " "0 -" (num3 vert-rad)
                ))))
; (define sim-vis-ball-dimensions
;     (lambda (objs)
;         (if (nil? objs)
;             '()
;             (cons
;                 (list (get-sim-object-rad (car objs)) (get-sim-object-rad (car objs)) (get-sim-object-rad (car objs)))
;                 (sim-vis-ball-dimensions (cdr objs))))))
(define sim-vis-ball-dimensions-horiz-single-2
    (lambda (curr other)
        (let (
            (midpt (/ (* (- (get-sim-object-pos other) (get-sim-object-pos curr)) (get-sim-object-rad curr)) (+ (get-sim-object-rad curr) (get-sim-object-rad other)))))
            (list
                (if (< midpt 0)
                    (min (get-sim-object-rad curr) (- midpt))
                    (get-sim-object-rad curr))
                (if (> midpt 0)
                    (min (get-sim-object-rad curr) midpt)
                    (get-sim-object-rad curr))))))
(display 
    (sim-vis-ball-dimensions-horiz-single-2
        (make-sim-object 1 0 0)
        (make-sim-object 1 0 0.5)))
(define merge-smallest-ball-dimension
    (lambda (curr other)
        (list
            (min (car curr) (car other))
            (min (cadr curr) (cadr other)))))
(define sim-vis-ball-dimensions-horiz-single
    (lambda (obj all-objs)
        (foldr merge-smallest-ball-dimension
            (map sim-vis-ball-dimensions-horiz-single-2
                (repeat (length all-objs) obj)
                all-objs))))
        ; (let* (
        ;     (left-edges
        ;         (map
        ;             -
        ;             (map get-sim-object-pos all-objs)
        ;             (map get-sim-object-rad all-objs)))
        ;     (right-edges
        ;         (map
        ;             +
        ;             (map get-sim-object-pos all-objs)
        ;             (map get-sim-object-rad all-objs))))
        ;     )))
(define sim-vis-ball-dimensions-2
    (lambda (objs all-objs)
        (if (nil? objs)
            '()
            (let* (
                (horiz-dim (sim-vis-ball-dimensions-horiz-single (car objs) all-objs))
                (rad-left (car horiz-dim))
                (rad-right (cadr horiz-dim))
                (orig-rad (get-sim-object-rad (car objs)))
                (target-area (get-sim-object-mass (car objs)))
                (rad-vert (inexact (* 2 (/ target-area (+ rad-left rad-right))))))
                (cons
                    (list rad-vert (car horiz-dim) (cadr horiz-dim))
                    (sim-vis-ball-dimensions-2 (cdr objs) all-objs))))))
(define sim-vis-ball-dimensions
    (lambda (sim-frame)
        (sim-vis-ball-dimensions-2 (sim-frame-all-objs sim-frame) (sim-frame-all-objs sim-frame))))

(define animate-formatted-list
    (lambda (nums)
        (if (nil? (cdr nums))
            (number->string (car nums))
            (string-append
                (num3 (car nums))
                ";"
                (animate-formatted-list (cdr nums))))))
(define animate-formatted-list-str
    (lambda (items)
        (if (nil? (cdr items))
            (car items)
            (string-append
                (car items)
                ";"
                (animate-formatted-list-str (cdr items))))))
(define sim-vis
    (lambda (simulation)
        (let (
            (single-ball (lambda (obj-number)
                (string-append
                    ; TODO: downsamp-sm closer to the "simulation" value, so that sim-vis-ball-dimension-2 doesn't have a ton of throwaway work
                    ; TODO: crosshair center
                    "<path fill=\"" (index svg-colors obj-number) "\">"
                    "<animateTransform attributeName=\"transform\" type=\"translate\" values=\""
                    (animate-formatted-list (downsamp-sm (get-pos-history simulation obj-number)))
                    "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                    "<animate attributeName=\"d\" values=\""
                    (let ((all-objs (sim-get-all-newest-objects simulation)))
                        (animate-formatted-list-str (map sim-vis-ball-svg (downsamp-sm (map index (map sim-vis-ball-dimensions simulation) (repeat (length simulation) obj-number))))))
                    "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                    "</path>"

                    "<path fill=\"none\" stroke=\"black\" vector-effect=\"non-scaling-stroke\" stroke-width=\"2\" d=\"M0 -0.25L0 0.25M-0.25 0L0.25 0\">"
                    "<animateTransform attributeName=\"transform\" type=\"translate\" values=\""
                    (animate-formatted-list (downsamp-sm (get-pos-history simulation obj-number)))
                    "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                    "</path>"))))
            (string-append
                "<svg style=\"border: 1px solid black\" viewBox=\"-6 -3 12 6\">"

                ; ; TODO: downsamp-sm closer to the "simulation" value, so that sim-vis-ball-dimension-2 doesn't have a ton of throwaway work
                ; "<path fill=\"red\">"
                ; "<animateTransform attributeName=\"transform\" type=\"translate\" values=\""
                ; (animate-formatted-list (downsamp-sm (get-pos-history simulation 0)))
                ; "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                ; "<animate attributeName=\"d\" values=\""
                ; ; (sim-vis-ball-svg 1 1 0.5) ";" (sim-vis-ball-svg 1 1.5 1)
                ; (animate-formatted-list-str (map sim-vis-ball-svg (downsamp-sm (map index (map sim-vis-ball-dimensions-2 simulation simulation) (repeat (length simulation) 0)))))
                ; "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                ; "</path>"

                ; "<path fill=\"green\">"
                ; "<animateTransform attributeName=\"transform\" type=\"translate\" values=\""
                ; (animate-formatted-list (downsamp-sm (get-pos-history simulation 1)))
                ; "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                ; "<animate attributeName=\"d\" values=\""
                ; ; (sim-vis-ball-svg 1 1 0.5) ";" (sim-vis-ball-svg 1 1.5 1)
                ; (animate-formatted-list-str (map sim-vis-ball-svg (downsamp-sm (map index (map sim-vis-ball-dimensions-2 simulation simulation) (repeat (length simulation) 1)))))
                ; "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                ; "</path>"

                (single-ball 0)
                (single-ball 1)
                ; (begin
                ;     (display (sim-get-num-objects simulation)) (display "\n")
                ;     (display (sim-get-newest-frame simulation)) (display "\n")
                ;     (display (sim-frame-all-objs (sim-get-newest-frame simulation))) (display "\n")
                ;     (display (length (sim-frame-all-objs (sim-get-newest-frame simulation)))) (display "\n")
                ;     "")
                (if (eq? (sim-get-num-objects simulation) 3)
                    (single-ball 2)
                    "")

                "</svg>"))))


(define rect-get-min-x
    (lambda (r)
        (car r)))
(define rect-get-min-y
    (lambda (r)
        (cadr r)))
(define rect-get-max-x
    (lambda (r)
        (caddr r)))
(define rect-get-max-y
    (lambda (r)
        (cadddr r)))
(define rect-get-width
    (lambda (r)
        (- (caddr r) (car r))))
(define rect-get-height
    (lambda (r)
        (- (cadddr r) (cadr r))))
(define rect-init
    (lambda (min-x min-y max-x max-y)
        (list min-x min-y max-x max-y)))

(define get-bounding-rect
    (lambda (path)
        (let ((xs (car path)) (ys (cadr path)))
            (list
                (apply min xs)
                (apply min ys)
                (apply max xs)
                (apply max ys)))))
(define max-bounding-rect
    (lambda (rect1 rect2)
        (list
            (min (car rect1) (car rect2))
            (min (cadr rect1) (cadr rect2))
            (max (caddr rect1) (caddr rect2))
            (max (cadddr rect1) (cadddr rect2)))))
(define inflate-rect
    (lambda (rect)
        (let ((w (rect-get-width rect)) (h (rect-get-height rect)))
            (rect-init
                (- (rect-get-min-x rect) (* w 0.125))
                (- (rect-get-min-y rect) (* h 0.125))
                (+ (rect-get-max-x rect) (* w 0.125))
                (+ (rect-get-max-y rect) (* h 0.125))
                ))))


(define svg-path-linelist-formatted-list
    (lambda (xs ys)
        (if (nil? xs)
            ""
            (string-append
                "L " (num3 (car xs)) " " (num3 (car ys)) " "
                (svg-path-linelist-formatted-list (cdr xs) (cdr ys))))))
(define sim-graph-single-integral
    (lambda (xys color fill-color)
        (let ((xs (car xys)) (ys (cadr xys)))
            (string-append
                "<path fill=\"" fill-color "\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" stroke-width=\"3\" d=\""
                "M " (num3 (car xs)) " " (num3 (car ys)) " "
                ; (begin (display ys) (display "\n") "")
                (svg-path-linelist-formatted-list (cdr xs) (cdr ys))
                "\" />"))))
(define sim-graph-single
    (lambda (xys color fill-color)
        (let ((xs (car xys)) (ys (cadr xys)))
            (string-append
                "<path fill=\"none\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" stroke-width=\"3\" d=\""
                "M " (num3 (car xs)) " " (num3 (car ys)) " "
                ; (begin (display ys) (display "\n") "")
                (svg-path-linelist-formatted-list (cdr xs) (cdr ys))
                "\" />"))))
(define sim-graph-point
    (lambda (xys color xsize ysize)
        (let ((xs (car xys)) (ys (cadr xys)))
            ; (string-append
            ;     "<path fill=\"none\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" stroke-width=\"3\" d=\""
            ;     "M " (number->string (car xs)) " " (number->string (car ys)) " "
            ;     (svg-path-linelist-formatted-list (cdr xs) (cdr ys))
            ;     "\" />")
            (string-append
                "<ellipse fill=\"" color "\" rx=\"" (number->string xsize) "\" ry=\"" (number->string ysize) "\">"
                "<animate attributeName=\"cx\" values=\"" 
                (animate-formatted-list-str (map num3 xs))
                "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                "<animate attributeName=\"cy\" values=\"" 
                (animate-formatted-list-str (map num3 ys))
                "\" dur=\"8s\" repeatCount=\"indefinite\" />"
                "</ellipse>"
                )
            )))
(define render-axes
    (lambda (bounding-rect)
        (string-append
            "<line stroke=\"black\" vector-effect=\"non-scaling-stroke\" "
            "x1=\"" (number->string (rect-get-min-x bounding-rect)) "\" y1=\"0\" x2=\"" (number->string (rect-get-max-x bounding-rect)) "\" y2=\"0\""
            " /><line stroke=\"black\" vector-effect=\"non-scaling-stroke\" "
            "x1=\"0\" y1=\"" (number->string (rect-get-min-y bounding-rect)) "\" x2=\"0\" y2=\"" (number->string (rect-get-max-y bounding-rect)) "\""
            " />"
            )))
(define sim-graphs
    (lambda (paths x-name y-name graph-single-func)
        (let* (
            (bounding-rect (inflate-rect (foldr max-bounding-rect (map get-bounding-rect paths))))
            (width (rect-get-width bounding-rect))
            (height (rect-get-height bounding-rect))
            (num-objects (length paths))
            (colors (list-truncate svg-colors num-objects))
            (fill-colors (list-truncate svg-integral-colors num-objects)))
            (string-append
                ; TODO: why is the viewbox 4x2 ? Why not 2x1 ?
                "<svg style=\"border: 1px solid black\" viewBox=\"0 0 4 2\">"
                "<g transform=\"matrix("
                (number->string (/ 4 width)) ","
                "0,0,"
                (number->string (/ -2 height)) ","
                (number->string (* 4 (/ (- (rect-get-min-x bounding-rect)) width))) ","
                (number->string (* 2 (/ (rect-get-max-y bounding-rect) height))) ")\">"

                (render-axes bounding-rect)
                (foldr string-append (map graph-single-func paths colors fill-colors))
                ; (begin (display (length paths)) (display "\n") (display colors) (display "\n") (display paths) (display "\n") "")
                (foldr string-append (map sim-graph-point paths colors (repeat num-objects (* 0.01 width)) (repeat num-objects (* 0.02 height))))
                "</g>"

                ; TODO: the sizing thing here is pretty shit. I have no idea what "1%" here is in reference to. But it seems to work...
                "<text x=\"2\" y=\"1.95\" font-size=\"1%\" text-anchor=\"middle\">" x-name "</text>"
                "<text x=\"-1\" y=\"0\" text-anchor=\"middle\" dominant-baseline=\"hanging\" font-size=\"1%\" transform=\"rotate(-90)\">" y-name "</text>"
                "</svg>\n"))))
(define sim-graph-fun-select-name
    (lambda (name)
        (cond
            ((eq? name get-time-history) "time")
            ((eq? name get-pos-history) "position")
            ((eq? name get-vel-history) "velocity")
            ((eq? name get-force-history) "force")
            ((eq? name get-p-history) "momentum")
            ((eq? name get-ke-history) "kinetic energy")
            )))
(define sim-graphs-2
    (lambda (sim x-fun y-fun)
        (let (
            (num-objects (sim-get-num-objects sim))
            (single-path (lambda (n)
                (list 
                    (downsamp-sm (x-fun sim n))
                    (downsamp-sm (y-fun sim n))))))
            (sim-graphs (map single-path (reverse (count-reverse num-objects))) (sim-graph-fun-select-name x-fun) (sim-graph-fun-select-name y-fun) sim-graph-single)
            )))


(define sim-graphs-2-integral
    (lambda (sim x-fun y-fun)
        (let (
            (num-objects (sim-get-num-objects sim))
            (single-path (lambda (n)
                (list 
                    (downsamp-sm (x-fun sim n))
                    (downsamp-sm (y-fun sim n))))))
            (sim-graphs (map single-path (reverse (count-reverse num-objects))) (sim-graph-fun-select-name x-fun) (sim-graph-fun-select-name y-fun) sim-graph-single-integral)
            )))
#|(define sim-graph-axes
    (lambda (sim x-fun y-fun)
        (let* (
            (bounding-rect (inflate-rect (foldr max-bounding-rect (map get-bounding-rect paths)))))
            (string-append
                "<line stroke=\"black\" vector-effect=\"non-scaling-stroke\" "
                "x1=\"" (number->string (rect-get-min-x bounding-rect)) "\" y1=\"0\" x2=\"" (number->string (rect-get-max-x bounding-rect)) "\" y2=\"0\""
                " /><line stroke=\"black\" vector-effect=\"non-scaling-stroke\" "
                "x1=\"0\" y1=\"" (number->string (rect-get-min-y bounding-rect)) "\" x2=\"0\" y2=\"" (number->string (rect-get-max-y bounding-rect)) "\""
                " />"
                )
            )))
(define sim-graph-proto
    (lambda (sim x-fun y-fun . drawing-funcs)
        (string-append
            "<svg style=\"border: 1px solid black\" viewBox=\"0 0 2 1\">"
            (foldr string-append (mapall drawing-funcs sim x-fun y-fun))
            "</svg>")))
(define sim-graphs-2-integral
    (lambda (sim x-fun y-fun)
        (sim-graph-proto
            sim x-fun y-fun
            sim-graph-axes
            sim-graph-labels
            sim-graph-area
            sim-graph-path
            sim-graph-integral-numbers)))|#


(define pair-up
    (lambda (l)
        (if (nil? (cdr l))
            (list (list (car l) (car l)))
            (cons
                (list (car l) (cadr l))
                (pair-up (cdr l))))))
; (define sim-graph-integral-rectangle-single-left
;     (lambda (x-pair y-pair color)
;         (string-append
;             "<rect x=\"" (num3 (car x-pair)) "\" y=\"0\" width=\"" (num3 (- (cadr x-pair) (car x-pair))) "\" height=\"" (num3 (car y-pair)) "\" fill=\"none\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" />")))
; (define sim-graph-integral-rectangle-single-right
;     (lambda (x-pair y-pair color)
;         (string-append
;             "<rect x=\"" (num3 (car x-pair)) "\" y=\"0\" width=\"" (num3 (- (cadr x-pair) (car x-pair))) "\" height=\"" (num3 (cadr y-pair)) "\" fill=\"none\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" />")))

(define sim-graph-integral-rectangles-left
    (lambda (xs ys color fill-color)
        (if (nil? (cdr xs))
            ""
            (string-append
                (string-append "<rect x=\"" (num3 (car xs)) "\" y=\"0\" width=\"" (num3 (- (cadr xs) (car xs))) "\" height=\"" (num3 (car ys)) "\" fill=\"" fill-color "\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" />")
                (sim-graph-integral-rectangles-left (cdr xs) (cdr ys) color fill-color)))))
(define sim-graph-integral-rectangles-right
    (lambda (xs ys color fill-color)
        (if (nil? (cdr xs))
            ""
            (string-append
                (string-append "<rect x=\"" (num3 (car xs)) "\" y=\"0\" width=\"" (num3 (- (cadr xs) (car xs))) "\" height=\"" (num3 (cadr ys)) "\" fill=\"" fill-color "\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" />")
                (sim-graph-integral-rectangles-right (cdr xs) (cdr ys) color fill-color)))))
(define sim-graph-integral-rectangles-double-right
    (lambda (xs ys color fill-color)
        (if (nil? (cddr xs))
            ""
            (string-append
                (string-append "<rect x=\"" (num3 (car xs)) "\" y=\"0\" width=\"" (num3 (- (cadr xs) (car xs))) "\" height=\"" (num3 (caddr ys)) "\" fill=\"" fill-color "\" stroke=\"" color "\" vector-effect=\"non-scaling-stroke\" />")
                (sim-graph-integral-rectangles-double-right (cdr xs) (cdr ys) color fill-color)))))
(define sim-graph-integral-rectangles
    (lambda (xys color fill-color func)
        (let ((xs (car xys)) (ys (cadr xys)))
            (string-append
                ; "<rect x=\"\" y\"\" width=\"\" height\"\" />"
                ; (begin (display (length (pair-up xs))) (display "\n") (display (pair-up (list 0 1 2 3 4))) (display "\n") (display (length xs)) (display "\n") (display (length ys)) (display "\n") "")
                ; (foldr string-append (map func (pair-up xs) (pair-up ys) (repeat (length xs) color)))
                (func xs ys color fill-color)
                ))))
(define sim-graphs-leftright
    (lambda (paths func)
        (let* (
            (bounding-rect (inflate-rect (foldr max-bounding-rect (map get-bounding-rect paths))))
            (width (rect-get-width bounding-rect))
            (height (rect-get-height bounding-rect))
            (num-objects (length paths))
            (colors (list-truncate svg-colors num-objects))
            (fill-colors (list-truncate svg-integral-colors num-objects)))
            (string-append
                "<svg style=\"border: 1px solid black\" viewBox=\"0 0 4 2\">"
                "<g transform=\"matrix("
                (number->string (/ 4 width)) ","
                "0,0,"
                (number->string (/ -2 height)) ","
                (number->string (* 4 (/ (- (rect-get-min-x bounding-rect)) width))) ","
                (number->string (* 2 (/ (rect-get-max-y bounding-rect) height))) ")\">"

                (render-axes bounding-rect)
                (foldr string-append (map sim-graph-integral-rectangles paths colors fill-colors (repeat (length colors) func)))
                (foldr string-append (map sim-graph-single paths colors fill-colors))
                ; (begin (display (length paths)) (display "\n") (display colors) (display "\n") (display paths) (display "\n") "")
                "</g></svg>\n"))))
(define get-time-2-history-temp-4 ; TODO: remove this
    (lambda (sim-history obj-number)
        (let ((times-dt (lambda (x) (inexact (* x (/ 1 4))))))
            (map times-dt (count-reverse (length sim-history))))))
(define get-time-2-history-temp-16 ; TODO: remove this
    (lambda (sim-history obj-number)
        (let ((times-dt (lambda (x) (inexact (* x (/ 1 16))))))
            (map times-dt (count-reverse (length sim-history))))))
(define sim-graphs-integral-dt-leftright
    (lambda (sim x-fun y-fun func)
        (let (
            (num-objects (sim-get-num-objects sim))
            (single-path (lambda (n)
                (list
                    (reverse (x-fun sim n))
                    (reverse (y-fun sim n))))))
            ; (begin (display num-objects) (display "\n") (display (length sim)) (display "\n") #|(display (car sim)) (display "\n")|# (display (count-reverse num-objects)) (display "\n") "")
            (sim-graphs-leftright (list (cadr (map single-path (reverse (count-reverse num-objects))))) func)
            )))
(define sim-graphs-integral-dt-left
    (lambda (sim-history x-fun y-fun)
        (sim-graphs-integral-dt-leftright sim-history x-fun y-fun sim-graph-integral-rectangles-left)))
(define sim-graphs-integral-dt-right
    (lambda (sim-history x-fun y-fun)
        (sim-graphs-integral-dt-leftright sim-history x-fun y-fun sim-graph-integral-rectangles-right)))
(define sim-graphs-integral-dt-double-right
    (lambda (sim-history x-fun y-fun)
        (sim-graphs-integral-dt-leftright sim-history x-fun y-fun sim-graph-integral-rectangles-double-right)))

(define para
    (lambda (. strs)
        (string-append "<p>" (apply string-append strs) "</p>\n")))

(define code-1
    (lambda (lines)
        (if (nil? (cdr lines))
            (car lines)
            (string-append
                (car lines)
                "\n"
                (code-1 (cdr lines))))))
(define code
    (lambda (. lines)
        (string-append
            "<pre>"
            (code-1 lines)
            "</pre>\n")))
(define table-row
    (lambda (. cells)
        (let (
            (cell-wrapper (lambda (x)
                (string-append "<td style=\"border: 1px solid black; border-collapse: collapse; padding: 0.5em;\">" x "</td>"))))
            (string-append
                "<tr>"
                (foldr string-append (map cell-wrapper cells))
                "</tr>"))))
(define table
    (lambda (. rows)
        (string-append
            "<table style=\"border: 1px solid black; border-collapse: collapse;\">"
            (foldr string-append rows)
            "</table>")))

(define lesson-section
    (lambda (head . tail)
        (if (nil? head)
            ""
            (string-append
                head
                (if (nil? tail)
                    ""
                    (apply lesson-section tail))))))

(define all_lessons '(
    ("Simulation loop" "chapter_00_sim_loop")
    ("Collisions" "chapter_01_collision")
    ("Simulation graphs" "chapter_02_sim_graphs")
    ("Calculus primer" "chapter_03_calculus")
    ("Momentum" "chapter_04_momentum")
    ("Kinetic Energy" "chapter_05_kinetic_energy")
    ))
(define lesson-title
    (lambda (number)
        (car (index all_lessons number))))
(define lesson-html
    (lambda (number)
        (cadr (index all_lessons number))))

(define physics-with-danno-html-header
    (lambda (lesson-number)
        (string-append
            "<!doctype html>"
            "<html>"
            "<head><meta charset=\"UTF-8\" />"
            (if (>= lesson-number 0)
                (string-append "<title>Physics with Danno: " (lesson-title lesson-number) "</title>")
                (string-append "<title>Chapters</title>")
                )
            "<script src=\"https://polyfill.io/v3/polyfill.min.js?features=es6\"></script>"
            "<script id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\"></script>"
            "</head>"
            "<body style=\"margin-left:auto; margin-right:auto; width: 80ch; font-size: 1.125rem\">"
            "<h1><a href=\"/physics/\">Physics with Danno</a></h1>")))
(define physics-with-danno-html-footer
    (string-append
        "<p>&copy; by Daniel Taylor</p>"
        "</body></html>"))

(define chapter-bar
    (lambda (lesson-number)
        (string-append
            "<div style=\"display: inline-block; width:50%; text-align: center\">"
            (if (eq? lesson-number 0)
                ""
                (string-append "<a href=\"/physics/" (lesson-html (- lesson-number 1)) "/\">Previous Chapter: " (lesson-title (- lesson-number 1)) "</a>"))
            "</div>"

            "<div style=\"display: inline-block; width:50%; text-align: center\">"
            (if (>= lesson-number (- (length all_lessons) 1))
                ""
                (string-append "<a href=\"/physics/" (lesson-html (+ lesson-number 1)) "/\">Next Chapter: " (lesson-title (+ lesson-number 1)) "</a>"))
            "</div>"
            )))
(define lesson
    (lambda (lesson-number . args)
        (string-append
            (physics-with-danno-html-header lesson-number)
            
            (chapter-bar lesson-number)

            "<h2>Lesson " (number->string lesson-number) ": " (lesson-title lesson-number) "</h2>\n"
            
            (apply lesson-section args)
            
            (chapter-bar lesson-number)

            physics-with-danno-html-footer)))

(define option
    (lambda (. args)
        (apply string-append args)))
(define sxs
    (lambda (el1 el2)
        (string-append 
            "<div style=\"display: inline-block; width:50%; margin:0\">" el1 "</div>"
            "<div style=\"display: inline-block; width:50%; margin:0\">" el2 "</div>")))

(define heading
    (lambda (str)
        (string-append "<h2>" str "</h2>")))

(define ulisti
    (lambda (item)
        (string-append "<li>" item "</li>")))
(define ulist
    (lambda (. strs)
        (string-append 
            "<ul>"
            (apply string-append (map ulisti strs))
            "</ul>")))

; (define math
;     (lambda (. strs)
;         (string-append "<math><mrow>" (apply string-append strs) "</mrow></math>")))
; (define mfrac
;     (lambda (num denom)
;         (string-append "<mfrac>" num denom "</mfrac>")))
; (define mpow
;     (lambda (base ex)
;         (string-append "<msup>" base ex "</msup>")))
; (define mnum
;     (lambda (num)
;         (string-append "<mn>" (number->string num) "</mn>")))

(define math2
    (lambda (expr)
        (cond
            ((number? expr)
                (string-append "<mn>" (number->string expr) "</mn>"))
            ((symbol? expr)
                (string-append "<mi>" (symbol->string expr) "</mi>"))
            ((string? expr)
                (string-append "<mi>" expr "</mi>"))
            ((eq? (car expr) '*)
                (let (
                    (aware-math (lambda (x)
                        (if (and (list? x) (or (eq? (car x) '-) (eq? (car x) '+)))
                            (math2 (list 'mparen x))
                            (math2 x)))))
                    (apply string-append (interleave (map aware-math (cdr expr)) "<mo>⋅</mo>"))))
            ((eq? (car expr) '/)
                (string-append "<mfrac>" (math2 (cadr expr)) (math2 (caddr expr)) "</mfrac>"))
            ((eq? (car expr) '^)
                (string-append "<msup>" (math2 (cadr expr)) (math2 (caddr expr)) "</msup>"))
            ((eq? (car expr) '_)
                (string-append "<msub>" (math2 (cadr expr)) (math2 (caddr expr)) "</msub>"))
            ((eq? (car expr) 'mt)
                (string-append "<msub><mrow>" (math2 (cadr expr)) "</mrow><mrow>" (math2 (caddr expr)) "</mrow></msub>"))
            ((and (eq? (car expr) '-) (eq? (length expr) 2))
                (string-append "<mo>-</mo>" (math2 (cadr expr))))
            ((eq? (car expr) '-)
                (apply string-append (interleave (map math2 (cdr expr)) "<mo>-</mo>")))
            ((eq? (car expr) '+)
                (apply string-append (interleave (map math2 (cdr expr)) "<mo>+</mo>")))
            ((eq? (car expr) '=)
                ; (string-append (math2 (cadr expr)) "<mo>=</mo>" (math2 (caddr expr))))
                (apply string-append (interleave (map math2 (cdr expr)) "<mo>=</mo>")))
            ((eq? (car expr) 'lim)
                ; (string-append (math2 (cadr expr)) "<mo>=</mo>" (math2 (caddr expr))))
                (apply string-append (interleave (map math2 (cdr expr)) "<munder><mo>→</mo><mrow><mi>dt</mi> <mo>→</mo> <mn>0</mn></mrow></munder>")))
            ((eq? (car expr) 'mparen)
                (string-append "<mrow><mo>(</mo>" (math2 (cadr expr)) "<mo>)</mo></mrow>"))
            ((eq? (car expr) 'abs)
                (string-append "<mrow><mi>abs</mi><mo>(</mo>" (math2 (cadr expr)) "<mo>)</mo></mrow>"))
            ((eq? (car expr) 'sum)
                (string-append "<munderover><mi>∑</mi><mrow>" (math2 (cadr expr)) "<mo>=</mo>" (math2 (caddr expr)) "</mrow><mrow>" (math2 (cadddr expr)) "</mrow></munderover>" (math2 (caddddr expr))))
            ((eq? (car expr) 'ball1)
                (string-append "<mrow style=\"color:" (car svg-colors) ";\">" (math2 (cadr expr)) "</mrow>"))
            ((eq? (car expr) 'ball2)
                (string-append "<mrow style=\"color:" (cadr svg-colors) ";\">" (math2 (cadr expr)) "</mrow>"))
            ((eq? (car expr) 'ball3)
                (string-append "<mrow style=\"color:" (caddr svg-colors) ";\">" (math2 (cadr expr)) "</mrow>"))
            ((eq? (car expr) 'fun)
                (string-append "<mrow><mi>" (math2 (cadr expr)) "</mi><mo>(</mo>" (math2 (caddr expr)) "<mo>)</mo></mrow>"))

            )))
(define math
    (lambda (expr)
        (string-append "<math><mrow>" (math2 expr) "</mrow></math>")))

(define bmath2
    (lambda (expr)
        (string-append "<mtr><mtd>" (math2 expr) "</mtd></mtr>")))
(define bmath
    (lambda (. exprs)
        (string-append "<math display=\"block\"><mtable>" (apply string-append (map bmath2 exprs)) "</mtable></math>")))
(define bmath-eqs
    (lambda (. exprs)
        (apply bmath exprs)))

(define sim-loop-code-sm
    (code
        "loop for every instant of time {"
        "    loop for every object {"
        "        1. force = ..."
        "        2. dvel = force / mass * dt"
        "        3. velocity += dvel"
        "        4. dpos = velocity * dt"
        "        5. position += dpos"
        "    }"
        "    time += dt"
        "}"))

(define sim-loop-code-lg
    (code
        "loop for every instant of time {"
        "    loop for every object pair (object 1, object 2) {"
        "        force for object 1 += force_function(object 1, object 2)"
        "        force for object 2 += force_function(object 2, object 1)"
        "    }"
        ""
        "    loop for every object {"
        "        1. force = total force for this object"
        "        2. dvel = force / mass * dt"
        "        3. velocity += dvel"
        "        4. dpos = velocity * dt"
        "        5. position += dpos"
        "    }"
        "    time += dt"
        "}"))
