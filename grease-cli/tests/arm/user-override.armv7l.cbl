; Copyright (c) Galois, Inc. 2024

;; flags {"--symbol", "test"}
;; flags {"--overrides", "tests/arm/extra/id-ptr.armv7l.cbl"}
;; go(prog)

(declare @id-ptr ((p (Ptr 32))) (Ptr 32))
(defun @test ((regs AArch32Regs)) AArch32Regs
  (start start:
    (let p (get-reg r0 regs))
    (let p2 (funcall @id-ptr p))
    (let regs2 (set-reg r0 p2 regs))
    (return regs2)))
;; ok()
