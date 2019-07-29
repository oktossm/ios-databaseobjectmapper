// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
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
  static let subModelLens = Lens<TestCDModel, Relation<TestSubModel>>(
    get: { $0.subModel },
    set: { subModel, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, someCount: testCDModel.someCount, urls: testCDModel.urls, subModel: subModel)
    }
  )
  var subModelLens: BoundLens<TestCDModel, Relation<TestSubModel>> {
     return BoundLens<TestCDModel, Relation<TestSubModel>>(instance: self, lens: TestCDModel.subModelLens)
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
extension TestModel {
  static let idLens = Lens<TestModel, Int>(
    get: { $0.id },
    set: { id, testModel in
       TestModel(id: id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, subModel: testModel.subModel)
    }
  )
  var idLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.idLens)
  }
  static let indexLens = Lens<TestModel, Int?>(
    get: { $0.index },
    set: { index, testModel in
       TestModel(id: testModel.id, index: index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, subModel: testModel.subModel)
    }
  )
  var indexLens: BoundLens<TestModel, Int?> {
     return BoundLens<TestModel, Int?>(instance: self, lens: TestModel.indexLens)
  }
  static let nameLens = Lens<TestModel, String>(
    get: { $0.name },
    set: { name, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, subModel: testModel.subModel)
    }
  )
  var nameLens: BoundLens<TestModel, String> {
     return BoundLens<TestModel, String>(instance: self, lens: TestModel.nameLens)
  }
  static let countLens = Lens<TestModel, Int>(
    get: { $0.count },
    set: { count, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: count, someCount: testModel.someCount, urls: testModel.urls, subModel: testModel.subModel)
    }
  )
  var countLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.countLens)
  }
  static let someCountLens = Lens<TestModel, Int>(
    get: { $0.someCount },
    set: { someCount, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: someCount, urls: testModel.urls, subModel: testModel.subModel)
    }
  )
  var someCountLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.someCountLens)
  }
  static let urlsLens = Lens<TestModel, [URL]?>(
    get: { $0.urls },
    set: { urls, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: urls, subModel: testModel.subModel)
    }
  )
  var urlsLens: BoundLens<TestModel, [URL]?> {
     return BoundLens<TestModel, [URL]?>(instance: self, lens: TestModel.urlsLens)
  }
  static let subModelLens = Lens<TestModel, TestSubModel?>(
    get: { $0.subModel },
    set: { subModel, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, someCount: testModel.someCount, urls: testModel.urls, subModel: subModel)
    }
  )
  var subModelLens: BoundLens<TestModel, TestSubModel?> {
     return BoundLens<TestModel, TestSubModel?>(instance: self, lens: TestModel.subModelLens)
  }
}
extension TestRRModel {
  static let idLens = Lens<TestRRModel, Int>(
    get: { $0.id },
    set: { id, testRRModel in
       TestRRModel(id: id, name: testRRModel.name, owner: testRRModel.owner)
    }
  )
  var idLens: BoundLens<TestRRModel, Int> {
     return BoundLens<TestRRModel, Int>(instance: self, lens: TestRRModel.idLens)
  }
  static let nameLens = Lens<TestRRModel, String>(
    get: { $0.name },
    set: { name, testRRModel in
       TestRRModel(id: testRRModel.id, name: name, owner: testRRModel.owner)
    }
  )
  var nameLens: BoundLens<TestRRModel, String> {
     return BoundLens<TestRRModel, String>(instance: self, lens: TestRRModel.nameLens)
  }
  static let ownerLens = Lens<TestRRModel, TestSubModel?>(
    get: { $0.owner },
    set: { owner, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: owner)
    }
  )
  var ownerLens: BoundLens<TestRRModel, TestSubModel?> {
     return BoundLens<TestRRModel, TestSubModel?>(instance: self, lens: TestRRModel.ownerLens)
  }
  static let usersLens = Lens<TestRRModel, Relation<TestRRModel>>(
    get: { $0.users },
    set: { users, testRRModel in
       TestRRModel(id: testRRModel.id, name: testRRModel.name, owner: testRRModel.owner)
    }
  )
  var usersLens: BoundLens<TestRRModel, Relation<TestRRModel>> {
     return BoundLens<TestRRModel, Relation<TestRRModel>>(instance: self, lens: TestRRModel.usersLens)
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
extension TestSubModel {
  static let userIdLens = Lens<TestSubModel, Int>(
    get: { $0.userId },
    set: { userId, testSubModel in
       TestSubModel(userId: userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: testSubModel.title, count: testSubModel.count)
    }
  )
  var userIdLens: BoundLens<TestSubModel, Int> {
     return BoundLens<TestSubModel, Int>(instance: self, lens: TestSubModel.userIdLens)
  }
  static let userNameLens = Lens<TestSubModel, String>(
    get: { $0.userName },
    set: { userName, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: userName, userAvatar: testSubModel.userAvatar, title: testSubModel.title, count: testSubModel.count)
    }
  )
  var userNameLens: BoundLens<TestSubModel, String> {
     return BoundLens<TestSubModel, String>(instance: self, lens: TestSubModel.userNameLens)
  }
  static let userAvatarLens = Lens<TestSubModel, String>(
    get: { $0.userAvatar },
    set: { userAvatar, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: userAvatar, title: testSubModel.title, count: testSubModel.count)
    }
  )
  var userAvatarLens: BoundLens<TestSubModel, String> {
     return BoundLens<TestSubModel, String>(instance: self, lens: TestSubModel.userAvatarLens)
  }
  static let titleLens = Lens<TestSubModel, String?>(
    get: { $0.title },
    set: { title, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: title, count: testSubModel.count)
    }
  )
  var titleLens: BoundLens<TestSubModel, String?> {
     return BoundLens<TestSubModel, String?>(instance: self, lens: TestSubModel.titleLens)
  }
  static let countLens = Lens<TestSubModel, Int>(
    get: { $0.count },
    set: { count, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: testSubModel.title, count: count)
    }
  )
  var countLens: BoundLens<TestSubModel, Int> {
     return BoundLens<TestSubModel, Int>(instance: self, lens: TestSubModel.countLens)
  }
  static let inverseModelLens = Lens<TestSubModel, Relation<TestRRModel>>(
    get: { $0.inverseModel },
    set: { inverseModel, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: testSubModel.title, count: testSubModel.count)
    }
  )
  var inverseModelLens: BoundLens<TestSubModel, Relation<TestRRModel>> {
     return BoundLens<TestSubModel, Relation<TestRRModel>>(instance: self, lens: TestSubModel.inverseModelLens)
  }
  static let directModelsLens = Lens<TestSubModel, Relation<TestRRModel>>(
    get: { $0.directModels },
    set: { directModels, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: testSubModel.title, count: testSubModel.count)
    }
  )
  var directModelsLens: BoundLens<TestSubModel, Relation<TestRRModel>> {
     return BoundLens<TestSubModel, Relation<TestRRModel>>(instance: self, lens: TestSubModel.directModelsLens)
  }
}
