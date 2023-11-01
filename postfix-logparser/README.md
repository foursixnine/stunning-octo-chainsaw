## From journal to .json

In order to convert from your log to json, so it is easily parseable, [jq](https://jqlang.github.io/jq/) offers an option
that allows you to run a filter, only until the end of the file:

```text
    Instead of running the filter for each JSON object in the input, read the entire input stream into a large array and
    run the filter just once.
```

This allows you to save the file directly, ready to be processed by your next tools:

`journalctl -u postfix.service --since yesterday -g "denied" --output json | jq -s "." > data/log.json`
