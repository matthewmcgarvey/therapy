# Notes

## 01-06-2023

I don't understand how in the kotlin library, you can go from
`Parser<String?, String?, Nothing>` to `Parser<String?, String?, String>`.
I don't think it's possible to do in Crystal. it seems more like a failure of the
Kotlin type system than a feature. In crystal, you'd have to make the new parser have
an error type of the union of the new and old types.

As long as all methods have handling for failure, the only place that can't fail is
the beginning method `from_nilable_string` since it is just passing through whatever
it receives. I think I will make a Failable and Non-Failable version so that I don't
have to try to copy what looks like broken Kotlin.

## 01-03-2023

Finding inspiration in https://github.com/sksamuel/tribune

I originally considered going with Rust's style of request parsing,
but their community is centered around Serde which is agnostic serialization/deserialization.
Crystal doesn't have that so the API would be unnatural especially when it comes to 
things like JSON parsing.

I'll think I'll just go back to the parsing/validation of individual fields and then
adding in composability like I originally was trying to do.