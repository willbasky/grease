; Copyright (c) Galois, Inc. 2024

;; flags {"--symbol", "test"}
;; flags {"--overrides", "tests/ppc32/extra/id-ptr.ppc32.cbl"}
;; go(prog)

(declare @id-ptr ((p (Ptr 32))) (Ptr 32))
(defun @test ((regs PPC32Regs)) PPC32Regs
  (start start:
    (let p (get-reg r4 regs))
    (let p2 (funcall @id-ptr p))
    (let regs2 (set-reg r4 p2 regs))
    (return regs2)))
;; ok()
