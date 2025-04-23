;; Student Verification Contract
;; This contract validates enrolled learners in the educational system

(define-data-var admin principal tx-sender)

;; Map to store verified students
(define-map verified-students principal
  {
    student-id: (string-utf8 32),
    institution: (string-utf8 64),
    enrollment-date: uint,
    graduation-date: uint,
    is-active: bool
  }
)

;; Public function to verify a student
(define-public (verify-student
    (student principal)
    (student-id (string-utf8 32))
    (institution (string-utf8 64))
    (enrollment-date uint)
    (graduation-date uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-students student
      {
        student-id: student-id,
        institution: institution,
        enrollment-date: enrollment-date,
        graduation-date: graduation-date,
        is-active: true
      }
    ))
  )
)

;; Public function to deactivate a student
(define-public (deactivate-student (student principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (map-get? verified-students student)) (err u101))
    (let ((student-data (unwrap-panic (map-get? verified-students student))))
      (ok (map-set verified-students student
        (merge student-data { is-active: false })
      ))
    )
  )
)

;; Read-only function to check if a student is verified
(define-read-only (is-verified-student (student principal))
  (match (map-get? verified-students student)
    student-data (and (get is-active student-data) true)
    false
  )
)

;; Read-only function to get student details
(define-read-only (get-student-details (student principal))
  (map-get? verified-students student)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
