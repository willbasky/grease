; Copyright (c) Galois, Inc. 2024

;; flags {"--symbol", "test"}
;; go(prog)

(defun @test ((regs X86Regs)) X86Regs
  (start start:
    (let p (get-field 5 regs))  ;; rsp, stack pointer
    (let off (bv 64 0x100000))
    (let q (pointer-add p off))
    (let b (bv 64 42))
;; next_line_must_fail()
    (pointer-write (Bitvector 64) le q b)
    (return regs)))
