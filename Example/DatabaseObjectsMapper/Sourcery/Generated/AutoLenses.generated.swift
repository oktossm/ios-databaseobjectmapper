// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// MARK: - AutoLenses
import Foundation
import DatabaseObjectsMapper

// swiftlint:disable line_length
infix operator *~: MultiplicationPrecedence
infix operator |>: AdditionPrecedence

//Lenses API
struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
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
struct BoundLens<Whole, Part> {
    let instance: Whole
    let lens: Lens<Whole, Part>

    func get() -> Part {
        return lens.get(instance)
    }
    func set(_ newPart: Part) -> Whole {
        return lens.set(newPart, instance)
    }
}

extension TestCDModel {
  static let idLens = Lens<TestCDModel, Int>(
    get: { $0.id },
    set: { id, testCDModel in
       TestCDModel(id: id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: testCDModel.subModel)
    }
  )
  var idLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.idLens)
  }
  static let indexLens = Lens<TestCDModel, Int?>(
    get: { $0.index },
    set: { index, testCDModel in
       TestCDModel(id: testCDModel.id, index: index, name: testCDModel.name, count: testCDModel.count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: testCDModel.subModel)
    }
  )
  var indexLens: BoundLens<TestCDModel, Int?> {
     return BoundLens<TestCDModel, Int?>(instance: self, lens: TestCDModel.indexLens)
  }
  static let nameLens = Lens<TestCDModel, String>(
    get: { $0.name },
    set: { name, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: name, count: testCDModel.count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: testCDModel.subModel)
    }
  )
  var nameLens: BoundLens<TestCDModel, String> {
     return BoundLens<TestCDModel, String>(instance: self, lens: TestCDModel.nameLens)
  }
  static let countLens = Lens<TestCDModel, Int>(
    get: { $0.count },
    set: { count, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: testCDModel.subModel)
    }
  )
  var countLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.countLens)
  }
  static let someCountLens = Lens<TestCDModel, Int>(
    get: { $0.someCount },
    set: { someCount, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, someCount: someCount, urls: testCDModel.urls, subModel: testCDModel.subModel)
    }
  )
  var someCountLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.someCountLens)
  }
  static let urlsLens = Lens<TestCDModel, [URL]?>(
    get: { $0.urls },
    set: { urls, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, someCount: testCDModel.someCount, urls: urls, subModel: testCDModel.subModel)
    }
  )
  var urlsLens: BoundLens<TestCDModel, [URL]?> {
     return BoundLens<TestCDModel, [URL]?>(instance: self, lens: TestCDModel.urlsLens)
  }
  static let subModelLens = Lens<TestCDModel, Relation<TestSomeModel>>(
    get: { $0.subModel },
    set: { subModel, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: subModel)
    }
  )
  var subModelLens: BoundLens<TestCDModel, Relation<TestSomeModel>> {
     return BoundLens<TestCDModel, Relation<TestSomeModel>>(instance: self, lens: TestCDModel.subModelLens)
  }
}
extension TestCDSimpleModel {
  static let titleLens = Lens<TestCDSimpleModel, String>(
    get: { $0.title },
    set: { title, testCDSimpleModel in
       TestCDSimpleModel(title: title, count: testCDSimpleModel.count)
    }
  )
  var titleLens: BoundLens<TestCDSimpleModel, String> {
     return BoundLens<TestCDSimpleModel, String>(instance: self, lens: TestCDSimpleModel.titleLens)
  }
  static let countLens = Lens<TestCDSimpleModel, Int>(
    get: { $0.count },
    set: { count, testCDSimpleModel in
       TestCDSimpleModel(title: testCDSimpleModel.title, count: count)
    }
  )
  var countLens: BoundLens<TestCDSimpleModel, Int> {
     return BoundLens<TestCDSimpleModel, Int>(instance: self, lens: TestCDSimpleModel.countLens)
  }
}
extension TestCollectionsModel {
  static let idLens = Lens<TestCollectionsModel, Int>(
    get: { $0.id },
    set: { id, testCollectionsModel in
       TestCollectionsModel(id: id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var idLens: BoundLens<TestCollectionsModel, Int> {
     return BoundLens<TestCollectionsModel, Int>(instance: self, lens: TestCollectionsModel.idLens)
  }
  static let stringsLens = Lens<TestCollectionsModel, [String]>(
    get: { $0.strings },
    set: { strings, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var stringsLens: BoundLens<TestCollectionsModel, [String]> {
     return BoundLens<TestCollectionsModel, [String]>(instance: self, lens: TestCollectionsModel.stringsLens)
  }
  static let intValuesLens = Lens<TestCollectionsModel, [Int64?]>(
    get: { $0.intValues },
    set: { intValues, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var intValuesLens: BoundLens<TestCollectionsModel, [Int64?]> {
     return BoundLens<TestCollectionsModel, [Int64?]>(instance: self, lens: TestCollectionsModel.intValuesLens)
  }
  static let doubleValuesLens = Lens<TestCollectionsModel, [Double]?>(
    get: { $0.doubleValues },
    set: { doubleValues, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var doubleValuesLens: BoundLens<TestCollectionsModel, [Double]?> {
     return BoundLens<TestCollectionsModel, [Double]?>(instance: self, lens: TestCollectionsModel.doubleValuesLens)
  }
  static let datesLens = Lens<TestCollectionsModel, [Date]?>(
    get: { $0.dates },
    set: { dates, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var datesLens: BoundLens<TestCollectionsModel, [Date]?> {
     return BoundLens<TestCollectionsModel, [Date]?>(instance: self, lens: TestCollectionsModel.datesLens)
  }
  static let codableLens = Lens<TestCollectionsModel, [SomeCodable]>(
    get: { $0.codable },
    set: { codable, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var codableLens: BoundLens<TestCollectionsModel, [SomeCodable]> {
     return BoundLens<TestCollectionsModel, [SomeCodable]>(instance: self, lens: TestCollectionsModel.codableLens)
  }
  static let persistableLens = Lens<TestCollectionsModel, [SomePersistable]>(
    get: { $0.persistable },
    set: { persistable, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var persistableLens: BoundLens<TestCollectionsModel, [SomePersistable]> {
     return BoundLens<TestCollectionsModel, [SomePersistable]>(instance: self, lens: TestCollectionsModel.persistableLens)
  }
  static let urlsLens = Lens<TestCollectionsModel, Array<URL>>(
    get: { $0.urls },
    set: { urls, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var urlsLens: BoundLens<TestCollectionsModel, Array<URL>> {
     return BoundLens<TestCollectionsModel, Array<URL>>(instance: self, lens: TestCollectionsModel.urlsLens)
  }
  static let dictLens = Lens<TestCollectionsModel, [String: SomePersistable]>(
    get: { $0.dict },
    set: { dict, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var dictLens: BoundLens<TestCollectionsModel, [String: SomePersistable]> {
     return BoundLens<TestCollectionsModel, [String: SomePersistable]>(instance: self, lens: TestCollectionsModel.dictLens)
  }
  static let anotherDictLens = Lens<TestCollectionsModel, [SomeCodable: SomeStringEnum]>(
    get: { $0.anotherDict },
    set: { anotherDict, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var anotherDictLens: BoundLens<TestCollectionsModel, [SomeCodable: SomeStringEnum]> {
     return BoundLens<TestCollectionsModel, [SomeCodable: SomeStringEnum]>(instance: self, lens: TestCollectionsModel.anotherDictLens)
  }
  static let setLens = Lens<TestCollectionsModel, Set<URL>>(
    get: { $0.set },
    set: { set, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var setLens: BoundLens<TestCollectionsModel, Set<URL>> {
     return BoundLens<TestCollectionsModel, Set<URL>>(instance: self, lens: TestCollectionsModel.setLens)
  }
  static let anotherSetLens = Lens<TestCollectionsModel, Set<SomeCodable?>>(
    get: { $0.anotherSet },
    set: { anotherSet, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var anotherSetLens: BoundLens<TestCollectionsModel, Set<SomeCodable?>> {
     return BoundLens<TestCollectionsModel, Set<SomeCodable?>>(instance: self, lens: TestCollectionsModel.anotherSetLens)
  }
  static let someEnumLens = Lens<TestCollectionsModel, [SomeEnum]>(
    get: { $0.someEnum },
    set: { someEnum, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: someEnum, someList: testCollectionsModel.someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var someEnumLens: BoundLens<TestCollectionsModel, [SomeEnum]> {
     return BoundLens<TestCollectionsModel, [SomeEnum]>(instance: self, lens: TestCollectionsModel.someEnumLens)
  }
  static let someListLens = Lens<TestCollectionsModel, [String]>(
    get: { $0.someList },
    set: { someList, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: someList, codableEnums: testCollectionsModel.codableEnums)
    }
  )
  var someListLens: BoundLens<TestCollectionsModel, [String]> {
     return BoundLens<TestCollectionsModel, [String]>(instance: self, lens: TestCollectionsModel.someListLens)
  }
  static let codableEnumsLens = Lens<TestCollectionsModel, [Link]>(
    get: { $0.codableEnums },
    set: { codableEnums, testCollectionsModel in
       TestCollectionsModel(id: testCollectionsModel.id, strings: testCollectionsModel.strings, intValues: testCollectionsModel.intValues, doubleValues: testCollectionsModel.doubleValues, dates: testCollectionsModel.dates, codable: testCollectionsModel.codable, persistable: testCollectionsModel.persistable, urls: testCollectionsModel.urls, dict: testCollectionsModel.dict, anotherDict: testCollectionsModel.anotherDict, set: testCollectionsModel.set, anotherSet: testCollectionsModel.anotherSet, someEnum: testCollectionsModel.someEnum, someList: testCollectionsModel.someList, codableEnums: codableEnums)
    }
  )
  var codableEnumsLens: BoundLens<TestCollectionsModel, [Link]> {
     return BoundLens<TestCollectionsModel, [Link]>(instance: self, lens: TestCollectionsModel.codableEnumsLens)
  }
}
extension TestDateModel {
  static let idLens = Lens<TestDateModel, Int>(
    get: { $0.id },
    set: { id, testDateModel in
       TestDateModel(id: id, date: testDateModel.date)
    }
  )
  var idLens: BoundLens<TestDateModel, Int> {
     return BoundLens<TestDateModel, Int>(instance: self, lens: TestDateModel.idLens)
  }
  static let dateLens = Lens<TestDateModel, Date>(
    get: { $0.date },
    set: { date, testDateModel in
       TestDateModel(id: testDateModel.id, date: date)
    }
  )
  var dateLens: BoundLens<TestDateModel, Date> {
     return BoundLens<TestDateModel, Date>(instance: self, lens: TestDateModel.dateLens)
  }
}
extension TestERRModel {
  static let nameLens = Lens<TestERRModel, String>(
    get: { $0.name },
    set: { name, testERRModel in
       TestERRModel(name: name, someCount: testERRModel.someCount, url: testERRModel.url)
    }
  )
  var nameLens: BoundLens<TestERRModel, String> {
     return BoundLens<TestERRModel, String>(instance: self, lens: TestERRModel.nameLens)
  }
  static let someCountLens = Lens<TestERRModel, Int>(
    get: { $0.someCount },
    set: { someCount, testERRModel in
       TestERRModel(name: testERRModel.name, someCount: someCount, url: testERRModel.url)
    }
  )
  var someCountLens: BoundLens<TestERRModel, Int> {
     return BoundLens<TestERRModel, Int>(instance: self, lens: TestERRModel.someCountLens)
  }
  static let urlLens = Lens<TestERRModel, URL?>(
    get: { $0.url },
    set: { url, testERRModel in
       TestERRModel(name: testERRModel.name, someCount: testERRModel.someCount, url: url)
    }
  )
  var urlLens: BoundLens<TestERRModel, URL?> {
     return BoundLens<TestERRModel, URL?>(instance: self, lens: TestERRModel.urlLens)
  }
}
extension TestModel {
  static let idLens = Lens<TestModel, Int>(
    get: { $0.id },
    set: { id, testModel in
       TestModel(id: id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, someModel: testModel.someModel)
    }
  )
  var idLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.idLens)
  }
  static let indexLens = Lens<TestModel, Int?>(
    get: { $0.index },
    set: { index, testModel in
       TestModel(id: testModel.id, index: index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, someModel: testModel.someModel)
    }
  )
  var indexLens: BoundLens<TestModel, Int?> {
     return BoundLens<TestModel, Int?>(instance: self, lens: TestModel.indexLens)
  }
  static let nameLens = Lens<TestModel, String>(
    get: { $0.name },
    set: { name, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, someModel: testModel.someModel)
    }
  )
  var nameLens: BoundLens<TestModel, String> {
     return BoundLens<TestModel, String>(instance: self, lens: TestModel.nameLens)
  }
  static let countLens = Lens<TestModel, Int>(
    get: { $0.count },
    set: { count, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: count, someCount: testModel.someCount, urls: testModel.urls, someModel: testModel.someModel)
    }
  )
  var countLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.countLens)
  }
  static let someCountLens = Lens<TestModel, Int>(
    get: { $0.someCount },
    set: { someCount, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: someCount, urls: testModel.urls, someModel: testModel.someModel)
    }
  )
  var someCountLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.someCountLens)
  }
  static let urlsLens = Lens<TestModel, [URL]?>(
    get: { $0.urls },
    set: { urls, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: urls, someModel: testModel.someModel)
    }
  )
  var urlsLens: BoundLens<TestModel, [URL]?> {
     return BoundLens<TestModel, [URL]?>(instance: self, lens: TestModel.urlsLens)
  }
  static let someModelLens = Lens<TestModel, TestSomeModel?>(
    get: { $0.someModel },
    set: { someModel, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, someModel: someModel)
    }
  )
  var someModelLens: BoundLens<TestModel, TestSomeModel?> {
     return BoundLens<TestModel, TestSomeModel?>(instance: self, lens: TestModel.someModelLens)
  }
}
extension TestPrimitivesModel {
  static let idLens = Lens<TestPrimitivesModel, Int>(
    get: { $0.id },
    set: { id, testPrimitivesModel in
       TestPrimitivesModel(id: id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var idLens: BoundLens<TestPrimitivesModel, Int> {
     return BoundLens<TestPrimitivesModel, Int>(instance: self, lens: TestPrimitivesModel.idLens)
  }
  static let valueLens = Lens<TestPrimitivesModel, Int32?>(
    get: { $0.value },
    set: { value, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var valueLens: BoundLens<TestPrimitivesModel, Int32?> {
     return BoundLens<TestPrimitivesModel, Int32?>(instance: self, lens: TestPrimitivesModel.valueLens)
  }
  static let doubleValueLens = Lens<TestPrimitivesModel, Double>(
    get: { $0.doubleValue },
    set: { doubleValue, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var doubleValueLens: BoundLens<TestPrimitivesModel, Double> {
     return BoundLens<TestPrimitivesModel, Double>(instance: self, lens: TestPrimitivesModel.doubleValueLens)
  }
  static let floatValueLens = Lens<TestPrimitivesModel, Float?>(
    get: { $0.floatValue },
    set: { floatValue, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var floatValueLens: BoundLens<TestPrimitivesModel, Float?> {
     return BoundLens<TestPrimitivesModel, Float?>(instance: self, lens: TestPrimitivesModel.floatValueLens)
  }
  static let boolValueLens = Lens<TestPrimitivesModel, Bool?>(
    get: { $0.boolValue },
    set: { boolValue, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var boolValueLens: BoundLens<TestPrimitivesModel, Bool?> {
     return BoundLens<TestPrimitivesModel, Bool?>(instance: self, lens: TestPrimitivesModel.boolValueLens)
  }
  static let urlValueLens = Lens<TestPrimitivesModel, URL?>(
    get: { $0.urlValue },
    set: { urlValue, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var urlValueLens: BoundLens<TestPrimitivesModel, URL?> {
     return BoundLens<TestPrimitivesModel, URL?>(instance: self, lens: TestPrimitivesModel.urlValueLens)
  }
  static let someEnumLens = Lens<TestPrimitivesModel, SomeEnum>(
    get: { $0.someEnum },
    set: { someEnum, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var someEnumLens: BoundLens<TestPrimitivesModel, SomeEnum> {
     return BoundLens<TestPrimitivesModel, SomeEnum>(instance: self, lens: TestPrimitivesModel.someEnumLens)
  }
  static let someEnumOptLens = Lens<TestPrimitivesModel, SomeEnum?>(
    get: { $0.someEnumOpt },
    set: { someEnumOpt, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var someEnumOptLens: BoundLens<TestPrimitivesModel, SomeEnum?> {
     return BoundLens<TestPrimitivesModel, SomeEnum?>(instance: self, lens: TestPrimitivesModel.someEnumOptLens)
  }
  static let stringEnumLens = Lens<TestPrimitivesModel, SomeStringEnum>(
    get: { $0.stringEnum },
    set: { stringEnum, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var stringEnumLens: BoundLens<TestPrimitivesModel, SomeStringEnum> {
     return BoundLens<TestPrimitivesModel, SomeStringEnum>(instance: self, lens: TestPrimitivesModel.stringEnumLens)
  }
  static let stringEnumOptLens = Lens<TestPrimitivesModel, SomeStringEnum?>(
    get: { $0.stringEnumOpt },
    set: { stringEnumOpt, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: stringEnumOpt, someComplexCodable: testPrimitivesModel.someComplexCodable)
    }
  )
  var stringEnumOptLens: BoundLens<TestPrimitivesModel, SomeStringEnum?> {
     return BoundLens<TestPrimitivesModel, SomeStringEnum?>(instance: self, lens: TestPrimitivesModel.stringEnumOptLens)
  }
  static let someComplexCodableLens = Lens<TestPrimitivesModel, SomeComplexCodable?>(
    get: { $0.someComplexCodable },
    set: { someComplexCodable, testPrimitivesModel in
       TestPrimitivesModel(id: testPrimitivesModel.id, value: testPrimitivesModel.value, doubleValue: testPrimitivesModel.doubleValue, floatValue: testPrimitivesModel.floatValue, boolValue: testPrimitivesModel.boolValue, urlValue: testPrimitivesModel.urlValue, someEnum: testPrimitivesModel.someEnum, someEnumOpt: testPrimitivesModel.someEnumOpt, stringEnum: testPrimitivesModel.stringEnum, stringEnumOpt: testPrimitivesModel.stringEnumOpt, someComplexCodable: someComplexCodable)
    }
  )
  var someComplexCodableLens: BoundLens<TestPrimitivesModel, SomeComplexCodable?> {
     return BoundLens<TestPrimitivesModel, SomeComplexCodable?>(instance: self, lens: TestPrimitivesModel.someComplexCodableLens)
  }
}
extension TestRNModel {
  static let idLens = Lens<TestRNModel, Int>(
    get: { $0.id },
    set: { id, testRNModel in
       TestRNModel(id: id, name: testRNModel.name, owner: testRNModel.owner)
    }
  )
  var idLens: BoundLens<TestRNModel, Int> {
     return BoundLens<TestRNModel, Int>(instance: self, lens: TestRNModel.idLens)
  }
  static let nameLens = Lens<TestRNModel, String>(
    get: { $0.name },
    set: { name, testRNModel in
       TestRNModel(id: testRNModel.id, name: name, owner: testRNModel.owner)
    }
  )
  var nameLens: BoundLens<TestRNModel, String> {
     return BoundLens<TestRNModel, String>(instance: self, lens: TestRNModel.nameLens)
  }
  static let ownerLens = Lens<TestRNModel, TestSomeModel>(
    get: { $0.owner },
    set: { owner, testRNModel in
       TestRNModel(id: testRNModel.id, name: testRNModel.name, owner: owner)
    }
  )
  var ownerLens: BoundLens<TestRNModel, TestSomeModel> {
     return BoundLens<TestRNModel, TestSomeModel>(instance: self, lens: TestRNModel.ownerLens)
  }
}
extension TestRRModel {
  static let idLens = Lens<TestRRModel, Int>(
    get: { $0.id },
    set: { id, testRRModel in
       TestRRModel(id: id, name: testRRModel.name, owner: testRRModel.owner, user: testRRModel.user)
    }
  )
  var idLens: BoundLens<TestRRModel, Int> {
     return BoundLens<TestRRModel, Int>(instance: self, lens: TestRRModel.idLens)
  }
  static let nameLens = Lens<TestRRModel, String>(
    get: { $0.name },
    set: { name, testRRModel in
       TestRRModel(id: testRRModel.id, name: name, owner: testRRModel.owner, user: testRRModel.user)
    }
  )
  var nameLens: BoundLens<TestRRModel, String> {
     return BoundLens<TestRRModel, String>(instance: self, lens: TestRRModel.nameLens)
  }
  static let ownerLens = Lens<TestRRModel, TestSomeModel?>(
    get: { $0.owner },
    set: { owner, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: owner, user: testRRModel.user)
    }
  )
  var ownerLens: BoundLens<TestRRModel, TestSomeModel?> {
     return BoundLens<TestRRModel, TestSomeModel?>(instance: self, lens: TestRRModel.ownerLens)
  }
  static let userLens = Lens<TestRRModel, TestERRModel?>(
    get: { $0.user },
    set: { user, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: testRRModel.owner, user: user)
    }
  )
  var userLens: BoundLens<TestRRModel, TestERRModel?> {
     return BoundLens<TestRRModel, TestERRModel?>(instance: self, lens: TestRRModel.userLens)
  }
  static let usersLens = Lens<TestRRModel, Relation<TestRRModel>>(
    get: { $0.users },
    set: { users, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: testRRModel.owner, user: testRRModel.user)
    }
  )
  var usersLens: BoundLens<TestRRModel, Relation<TestRRModel>> {
     return BoundLens<TestRRModel, Relation<TestRRModel>>(instance: self, lens: TestRRModel.usersLens)
  }
  static let ownersLens = Lens<TestRRModel, EmbeddedRelation<TestERRModel>>(
    get: { $0.owners },
    set: { owners, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: testRRModel.owner, user: testRRModel.user)
    }
  )
  var ownersLens: BoundLens<TestRRModel, EmbeddedRelation<TestERRModel>> {
     return BoundLens<TestRRModel, EmbeddedRelation<TestERRModel>>(instance: self, lens: TestRRModel.ownersLens)
  }
}
extension TestSimpleModel {
  static let titleLens = Lens<TestSimpleModel, String>(
    get: { $0.title },
    set: { title, testSimpleModel in
       TestSimpleModel(title: title, count: testSimpleModel.count)
    }
  )
  var titleLens: BoundLens<TestSimpleModel, String> {
     return BoundLens<TestSimpleModel, String>(instance: self, lens: TestSimpleModel.titleLens)
  }
  static let countLens = Lens<TestSimpleModel, Int>(
    get: { $0.count },
    set: { count, testSimpleModel in
       TestSimpleModel(title: testSimpleModel.title, count: count)
    }
  )
  var countLens: BoundLens<TestSimpleModel, Int> {
     return BoundLens<TestSimpleModel, Int>(instance: self, lens: TestSimpleModel.countLens)
  }
}
extension TestSomeModel {
  static let userIdLens = Lens<TestSomeModel, Int>(
    get: { $0.userId },
    set: { userId, testSomeModel in
       TestSomeModel(userId: userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var userIdLens: BoundLens<TestSomeModel, Int> {
     return BoundLens<TestSomeModel, Int>(instance: self, lens: TestSomeModel.userIdLens)
  }
  static let userNameLens = Lens<TestSomeModel, String>(
    get: { $0.userName },
    set: { userName, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var userNameLens: BoundLens<TestSomeModel, String> {
     return BoundLens<TestSomeModel, String>(instance: self, lens: TestSomeModel.userNameLens)
  }
  static let userAvatarLens = Lens<TestSomeModel, String>(
    get: { $0.userAvatar },
    set: { userAvatar, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var userAvatarLens: BoundLens<TestSomeModel, String> {
     return BoundLens<TestSomeModel, String>(instance: self, lens: TestSomeModel.userAvatarLens)
  }
  static let titleLens = Lens<TestSomeModel, String?>(
    get: { $0.title },
    set: { title, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var titleLens: BoundLens<TestSomeModel, String?> {
     return BoundLens<TestSomeModel, String?>(instance: self, lens: TestSomeModel.titleLens)
  }
  static let countLens = Lens<TestSomeModel, Int>(
    get: { $0.count },
    set: { count, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var countLens: BoundLens<TestSomeModel, Int> {
     return BoundLens<TestSomeModel, Int>(instance: self, lens: TestSomeModel.countLens)
  }
  static let inverseModelLens = Lens<TestSomeModel, Relation<TestRRModel>>(
    get: { $0.inverseModel },
    set: { inverseModel, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var inverseModelLens: BoundLens<TestSomeModel, Relation<TestRRModel>> {
     return BoundLens<TestSomeModel, Relation<TestRRModel>>(instance: self, lens: TestSomeModel.inverseModelLens)
  }
  static let directModelsLens = Lens<TestSomeModel, Relation<TestRRModel>>(
    get: { $0.directModels },
    set: { directModels, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: testSomeModel.nestedModel)
    }
  )
  var directModelsLens: BoundLens<TestSomeModel, Relation<TestRRModel>> {
     return BoundLens<TestSomeModel, Relation<TestRRModel>>(instance: self, lens: TestSomeModel.directModelsLens)
  }
  static let nestedModelLens = Lens<TestSomeModel, TestNestedModel?>(
    get: { $0.nestedModel },
    set: { nestedModel, testSomeModel in
       TestSomeModel(userId: testSomeModel.userId, userName: testSomeModel.userName, userAvatar: testSomeModel.userAvatar, title: testSomeModel.title, count: testSomeModel.count, nestedModel: nestedModel)
    }
  )
  var nestedModelLens: BoundLens<TestSomeModel, TestNestedModel?> {
     return BoundLens<TestSomeModel, TestNestedModel?>(instance: self, lens: TestSomeModel.nestedModelLens)
  }
}
