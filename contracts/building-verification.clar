;; Building Verification Contract
;; This contract validates commercial properties

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Data map to store verified buildings
(define-map verified-buildings principal
  {
    building-id: (string-utf8 36),
    name: (string-utf8 100),
    address: (string-utf8 100),
    verified: bool,
    verification-date: uint
  }
)

;; Function to verify a building
(define-public (verify-building
    (building-id (string-utf8 36))
    (name (string-utf8 100))
    (address (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (map-set verified-buildings tx-sender
      {
        building-id: building-id,
        name: name,
        address: address,
        verified: true,
        verification-date: block-height
      }))
  )
)

;; Function to revoke a building's verification
(define-public (revoke-verification (building-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-some (map-get? verified-buildings building-owner)) (err u404))
    (let ((building (unwrap-panic (map-get? verified-buildings building-owner))))
      (ok (map-set verified-buildings building-owner
        (merge building { verified: false })))
    )
  )
)

;; Function to check if a building is verified
(define-read-only (is-building-verified (building-owner principal))
  (if (is-some (map-get? verified-buildings building-owner))
    (get verified (unwrap-panic (map-get? verified-buildings building-owner)))
    false
  )
)

;; Function to get building details
(define-read-only (get-building-details (building-owner principal))
  (map-get? verified-buildings building-owner)
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)
