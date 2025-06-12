;; Production Manager Verification Contract
;; Manages verification and authorization of production managers

(define-map production-managers principal {
  name: (string-ascii 50),
  department: (string-ascii 30),
  verified: bool,
  verification-date: uint
})

(define-map manager-permissions principal {
  can-identify-waste: bool,
  can-optimize-flow: bool,
  can-manage-improvements: bool,
  can-measure-efficiency: bool
})

(define-data-var contract-owner principal tx-sender)

;; Register a new production manager
(define-public (register-manager (manager principal) (name (string-ascii 50)) (department (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (map-set production-managers manager {
      name: name,
      department: department,
      verified: false,
      verification-date: u0
    })
    (ok true)
  )
)

;; Verify a production manager
(define-public (verify-manager (manager principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (match (map-get? production-managers manager)
      manager-data (begin
        (map-set production-managers manager (merge manager-data {
          verified: true,
          verification-date: block-height
        }))
        (map-set manager-permissions manager {
          can-identify-waste: true,
          can-optimize-flow: true,
          can-manage-improvements: true,
          can-measure-efficiency: true
        })
        (ok true)
      )
      (err u101)
    )
  )
)

;; Check if manager is verified
(define-read-only (is-manager-verified (manager principal))
  (match (map-get? production-managers manager)
    manager-data (get verified manager-data)
    false
  )
)

;; Get manager info
(define-read-only (get-manager-info (manager principal))
  (map-get? production-managers manager)
)
