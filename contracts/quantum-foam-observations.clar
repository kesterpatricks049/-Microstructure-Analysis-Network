;; Quantum Foam Observations Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var observation-counter uint u0)
(define-map quantum-foam-observations uint {
    observer: principal,
    timestamp: uint,
    location: (tuple (x int) (y int) (z int) (t int)),
    foam-density: uint,
    energy-fluctuation: uint,
    notes: (string-utf8 1000)
})

;; Public Functions
(define-public (record-observation (location (tuple (x int) (y int) (z int) (t int))) (foam-density uint) (energy-fluctuation uint) (notes (string-utf8 1000)))
    (let
        (
            (observation-id (+ (var-get observation-counter) u1))
        )
        (asserts! (and (>= foam-density u0) (<= foam-density u1000)) err-invalid-parameters)
        (asserts! (and (>= energy-fluctuation u0) (<= energy-fluctuation u1000)) err-invalid-parameters)
        (map-set quantum-foam-observations observation-id {
            observer: tx-sender,
            timestamp: block-height,
            location: location,
            foam-density: foam-density,
            energy-fluctuation: energy-fluctuation,
            notes: notes
        })
        (var-set observation-counter observation-id)
        (ok observation-id)
    )
)

(define-public (update-observation-notes (observation-id uint) (new-notes (string-utf8 1000)))
    (let
        (
            (observation (unwrap! (map-get? quantum-foam-observations observation-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get observer observation)) err-not-authorized)
        (map-set quantum-foam-observations observation-id
            (merge observation {
                notes: new-notes
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-observation (observation-id uint))
    (map-get? quantum-foam-observations observation-id)
)

(define-read-only (get-observation-count)
    (var-get observation-counter)
)
