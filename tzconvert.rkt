#lang racket

(require racket/cmdline)
(require gregor)

(define string->time
  (λ (time) (parse-time time "h:mma")))

(define zone-time
  (λ (time tz) (at-time (now/moment #:tz tz) time)))

(define convert-time
  (λ (time new-tz)
    (let ([seconds (seconds-between time (with-timezone time new-tz))])
      (zone-time (-seconds time seconds) new-tz))))

(define time-and-zones
 (λ (argv)
   (command-line
    #:program "tzconvert"
    #:argv argv
    #:args (time from-zone to-zone)
    (list time from-zone to-zone))))

(define parse-and-zone
  (λ (time from-zone to-zone)
    (list (zone-time (string->time time) from-zone) to-zone)))

; '("10:00AM" "America/Los_Angeles" "America/New_York")

(module* main #f
  (let* ([argv (current-command-line-arguments)]
         [time (apply convert-time (apply parse-and-zone (time-and-zones argv)))])
    (display (~t time "h:mm a"))))

