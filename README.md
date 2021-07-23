[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
![Build Status](https://github.com/starke0o/custom-type-conversion-coder/actions/workflows/tests.yml/badge.svg)

# Why?

Some APIs are not so accurate with the data types. So it can happen that, for example, all Int values in a json response are provided as text.

If you want to decode such a json with the JSONDecoder, you have to implement an extra decoding for each model, because the JSONDecoder does not offer the possibility to override the decoding of single types like Int.

With this framework, it is no longer necessary.

# Installation
### Swift Package

Open `Package.swift` and add the package to your project's dependencies:

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/starke0o/custom-type-conversion-coder.git", from: "1.0.0")
    ]
)
```

# How to

## Wrap your decoder

```swift
let jsonDecoder = JSONDecoder()
let decoder = CustomTypeConversionDecoder(decoder: jsonDecoder)
```

## Define custom decoding(s)

Use `valueDecodingStrategy(for:customDecoding:)` to define your own decoding strategy. The strategy is applied to all values with the same types. 

```swift
// Decoding strategy for int values
decoder.valueDecodingStrategy(for: Int.self, customDecoding: { decoder in
    let container = try decoder.singleValueContainer()
    
    let stringValue = try container.decode(String.self)
    
    guard let int = Int(stringValue) else {
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to a String value containing a number"))
    }
    
    return int
})
```

`customDecoding` is comparable to the decoding constructor `init(from decoder: Decoder) throws`.

## Use the custom type conversion decoder

The CustomTypeConversionDecoder can be used like a normal JSONDecoder.

```swift
decoder.decode(Model.self, from: data)
```

# Some examples

## Trim string values

```swift
decoder.valueDecodingStrategy(for: String.self, customDecoding: { decoder in
    let container = try decoder.singleValueContainer()
    
    return try container.decode(String.self)
        .trimmingCharacters(in: .whitespacesAndNewlines)
})
```

## Bool from 0 or 1

```swift
decoder.valueDecodingStrategy(for: String.self, customDecoding: { decoder in
    let container = try decoder.singleValueContainer()
    let intValue = return int != 0

    return int != 0
})
```

# License

CustomTypeConversionCoder is released under an MIT license. See LICENCE for more information.
