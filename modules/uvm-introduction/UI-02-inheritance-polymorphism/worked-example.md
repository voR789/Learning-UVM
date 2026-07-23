# Worked example: replaceable transaction formatting

This example is separate from the response-checking lab.

```systemverilog
class formatter;
    virtual function string format(int value);
        return $sformatf("value=%0d", value);
    endfunction
endclass

class hex_formatter extends formatter;
    virtual function string format(int value);
        return $sformatf("value=0x%0h", value);
    endfunction
endclass

function void log_value(formatter selected, int value);
    $display("%s", selected.format(value));
endfunction
```

Trace the roles:

1. `formatter` defines the stable `format` contract.
2. `hex_formatter` inherits that contract and overrides its behavior.
3. `selected` is declared as a base-class handle.
4. The caller `log_value` knows nothing about `hex_formatter`.
5. When `selected` refers to a `hex_formatter`, the virtual call uses the hex
   override.

This is useful because the caller remains stable. A test can select a decimal,
hexadecimal, JSON, or compact formatter without adding a branch to `log_value`.

## Prediction

Assume `formatter f; hex_formatter h = new(); f = h;`. What text should
`f.format(26)` return, and would the answer change if the base `format` method
were not virtual?
