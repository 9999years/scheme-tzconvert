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
    (values time from-zone to-zone))))

; '("10:00AM" "America/Los_Angeles" "America/New_York")

(module* main #f
  (let* ([argv (current-command-line-arguments)])
    (let-values ([(time from-zone to-zone) (time-and-zones argv)])
      (let* ([time (string->time time)]
             [time (zone-time time from-zone)]
             [time (convert-time time to-zone)])
        (print (~t time "h:mm a"))))))

