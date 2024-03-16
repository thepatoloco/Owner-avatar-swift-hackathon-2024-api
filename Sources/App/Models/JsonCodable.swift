import Foundation

func decode(fromObject container: KeyedDecodingContainer<JSONCodingKeys>) -> [String: Any] {
  var result: [String: Any] = [:]

  for key in container.allKeys {
    if let val = try? container.decode(Int.self, forKey: key) {
      result[key.stringValue] = val
    } else if let val = try? container.decode(Double.self, forKey: key) {
      result[key.stringValue] = val
    } else if let val = try? container.decode(String.self, forKey: key) {
      result[key.stringValue] = val
    } else if let val = try? container.decode(Bool.self, forKey: key) {
      result[key.stringValue] = val
    } else if let nestedContainer = try? container.nestedContainer(
      keyedBy: JSONCodingKeys.self, forKey: key)
    {
      result[key.stringValue] = decode(fromObject: nestedContainer)
    } else if var nestedArray = try? container.nestedUnkeyedContainer(forKey: key) {
      result[key.stringValue] = decode(fromArray: &nestedArray)
    } else if (try? container.decodeNil(forKey: key)) == true {
      result.updateValue(Any?(nil) as Any, forKey: key.stringValue)
    }
  }

  return result
}

func decode(fromArray container: inout UnkeyedDecodingContainer) -> [Any] {
  var result: [Any] = []

  while !container.isAtEnd {
    if let value = try? container.decode(String.self) {
      result.append(value)
    } else if let value = try? container.decode(Int.self) {
      result.append(value)
    } else if let value = try? container.decode(Double.self) {
      result.append(value)
    } else if let value = try? container.decode(Bool.self) {
      result.append(value)
    } else if let nestedContainer = try? container.nestedContainer(keyedBy: JSONCodingKeys.self) {
      result.append(decode(fromObject: nestedContainer))
    } else if var nestedArray = try? container.nestedUnkeyedContainer() {
      result.append(decode(fromArray: &nestedArray))
    } else if (try? container.decodeNil()) == true {
      result.append(Any?(nil) as Any)
    }
  }

  return result
}

func encodeValue(fromArrayContainer container: inout UnkeyedEncodingContainer, arr: [Any]) throws {
  for value in arr {
    if let value = value as? String {
      try container.encode(value)
    } else if let value = value as? Int {
      try container.encode(value)
    } else if let value = value as? Double {
      try container.encode(value)
    } else if let value = value as? Bool {
      try container.encode(value)
    } else if let value = value as? [String: JSON] {
        try container.encode(value)
    } else if let value = value as? [Any] {
      var unkeyedContainer = container.nestedUnkeyedContainer()
      try encodeValue(fromArrayContainer: &unkeyedContainer, arr: value)
    } else {
      try container.encodeNil()
    }
  }
}



struct JSONCodingKeys: CodingKey {
  var stringValue: String
    
  init(stringValue: String) {
    self.stringValue = stringValue
  }
    
  var intValue: Int?
    
  init?(intValue: Int) {
    self.init(stringValue: "\(intValue)")
    self.intValue = intValue
  }
}

struct JSON: Codable {
  var value: Any?

  init(value: Any?) {
    self.value = value
  }
  init(from decoder: Decoder) throws {
    if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
      self.value = decode(fromObject: container)
    } else if var array = try? decoder.unkeyedContainer() {
      self.value = decode(fromArray: &array)
    } else if let value = try? decoder.singleValueContainer() {
      if value.decodeNil() {
        self.value = nil
      } else {
        if let result = try? value.decode(Int.self) { self.value = result }
        if let result = try? value.decode(Double.self) { self.value = result }
        if let result = try? value.decode(String.self) { self.value = result }
        if let result = try? value.decode(Bool.self) { self.value = result }
      }
    }
  }

  func encode(to encoder: Encoder) throws {
      if let arr = self.value as? [Any] {
          var container = encoder.unkeyedContainer()
          try encodeValue(fromArrayContainer: &container, arr: arr)
      } else {
          var container = encoder.singleValueContainer()

          if let value = self.value as? String {
              try! container.encode(value)
          } else if let value = self.value as? Int {
              try! container.encode(value)
          } else if let value = self.value as? Double {
              try! container.encode(value)
          } else if let value = self.value as? Bool {
              try! container.encode(value)
          } else if let value = self.value as? [String: JSON] {
              try! container.encode(value)
          } else {
              try! container.encodeNil()
          }
      }
  }
}
