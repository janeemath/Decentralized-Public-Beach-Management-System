;; Lifeguard Scheduling Contract
;; Manages lifeguard certifications, assignments, and shift scheduling

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-EXPIRED (err u104))

;; Data Variables
(define-data-var next-lifeguard-id uint u1)
(define-data-var next-shift-id uint u1)
(define-data-var emergency-mode bool false)

;; Data Maps
(define-map lifeguards
  { lifeguard-id: uint }
  {
    name: (string-ascii 50),
    certification-expiry: uint,
    total-hours: uint,
    rating: uint,
    active: bool
  }
)

(define-map shifts
  { shift-id: uint }
  {
    lifeguard-id: uint,
    start-time: uint,
    end-time: uint,
    beach-section: uint,
    completed: bool,
    notes: (string-ascii 200)
  }
)

(define-map lifeguard-availability
  { lifeguard-id: uint, date: uint }
  { available: bool }
)

(define-map administrators
  { admin: principal }
  { authorized: bool }
)

;; Authorization Functions
(define-private (is-authorized (caller principal))
  (or
    (is-eq caller CONTRACT-OWNER)
    (default-to false (get authorized (map-get? administrators { admin: caller })))
  )
)

;; Administrative Functions
(define-public (add-administrator (admin principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set administrators { admin: admin } { authorized: true }))
  )
)

(define-public (remove-administrator (admin principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-delete administrators { admin: admin }))
  )
)

(define-public (toggle-emergency-mode)
  (begin
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (var-set emergency-mode (not (var-get emergency-mode)))
    (ok (var-get emergency-mode))
  )
)

;; Lifeguard Management Functions
(define-public (register-lifeguard (name (string-ascii 50)) (certification-expiry uint))
  (let
    (
      (lifeguard-id (var-get next-lifeguard-id))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> certification-expiry block-height) ERR-INVALID-INPUT)

    (map-set lifeguards
      { lifeguard-id: lifeguard-id }
      {
        name: name,
        certification-expiry: certification-expiry,
        total-hours: u0,
        rating: u5,
        active: true
      }
    )
    (var-set next-lifeguard-id (+ lifeguard-id u1))
    (ok lifeguard-id)
  )
)

(define-public (update-lifeguard-status (lifeguard-id uint) (active bool))
  (let
    (
      (lifeguard (unwrap! (map-get? lifeguards { lifeguard-id: lifeguard-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)

    (map-set lifeguards
      { lifeguard-id: lifeguard-id }
      (merge lifeguard { active: active })
    )
    (ok true)
  )
)

(define-public (update-lifeguard-rating (lifeguard-id uint) (rating uint))
  (let
    (
      (lifeguard (unwrap! (map-get? lifeguards { lifeguard-id: lifeguard-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= rating u1) (<= rating u10)) ERR-INVALID-INPUT)

    (map-set lifeguards
      { lifeguard-id: lifeguard-id }
      (merge lifeguard { rating: rating })
    )
    (ok true)
  )
)

;; Shift Management Functions
(define-public (schedule-shift (lifeguard-id uint) (start-time uint) (end-time uint) (beach-section uint))
  (let
    (
      (shift-id (var-get next-shift-id))
      (lifeguard (unwrap! (map-get? lifeguards { lifeguard-id: lifeguard-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (get active lifeguard) ERR-INVALID-INPUT)
    (asserts! (> (get certification-expiry lifeguard) start-time) ERR-EXPIRED)
    (asserts! (> end-time start-time) ERR-INVALID-INPUT)
    (asserts! (> beach-section u0) ERR-INVALID-INPUT)

    (map-set shifts
      { shift-id: shift-id }
      {
        lifeguard-id: lifeguard-id,
        start-time: start-time,
        end-time: end-time,
        beach-section: beach-section,
        completed: false,
        notes: ""
      }
    )
    (var-set next-shift-id (+ shift-id u1))
    (ok shift-id)
  )
)

(define-public (complete-shift (shift-id uint) (notes (string-ascii 200)))
  (let
    (
      (shift (unwrap! (map-get? shifts { shift-id: shift-id }) ERR-NOT-FOUND))
      (lifeguard-id (get lifeguard-id shift))
      (lifeguard (unwrap! (map-get? lifeguards { lifeguard-id: lifeguard-id }) ERR-NOT-FOUND))
      (shift-hours (/ (- (get end-time shift) (get start-time shift)) u3600))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get completed shift)) ERR-INVALID-INPUT)

    ;; Update shift as completed
    (map-set shifts
      { shift-id: shift-id }
      (merge shift { completed: true, notes: notes })
    )

    ;; Update lifeguard total hours
    (map-set lifeguards
      { lifeguard-id: lifeguard-id }
      (merge lifeguard { total-hours: (+ (get total-hours lifeguard) shift-hours) })
    )

    (ok true)
  )
)

(define-public (set-availability (lifeguard-id uint) (date uint) (available bool))
  (begin
    (asserts! (is-some (map-get? lifeguards { lifeguard-id: lifeguard-id })) ERR-NOT-FOUND)
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)

    (map-set lifeguard-availability
      { lifeguard-id: lifeguard-id, date: date }
      { available: available }
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-lifeguard (lifeguard-id uint))
  (map-get? lifeguards { lifeguard-id: lifeguard-id })
)

(define-read-only (get-shift (shift-id uint))
  (map-get? shifts { shift-id: shift-id })
)

(define-read-only (get-availability (lifeguard-id uint) (date uint))
  (default-to { available: true } (map-get? lifeguard-availability { lifeguard-id: lifeguard-id, date: date }))
)

(define-read-only (get-emergency-status)
  (var-get emergency-mode)
)

(define-read-only (get-next-lifeguard-id)
  (var-get next-lifeguard-id)
)

(define-read-only (get-next-shift-id)
  (var-get next-shift-id)
)
