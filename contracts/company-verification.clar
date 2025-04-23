;; Company Verification Contract
;; This contract confirms legitimate business partners for internships

(define-data-var admin principal tx-sender)

;; Map to store verified companies
(define-map verified-companies principal
  {
    company-name: (string-utf8 64),
    industry: (string-utf8 32),
    registration-id: (string-utf8 32),
    verification-date: uint,
    is-active: bool
  }
)

;; Public function to verify a company
(define-public (verify-company
    (company principal)
    (company-name (string-utf8 64))
    (industry (string-utf8 32))
    (registration-id (string-utf8 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-companies company
      {
        company-name: company-name,
        industry: industry,
        registration-id: registration-id,
        verification-date: block-height,
        is-active: true
      }
    ))
  )
)

;; Public function to deactivate a company
(define-public (deactivate-company (company principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (map-get? verified-companies company)) (err u101))
    (let ((company-data (unwrap-panic (map-get? verified-companies company))))
      (ok (map-set verified-companies company
        (merge company-data { is-active: false })
      ))
    )
  )
)

;; Read-only function to check if a company is verified
(define-read-only (is-verified-company (company principal))
  (match (map-get? verified-companies company)
    company-data (and (get is-active company-data) true)
    false
  )
)

;; Read-only function to get company details
(define-read-only (get-company-details (company principal))
  (map-get? verified-companies company)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
