{-|
Copyright        : (c) Galois, Inc. 2025
Maintainer       : GREASE Maintainers <grease@galois.com>
-}

{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Grease.LLVM.SimulatorHooks.Diagnostic
  ( Diagnostic(..)
  , severity
  ) where

import Prettyprinter qualified as PP

import Grease.Diagnostic.Severity (Severity(Info))

data Diagnostic where
  SkippedSymbolicFnHandleCall :: Diagnostic

instance PP.Pretty Diagnostic where
  pretty d =
    case d of
      SkippedSymbolicFnHandleCall ->
        "Skipped call to a symbolic function handle"

severity :: Diagnostic -> Severity
severity =
  \case
    SkippedSymbolicFnHandleCall{} -> Info
