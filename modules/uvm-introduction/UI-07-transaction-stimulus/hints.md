# UI-07 Hints

1. Which side grants/sends a request, and which side must acknowledge it?
2. Pair `start_item` with `finish_item`; pair `get_next_item` with `item_done`.
3. The five TODOs are confined to sequence body, driver run phase, and agent connect phase.
4. Connect driver port to sequencer export; then implement the two handshake pairs.
5. Use the exact methods named in the reading without macros.
6. `start_item(req); finish_item(req); seq_item_port.get_next_item(req); seq_item_port.item_done();` and connect the specialized endpoints.
