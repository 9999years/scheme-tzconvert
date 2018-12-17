#lang racket

(require racket/cmdline)
(require gregor)

(module+ test
  (require rackunit)
  (require gregor/time))

(module+ test
  (define (check-custom= f)
    (λ (a b) (check-pred
              (λ (x) (f b x))
              a)))
  (define check-time= (check-custom= time=?))
  (check-time= (string->time "11:59AM") (time 11 59))
  (check-time= (string->time "3:02PM") (time 15 2)))

(define (string->time time) (parse-time time "h:mma"))

(module+ test
  (define check-moment= (check-custom= moment=?))
  (check-moment= (zone-time (time 1 14) "UTC") (moment 1970 1 1 1 14 #:tz "UTC")))
;;; Adds time-zone `tz` to a time `time`
(define (zone-time time tz) (at-time (moment 1970 #:tz tz) time))


(module+ test
  (check-moment= (convert-time (zone-time
                                (time 1 14)
                                "America/Los_Angeles")
                               "EST")
                 (moment 1970 1 1 4 14 #:tz "EST")))
;;; Changes the timezone on `time` to `new-tz` and shifts it to convert from
;;; one time to another
(define (convert-time time new-tz)
  (let ([seconds (seconds-between time (with-timezone time new-tz))])
    (zone-time (-seconds time seconds) new-tz)))

; CLI interface:

; (argv '("10:00AM" "America/Los_Angeles" "America/New_York"))
(define argv          (make-parameter (current-command-line-arguments)))
(define arg-time      (make-parameter now/moment))
(define arg-from-zone (make-parameter "UTC"))
(define arg-to-zone   (make-parameter "UTC"))

;;; parses command-line arguments into time, from-zone, and to-zone. Raises an
;;; exception if necessary
(define (time-and-zones! argv)
 (command-line
  #:program "tzconvert"
  #:argv argv
  #:args (time from-zone to-zone)
  (begin
    (arg-time time)
    (arg-from-zone from-zone)
    (arg-to-zone to-zone))))

(module+ main
  (argv '("10:00AM" "America/Los_Angeles" "America/New_York"))
  (time-and-zones! (argv))
  (let* ([time (string->time (arg-time))]
         [time (zone-time time (arg-from-zone))]
         [time (convert-time time (arg-to-zone))]
         [time (~t time "h:mm a")])
    (display time)))

