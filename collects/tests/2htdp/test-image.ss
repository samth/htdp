#lang scheme/base
(require "../../2htdp/private/image-core.ss"
         "../../2htdp/private/image-more.ss"
         scheme/math
         scheme/class
         scheme/gui/base
         tests/eli-tester)

;(define-syntax-rule (test a => b) (begin a b))

;; test case: (beside (text "a"...) (text "b" ...)) vs (text "ab")

;(show-image (frame (rotate 210 (ellipse 200 400 'solid 'purple))))

#;
(show-image
 (overlay/xy (rectangle 100 10 'solid 'red)
             0
             10
             (rectangle 100 10 'solid 'red)))


#;
(show-image
 (let loop ([image (rectangle 400 8 'solid 'red)]
            [n 2])
   (cond
     [(= n 7) image]
     [else
      (loop (overlay/places 'center 'center
                            image
                            (rotate (* 180 (/ 1 n)) image))
            (+ n 1))])))

(define-syntax-rule 
  (round-numbers e)
  (call-with-values (λ () e) round-numbers/values))

(define (round-numbers/values . args) (apply values (round-numbers/proc args)))

(define (round-numbers/proc x)
  (let loop ([x x])
    (cond
      [(number? x) (let ([n (exact->inexact (/ (round (* 100. x)) 100))])
                     (if (equal? n -0.0)
                         0.0
                         n))]
      [(pair? x) (cons (loop (car x)) (loop (cdr x)))]
      [(vector? x) (apply vector (map loop (vector->list x)))]
      [(let-values ([(a b) (struct-info x)]) a)
       =>
       (λ (struct-type)
         (apply
          (struct-type-make-constructor
           struct-type)
          (map loop (cdr (vector->list (struct->vector x))))))]
      [else x])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  testing overlays
;;

(test (overlay (ellipse 100 100 'solid 'blue)
               (ellipse 120 120 'solid 'red))
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 100 100 'solid 'blue)))
        (make-translate 0 0 (image-shape (ellipse 120 120 'solid 'red))))
       (make-bb 120
                120
                120)
       #f))

(test (overlay/xy (ellipse 100 100 'solid 'blue)
                  0 0
                  (ellipse 120 120 'solid 'red))
      =>
      (overlay (ellipse 100 100 'solid 'blue)
               (ellipse 120 120 'solid 'red)))


(test (overlay/xy (ellipse 50 100 'solid 'red)
                  -25 25
                  (ellipse 100 50 'solid 'green))
      =>
      (make-image
       (make-overlay
        (make-translate
         25 0
         (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate
         0 25
         (image-shape (ellipse 100 50 'solid 'green))))
       (make-bb 100
                100
                100)
       #f))

(test (overlay/xy (ellipse 100 50 'solid 'green)
                  10 10
                  (ellipse 50 100 'solid 'red))
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 100 50 'solid 'green)))
        (make-translate 10 10 (image-shape (ellipse 50 100 'solid 'red))))
       (make-bb 100
                110
                110)
       #f))

(test (overlay (ellipse 100 50 'solid 'green)
               (ellipse 50 100 'solid 'red))
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 100 50 'solid 'green)))
        (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red))))
       (make-bb 100
                100
                100)
       #f))

(test (overlay (ellipse 100 100 'solid 'blue)
               (ellipse 120 120 'solid 'red)
               (ellipse 140 140 'solid 'green))
      =>
      (make-image
       (make-overlay
        (make-translate 
         0 0
         (make-overlay
          (make-translate 0 0 (image-shape (ellipse 100 100 'solid 'blue)))
          (make-translate 0 0 (image-shape (ellipse 120 120 'solid 'red)))))
        (make-translate 0 0 (image-shape (ellipse 140 140 'solid 'green))))
       (make-bb 140 140 140)
       #f))

(test (overlay/places 'middle
                      'middle
                      (ellipse 100 50 'solid 'green)
                      (ellipse 50 100 'solid 'red))
      =>
      (make-image
       (make-overlay
        (make-translate 0 25 (image-shape (ellipse 100 50 'solid 'green)))
        (make-translate 25 0 (image-shape (ellipse 50 100 'solid 'red))))
       (make-bb 100 100 100)
       #f))

(test (overlay/places 'middle
                      'middle
                      (ellipse 50 100 'solid 'red)
                      (ellipse 100 50 'solid 'green))
      =>
      (make-image
       (make-overlay
        (make-translate 25 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 0 25 (image-shape (ellipse 100 50 'solid 'green))))
       (make-bb 100 100 100)
       #f))


(test (overlay/places 'right
                      'bottom
                      (ellipse 50 100 'solid 'red)
                      (ellipse 100 50 'solid 'green))
      =>
      (make-image
       (make-overlay
        (make-translate 50 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 0 50 (image-shape (ellipse 100 50 'solid 'green))))
       (make-bb 100 100 100)
       #f))

(test (overlay/places 'right
                      'baseline
                      (ellipse 50 100 'solid 'red)
                      (ellipse 100 50 'solid 'green))
      =>
      (make-image
       (make-overlay
        (make-translate 50 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 0 50 (image-shape (ellipse 100 50 'solid 'green))))
       (make-bb 100 100 100)
       #f))

(test (beside/places 'top
                     (ellipse 50 100 'solid 'red)
                     (ellipse 100 50 'solid 'blue))
      
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 50 0 (image-shape (ellipse 100 50 'solid 'blue))))
       (make-bb 150 100 100)
       #f))

(test (beside/places 'center
                     (ellipse 50 100 'solid 'red)
                     (ellipse 100 50 'solid 'blue))
      
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 50 25 (image-shape (ellipse 100 50 'solid 'blue))))
       (make-bb 150 100 100)
       #f))

(test (beside/places 'baseline
                     (ellipse 50 100 'solid 'red)
                     (ellipse 100 50 'solid 'blue))
      
      =>
      (make-image
       (make-overlay
        (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red)))
        (make-translate 50 50 (image-shape (ellipse 100 50 'solid 'blue))))
       (make-bb 150 100 100)
       #f))

(test (beside (ellipse 50 100 'solid 'red)
              (ellipse 100 50 'solid 'blue))
      =>
      (beside/places 'top
                     (ellipse 50 100 'solid 'red)
                     (ellipse 100 50 'solid 'blue)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  testing normalization
;;

(test (normalize-shape (image-shape (ellipse 50 100 'solid 'red))
                       values)
      =>
      (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red))))

(test (normalize-shape (make-overlay (image-shape (ellipse 50 100 'solid 'red))
                                     (image-shape (ellipse 50 100 'solid 'blue)))
                       values)
      =>
      (make-overlay (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red)))
                    (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'blue)))))

(test (normalize-shape (make-overlay
                        (make-overlay (image-shape (ellipse 50 100 'solid 'red))
                                      (image-shape (ellipse 50 100 'solid 'blue)))
                        (image-shape (ellipse 50 100 'solid 'green)))
                       values)
      =>
      (make-overlay 
       (make-overlay (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red)))
                     (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'blue))))
       (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'green)))))

(test (normalize-shape (make-overlay
                        (image-shape (ellipse 50 100 'solid 'green))
                        (make-overlay (image-shape (ellipse 50 100 'solid 'red))
                                      (image-shape (ellipse 50 100 'solid 'blue))))
                       values)
      =>
      (make-overlay 
       (make-overlay (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'green)))
                     (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'red))))
       (make-translate 0 0 (image-shape (ellipse 50 100 'solid 'blue)))))

(test (normalize-shape (make-translate 100 100 (image-shape (ellipse 50 100 'solid 'blue)))
                       values)
      =>
      (make-translate 100 100 (image-shape (ellipse 50 100 'solid 'blue))))

(test (normalize-shape (make-translate 10 20 (make-translate 100 100 (image-shape (ellipse 50 100 'solid 'blue))))
                       values)
      =>
      (make-translate 110 120 (image-shape (ellipse 50 100 'solid 'blue))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  testing rotating
;;

(test (bring-between 123 360) => 123)
(test (bring-between 365 360) => 5)
(test (bring-between -5 360) => 355)
(test (bring-between 720 360) => 0)
(test (bring-between 720.5 360) => .5)

(test (round-numbers
       (normalize-shape (image-shape (rotate 90 (rectangle 100 100 'solid 'blue)))
                        values))
      =>
      (round-numbers (image-shape (rectangle 100 100 'solid 'blue))))

(test (round-numbers
       (normalize-shape (image-shape (rotate 90 (rotate 90 (rectangle 50 100 'solid 'purple))))
                        values))
      =>
      (round-numbers
       (normalize-shape (image-shape (rotate 180 (rectangle 50 100 'solid 'purple)))
                        values)))

(test (normalize-shape (image-shape (rotate 90 (ellipse 10 10 'solid 'red))))
      =>
      (normalize-shape (image-shape (ellipse 10 10 'solid 'red))))

(test (normalize-shape (image-shape (rotate 90 (ellipse 10 12 'solid 'red))))
      =>
      (normalize-shape (image-shape (ellipse 12 10 'solid 'red))))

(test (normalize-shape (image-shape (rotate 135 (ellipse 10 12 'solid 'red))))
      =>
      (normalize-shape (image-shape (rotate 45 (ellipse 12 10 'solid 'red)))))

(test (rotate -90 (ellipse 200 400 'solid 'purple))
      =>
      (rotate 90 (ellipse 200 400 'solid 'purple)))

(require (only-in lang/htdp-advanced equal~?))

(test (equal~? (rectangle 100 10 'solid 'red)
               (rotate 90 (rectangle 10 100 'solid 'red))
               0.1)
      =>
      #t)

(test (equal~? (rectangle 100 10 'solid 'red)
               (rotate 90 (rectangle 10.001 100.0001 'solid 'red))
               0.1)
      =>
      #t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; scaling tests
;;

(test (scale 2 (rectangle 100 10 'solid 'blue))
      =>
      (rectangle 200 20 'solid 'blue))

(test (scale 3
             (overlay/xy (rectangle 100 10 'solid 'blue)
                         0
                         20
                         (rectangle 100 10 'solid 'red)))
      =>
      (overlay/xy (rectangle 300 30 'solid 'blue)
                  0
                  60
                  (rectangle 300 30 'solid 'red)))

(test (scale 3
             (overlay/xy (rectangle 100 10 'solid 'blue)
                         0
                         20
                         (overlay/xy (rectangle 100 10 'solid 'blue)
                                     0
                                     20
                                     (rectangle 100 10 'solid 'purple))))
      =>
      (overlay/xy (rectangle 300 30 'solid 'blue)
                  0
                  60
                  (overlay/xy (rectangle 300 30 'solid 'blue)
                              0
                              60
                              (rectangle 300 30 'solid 'purple))))

(test (scale/xy 3 4 (ellipse 30 60 'outline 'purple))
      =>
      (ellipse (* 30 3) (* 60 4) 'outline 'purple))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; misc tests
;;

(test (rectangle 100 10 'solid 'blue)
      =>
      (rectangle 100 10 "solid" "blue"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  bitmap tests
;;

(define (fill-bitmap b color)
  (let ([bdc (make-object bitmap-dc% b)])
    (send bdc set-brush color 'solid)
    (send bdc set-pen color 1 'solid)
    (send bdc draw-rectangle 0 0 (send b get-width) (send b get-height))
    (send bdc set-bitmap #f)))

(define blue-10x20-bitmap (make-object bitmap% 10 20))
(fill-bitmap blue-10x20-bitmap "blue")
(define blue-20x10-bitmap (make-object bitmap% 20 10))
(fill-bitmap blue-20x10-bitmap "blue")
(define blue-20x40-bitmap (make-object bitmap% 20 40))
(fill-bitmap blue-20x40-bitmap "blue")

(test (image-right (image-snip->image (make-object image-snip% blue-10x20-bitmap)))
      => 
      10)
(test (image-bottom (image-snip->image (make-object image-snip% blue-10x20-bitmap)))
      => 
      20)
(test (image-baseline (image-snip->image (make-object image-snip% blue-10x20-bitmap)))
      => 
      20)
(test (scale 2 (make-object image-snip% blue-10x20-bitmap))
      =>
      (image-snip->image (make-object image-snip% blue-20x40-bitmap)))
(test (rotate 90 (make-object image-snip% blue-10x20-bitmap))
      =>
      (image-snip->image (make-object image-snip% blue-20x10-bitmap)))