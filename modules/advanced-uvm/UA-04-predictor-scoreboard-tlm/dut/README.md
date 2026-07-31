# Transaction-level DUT stand-in

UA-04 focuses on TLM prediction and checking, not pin-level driving. The supplied
source emits observed commands and actual results. A fixture corrupts one actual
result to prove the checker rejects incorrect behavior.
