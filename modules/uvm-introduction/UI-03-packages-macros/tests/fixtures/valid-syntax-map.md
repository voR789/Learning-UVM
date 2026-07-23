# Valid UI-03 Syntax Map Fixture

| Mechanism | What it does | What it does not do |
|---|---|---|
| Compile order | Defines packages before consumers | Does not import names |
| Package import | Makes compiled declarations visible | Does not compile files |
| Macro include | Inserts macro definitions textually | Does not register a class by itself |
| Object registration | Adds UVM type information and type_id | Does not construct an instance immediately |
| Construction request | Requests an instance through registered type machinery | Does not make source dependencies visible |

Import exposes declarations, while include textually exposes preprocessor macro definitions.
