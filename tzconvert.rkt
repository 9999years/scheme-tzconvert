# lang racket

(require racket/cmdline)
(require tzinfo)
(require gregor)

;;; offset a time by a timezone
(define time-offset
 (λ ([time : time?] [offset])) ())

(define time-and-zones
 (command-line
  #:program "tzconvert"
  #:args (time from-zone to-zone)
  time from-zone to-zone))

(module* main # f
 ())
