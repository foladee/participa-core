;; ============================================================
;; Contract: participa-core.clar
;; Purpose : Proof-of-Participation reward engine
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER          (err u40001))
(define-constant ERR-NOT-REPORTER       (err u40002))
(define-constant ERR-NO-REWARDS         (err u40003))
(define-constant ERR-INSUFFICIENT-FUND  (err u40004))

;; -------------------------
;; CONSTANTS
;; -------------------------
(define-constant REWARD-RATE u1000)
;; 1000 participation points = 1 STX reward unit

(define-constant contract-owner (as-contract tx-sender))
;; Contract owner is set at deployment time

;; -------------------------
;; STORAGE
;; -------------------------

;; Authorized participation reporters
(define-map reporters
  principal
  bool
)

;; User participation tracking
(define-map participation
  principal
  {
    points: uint,
    claimed: uint
  }
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender contract-owner)
)

(define-read-only (is-reporter? (who principal))
  (default-to false (map-get? reporters who))
)

(define-read-only (get-points (user principal))
  (default-to { points: u0, claimed: u0 }
              (map-get? participation user))
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (add-reporter (r principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (asserts! (not (is-eq r (as-contract tx-sender))) ERR-NOT-OWNER)
    (map-set reporters r true)
    (ok true)
  )
)

(define-public (remove-reporter (r principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (asserts! (not (is-eq r (as-contract tx-sender))) ERR-NOT-OWNER)
    (map-delete reporters r)
    (ok true)
  )
)

;; -------------------------
;; PARTICIPATION LOGIC
;; -------------------------

(define-public (report-participation
  (user principal)
  (amount uint)
)
  (begin
    (asserts! (is-reporter? tx-sender) ERR-NOT-REPORTER)
    (asserts! (> amount u0) ERR-NO-REWARDS)
    (let ((user-check (unwrap! (some user) ERR-NOT-REPORTER)))
      (let ((current (get-points user-check)))
        (map-set participation user-check
          {
            points: (+ (get points current) amount),
            claimed: (get claimed current)
          }
        )
      )
    )

    (ok true)
  )
)

;; -------------------------
;; REWARD CLAIMING
;; -------------------------

(define-public (claim-reward)
  (let ((data (get-points tx-sender)))
    (let (
      (total-points (get points data))
      (already-claimed (get claimed data))
      (eligible (/ total-points REWARD-RATE))
    )
      (asserts! (> eligible already-claimed) ERR-NO-REWARDS)

      (let ((reward (- eligible already-claimed)))
        (map-set participation tx-sender
          {
            points: total-points,
            claimed: eligible
          }
        )

        (try! (stx-transfer? reward contract-owner tx-sender))
        (ok reward)
      )
    )
  )
)
