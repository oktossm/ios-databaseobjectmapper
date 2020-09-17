// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoLenses
import Foundation
import DatabaseObjectsMapper

// swiftlint:disable line_length
infix operator *~: MultiplicationPrecedence
infix operator |>: AdditionPrecedence

//Lenses API
public struct Lens<Whole, Part> {
    public let get: (Whole) -> Part
    public let set: (Part, Whole) -> Whole
}

func * <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) },
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}

func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in lhs.set(rhs, a) }
}

func |> <A, B> (x: A, f: (A) -> B) -> B {
    return f(x)
}

func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

// Bound lenses API
public struct BoundLens<Whole, Part> {
    let instance: Whole
    let lens: Lens<Whole, Part>

    public func get() -> Part {
        return lens.get(instance)
    }
    public func set(_ newPart: Part) -> Whole {
        return lens.set(newPart, instance)
    }
}

internal extension TestCDModel {
  static let idLens = Lens<TestCDModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestCDModel(id: id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, subModel: _value.subModel)
    }
  )
  var idLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.idLens)
  }
  static let indexLens = Lens<TestCDModel, Int?>(
    get: { $0.index },
    set: { index, _value in
       TestCDModel(id: _value.id, index: index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, subModel: _value.subModel)
    }
  )
  var indexLens: BoundLens<TestCDModel, Int?> {
     return BoundLens<TestCDModel, Int?>(instance: self, lens: TestCDModel.indexLens)
  }
  static let nameLens = Lens<TestCDModel, String>(
    get: { $0.name },
    set: { name, _value in
       TestCDModel(id: _value.id, index: _value.index, name: name, count: _value.count, someCount: _value.someCount, urls: _value.urls, subModel: _value.subModel)
    }
  )
  var nameLens: BoundLens<TestCDModel, String> {
     return BoundLens<TestCDModel, String>(instance: self, lens: TestCDModel.nameLens)
  }
  static let countLens = Lens<TestCDModel, Int>(
    get: { $0.count },
    set: { count, _value in
       TestCDModel(id: _value.id, index: _value.index, name: _value.name, count: count, someCount: _value.someCount, urls: _value.urls, subModel: _value.subModel)
    }
  )
  var countLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.countLens)
  }
  static let someCountLens = Lens<TestCDModel, Int>(
    get: { $0.someCount },
    set: { someCount, _value in
       TestCDModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: someCount, urls: _value.urls, subModel: _value.subModel)
    }
  )
  var someCountLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.someCountLens)
  }
  static let urlsLens = Lens<TestCDModel, [URL]?>(
    get: { $0.urls },
    set: { urls, _value in
       TestCDModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: urls, subModel: _value.subModel)
    }
  )
  var urlsLens: BoundLens<TestCDModel, [URL]?> {
     return BoundLens<TestCDModel, [URL]?>(instance: self, lens: TestCDModel.urlsLens)
  }
  static let subModelLens = Lens<TestCDModel, Relation<TestSomeModel>>(
    get: { $0.subModel },
    set: { subModel, _value in
       TestCDModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, subModel: subModel)
    }
  )
  var subModelLens: BoundLens<TestCDModel, Relation<TestSomeModel>> {
     return BoundLens<TestCDModel, Relation<TestSomeModel>>(instance: self, lens: TestCDModel.subModelLens)
  }
}
internal extension TestCDSimpleModel {
  static let titleLens = Lens<TestCDSimpleModel, String>(
    get: { $0.title },
    set: { title, _value in
       TestCDSimpleModel(title: title, count: _value.count)
    }
  )
  var titleLens: BoundLens<TestCDSimpleModel, String> {
     return BoundLens<TestCDSimpleModel, String>(instance: self, lens: TestCDSimpleModel.titleLens)
  }
  static let countLens = Lens<TestCDSimpleModel, Int>(
    get: { $0.count },
    set: { count, _value in
       TestCDSimpleModel(title: _value.title, count: count)
    }
  )
  var countLens: BoundLens<TestCDSimpleModel, Int> {
     return BoundLens<TestCDSimpleModel, Int>(instance: self, lens: TestCDSimpleModel.countLens)
  }
}
internal extension TestCollectionsModel {
  static let idLens = Lens<TestCollectionsModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestCollectionsModel(id: id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var idLens: BoundLens<TestCollectionsModel, Int> {
     return BoundLens<TestCollectionsModel, Int>(instance: self, lens: TestCollectionsModel.idLens)
  }
  static let stringsLens = Lens<TestCollectionsModel, [String]>(
    get: { $0.strings },
    set: { strings, _value in
       TestCollectionsModel(id: _value.id, strings: strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var stringsLens: BoundLens<TestCollectionsModel, [String]> {
     return BoundLens<TestCollectionsModel, [String]>(instance: self, lens: TestCollectionsModel.stringsLens)
  }
  static let intValuesLens = Lens<TestCollectionsModel, [Int64?]?>(
    get: { $0.intValues },
    set: { intValues, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var intValuesLens: BoundLens<TestCollectionsModel, [Int64?]?> {
     return BoundLens<TestCollectionsModel, [Int64?]?>(instance: self, lens: TestCollectionsModel.intValuesLens)
  }
  static let doubleValuesLens = Lens<TestCollectionsModel, [Double]?>(
    get: { $0.doubleValues },
    set: { doubleValues, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var doubleValuesLens: BoundLens<TestCollectionsModel, [Double]?> {
     return BoundLens<TestCollectionsModel, [Double]?>(instance: self, lens: TestCollectionsModel.doubleValuesLens)
  }
  static let datesLens = Lens<TestCollectionsModel, [Date]?>(
    get: { $0.dates },
    set: { dates, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var datesLens: BoundLens<TestCollectionsModel, [Date]?> {
     return BoundLens<TestCollectionsModel, [Date]?>(instance: self, lens: TestCollectionsModel.datesLens)
  }
  static let codableLens = Lens<TestCollectionsModel, [SomeCodable]>(
    get: { $0.codable },
    set: { codable, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var codableLens: BoundLens<TestCollectionsModel, [SomeCodable]> {
     return BoundLens<TestCollectionsModel, [SomeCodable]>(instance: self, lens: TestCollectionsModel.codableLens)
  }
  static let urlsLens = Lens<TestCollectionsModel, Array<URL?>>(
    get: { $0.urls },
    set: { urls, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var urlsLens: BoundLens<TestCollectionsModel, Array<URL?>> {
     return BoundLens<TestCollectionsModel, Array<URL?>>(instance: self, lens: TestCollectionsModel.urlsLens)
  }
  static let dictLens = Lens<TestCollectionsModel, [Int: SomeCodable]>(
    get: { $0.dict },
    set: { dict, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var dictLens: BoundLens<TestCollectionsModel, [Int: SomeCodable]> {
     return BoundLens<TestCollectionsModel, [Int: SomeCodable]>(instance: self, lens: TestCollectionsModel.dictLens)
  }
  static let anotherDictLens = Lens<TestCollectionsModel, [SomeCodable: Int]>(
    get: { $0.anotherDict },
    set: { anotherDict, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var anotherDictLens: BoundLens<TestCollectionsModel, [SomeCodable: Int]> {
     return BoundLens<TestCollectionsModel, [SomeCodable: Int]>(instance: self, lens: TestCollectionsModel.anotherDictLens)
  }
  static let setLens = Lens<TestCollectionsModel, Set<URL?>>(
    get: { $0.set },
    set: { set, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: set, anotherSet: _value.anotherSet, someEnum: _value.someEnum)
    }
  )
  var setLens: BoundLens<TestCollectionsModel, Set<URL?>> {
     return BoundLens<TestCollectionsModel, Set<URL?>>(instance: self, lens: TestCollectionsModel.setLens)
  }
  static let anotherSetLens = Lens<TestCollectionsModel, Set<SomeCodable>?>(
    get: { $0.anotherSet },
    set: { anotherSet, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: anotherSet, someEnum: _value.someEnum)
    }
  )
  var anotherSetLens: BoundLens<TestCollectionsModel, Set<SomeCodable>?> {
     return BoundLens<TestCollectionsModel, Set<SomeCodable>?>(instance: self, lens: TestCollectionsModel.anotherSetLens)
  }
  static let someEnumLens = Lens<TestCollectionsModel, [SomeEnum]>(
    get: { $0.someEnum },
    set: { someEnum, _value in
       TestCollectionsModel(id: _value.id, strings: _value.strings, intValues: _value.intValues, doubleValues: _value.doubleValues, dates: _value.dates, codable: _value.codable, urls: _value.urls, dict: _value.dict, anotherDict: _value.anotherDict, set: _value.set, anotherSet: _value.anotherSet, someEnum: someEnum)
    }
  )
  var someEnumLens: BoundLens<TestCollectionsModel, [SomeEnum]> {
     return BoundLens<TestCollectionsModel, [SomeEnum]>(instance: self, lens: TestCollectionsModel.someEnumLens)
  }
}
internal extension TestDateModel {
  static let idLens = Lens<TestDateModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestDateModel(id: id, date: _value.date)
    }
  )
  var idLens: BoundLens<TestDateModel, Int> {
     return BoundLens<TestDateModel, Int>(instance: self, lens: TestDateModel.idLens)
  }
  static let dateLens = Lens<TestDateModel, Date>(
    get: { $0.date },
    set: { date, _value in
       TestDateModel(id: _value.id, date: date)
    }
  )
  var dateLens: BoundLens<TestDateModel, Date> {
     return BoundLens<TestDateModel, Date>(instance: self, lens: TestDateModel.dateLens)
  }
}
internal extension TestModel {
  static let idLens = Lens<TestModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestModel(id: id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, someModel: _value.someModel)
    }
  )
  var idLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.idLens)
  }
  static let indexLens = Lens<TestModel, Int?>(
    get: { $0.index },
    set: { index, _value in
       TestModel(id: _value.id, index: index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, someModel: _value.someModel)
    }
  )
  var indexLens: BoundLens<TestModel, Int?> {
     return BoundLens<TestModel, Int?>(instance: self, lens: TestModel.indexLens)
  }
  static let nameLens = Lens<TestModel, String>(
    get: { $0.name },
    set: { name, _value in
       TestModel(id: _value.id, index: _value.index, name: name, count: _value.count, someCount: _value.someCount, urls: _value.urls, someModel: _value.someModel)
    }
  )
  var nameLens: BoundLens<TestModel, String> {
     return BoundLens<TestModel, String>(instance: self, lens: TestModel.nameLens)
  }
  static let countLens = Lens<TestModel, Int>(
    get: { $0.count },
    set: { count, _value in
       TestModel(id: _value.id, index: _value.index, name: _value.name, count: count, someCount: _value.someCount, urls: _value.urls, someModel: _value.someModel)
    }
  )
  var countLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.countLens)
  }
  static let someCountLens = Lens<TestModel, Int>(
    get: { $0.someCount },
    set: { someCount, _value in
       TestModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: someCount, urls: _value.urls, someModel: _value.someModel)
    }
  )
  var someCountLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.someCountLens)
  }
  static let urlsLens = Lens<TestModel, [URL]?>(
    get: { $0.urls },
    set: { urls, _value in
       TestModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: urls, someModel: _value.someModel)
    }
  )
  var urlsLens: BoundLens<TestModel, [URL]?> {
     return BoundLens<TestModel, [URL]?>(instance: self, lens: TestModel.urlsLens)
  }
  static let someModelLens = Lens<TestModel, TestSomeModel?>(
    get: { $0.someModel },
    set: { someModel, _value in
       TestModel(id: _value.id, index: _value.index, name: _value.name, count: _value.count, someCount: _value.someCount, urls: _value.urls, someModel: someModel)
    }
  )
  var someModelLens: BoundLens<TestModel, TestSomeModel?> {
     return BoundLens<TestModel, TestSomeModel?>(instance: self, lens: TestModel.someModelLens)
  }
}
internal extension TestPrimitivesModel {
  static let idLens = Lens<TestPrimitivesModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestPrimitivesModel(id: id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var idLens: BoundLens<TestPrimitivesModel, Int> {
     return BoundLens<TestPrimitivesModel, Int>(instance: self, lens: TestPrimitivesModel.idLens)
  }
  static let valueLens = Lens<TestPrimitivesModel, Int32?>(
    get: { $0.value },
    set: { value, _value in
       TestPrimitivesModel(id: _value.id, value: value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var valueLens: BoundLens<TestPrimitivesModel, Int32?> {
     return BoundLens<TestPrimitivesModel, Int32?>(instance: self, lens: TestPrimitivesModel.valueLens)
  }
  static let doubleValueLens = Lens<TestPrimitivesModel, Double>(
    get: { $0.doubleValue },
    set: { doubleValue, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var doubleValueLens: BoundLens<TestPrimitivesModel, Double> {
     return BoundLens<TestPrimitivesModel, Double>(instance: self, lens: TestPrimitivesModel.doubleValueLens)
  }
  static let floatValueLens = Lens<TestPrimitivesModel, Float?>(
    get: { $0.floatValue },
    set: { floatValue, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var floatValueLens: BoundLens<TestPrimitivesModel, Float?> {
     return BoundLens<TestPrimitivesModel, Float?>(instance: self, lens: TestPrimitivesModel.floatValueLens)
  }
  static let boolValueLens = Lens<TestPrimitivesModel, Bool?>(
    get: { $0.boolValue },
    set: { boolValue, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var boolValueLens: BoundLens<TestPrimitivesModel, Bool?> {
     return BoundLens<TestPrimitivesModel, Bool?>(instance: self, lens: TestPrimitivesModel.boolValueLens)
  }
  static let urlValueLens = Lens<TestPrimitivesModel, URL?>(
    get: { $0.urlValue },
    set: { urlValue, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var urlValueLens: BoundLens<TestPrimitivesModel, URL?> {
     return BoundLens<TestPrimitivesModel, URL?>(instance: self, lens: TestPrimitivesModel.urlValueLens)
  }
  static let someEnumLens = Lens<TestPrimitivesModel, SomeEnum>(
    get: { $0.someEnum },
    set: { someEnum, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var someEnumLens: BoundLens<TestPrimitivesModel, SomeEnum> {
     return BoundLens<TestPrimitivesModel, SomeEnum>(instance: self, lens: TestPrimitivesModel.someEnumLens)
  }
  static let someEnumOptLens = Lens<TestPrimitivesModel, SomeEnum?>(
    get: { $0.someEnumOpt },
    set: { someEnumOpt, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var someEnumOptLens: BoundLens<TestPrimitivesModel, SomeEnum?> {
     return BoundLens<TestPrimitivesModel, SomeEnum?>(instance: self, lens: TestPrimitivesModel.someEnumOptLens)
  }
  static let stringEnumLens = Lens<TestPrimitivesModel, SomeStringEnum>(
    get: { $0.stringEnum },
    set: { stringEnum, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: stringEnum, stringEnumOpt: _value.stringEnumOpt)
    }
  )
  var stringEnumLens: BoundLens<TestPrimitivesModel, SomeStringEnum> {
     return BoundLens<TestPrimitivesModel, SomeStringEnum>(instance: self, lens: TestPrimitivesModel.stringEnumLens)
  }
  static let stringEnumOptLens = Lens<TestPrimitivesModel, SomeStringEnum?>(
    get: { $0.stringEnumOpt },
    set: { stringEnumOpt, _value in
       TestPrimitivesModel(id: _value.id, value: _value.value, doubleValue: _value.doubleValue, floatValue: _value.floatValue, boolValue: _value.boolValue, urlValue: _value.urlValue, someEnum: _value.someEnum, someEnumOpt: _value.someEnumOpt, stringEnum: _value.stringEnum, stringEnumOpt: stringEnumOpt)
    }
  )
  var stringEnumOptLens: BoundLens<TestPrimitivesModel, SomeStringEnum?> {
     return BoundLens<TestPrimitivesModel, SomeStringEnum?>(instance: self, lens: TestPrimitivesModel.stringEnumOptLens)
  }
}
internal extension TestRNModel {
  static let idLens = Lens<TestRNModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestRNModel(id: id, name: _value.name, owner: _value.owner)
    }
  )
  var idLens: BoundLens<TestRNModel, Int> {
     return BoundLens<TestRNModel, Int>(instance: self, lens: TestRNModel.idLens)
  }
  static let nameLens = Lens<TestRNModel, String>(
    get: { $0.name },
    set: { name, _value in
       TestRNModel(id: _value.id, name: name, owner: _value.owner)
    }
  )
  var nameLens: BoundLens<TestRNModel, String> {
     return BoundLens<TestRNModel, String>(instance: self, lens: TestRNModel.nameLens)
  }
  static let ownerLens = Lens<TestRNModel, TestSomeModel>(
    get: { $0.owner },
    set: { owner, _value in
       TestRNModel(id: _value.id, name: _value.name, owner: owner)
    }
  )
  var ownerLens: BoundLens<TestRNModel, TestSomeModel> {
     return BoundLens<TestRNModel, TestSomeModel>(instance: self, lens: TestRNModel.ownerLens)
  }
}
internal extension TestRRModel {
  static let idLens = Lens<TestRRModel, Int>(
    get: { $0.id },
    set: { id, _value in
       TestRRModel(id: id, name: _value.name, owner: _value.owner)
    }
  )
  var idLens: BoundLens<TestRRModel, Int> {
     return BoundLens<TestRRModel, Int>(instance: self, lens: TestRRModel.idLens)
  }
  static let nameLens = Lens<TestRRModel, String>(
    get: { $0.name },
    set: { name, _value in
       TestRRModel(id: _value.id, name: name, owner: _value.owner)
    }
  )
  var nameLens: BoundLens<TestRRModel, String> {
     return BoundLens<TestRRModel, String>(instance: self, lens: TestRRModel.nameLens)
  }
  static let ownerLens = Lens<TestRRModel, TestSomeModel?>(
    get: { $0.owner },
    set: { owner, _value in
       TestRRModel(id: _value.id, name: _value.name, owner: owner)
    }
  )
  var ownerLens: BoundLens<TestRRModel, TestSomeModel?> {
     return BoundLens<TestRRModel, TestSomeModel?>(instance: self, lens: TestRRModel.ownerLens)
  }
}
internal extension TestSimpleModel {
  static let titleLens = Lens<TestSimpleModel, String>(
    get: { $0.title },
    set: { title, _value in
       TestSimpleModel(title: title, count: _value.count)
    }
  )
  var titleLens: BoundLens<TestSimpleModel, String> {
     return BoundLens<TestSimpleModel, String>(instance: self, lens: TestSimpleModel.titleLens)
  }
  static let countLens = Lens<TestSimpleModel, Int>(
    get: { $0.count },
    set: { count, _value in
       TestSimpleModel(title: _value.title, count: count)
    }
  )
  var countLens: BoundLens<TestSimpleModel, Int> {
     return BoundLens<TestSimpleModel, Int>(instance: self, lens: TestSimpleModel.countLens)
  }
}
internal extension TestSomeModel {
  static let userIdLens = Lens<TestSomeModel, Int>(
    get: { $0.userId },
    set: { userId, _value in
       TestSomeModel(userId: userId, userName: _value.userName, userAvatar: _value.userAvatar, title: _value.title, count: _value.count, nestedModel: _value.nestedModel)
    }
  )
  var userIdLens: BoundLens<TestSomeModel, Int> {
     return BoundLens<TestSomeModel, Int>(instance: self, lens: TestSomeModel.userIdLens)
  }
  static let userNameLens = Lens<TestSomeModel, String>(
    get: { $0.userName },
    set: { userName, _value in
       TestSomeModel(userId: _value.userId, userName: userName, userAvatar: _value.userAvatar, title: _value.title, count: _value.count, nestedModel: _value.nestedModel)
    }
  )
  var userNameLens: BoundLens<TestSomeModel, String> {
     return BoundLens<TestSomeModel, String>(instance: self, lens: TestSomeModel.userNameLens)
  }
  static let userAvatarLens = Lens<TestSomeModel, String>(
    get: { $0.userAvatar },
    set: { userAvatar, _value in
       TestSomeModel(userId: _value.userId, userName: _value.userName, userAvatar: userAvatar, title: _value.title, count: _value.count, nestedModel: _value.nestedModel)
    }
  )
  var userAvatarLens: BoundLens<TestSomeModel, String> {
     return BoundLens<TestSomeModel, String>(instance: self, lens: TestSomeModel.userAvatarLens)
  }
  static let titleLens = Lens<TestSomeModel, String?>(
    get: { $0.title },
    set: { title, _value in
       TestSomeModel(userId: _value.userId, userName: _value.userName, userAvatar: _value.userAvatar, title: title, count: _value.count, nestedModel: _value.nestedModel)
    }
  )
  var titleLens: BoundLens<TestSomeModel, String?> {
     return BoundLens<TestSomeModel, String?>(instance: self, lens: TestSomeModel.titleLens)
  }
  static let countLens = Lens<TestSomeModel, Int>(
    get: { $0.count },
    set: { count, _value in
       TestSomeModel(userId: _value.userId, userName: _value.userName, userAvatar: _value.userAvatar, title: _value.title, count: count, nestedModel: _value.nestedModel)
    }
  )
  var countLens: BoundLens<TestSomeModel, Int> {
     return BoundLens<TestSomeModel, Int>(instance: self, lens: TestSomeModel.countLens)
  }
  static let nestedModelLens = Lens<TestSomeModel, TestNestedModel?>(
    get: { $0.nestedModel },
    set: { nestedModel, _value in
       TestSomeModel(userId: _value.userId, userName: _value.userName, userAvatar: _value.userAvatar, title: _value.title, count: _value.count, nestedModel: nestedModel)
    }
  )
  var nestedModelLens: BoundLens<TestSomeModel, TestNestedModel?> {
     return BoundLens<TestSomeModel, TestNestedModel?>(instance: self, lens: TestSomeModel.nestedModelLens)
  }
}
