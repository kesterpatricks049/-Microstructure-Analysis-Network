;; Microscopic Wormhole Creation Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var wormhole-counter uint u0)
(define-map microscopic-wormholes uint {
    creator: principal,
    timestamp: uint,
    start-location: (tuple (x int) (y int) (z int) (t int)),
    end-location: (tuple (x int) (y int) (z int) (t int)),
    diameter: uint,
    stability: uint,
    energy-used: uint,
    notes: (string-utf8 1000)
})

;; Public Functions
(define-public (create-wormhole
    (start-location (tuple (x int) (y int) (z int) (t int)))
    (end-location (tuple (x int) (y int) (z int) (t int)))
    (diameter uint)
    (stability uint)
    (energy-used uint)
    (notes (string-utf8 1000)))
    (let
        (
            (wormhole-id (+ (var-get wormhole-counter) u1))
        )
        (asserts! (> diameter u0) err-invalid-parameters)
        (asserts! (and (>= stability u0) (<= stability u100)) err-invalid-parameters)
        (asserts! (> energy-used u0) err-invalid-parameters)
        (map-set microscopic-wormholes wormhole-id {
            creator: tx-sender,
            timestamp: block-height,
            start-location: start-location,
            end-location: end-location,
            diameter: diameter,
            stability: stability,
            energy-used: energy-used,
            notes: notes
        })
        (var-set wormhole-counter wormhole-id)
        (ok wormhole-id)
    )
)

(define-public (update-wormhole-stability (wormhole-id uint) (new-stability uint))
    (let
        (
            (wormhole (unwrap! (map-get? microscopic-wormholes wormhole-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator wormhole)) err-not-authorized)
        (asserts! (and (>= new-stability u0) (<= new-stability u100)) err-invalid-parameters)
        (map-set microscopic-wormholes wormhole-id
            (merge wormhole {
                stability: new-stability
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-wormhole (wormhole-id uint))
    (map-get? microscopic-wormholes wormhole-id)
)

(define-read-only (get-wormhole-count)
    (var-get wormhole-counter)
)
