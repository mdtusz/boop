#lang racket/base

; Throughout the code, n10n is short for notification.

(require racket/gui)

(module+ test
  (require rackunit))

(define-values (WIDTH HEIGHT) (get-display-size))

(define n10n-width 400)
(define n10n-height 100)
(define margin 20)
(define frame (new frame%
                   [label "Hello"]
                   [style (list
                            'no-resize-border
                            'float
                            'no-caption
                            'no-system-menu
                            'hide-menu-bar)]
                   [x (- WIDTH (+ n10n-width margin))]
                   [y (- HEIGHT (+ n10n-height margin))]
                   [width n10n-width]
                   [height n10n-height]))


(define (draw-n10n c dc)
  (draw-title dc)
  (draw-summary dc)
  (draw-close dc "black"))

(define (draw-title dc)
  (send dc set-text-foreground "black")
  (send dc set-font (make-object font% 18.0 'default))
  (send dc draw-text "Low Battery" 10 10))

(define (draw-summary dc)
  (send dc set-text-foreground "dimgray")
  (send dc set-font (make-object font% 12 'default))
  (send dc draw-text "Battery is at 10%." 10 50))

(define (draw-close dc color)
  (send dc set-pen color 2 'solid)
  (send dc draw-line
        (- n10n-width 10) 10
        (- n10n-width 25) 25)
  (send dc draw-line
        (- n10n-width 25) 10
        (- n10n-width 10) 25))

(define n10n% (class canvas%
                       (super-new)
                       (define dc (send this get-dc))
                       (define/override (on-event event)
                                        (define type (send event get-event-type))
                                        (case type
                                          [(left-down) (send this handle-click event)]
                                          [(motion) (send this handle-move event)]))

                       (define/public (handle-click event)
                         (let ([x (send event get-x)]
                               [y (send event get-y)]
                               [lbxc (- n10n-width 25)]
                               [ubxc (- n10n-width 10)]
                               [lbyc 10]
                               [ubyc 25])
                           (if (and (< lbxc x ubxc) (< lbyc y ubyc))
                             (exit)
                             (void))))

                       (define/public (handle-move event)
                         (let ([x (send event get-x)]
                               [y (send event get-y)]
                               [lbxc (- n10n-width 25)]
                               [ubxc (- n10n-width 10)]
                               [lbyc 10]
                               [ubyc 25])
                           (if (and (< lbxc x ubxc) (< lbyc y ubyc))
                             (draw-close dc "red")
                             (draw-close dc "black"))))))

(define canvas (new n10n%
                    [parent frame]
                    [paint-callback draw-n10n]))

(define timer (new timer%
                   [notify-callback exit]
                   [interval 10000]))

(module+ test)

(define (run-main)
  (send frame show #t))

(module+ main (run-main))
