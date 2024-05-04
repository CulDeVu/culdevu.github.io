; TODO: could probably get rid of node-type-builtin-function to get just 2 bits for the type
; Alternatively, getting rid of nil. This would make cons-step-2 slightly simpler, and would make addition 1 instruction faster
; Now that I'm thinking about it more, I think we should keep nil in. Conceptually, at least, it's useful for (nil? x), and it's nice to have an actual nil at the end of every list like how it's supposed to be.
; I haven't tested this or anything, but I suspect that it would be way more efficient to put envt in here.
; still need to fit symbols in this list
(define node-type-nil 0)
(define node-type-int 1)
(define node-type-call 2)
(define node-type-builtin-function 3)
(define node-type-list 4)
(define node-type-reloc 5)
(define node-type-closure 6) ; structured as (code . env)
(define node-type-empty 7)

(define builtin-plus 1)
(define builtin-if 2)
(define builtin-set 3) ; TODO: do I want set? Not having it would certainly make the garbage collection mark phase easier. Is that worth it?
(define builtin-car 4)
(define builtin-cdr 5)
(define builtin-cons 6)
(define builtin-bnand 7)
(define builtin-type 8)
(define builtin-geq 9) ; maybe getting rid of?
(define builtin-lambda 10)
(define builtin-envt 11)
(define builtin-zero? 12)


; octal bus transceiver: 74hc245
; quad d-flip-flop tristate: 74hc173

(define node-mark
    (lambda (node) (car node)))

(define node-value (
    lambda (node) (caddr node)
))

(define node-type (
    lambda (node) (cadr node)
))

(define node-cdr-ptr (
    lambda (node) (cadddr node)
))

(define index (
    lambda (l ind) (begin
        ; bounds check?
        (if (nil? l)
            (error "index OOB")
            (if (eq? ind 0)
                (car l)
                (index (cdr l) (- ind 1)))
            )
        )
    )
)

(define length2 
    (lambda (l accum) 
        (if (nil? l)
            accum
            (length2 (cdr l) (+ accum 1)))))
(define length 
    (lambda (l) (length2 l 0)))

(define string-starts
    (lambda (outer inner)
        (equal?
            inner
            (substring outer 0 (string-length inner))
            )))

(define neq?
    (lambda (x y)
        (not (eq? x y))))


(define doing-idk 0)
(define doing-builtin-plus 1)
(define doing-call 2)
(define doing-if 3)
(define doing-if-skip 4)
(define doing-if-this-one 5)
(define doing-car 6)
(define doing-cdr 7)
(define doing-geq-step-1 8) ; eating first argument, waiting
(define doing-geq-step-2 9) ; eating second argument, doing the geq, returning
(define doing-set-step-1 10)
(define doing-set-step-2 11)
(define doing-cons-step-1 12)
(define doing-cons-step-2 13)
(define doing-lambda 14)
(define doing-function-arg 15)
(define doing-function-call-with-args 16)
(define doing-zero? 17)
(define doing-GC-stage-1 18)
(define doing-GC-stage-2 19)
(define doing-GC-stage-3 20)
(define doing-GC-stage-4 21)



; microcode attempt 2
; (define-syntax defmicro
;     (syntax-rules ()
;         ((defmicro a b c d)
;             (list 0 a b c d 0))))
(define defmicro
    (lambda (a b c d)
        (list 0 a b c 0 d)))

(define defmicro-gc
    (lambda (node-mark node-type node-val state head-at-top instrs)
        (list node-mark node-type node-val state head-at-top instrs)))

(define microcode-3
    (lambda (instr-mark instr-type instr-val instr-cdr-nonzero state-val mem-overflow)
        (cond

            ; GC start
            ; Placed up here to preempt all the stuff below, because I don't feel like adding "(neq? mem-overflow 1)" to everything
            ((and
                (eq? mem-overflow 1)
                (neq? state-val doing-GC-stage-3)
                (neq? state-val doing-GC-stage-4)) `(

                ; mark state
                ; (from-state-cdr-on-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 1) (from-micro-constant-on-type ,node-type-int) from-state-val from-state-cdr to-write)
                (from-head-on-cdr to-state-cdr)
                (incr-head)

                ; mark stack
                ; (from-stack-cdr-on-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 1) (from-micro-constant-on-type ,node-type-list) from-stack-val from-stack-cdr to-write)
                (from-head-on-cdr to-stack-cdr)
                (incr-head)

                ; mark accumulator
                ; (from-accumulator-cdr-on-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 1) from-accumulator-type from-accumulator-val from-accumulator-cdr to-write)
                (from-head-on-cdr to-accumulator-cdr)
                (incr-head)

                ; mark envt cdr
                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 1) (from-micro-constant-on-type ,node-type-list) from-envt-val from-envt-cdr to-write)
                (from-head-on-cdr to-envt-cdr)
                (incr-head)

                ; backup instr
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 1) from-instr-type from-instr-val from-instr-cdr to-write)
                (from-head to-envt-val)
                (incr-head)

                ; mark envt val
                ; (from-envt-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)

                ; TODO: push instr node as well

                ; ((from-micro-constant-on-val -1) to-accumulator-val)
                ; (from-add to-head)
                ; (from-head to-mem-addr)
                ; (from-read to-instr-mark to-instr-type to-instr-val to-instr-cdr)
                ; ((from-micro-constant-on-mark 1) to-instr-mark)
                ; (from-instr-mark from-instr-type from-instr-val from-instr-cdr to-write)
                
                (from-head to-mem-addr)
                (from-read to-instr-mark to-instr-type to-temp-val to-temp-cdr)
                ; ((from-micro-constant-on-mark 1) to-instr-mark)
                ; (from-instr-mark from-instr-type from-temp-val from-temp-cdr to-write)

                (from-head to-instr-val)

                ((from-micro-constant-on-val ,doing-GC-stage-3) to-state-val)

                ; To set mem-overflow back to zero; we no longer need it.
                ((from-micro-constant-on-val 0) to-head)

                (micro-reset)
                ))

            ; a call node, encountered in the middle of normal execution
            ((and 
                (eq? instr-type node-type-call)
                (not (eq? state-val doing-lambda))
                (not (eq? state-val doing-if-skip))
                (not (>= state-val doing-GC-stage-1))) `(
                ; push stack
                (from-head to-mem-addr)
                ; storing as a node-type-list so that the GC will follow the stack val and not delete it.
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-list) from-stack-val from-stack-cdr to-write)
                (from-instr-cdr-on-val from-head-on-cdr to-stack-val to-stack-cdr)
                (incr-head)

                ; push accumulator
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) from-accumulator-type from-accumulator-val from-accumulator-cdr to-write)
                ((from-micro-constant-on-val 0) from-head-on-cdr to-accumulator-val to-accumulator-cdr)
                (incr-head)

                ; push state
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-int) from-state-val from-state-cdr to-write)
                ((from-micro-constant-on-val ,doing-call) from-head-on-cdr to-state-val to-state-cdr)
                (incr-head)

                ; advance instr
                (from-instr-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                (micro-reset)
                ))

            ; lambda shit!
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-lambda)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-lambda) to-state-val)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-call)
                (eq? state-val doing-lambda)) `(
                ; return node
                ; First the envt
                ; (from-head to-mem-addr)
                ; ((from-micro-constant-on-type node-type-list) from-envt- (from-micro-constant-on-cdr 0) to-write)
                ; (from-envt-type from-envt-val from-envt-cdr to-write)
                ; Delay incrementing head to store into cdr later
                ; Second, the function definition
                (from-envt-val-on-cdr to-instr-cdr) ; the function definition node is already in instr, ready to be written, just need to set the cdr
                (incr-head)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) from-instr-type from-instr-val from-instr-cdr to-write)
                ; Delay incrementing head to store into cdr later
                ; Third, the function node to hold them
                ((from-micro-constant-on-type ,node-type-closure) from-head from-stack-val-on-cdr to-instr-type to-instr-val to-instr-cdr) ; using instr as scratch space
                (incr-head)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) from-instr-type from-instr-val from-instr-cdr to-write)
                (incr-head)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                (micro-reset)
                ))

            ;;;;; PLUS SHIT
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-plus)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-builtin-plus) to-state-val)
                ((from-micro-constant-on-type ,node-type-int) to-accumulator-type)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-int)
                (eq? state-val doing-builtin-plus)) '(
                (from-add to-accumulator-val)

                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                (micro-reset)
                ))

            ; TODO: fix this plus situation. It should return on last param, not on jump-to-nil
            ((and
                (eq? instr-type node-type-nil)
                (eq? state-val doing-builtin-plus)) `(
                ; return node
                ((from-micro-constant-on-type ,node-type-int) from-accumulator-val from-stack-val-on-cdr to-instr-type to-instr-val to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                (micro-reset)
                ))

            ;;;;; IF
            ; starting a new function call, an if
            ; TODO: known bug if the "if" call only has 2 arguments (so only the condition and "then" branch, but no else), if can go into an infinite loop
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-if)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-if) to-state-val)

                (micro-reset)
                ))

            ; doing a builtin-function if, expecting a conditional
            ((and
                (eq? instr-type node-type-int)
                (eq? instr-val 0)
                (eq? state-val doing-if)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-if-skip) to-state-val)

                (micro-reset)
                ))

            ; variant 2
            ; TODO: instead, any value other than 0?
            ((and
                (eq? instr-type node-type-int)
                (eq? instr-val 1)
                (eq? state-val doing-if)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-if-this-one) to-state-val)

                (micro-reset)
                ))

            ; doing a builtin-function if, this is the one we've selected
            ((and
                (eq? state-val doing-if-this-one)) `(
                ; return node
                (from-stack-val-on-cdr to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                (micro-reset)
                ))

            ; doing a builtin-function if, this is the one we're skipping over
            ((and
                (eq? state-val doing-if-skip)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-if-this-one) to-state-val)

                (micro-reset)
                ))

            ; closure shit!!
            ((and
                (eq? instr-type node-type-closure)
                (eq? state-val doing-call)) `(
                ; todo: there's something to think about regarding the stack here. Without storing the ptr to this instruction, there's no real way to recover it later. So when a crash happens, the stack trace might skip over this:
                ; (+ 1 (user-func a b)) -> the stack will be (... . user-func . +-invocation), with no mention of the user-func-invocation. Is this okay? I don't know...

                ; Push the function node on the accumulator stack, and present a fresh stack head for the next part.
                ((from-micro-constant-on-type ,node-type-list) to-accumulator-type)
                (from-instr-val to-mem-addr)
                (from-read to-accumulator-val)
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-list) from-accumulator-val from-accumulator-cdr to-write)
                ((from-micro-constant-on-val 0) from-head-on-cdr to-accumulator-val to-accumulator-cdr)
                (incr-head)

                ; put the ptr to the envt at the top of the accumulator stack
                (from-instr-val to-mem-addr)
                (from-read to-accumulator-val-from-bus-cdr) ; okay, this one I'm a little unsure of. But this is what I want to have happen.
                ; (from-envt-val to-accumulator-val)

                ; push the current envt onto the stack, since the normal call handler doesn't do this yet
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) from-envt-type from-envt-val from-envt-cdr to-write)
                (from-head-on-cdr to-envt-cdr)
                (incr-head)

                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-function-arg) to-state-val)

                (micro-reset)
                ))

            ((and
                (neq? instr-type node-type-nil)
                (eq? state-val doing-function-arg)) `(
                ; push the next argument onto the env
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) from-instr-type from-instr-val from-accumulator-val-on-cdr to-write)
                (from-head to-accumulator-val)
                (incr-head)

                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-nil)
                (eq? state-val doing-function-arg)) `(
                ; time to clean up the accumulator stack and call

                ; read out the new envt
                ; (from-accumulator-val to-mem-addr)
                ; (from-read to-envt-type to-envt-val to-envt-cdr)
                ((from-micro-constant-on-type ,node-type-list) from-accumulator-val to-envt-type to-envt-val) ; TODO: is envt-type really necessary?

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; read out the node-type-call pointing to the code to run
                ; (from-accumulator-val to-mem-addr)
                ; (from-read to-instr-type to-instr-val to-instr-cdr)
                ((from-micro-constant-on-type ,node-type-call) from-accumulator-val (from-micro-constant-on-cdr 0) to-instr-type to-instr-val to-instr-cdr)

                ; ... i guess leave the rest of the state like it is?
                ((from-micro-constant-on-val ,doing-function-call-with-args) to-state-val)

                (micro-reset)
                ))

            ((and
                (eq? state-val doing-function-call-with-args)) `(
                ; just return what we've got.
                (from-stack-val-on-cdr to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; pop envt
                (from-envt-cdr-on-val to-mem-addr)
                (from-read to-envt-val to-envt-cdr)

                (micro-reset)
                ))

            ; car shit
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-car)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-car) to-state-val)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-list)
                (eq? state-val doing-car)) `(
                ; read it and return
                (from-instr-val to-mem-addr)
                (from-read to-instr-type to-instr-val)
                (from-stack-val-on-cdr to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; pop envt
                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-envt-val to-envt-cdr)

                (micro-reset)
                ))

            ; cdr shit
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-cdr)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-cdr) to-state-val)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-list)
                (eq? state-val doing-cdr)) `(
                ; read it and return
                (from-instr-val to-mem-addr)
                ; (from-read to-instr-type to-instr-val)
                (from-read to-accumulator-val-from-bus-cdr)
                ((from-micro-constant-on-type ,node-type-list) from-accumulator-val to-instr-type to-instr-val)
                (from-stack-val-on-cdr to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; pop envt
                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-envt-val to-envt-cdr)

                (micro-reset)
                ))

            ; builtin envt shit
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-envt)
                (< state-val doing-GC-stage-1)) '* `(
                ; advance instr
                (from-envt-type from-envt-val to-instr-type to-instr-val)

                (micro-reset)
                ))

            ; builtin eq shit
            ((and
                (eq? instr-type node-type-builtin-function)
                (eq? instr-val builtin-zero?)
                (eq? state-val doing-call)) `(
                ; advance instr
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ((from-micro-constant-on-val ,doing-zero?) to-state-val)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-int)
                (eq? instr-val 0)
                (eq? state-val doing-zero?)) `(
                ((from-micro-constant-on-type ,node-type-int) (from-micro-constant-on-val 1) from-stack-val-on-cdr to-instr-type to-instr-val to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; pop envt
                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-envt-val to-envt-cdr)

                (micro-reset)
                ))

            ((and
                (eq? instr-type node-type-int)
                (neq? instr-val 0)
                (eq? state-val doing-zero?)) `(
                ((from-micro-constant-on-type ,node-type-int) (from-micro-constant-on-val 0) from-stack-val-on-cdr to-instr-type to-instr-val to-instr-cdr)

                ; pop stack
                (from-stack-cdr-on-val to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; pop accumulator
                (from-accumulator-cdr-on-val to-mem-addr)
                (from-read to-accumulator-type to-accumulator-val to-accumulator-cdr)

                ; pop state
                (from-state-cdr-on-val to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; pop envt
                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-envt-val to-envt-cdr)

                (micro-reset)
                ))

            ; GC !! Mark and sweep downward phase
            #|((and
                (eq? mem-overflow 1)) `(
                (from-head to-instr-val)

                ; ((from-micro-constant-on-val -1) to-accumulator-val)
                ; (from-add to-head)
                ; (from-head to-mem-addr)
                ; (from-read to-instr-mark to-instr-type to-instr-val to-instr-cdr)
                ; ((from-micro-constant-on-mark 1) to-instr-mark)
                ; (from-instr-mark from-instr-type from-instr-val from-instr-cdr to-write)
                ((from-micro-constant-on-val 94) to-head)
                (from-head to-mem-addr)
                (from-read to-instr-mark to-instr-type to-instr-val to-instr-cdr)
                ((from-micro-constant-on-mark 1) to-instr-mark)
                (from-instr-mark from-instr-type from-instr-val from-instr-cdr to-write)

                (from-head to-instr-val)

                ((from-micro-constant-on-val ,doing-GC-stage-3) to-state-val)

                ((from-micro-constant-on-val 0) to-head)

                (micro-reset)
                ))|#

            ; GC !!
            ; Downwards mark and sweep phase
            ((and
                (eq? instr-mark 0)
                (eq? state-val doing-GC-stage-3)) `(
                (from-instr-val to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-empty) (from-micro-constant-on-val 0) (from-micro-constant-on-cdr 0) to-write)

                ((from-micro-constant-on-val -1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val to-mem-addr)
                (from-read to-instr-mark to-instr-type to-temp-val to-temp-cdr)

                (micro-reset)
                ))

            ((and
                (eq? instr-mark 1)
                (eq? state-val doing-GC-stage-3)
                (or
                    (eq? instr-type node-type-list)
                    (eq? instr-type node-type-closure)
                    (eq? instr-type node-type-call))) `(
                (from-instr-val to-mem-addr)
                ((from-micro-constant-on-mark 0) from-instr-type from-temp-val from-temp-cdr to-write)

                ; mark cdr
                (from-temp-cdr to-instr-cdr) ; Super dumb
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val to-temp-cdr)
                ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)
                (from-instr-val to-mem-addr) ; Restore temp
                (from-read to-temp-val to-temp-cdr)

                ; mark val
                (from-temp-val to-mem-addr)
                (from-read to-temp-type to-temp-val to-temp-cdr)
                ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)

                ((from-micro-constant-on-val -1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val to-mem-addr)
                (from-read to-instr-mark to-instr-type to-temp-val to-temp-cdr)

                (micro-reset)
                ))

            ((and
                (eq? instr-mark 1)
                (neq? instr-val 0)
                (eq? state-val doing-GC-stage-3)
                (or
                    (eq? instr-type node-type-int)
                    (eq? instr-type node-type-nil)
                    (eq? instr-type node-type-builtin-function))) `(
                (from-instr-val to-mem-addr)
                ; (from-read to-temp-type to-temp-val to-temp-cdr)
                ((from-micro-constant-on-mark 0) from-instr-type from-temp-val from-temp-cdr to-write)

                ; mark cdr
                (from-temp-cdr to-instr-cdr) ; Super dumb
                (from-instr-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val to-temp-cdr)
                ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)

                ((from-micro-constant-on-val -1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val to-mem-addr)
                (from-read to-instr-mark to-instr-type to-temp-val to-temp-cdr)

                (micro-reset)
                ))

            ((and
                (eq? instr-mark 0)
                (eq? state-val doing-GC-stage-3)
                (eq? instr-type node-type-reloc)) `(

                (from-instr-val to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type node-type-empty) (from-micro-constant-on-val 0) (from-micro-constant-on-cdr 0) to-write)

                ((from-micro-constant-on-val -1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val to-mem-addr)
                (from-read to-instr-mark to-instr-type to-temp-val to-temp-cdr)

                (micro-reset)
                ))

            ; The final step in the downward phase
            ((and
                (eq? instr-type node-type-nil)
                (eq? instr-val 0)
                (eq? state-val doing-GC-stage-3)) `(
                ((from-micro-constant-on-val ,doing-GC-stage-4) to-state-val)
                ; head = upper sweeping ptr
                ; stack-val = lower sweeping ptr
                ; instr-cdr = difference between upper and lower ptrs
                ; instr-val = upper sweep ptr type
                ; instr-type = lower sweep ptr type
                ((from-micro-constant-on-val 2) to-head)
                ((from-micro-constant-on-val 1) to-stack-val)
                ((from-micro-constant-on-cdr 1) to-instr-cdr)

                ; temporarily use instr-type to move a type into instr-val
                (from-head to-mem-addr)
                (from-read to-instr-type)
                (from-instr-type-on-val to-instr-val)

                (from-stack-val to-mem-addr)
                (from-read to-instr-type)

                (micro-reset)
                ))

            ; Upward phase compact

            ; lower ptr isn't pointing to a valid location for compacting, keep going
            ((and
                (eq? mem-overflow 0)
                (neq? instr-type node-type-empty)
                (eq? instr-cdr-nonzero 1)
                (eq? state-val doing-GC-stage-4)) `(

                ; store away instr-val temporarily; we need the space
                (from-instr-val to-temp-val)

                ; --difference
                (from-instr-cdr-on-val to-instr-val)
                ((from-micro-constant-on-val -1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val-on-cdr to-instr-cdr)

                ; ++lower_ptr
                (from-stack-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-stack-val)

                ; refresh lower_type
                (from-stack-val to-mem-addr)
                (from-read to-instr-type)

                ; restore instr-val
                (from-temp-val to-instr-val)

                (micro-reset)
                ))

            ; upper_ptr just needs a bump, no reloc stuff needs to happen
            ((and
                (eq? mem-overflow 0)
                (eq? state-val doing-GC-stage-4)
                (or
                    (and (eq? instr-val node-type-empty) (eq? instr-type node-type-empty))
                    (and (eq? instr-val node-type-reloc) (eq? instr-type node-type-empty))
                    (and (eq? instr-cdr-nonzero 0) (eq? instr-val node-type-reloc))
                    (and (eq? instr-cdr-nonzero 0) (eq? instr-val node-type-empty)))) `(

                ; TODO: reloc rewriting shit

                ; store away instr-val temporarily; we need the space
                (from-instr-val to-temp-val)

                ; ++difference
                (from-instr-cdr-on-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val-on-cdr to-instr-cdr)

                ; ++upper_ptr
                (from-head to-instr-val)
                (from-add to-head)

                ; restore instr-val
                (from-temp-val to-instr-val)

                ; TODO: don't do the thing above

                ; refresh upper_type
                (from-head to-mem-addr)
                (from-read to-temp-type)
                (from-temp-type-on-val to-instr-val)

                (micro-reset)
                ))

            ; lower_ptr == upper_ptr and it's a non-list type
            ((and
                (eq? mem-overflow 0)
                (eq? instr-cdr-nonzero 0)
                (eq? state-val doing-GC-stage-4)
                (or
                    (eq? instr-val node-type-nil)
                    (eq? instr-val node-type-int)
                    (eq? instr-val node-type-builtin-function))) `(
                ; rewrite shit for cdr
                ; (write (read-cdr head_ptr) 
                ;        (gc-reloc (read-type (read-cdr head_ptr))
                ;                  (read-val (read-cdr head_ptr)
                ;                  (read-cdr head_ptr))))
                (from-head to-mem-addr)
                (from-read to-temp-cdr)
                (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-val)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write) ; Not actually useful; see next couple steps

                ; store away instr-val temporarily; we need the space
                (from-instr-val to-temp-val)

                ; ++difference
                (from-instr-cdr-on-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val-on-cdr to-instr-cdr)

                ; ++upper_ptr
                (from-head to-instr-val)
                (from-add to-head)

                ; restore instr-val
                (from-temp-val to-instr-val)

                ; TODO: don't do the thing above

                ; refresh upper_type
                (from-head to-mem-addr)
                (from-read to-temp-type)
                (from-temp-type-on-val to-instr-val)

                (micro-reset)
                ))

            ; lower_ptr == upper_ptr and it's a list type
            ((and
                (eq? mem-overflow 0)
                (eq? instr-cdr-nonzero 0)
                (eq? state-val doing-GC-stage-4)
                (or
                    (eq? instr-val node-type-call)
                    (eq? instr-val node-type-list)
                    (eq? instr-val node-type-closure))) `(
                ; rewrite shit for val
                (from-head to-mem-addr)
                (from-read to-mem-addr to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                ; (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-cdr)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write)

                ; rewrite shit for cdr
                ; (write (read-cdr head_ptr) 
                ;        (gc-reloc (read-type (read-cdr head_ptr))
                ;                  (read-val (read-cdr head_ptr)
                ;                  (read-cdr head_ptr))))
                (from-head to-mem-addr)
                (from-read to-temp-cdr)
                (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-val)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write) ; Not actually useful; see next couple steps

                ; store away instr-val temporarily; we need the space
                (from-instr-val to-temp-val)

                ; ++difference
                (from-instr-cdr-on-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val-on-cdr to-instr-cdr)

                ; ++upper_ptr
                (from-head to-instr-val)
                (from-add to-head)

                ; restore instr-val
                (from-temp-val to-instr-val)

                ; TODO: don't do the thing above

                ; refresh upper_type
                (from-head to-mem-addr)
                (from-read to-temp-type)
                (from-temp-type-on-val to-instr-val)

                (micro-reset)
                ))

            ; if (GC-stage-3 && upper-head != top && upper-node-type & ATOM && lower-node-type == nil)
            ;     // rewrite shit for cdr
            ;     write upper-node to lower-head
            ;     write (reloc lower-head 0) to upper-head

            ;     ++lower-head
            ;     read lower-head into lower-node
            ;     ++upper-head
            ;     read upper-head into upper-node
            ((and
                (eq? mem-overflow 0)
                (eq? instr-type node-type-empty)
                (eq? state-val doing-GC-stage-4)
                (or
                    (eq? instr-val node-type-nil)
                    (eq? instr-val node-type-int)
                    (eq? instr-val node-type-builtin-function))) `(
                ; rewrite shit for cdr
                ; (write (read-cdr head_ptr) 
                ;        (gc-reloc (read-type (read-cdr head_ptr))
                ;                  (read-val (read-cdr head_ptr)
                ;                  (read-cdr head_ptr))))
                (from-head to-mem-addr)
                (from-read to-temp-cdr)
                (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-val)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write) ; Not actually useful; see next couple steps

                ; write upper node to lower ptr
                (from-stack-val to-mem-addr)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write)

                ; write a reloc at upper ptr
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-reloc) from-stack-val (from-micro-constant-on-cdr 0) to-write)

                ; ++lower_ptr
                (from-instr-val to-temp-val)
                (from-stack-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-stack-val)
                (from-temp-val to-instr-val)

                ; ++upper_ptr
                (incr-head)

                ; refresh lower_type
                (from-stack-val to-mem-addr)
                (from-read to-instr-type)

                ; refresh upper_type
                (from-head to-mem-addr)
                (from-read to-temp-type)
                (from-temp-type-on-val to-instr-val)

                (micro-reset)
                ))

            ((and
                (eq? mem-overflow 0)
                (eq? instr-type node-type-empty)
                (eq? state-val doing-GC-stage-4)
                (or
                    (eq? instr-val node-type-call)
                    (eq? instr-val node-type-list)
                    (eq? instr-val node-type-closure))) `(
                ; rewrite shit for val
                (from-head to-mem-addr)
                (from-read to-mem-addr to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                ; (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-cdr)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write)

                ; rewrite shit for cdr
                (from-head to-mem-addr)
                (from-read to-temp-cdr)
                (from-temp-cdr-on-val to-mem-addr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-temp-val)
                (from-temp-val-on-cdr to-temp-cdr)
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-val)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write) ; Not actually useful; see next couple steps

                ; TODO: remove!
                (from-head to-mem-addr)
                (from-read to-temp-type to-temp-val to-temp-cdr)

                ; write upper node to lower ptr
                (from-stack-val to-mem-addr)
                ((from-micro-constant-on-mark 0) from-temp-type from-temp-val from-temp-cdr to-write)

                ; write a reloc at upper ptr
                (from-head to-mem-addr)
                ((from-micro-constant-on-mark 0) (from-micro-constant-on-type ,node-type-reloc) from-stack-val (from-micro-constant-on-cdr 0) to-write)

                ; ++lower_ptr
                (from-instr-val to-temp-val)
                (from-stack-val to-instr-val)
                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-stack-val)
                (from-temp-val to-instr-val)

                ; ++upper_ptr
                (incr-head)

                ; refresh lower_type
                (from-stack-val to-mem-addr)
                (from-read to-instr-type)

                ; refresh upper_type
                (from-head to-mem-addr)
                (from-read to-temp-type)
                (from-temp-type-on-val to-instr-val)

                (micro-reset)
            ))

            ((and
                (eq? mem-overflow 1)
                (eq? state-val doing-GC-stage-4)) `(

                ; copy over lower ptr to head
                (from-stack-val to-head)

                ; pop off state, with reloc correction
                (from-state-cdr from-state-cdr-on-val to-mem-addr to-temp-cdr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-mem-addr)
                (from-read to-state-val to-state-cdr)

                ; (from-state-cdr-on-val to-mem-addr)
                ; (from-read to-state-val to-state-cdr)

                ; pop off stack, with reloc correction
                (from-stack-cdr from-stack-cdr-on-val to-mem-addr to-temp-cdr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-mem-addr)
                (from-read to-stack-val to-stack-cdr)

                ; (from-stack-cdr-on-val to-mem-addr)
                ; (from-read to-stack-val to-stack-cdr)

                ; pop off accumulator, with reloc correction
                (from-accumulator-cdr from-accumulator-cdr-on-val to-mem-addr to-temp-cdr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-mem-addr)
                (from-read to-accumulator-val to-accumulator-cdr)

                ; (from-accumulator-cdr-on-val to-mem-addr)
                ; (from-read to-accumulator-val to-accumulator-cdr)

                ; pop off instr
                (from-envt-val from-envt-val-on-cdr to-mem-addr to-temp-cdr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-mem-addr)
                (from-read to-instr-type to-instr-val to-instr-cdr)

                ; pop off envt, with reloc correction
                (from-envt-cdr from-envt-cdr-on-val to-mem-addr to-temp-cdr)
                (from-read to-temp-type to-temp-val)
                (from-gc-reloc to-mem-addr)
                (from-read to-envt-val to-envt-cdr)

                ; (from-envt-cdr-on-val to-mem-addr)
                ; (from-read to-envt-val to-envt-cdr)

                ((from-micro-constant-on-mark 0) to-instr-mark)

                (micro-reset)
            ))

            #|((and
                (eq? mem-overflow 0)
                (eq? instr-type node-type-empty)
                (eq? state-val doing-GC-stage-4)
                (or
                    (eq? instr-val node-type-list)
                    (eq? instr-val node-type-call)
                    (eq? instr-val node-type-closure))) `(
                ; rewrite shit for val
                ; rewrite shit for cdr

                ; write upper node to lower ptr
                ; write a reloc at upper ptr

                ; ++lower_ptr
                ; refresh lower_type
                ; ++upper_ptr
                ; refresh upper_type

                (micro-reset)
                ))|#

            ; ((and
            ;     (< head 127)))

            (#t
                (error "Couldn't find matching microcode" instr-mark instr-type instr-val instr-cdr-nonzero state-val mem-overflow))

            ; Compact upwards phase
            ; head = upper sweeping ptr
            ; state-val = lower sweeping ptr
            ; instr-cdr = difference between upper and lower ptrs
            ; instr-val = upper sweep ptr type
            ; instr-type = lower sweep ptr type
            #|(defmicro-gc 0 node-type-builtin-function '* doing-GC-stage-4 0 `(
                (from-instr-val to-mem-addr)
                (from-read to-temp-type to-temp-val to-temp-cdr)
                ((from-micro-constant-on-mark 1) from-temp-type from-temp-val from-temp-cdr to-write)

                ((from-micro-constant-on-val 1) to-accumulator-val)
                (from-add to-instr-val)
                (from-instr-val to-mem-addr)
                (from-read to-instr-mark to-instr-type)

                (micro-reset)
                ))


            ; (defmicro-gc 0 '* '* doing-GC-stage-2 '* `(
            ;     (from-instr-val to-temp-val)
            ;     (from-head to-instr-val)
            ;     ((from-micro-constant-on-val -1) to-accumulator-val)
            ;     (from-add to-head)
            ;     (from-temp-val to-instr-val)

            ;     ((from-micro-constant-on-val ,doing-GC-stage-3) to-state-val)

            ;     (micro-reset)
            ;     ))

            |#

            )))


(define caddddr
    (lambda (l)
        (car (cdr (cdr (cdr (cdr l)))))))
(define cadddddr
    (lambda (l)
        (car (cdr (cdr (cdr (cdr (cdr l))))))))
(define search-matching-microcode
    (lambda (microcode instr-mark instr-type instr-val state do-gc)
        (if (nil? microcode)
            (error "Couldn't find matching microcode" instr-type instr-val state)
            (let ((head (car microcode)))
                ; (begin (printf head "\n") 
                (if (or (eq? (car head) instr-mark) (eq? (car head) '*))
                    (if (or (eq? (cadr head) instr-type) (eq? (cadr head) '*))
                        (if (or (eq? (caddr head) instr-val) (eq? (caddr head) '*))
                            (if (or (eq? (cadddr head) state) (eq? (cadddr head) '*))
                                (if (or (eq? (caddddr head) do-gc) (eq? (caddddr head) '*))
                                    (cadddddr head)
                                    (search-matching-microcode (cdr microcode) instr-mark instr-type instr-val state do-gc))
                                (search-matching-microcode (cdr microcode) instr-mark instr-type instr-val state do-gc))
                            (search-matching-microcode (cdr microcode) instr-mark instr-type instr-val state do-gc))
                        (search-matching-microcode (cdr microcode) instr-mark instr-type instr-val state do-gc))
                    (search-matching-microcode (cdr microcode) instr-mark instr-type instr-val state do-gc))))))


; (define cpu-state-init
;     (lambda (instr stack accumulator state microcode mem-addr micro-instr micro-state heap head busses)
;         (list 'cpu-state aa)))

; (define define-struct
;     (lambda (name . args)
;         (begin
;             (set! ))))

; (define-syntax defstruct
;     (syntax-rules ()
;         ((defstruct name . fields)
;             (begin
;                 (set! init (lambda ()))))))


(define printf
    (lambda (head . tail)
        (begin
            (display head)
            (if (nil? tail)
                '()
                (begin
                    (display " ")
                    (apply printf tail))))))

; (define printf
;     (lambda (head . tail)
;         (begin
;             (display (cons head tail))
;             (display "\n"))))

(define-macro (def-my-struct name . fields)
    `(define cpu-state-init (lambda (,@fields) (vector ,@fields))))
; (define def-my-struct
;     (lambda (name . fields)
;         `(define cpu-state-init (lambda (,@fields) (vector ,@fields)))))

(define-macro (def-struct-get name num)
    `(define ,(string->symbol (string-append "get-" (symbol->string name)))
        (lambda (state) (vector-ref state ,num))))
(define-macro (def-struct-get-4)
    `(lambda (name num)
        `(define ,(string->symbol (string-append "get-" (symbol->string name)))
            (lambda (state) (vector-ref state ,num)))))
(define def-struct-get-2 
    (lambda (name num)
        `(define ,(string->symbol (string-append "get-" (symbol->string name)))
            (lambda (state) (vector-ref state ,num)))))

(define-macro (def-struct-set name num)
    `(define ,(string->symbol (string-append "set-" (symbol->string name)))
        (lambda (state val)
            (if (eq? val '--)
                (error "Writing uninit bus line")
                (let ((cpy (vector-copy state)))
                    (begin
                        (vector-set! cpy ,num val)
                        cpy))))))

(define-macro (def-struct-set-no-checking name num)
    `(define ,(string->symbol (string-append "set-" (symbol->string name)))
        (lambda (state val)
            (let ((cpy (vector-copy state)))
                (begin
                    (vector-set! cpy ,num val)
                    cpy)))))
(define def-struct-set-2
    (lambda (name num)
        `(define ,(string->symbol (string-append "set-" (symbol->string name)))
            (lambda (state val)
                
                ; Choose between doing -- checking or not
                ,(if (string-starts (symbol->string name) "bus-")
                    `(let ((cpy (vector-copy state)))
                        (begin
                            (vector-set! cpy ,num val)
                            cpy))
                    `(if (eq? val '--)
                        (begin (printf ,(symbol->string name) (string-starts ,(symbol->string name) "bus-") state "\n" val "\n") (error "Writing uninit bus line"))
                        (let ((cpy (vector-copy state)))
                            (begin
                                (vector-set! cpy ,num val)
                                cpy))))))))

(define count
    (lambda (n)
        (if (zero? n)
            '()
            (append (count (- n 1)) (list (- n 1))))))
; (define-macro (def-my-struct-2 name . fields)
;     (append 
;         `(begin
;             (def-my-struct ,@fields))

;         (map
;             (lambda (name num)
;                 `(define ,(string->symbol (string-append "get-" (symbol->string name)))
;                     (lambda (state) (vector-ref state ,num)))) 
;             fields (count (length fields)))
;         (map def-struct-set-2 fields (count (length fields)))
;         ))
; (define-syntax def-struct-get-3
;     (syntax-rules ()
;         ((def-struct-get-3 field ...)
;             (begin
;                 (define (string->symbol (string-append "get-" (symbol->string name)))
;                     (lambda (state) (vector-ref state num)))
;                 (def-struct-get-3 ...)))))
; (define-syntax def-my-struct-2
;     (syntax-rules ()
;         ((def-my-struct-2 ...)
;             (begin
;                 (def-my-struct ...)
;                 (def-struct-get-3 ...)
;                 ))))

; ,(string->symbol (append "get-" name))

; (define-syntax def-struct-set
;     (syntax-rules ()
;         ((defmicro a b c d)
;             (list a b c d))))

(def-my-struct cpu-state
    instr-mark instr-type instr-val instr-cdr
    stack-val stack-cdr
    accumulator-type accumulator-val accumulator-cdr
    state-val state-cdr
    temp-type temp-val temp-cdr
    envt-type envt-val envt-cdr
    mem-addr
    micro-instr-mark micro-instr-type micro-instr-val
    micro-state-val
    micro-mem-overflow micro-instr-cdr-nonzero
    micro-index
    heap
    head
    bus-mark bus-type bus-val bus-cdr)

; (define get-instr-type
;     (lambda (state) (vector-ref state 0)))
(def-struct-get instr-mark 0)
(def-struct-get instr-type 1)
(def-struct-get instr-val 2)
(def-struct-get instr-cdr 3)
(def-struct-get stack-val 4)
(def-struct-get stack-cdr 5)
(def-struct-get accumulator-type 6)
(def-struct-get accumulator-val 7)
(def-struct-get accumulator-cdr 8)
(def-struct-get state-val 9)
(def-struct-get state-cdr 10)
(def-struct-get temp-type 11)
(def-struct-get temp-val 12)
(def-struct-get temp-cdr 13)
(def-struct-get envt-type 14)
(def-struct-get envt-val 15)
(def-struct-get envt-cdr 16)
(def-struct-get mem-addr 17)
(def-struct-get micro-instr-mark 18)
(def-struct-get micro-instr-type 19)
(def-struct-get micro-instr-val 20)
(def-struct-get micro-state-val 21)
(def-struct-get micro-mem-overflow 22)
(def-struct-get micro-instr-cdr-nonzero 23)
(def-struct-get micro-index 24)
(def-struct-get heap 25)
(def-struct-get head 26)
(def-struct-get bus-mark 27)
(def-struct-get bus-type 28)
(def-struct-get bus-val 29)
(def-struct-get bus-cdr 30)



(def-struct-set instr-mark 0)
(def-struct-set instr-type 1)
(def-struct-set instr-val 2)
(def-struct-set instr-cdr 3)
(def-struct-set stack-val 4)
(def-struct-set stack-cdr 5)
(def-struct-set accumulator-type 6)
(def-struct-set accumulator-val 7)
(def-struct-set accumulator-cdr 8)
(def-struct-set state-val 9)
(def-struct-set state-cdr 10)
(def-struct-set temp-type 11)
(def-struct-set temp-val 12)
(def-struct-set temp-cdr 13)
(def-struct-set envt-type 14)
(def-struct-set envt-val 15)
(def-struct-set envt-cdr 16)
(def-struct-set mem-addr 17)
(def-struct-set micro-instr-mark 18)
(def-struct-set micro-instr-type 19)
(def-struct-set micro-instr-val 20)
(def-struct-set micro-state-val 21)
(def-struct-set micro-mem-overflow 22)
(def-struct-set micro-instr-cdr-nonzero 23)
(def-struct-set micro-index 24)
(def-struct-set heap 25)
(def-struct-set head 26)
(def-struct-set-no-checking bus-mark 27)
(def-struct-set-no-checking bus-type 28)
(def-struct-set-no-checking bus-val 29)
(def-struct-set-no-checking bus-cdr 30)



(define write-heap
    (lambda (state addr mark type val kdr)
        (if (or (eq? mark '--) (eq? type '--) (eq? val '--) (eq? kdr '--))
            (error "trying to write uninit bus to the heap")
            (let ((heap' (vector-copy (get-heap state))))
                (begin
                    (vector-set! heap' addr (list mark type val kdr))
                    (set-heap state heap'))))))

(define write-bus-mark
    (lambda (state val)
        (if (eq? (get-bus-mark state) '--)
            (let ((ret (vector-copy state)) (prev-bus (get-bus-mark state)))
                (begin
                    (set-bus-mark ret val)))
            (error "double write on bus"))))
(define write-bus-type
    (lambda (state val)
        (if (eq? (get-bus-type state) '--)
            (let ((ret (vector-copy state)) (prev-bus (get-bus-type state)))
                (begin
                    (set-bus-type ret val)))
            (error "double write on bus"))))
(define write-bus-val
    (lambda (state val)
        (if (eq? (get-bus-val state) '--)
            (let ((ret (vector-copy state)) (prev-bus (get-bus-val state)))
                (begin
                    (set-bus-val ret val)))
            (error "double write on bus"))))
(define write-bus-cdr
    (lambda (state val)
        (if (eq? (get-bus-cdr state) '--)
            (let ((ret (vector-copy state)) (prev-bus (get-bus-cdr state)))
                (begin
                    (set-bus-cdr ret val)))
            (error "double write on bus"))))


(define get-depth
    (lambda (state n)
        (if (eq? n 0)
            0
            (begin #|(printf n " ")|# (+ 1 (get-depth state (node-cdr-ptr (vector-ref (get-heap state) n))))))))
(define print-cpu-state
    (lambda (name state)
        #|(printf name 
            "I" (get-instr-mark state) (get-instr-type state) (get-instr-val state) (get-instr-cdr state) 
            "SK" (get-stack-val state) (get-stack-cdr state) "(" (number->string (get-depth state (get-stack-cdr state))) ")"
            "A" (get-accumulator-val state) (get-accumulator-cdr state)
            "ST" (get-state-val state) (get-state-cdr state)
            "EV" (get-envt-type state) (get-envt-val state) (get-envt-cdr state)
            "M" (get-mem-addr state) 
            "MI" (get-micro-instr-type state) (get-micro-instr-val state) (get-micro-state-val state) (get-micro-mem-overflow state) (get-micro-index state)
            "H" (get-head state)
            "B" (get-bus-mark state) (get-bus-type state) (get-bus-val state) (get-bus-cdr state) "\n")|#
        (printf name 
            "I" (get-instr-mark state) (get-instr-type state) (get-instr-val state) (get-instr-cdr state) 
            "SK" (get-stack-val state) (get-stack-cdr state) #|"(" (number->string (get-depth state (get-stack-cdr state))) ")"|#
            "A" (get-accumulator-val state) (get-accumulator-cdr state)
            "ST" (get-state-val state) (get-state-cdr state)
            "EV" (get-envt-type state) (get-envt-val state) (get-envt-cdr state)
            "M" (get-mem-addr state) 
            "MI" (get-micro-instr-type state) (get-micro-instr-val state) (get-micro-state-val state) (get-micro-mem-overflow state) (get-micro-index state) (get-micro-instr-cdr-nonzero state)
            "H" (get-head state)
            "B" (get-bus-mark state) (get-bus-type state) (get-bus-val state) (get-bus-cdr state) "\n")
        ))



(define write-cycle
    (lambda (uops cpu-state)
        (begin 
            ; (print-cpu-state "write-cycle" cpu-state)
        (if (nil? uops)
            cpu-state
            (let ((uop-head (car uops)))
                (cond
                    ((eq? uop-head 'from-instr-mark)
                        (write-cycle (cdr uops) (write-bus-mark cpu-state (get-instr-mark cpu-state))))
                    ((eq? uop-head 'from-instr-type)
                        (write-cycle (cdr uops) (write-bus-type cpu-state (get-instr-type cpu-state))))
                    ((eq? uop-head 'from-instr-type-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-instr-type cpu-state))))
                    ((eq? uop-head 'from-instr-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-instr-val cpu-state))))
                    ((eq? uop-head 'from-instr-val-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-instr-val cpu-state))))
                    ((eq? uop-head 'from-instr-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-instr-cdr cpu-state))))
                    ((eq? uop-head 'from-instr-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-instr-cdr cpu-state))))

                    ((eq? uop-head 'from-stack-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-stack-val cpu-state))))
                    ((eq? uop-head 'from-stack-val-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-stack-val cpu-state))))
                    ((eq? uop-head 'from-stack-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-stack-cdr cpu-state))))
                    ((eq? uop-head 'from-stack-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-stack-cdr cpu-state))))

                    ((eq? uop-head 'from-accumulator-type)
                        (write-cycle (cdr uops) (write-bus-type cpu-state (get-accumulator-type cpu-state))))
                    ((eq? uop-head 'from-accumulator-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-accumulator-val cpu-state))))
                    ((eq? uop-head 'from-accumulator-val-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-accumulator-val cpu-state))))
                    ((eq? uop-head 'from-accumulator-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-accumulator-cdr cpu-state))))
                    ((eq? uop-head 'from-accumulator-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-accumulator-cdr cpu-state))))

                    ((eq? uop-head 'from-state-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-state-val cpu-state))))
                    ((eq? uop-head 'from-state-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-state-cdr cpu-state))))
                    ((eq? uop-head 'from-state-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-state-cdr cpu-state))))

                    ((eq? uop-head 'from-temp-type)
                        (write-cycle (cdr uops) (write-bus-type cpu-state (get-temp-type cpu-state))))
                    ((eq? uop-head 'from-temp-type-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-temp-type cpu-state))))
                    ((eq? uop-head 'from-temp-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-temp-val cpu-state))))
                    ((eq? uop-head 'from-temp-val-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-temp-val cpu-state))))
                    ((eq? uop-head 'from-temp-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-temp-cdr cpu-state))))
                    ((eq? uop-head 'from-temp-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-temp-cdr cpu-state))))

                    ((eq? uop-head 'from-envt-type)
                        (write-cycle (cdr uops) (write-bus-type cpu-state (get-envt-type cpu-state))))
                    ((eq? uop-head 'from-envt-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-envt-val cpu-state))))
                    ((eq? uop-head 'from-envt-val-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-envt-val cpu-state))))
                    ((eq? uop-head 'from-envt-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-envt-cdr cpu-state))))
                    ((eq? uop-head 'from-envt-cdr-on-val)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-envt-cdr cpu-state))))

                    ((eq? uop-head 'from-head)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (get-head cpu-state))))
                    ((eq? uop-head 'from-head-on-cdr)
                        (write-cycle (cdr uops) (write-bus-cdr cpu-state (get-head cpu-state))))

                    ((eq? uop-head 'incr-head)
                        (write-cycle (cdr uops) (set-head cpu-state (+ 1 (get-head cpu-state)))))

                    ((eq? uop-head 'from-gc-reloc)
                        (write-cycle (cdr uops) (set-bus-val cpu-state (if (eq? (get-temp-type cpu-state) node-type-reloc) (get-temp-val cpu-state) (get-temp-cdr cpu-state)))))

                    ((eq? uop-head 'from-read)
                        (let ((mem (vector-ref (get-heap cpu-state) (get-mem-addr cpu-state))))
                           (write-cycle (cdr uops) (write-bus-mark (write-bus-type (write-bus-val (write-bus-cdr cpu-state (node-cdr-ptr mem)) (node-value mem)) (node-type mem)) (node-mark mem)))))
                    ((eq? uop-head 'from-add)
                        (write-cycle (cdr uops) (write-bus-val cpu-state (+ (get-accumulator-val cpu-state) (get-instr-val cpu-state)))))

                    ((list? uop-head)
                        (cond
                            ((eq? (car uop-head) 'from-micro-constant-on-mark)
                                (write-cycle (cdr uops) (write-bus-mark cpu-state (cadr uop-head))))
                            ((eq? (car uop-head) 'from-micro-constant-on-type)
                                (write-cycle (cdr uops) (write-bus-type cpu-state (cadr uop-head))))
                            ((eq? (car uop-head) 'from-micro-constant-on-val)
                                (write-cycle (cdr uops) (write-bus-val cpu-state (cadr uop-head))))
                            ((eq? (car uop-head) 'from-micro-constant-on-cdr)
                                (write-cycle (cdr uops) (write-bus-cdr cpu-state (cadr uop-head))))
                            ((#t)
                                (error "Unrecognized subcommand in defmicro"))))
                    (#t (write-cycle (cdr uops) cpu-state)))))))
        )


(define read-cycle
    (lambda (uops cpu-state)
        (begin 
            ; (print-cpu-state "read-cycle" cpu-state)
        (if (nil? uops)
            cpu-state
            (let ((uop (car uops)))
                (cond
                    ((eq? uop 'to-instr-mark)
                        (read-cycle (cdr uops) (set-instr-mark cpu-state (get-bus-mark cpu-state))))
                    ((eq? uop 'to-instr-type)
                        (read-cycle (cdr uops) (set-instr-type cpu-state (get-bus-type cpu-state))))
                    ((eq? uop 'to-instr-val)
                        (read-cycle (cdr uops) (set-instr-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-instr-cdr)
                        (read-cycle (cdr uops) (set-instr-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-stack-val)
                        (read-cycle (cdr uops) (set-stack-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-stack-cdr)
                        (read-cycle (cdr uops) (set-stack-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-accumulator-type)
                        (read-cycle (cdr uops) (set-accumulator-type cpu-state (get-bus-type cpu-state))))
                    ((eq? uop 'to-accumulator-val)
                        (read-cycle (cdr uops) (set-accumulator-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-accumulator-val-from-bus-cdr) ; a special form
                        (read-cycle (cdr uops) (set-accumulator-val cpu-state (get-bus-cdr cpu-state))))
                    ((eq? uop 'to-accumulator-cdr)
                        (read-cycle (cdr uops) (set-accumulator-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-state-val)
                        (read-cycle (cdr uops) (set-state-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-state-cdr)
                        (read-cycle (cdr uops) (set-state-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-temp-type)
                        (read-cycle (cdr uops) (set-temp-type cpu-state (get-bus-type cpu-state))))
                    ((eq? uop 'to-temp-val)
                        (read-cycle (cdr uops) (set-temp-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-temp-cdr)
                        (read-cycle (cdr uops) (set-temp-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-envt-type)
                        (read-cycle (cdr uops) (set-envt-type cpu-state (get-bus-type cpu-state))))
                    ((eq? uop 'to-envt-val)
                        (read-cycle (cdr uops) (set-envt-val cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-envt-cdr)
                        (read-cycle (cdr uops) (set-envt-cdr cpu-state (get-bus-cdr cpu-state))))

                    ((eq? uop 'to-head)
                        (read-cycle (cdr uops) (set-head cpu-state (get-bus-val cpu-state))))

                    ((eq? uop 'to-mem-addr)
                        (read-cycle (cdr uops) (set-mem-addr cpu-state (get-bus-val cpu-state))))
                    ((eq? uop 'to-write)
                        (read-cycle (cdr uops) (write-heap cpu-state (get-mem-addr cpu-state) (get-bus-mark cpu-state) (get-bus-type cpu-state) (get-bus-val cpu-state) (get-bus-cdr cpu-state))))

                    ; There's no good place to put this, so I'm just putting this here
                    ((eq? uop 'micro-reset)
                        (read-cycle (cdr uops) 
                            (set-micro-instr-cdr-nonzero
                                (set-micro-mem-overflow 
                                    (set-micro-instr-mark
                                        (set-micro-instr-type 
                                            (set-micro-instr-val 
                                                (set-micro-state-val 
                                                    (set-micro-index cpu-state -1) 
                                                    (get-state-val cpu-state)) 
                                                (get-instr-val cpu-state)) 
                                            (get-instr-type cpu-state))
                                        (get-instr-mark cpu-state)) 
                                    (if (or 
                                        (and (eq? (get-state-val cpu-state) doing-GC-stage-4) (eq? (get-head cpu-state) 200))
                                        (and (neq? (get-state-val cpu-state) doing-GC-stage-4) (> (get-head cpu-state) 180)))
                                        1 0))
                                (if (neq? (get-instr-cdr cpu-state) 0) 1 0))))
                    (#t (read-cycle (cdr uops) cpu-state)))))))
        )



(define clear-bus-cycle
    (lambda (cpu-state)
        (begin
            ; (print-cpu-state "clear-bus-cycle" cpu-state)
            (let ((state' (set-bus-mark (set-bus-type (set-bus-val (set-bus-cdr cpu-state '--) '--) '--) '--)))
                (set-micro-index state' (+ 1 (get-micro-index state')))))))


; Bus values are ordered as (addr type val cdr)
; (define fill-bus
;     (lambda (uops bus-vals instr stack accumulator state microcode head)
;         (let ((uop-head (cdr uops)))
;             (cond
;                 ((and (eq? uop-head 'from-instr-type) (eq? (cadr uop-head) '--))
;                     (fill-bus 
;                         (cdr uops) 
;                         (list (car bus-vals) (car instr) (caddr bus-vals) (cadddr bus-vals))
;                         instr stack accumulator state microcode))
;                 ((and (eq? uop-head 'from-head) (eq? (cadr uop-head) '--))
;                     (fill-bus 
;                         (cdr uops) 
;                         (list (car bus-vals) (car instr) (caddr bus-vals) (cadddr bus-vals))
;                         instr stack accumulator state microcode))
;                 ((#t) (error "fill-bus error"))))))


; (define micro-eval
;     (lambda (instr stack accumulator state microcode mem-addr micro-instr micro-state heap head)
;         (let ((uops (search-matching-microcode microcode-2 (car instr) (cadr instr) (car state))))
;             (let ((uop (index uops microcode)))
;                 (let ((write-state (write-cycle uop cpu-state)))
;                     (display ""))))))

(define render-list
    (lambda (state ptr)
        (if (eq? ptr 0)
            0
            (begin
                (display (vector-ref (get-heap state) ptr)) (display " ")
                (render-list state (node-cdr-ptr (vector-ref (get-heap state) ptr)))))))


(define check-for-ptr-ordering
    (lambda (index l)
        (if (nil? l)
            '()
            (let ((el (car l)))
                (cond
                    ((and
                        (or
                            (eq? (node-type el) node-type-nil)
                            (eq? (node-type el) node-type-int)
                            (eq? (node-type el) node-type-builtin-function))
                        (<= (node-cdr-ptr el) index)) ; Equaltiy for nil at 0
                        (check-for-ptr-ordering (+ index 1) (cdr l)))

                    ((and
                        (or
                            (eq? (node-type el) node-type-call)
                            (eq? (node-type el) node-type-list)
                            (eq? (node-type el) node-type-closure))
                        (< (node-cdr-ptr el) index)
                        (< (node-value el) index))
                        (check-for-ptr-ordering (+ index 1) (cdr l)))

                    ((or
                        (eq? (node-type el) node-type-reloc)
                        (eq? (node-type el) node-type-empty))
                        (check-for-ptr-ordering (+ index 1) (cdr l)))

                    (#t (error "val or ptr doesn't point the downward: " el))

                    )))))


(define micro-eval-2
    (lambda (cpu-state) (begin 
        #|(if (and (eq? (get-state-val cpu-state) doing-GC-stage-4) (eq? (get-head cpu-state) 103)) (+ 1 "hi") 0)|#
        (if (eq? (get-micro-index cpu-state) 0) 
            (begin  
                (display "!!!!!!\n")
                (display (get-micro-instr-mark cpu-state)) (display " ") (display (get-micro-instr-type cpu-state)) (display " ") (display (get-micro-instr-val cpu-state)) (display " ") (display (get-micro-state-val cpu-state))
                (display "\n!!!!!!\n")
                (render-list cpu-state (get-envt-val cpu-state)) (display "\n")
                ; (render-list cpu-state (get-micro-instr-val cpu-state)) (display "\n")
                (display (get-heap cpu-state)) (display "\n")
                ))

        (check-for-ptr-ordering 0 (vector->list (get-heap cpu-state))) ; TODO: remove the vector->list, it's wasteful

        ; (let ((uops (search-matching-microcode microcode-2 (get-micro-instr-mark cpu-state) (get-micro-instr-type cpu-state) (get-micro-instr-val cpu-state) (get-micro-state-val cpu-state) (get-micro-mem-overflow cpu-state))))
        (let ((uops (microcode-3 (get-micro-instr-mark cpu-state) (get-micro-instr-type cpu-state) (get-micro-instr-val cpu-state) (get-micro-instr-cdr-nonzero cpu-state) (get-micro-state-val cpu-state) (get-micro-mem-overflow cpu-state))))
            (let ((uop (index uops (get-micro-index cpu-state))))
                (begin
                    (printf uop "\n")
                    (let ((write-state (write-cycle uop cpu-state)))
                        (begin (print-cpu-state "write-state" write-state) (let ((read-state (read-cycle uop write-state)))
                            (let ((finish-state (clear-bus-cycle read-state)))
                                (micro-eval-2 finish-state)))))))))))

; (define instructions2 (list->vector (append instructions '(
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
;     (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)))))
; (define micro-eval-2-start 
;     (lambda ()
;         (micro-eval-2 (cpu-state-init 
;             (car first-instr) (cadr first-instr) (caddr first-instr)
;             0 0 
;             0 0
;             0 0
;             0
;             0
;             (car first-instr) (cadr first-instr)
;             0
;             0
;             instructions2
;             (length instructions)
;             '-- '-- '--))))
; ; (micro-eval-2-start)

(define repeat
    (lambda (num a)
        (if (eq? num 0)
            '()
            (cons a (repeat (- num 1) a)))))
(define micro-eval-3
    (lambda (start-instr code)
        (micro-eval-2 (cpu-state-init 
            0 (node-type start-instr) (node-value start-instr) (node-cdr-ptr start-instr)
            0 0 
            0 0 0
            0 0
            0 0 0
            0 0 0
            0
            0 (node-type start-instr) (node-value start-instr)
            0
            0 1
            0
            (list->vector (append code (repeat 300 (list 0 node-type-empty 0 0))))
            (length code)
            '-- '-- '-- '--))))


; some microcode ideas and stuff

; (define-syntax def-microcode
;     (syntax-rules ()
;         ((def-microcode a b c d)
;             (list a b c d))))

; (define-syntax def-allocate
;     (syntax-rules ()
;         ((def-allocate type value ptr dst-ptr dst)
;             (list 
;                 '(*heap-head* *mem-addr*)
;                 (list type '*mem-value-type*)
;                 (list value '*mem-value-value*)
;                 (list ptr '*mem-value-cdr*)
;                 '(do-write)
;                 (list '*heap-head* dst-ptr)
;                 ; bump the heap head
;                 '(*heap-head* *adder-input-1*)
;                 '(*mem-value* dst)
;                 '(1 *adder-input-2*)
;                 '(*adder-output* *heap-head*)))))

; (define-syntax def-next-instr
;     (syntax-rules ()
;         ((def-next-instr) '(
;                 (*instr-cdr* *stack*)
;                 (*stack-value* *mem-addr*)
;                 (do-read)
;                 (*mem-value* *instr*)))))


; compiler
; (define to-compile '(+ (if 1 5 0) (car (cdr (cons 7 (cons 8 ()))))))
(define complex-compile '((lambda (+ (car env) (car (cdr env)))) 5 103))
; (define even-more-complex-compile '(((lambda (lambda (+ (car env) (car (cdr env))))) 5) 4))
(define even-more-complex-compile '(((lambda (lambda (+ (car env) (car (cdr env))))) 5) 4))
(define to-compile '(+ (if 1 5 6) 4))
(define multiply-compile '(
    (lambda
        ((car env) (car (cdr (cdr env))) (car (cdr env)) (car env)))
    5
    10
    (lambda
        (if
            (zero? (car (cdr (cdr env))))
            0
            (+ (car (cdr env)) ((car env) (+ (car (cdr (cdr env))) -1) (car (cdr env)) (car env)))))))
(define very-simple '(+ (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1) (+ 1 1)))

(define *compile-stack-head* 1)
(define result-instr (list (list 0 node-type-nil 0 0)))
#|(define compile (lambda (expr)
    (cond
        ((number? expr) (begin
            (display "eating a number!\n")
            (list node-type-int expr 0)
            ))
        ((nil? expr) (begin
            (display "eating a nil!\n")
            (list node-type-nil 0 0)
            ))
        ((eq? (car expr) 'env) (begin
            (display "eating a env!\n")
            (list node-type-builtin-function builtin-envt 0)
            ))

        ; if it's not one of the literals above, it's one of these calls
        ((eq? (car expr) '+) 
            (let ((expr1 (compile (cadr expr))) (expr2 (compile (caddr expr))))
                (begin
                    (display "compiling a plus!\n")
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-plus (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr1) (cadr expr1) (+ *compile-stack-head* 2)))))
                    (set! result-instr (append result-instr (list (list (car expr2) (cadr expr2) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 3))
                    (list node-type-call (- *compile-stack-head* 3) 0)
                    )))
        ((eq? (car expr) 'if) 
            (let ((expr-cond (compile (cadr expr))) (expr-a (compile (caddr expr))) (expr-b (compile (cadddr expr))))
                (begin
                    (display "compiling an if!\n")
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-if (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr-cond) (cadr expr-cond) (+ *compile-stack-head* 2)))))
                    (set! result-instr (append result-instr (list (list (car expr-a) (cadr expr-a) (+ *compile-stack-head* 3)))))
                    (set! result-instr (append result-instr (list (list (car expr-b) (cadr expr-b) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 4))
                    (list node-type-call (- *compile-stack-head* 4) 0)
                    )))
        ((eq? (car expr) '>=)
            (let ((expr-a (compile (cadr expr))) (expr-b (compile (caddr expr))))
                (begin
                    (display "compile a >=\n")
                    (display expr-a)
                    (display expr-b)
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-geq (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr-a) (cadr expr-a) (+ *compile-stack-head* 2)))))
                    (set! result-instr (append result-instr (list (list (car expr-b) (cadr expr-b) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 3))
                    (list node-type-call (- *compile-stack-head* 3) 0)
                    )))
        ((eq? (car expr) 'car)
            (let ((expr-a (compile (cadr expr))))
                (begin
                    (display "compile a car\n")
                    (display expr-a)
                    (display "\n")
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-car (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr-a) (cadr expr-a) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 2))
                    (list node-type-call (- *compile-stack-head* 2) 0)
                    )))
        ((eq? (car expr) 'cdr)
            (let ((expr-a (compile (cadr expr))))
                (begin
                    (display "compile a cdr\n")
                    (display expr-a)
                    (display "\n")
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-cdr (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr-a) (cadr expr-a) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 2))
                    (list node-type-call (- *compile-stack-head* 2) 0)
                    )))
        ((eq? (car expr) 'cons)
            (let ((expr-a (compile (cadr expr))) (expr-b (compile (caddr expr))))
                (begin
                    (display "compile a cons\n")
                    (display expr-a)
                    (display expr-b)
                    (set! result-instr (append result-instr (list (list node-type-builtin-function builtin-cons (+ *compile-stack-head* 1)))))
                    (set! result-instr (append result-instr (list (list (car expr-a) (cadr expr-a) (+ *compile-stack-head* 2)))))
                    (set! result-instr (append result-instr (list (list (car expr-b) (cadr expr-b) 0))))
                    (set! *compile-stack-head* (+ *compile-stack-head* 3))
                    (list node-type-call (- *compile-stack-head* 3) 0)
                    )))
        ((eq? (car expr) 'lambda)
            (let ((expr-a (compile (cadr expr))))
                (begin
                    (display "compile a lambda\n")
                    (display expr-a)
                    )))
        (#t (error "unrecognized" expr))
        )))|#
#|(define compile-2-call (lambda (expr)
    (if (nil? expr)
        0 ; we're looking at a nil list
        (begin
            (let ((prv-stack-head *compile-stack-head*) (node (car expr)))
                (if (nil? (cdr expr))
                    (set! result-instr (append result-instr (list (list 0 (node-type node) (node-value node) 0))))
                    (set! result-instr (append result-instr (list (list 0 (node-type node) (node-value node) (+ *compile-stack-head* 1))))))
                (set! *compile-stack-head* (+ *compile-stack-head* 1))
                (compile-2-call (cdr expr))
                prv-stack-head)
            ))))|#
(define compile-2-call (lambda (expr)
    (if (nil? expr)
        0 ; we're looking at a nil list
        (begin
            (let ((node (car expr)) (cdr-ptr (compile-2-call (cdr expr))))
                (set! result-instr (append result-instr (list (list 0 (node-type node) (node-value node) cdr-ptr))))
                (set! *compile-stack-head* (+ *compile-stack-head* 1))
                (- *compile-stack-head* 1))
            ))))
(define compile-2 (lambda (expr)
    (cond
        ((number? expr)
            (list 0 node-type-int expr 0))
        ((eq? expr 'env)
            (list 0 node-type-builtin-function builtin-envt 0))
        ((nil? expr)
            (list 0 node-type-nil 0 0))

        ((eq? expr 'lambda) (begin
            (display "compile a lambda\n")
            (list 0 node-type-builtin-function builtin-lambda 0)))
        ((eq? expr '+) (begin
            (display "compile a plus\n")
            (list 0 node-type-builtin-function builtin-plus 0)))
        ((eq? expr 'car) (begin
            (display "compile a car\n")
            (list 0 node-type-builtin-function builtin-car 0)))
        ((eq? expr 'cdr) (begin
            (display "compile a cdr\n")
            (list 0 node-type-builtin-function builtin-cdr 0)))
        ((eq? expr 'if) (begin
            (display "compile a if\n")
            (list 0 node-type-builtin-function builtin-if 0)))
        ((eq? expr 'zero?) (begin
            (display "compile a zero?\n")
            (list 0 node-type-builtin-function builtin-zero? 0)))

        ; ((and (list? expr) (eq? (car expr) 'lambda))
        ;     (let ((ptr (compile-2-call (map compile-2 (list (cadr expr) '())))))
        ;         (list node-type-closure ptr 0)))
        ((list? expr) (begin
            ; loop through each item, compiling each, and pushing them onto result-instr, and modifying their cdr ptrs
            (let ((ptr (compile-2-call (map compile-2 expr))))
                (list 0 node-type-call ptr 0))
        ))
        (#t (error "unrecognized" expr))
        )))

(define aa (compile-2 multiply-compile))
; (define aa (compile-2 very-simple))
(display result-instr)
(display "\n")
(micro-eval-3 aa result-instr)
