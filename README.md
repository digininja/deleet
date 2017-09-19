# deleet
Take a word list and convert 1337 spellings back to normal

In an attempt to strip prefix and suffix, I'm looking for the first alpha character then taking alphas and numerics up till the last alpha in the string, this is the regex:

```
/^[^a-z]*([a-z0-9]*[a-z])[^a-z]*$/i
```

Some examples:

* Lond0n2012 becomes London
* 123s3cr3t becomes secret
* 1p455w0rd9 becomes password

This means I might miss some words so will try to work on this to tune it a bit better.
