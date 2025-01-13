;; Spacetime Curvature Experiments Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var experiment-counter uint u0)
(define-map curvature-experiments uint {
    experimenter: principal,
    timestamp: uint,
    location: (tuple (x int) (y int) (z int) (t int)),
    curvature-magnitude: uint,
    applied-energy: uint,
    results: (string-utf8 1000)
})

;; Public Functions
(define-public (conduct-experiment (location (tuple (x int) (y int) (z int) (t int))) (curvature-magnitude uint) (applied-energy uint) (results (string-utf8 1000)))
    (let
        (
            (experiment-id (+ (var-get experiment-counter) u1))
        )
        (asserts! (and (>= curvature-magnitude u0) (<= curvature-magnitude u1000)) err-invalid-parameters)
        (asserts! (> applied-energy u0) err-invalid-parameters)
        (map-set curvature-experiments experiment-id {
            experimenter: tx-sender,
            timestamp: block-height,
            location: location,
            curvature-magnitude: curvature-magnitude,
            applied-energy: applied-energy,
            results: results
        })
        (var-set experiment-counter experiment-id)
        (ok experiment-id)
    )
)

(define-public (update-experiment-results (experiment-id uint) (new-results (string-utf8 1000)))
    (let
        (
            (experiment (unwrap! (map-get? curvature-experiments experiment-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get experimenter experiment)) err-not-authorized)
        (map-set curvature-experiments experiment-id
            (merge experiment {
                results: new-results
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-experiment (experiment-id uint))
    (map-get? curvature-experiments experiment-id)
)

(define-read-only (get-experiment-count)
    (var-get experiment-counter)
)
