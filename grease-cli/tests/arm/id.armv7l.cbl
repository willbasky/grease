; Copyright (c) Galois, Inc. 2024

;; flags {"--symbol", "test"}
;; go(prog)

(defun @test ((regs AArch32Regs)) AArch32Regs
  (start start:
    (return regs)))
;; ok()
