#lang scheme

;; the on-mouse and on-draw clauses are added to show more events in the
;; event log; they are no-ops otherwise 

(require 2htdp/universe htdp/testing htdp/image)
;(require "../universe.rkt" htdp/testing)

;; World   = Number | 'resting 
(define WORLD0 'resting)

;; constants 
(define HEIGHT 100)
(define DefWidth 50)

;; visual constants 
(define BALL (circle 3 'solid 'red))

(define mt (nw:rectangle DefWidth HEIGHT 'solid 'gray))

;; -----------------------------------------------------------------------------
;; Number (U String Symbol) [Boolean] -> true
;; create and hook up a player with the localhost server 
(define (make-player width t (show-state? #f))
  (local ((define mt (place-image (text (format "~a" t) 11 'black) 
                                  5 85 
                                  (empty-scene width HEIGHT)))
          
          ;; ----------------------------------------------------------------
          ;; World Number -> Message 
          ;; on receiving a message from server, place the ball at lower end or stop
          #|
          (check-expect (receive 'resting 'go) HEIGHT)
          (check-expect (receive HEIGHT 'go) HEIGHT)
          (check-expect (receive (- HEIGHT 1) 'go) (- HEIGHT 1))
          (check-expect (receive 0 'go) 0)
          |#
          (define (receive w n) 
            (cond
              [(number? w) w]
              [else HEIGHT]))
          ;; World -> World 
          #|
          (check-expect (move 'resting) 'resting)
          (check-expect (move HEIGHT) (- HEIGHT 1))
          (check-expect (move 0) (make-package 'resting 'go))
          |#
          (define (move x)
            (cond
              [(symbol? x) x]
              [(number? x) (if (<= x 0) (make-package 'resting 'go) (sub1 x))]))
          
          ;; World -> Scene 
          ;; render the world 
          
          ; (check-expect (draw 100) (place-image BALL 50 100 mt))
          
          (define (draw w)
            (cond
              [(symbol? w) (place-image (text "resting" 11 'red) 10 10 mt)]
              [(number? w) (place-image BALL 50 w mt)])))
    (big-bang WORLD0 
              (on-draw    draw)
              (on-tick    move .01)
              (on-mouse   (lambda (w x y me) w))
	      (on-key     (lambda (w ke) w))
              (check-with (lambda (w) (or (symbol? w) (number? w))))
              (on-receive receive)
	      (state      show-state?)
	      (name       t)
              (register   LOCALHOST))))

; (generate-report)

;; --- 

(require scheme/contract)

(provide
  (contract-out 
    [make-player (->* ((and/c number? (>=/c 100)) (or/c string? symbol?)) (boolean?) any/c)]))
