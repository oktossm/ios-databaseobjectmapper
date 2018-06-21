// Generated using Sourcery 0.12.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoLenses
import Foundation

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
       TestCDModel(id: id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var idLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.idLens)
  }
  static let indexLens = Lens<TestCDModel, Int?>(
    get: { $0.index },
    set: { index, testCDModel in
       TestCDModel(id: testCDModel.id, index: index, name: testCDModel.name, count: testCDModel.count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var indexLens: BoundLens<TestCDModel, Int?> {
     return BoundLens<TestCDModel, Int?>(instance: self, lens: TestCDModel.indexLens)
  }
  static let nameLens = Lens<TestCDModel, String>(
    get: { $0.name },
    set: { name, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: name, count: testCDModel.count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var nameLens: BoundLens<TestCDModel, String> {
     return BoundLens<TestCDModel, String>(instance: self, lens: TestCDModel.nameLens)
  }
  static let countLens = Lens<TestCDModel, Int>(
    get: { $0.count },
    set: { count, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var countLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.countLens)
  }
  static let superCountLens = Lens<TestCDModel, Int>(
    get: { $0.superCount },
    set: { superCount, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, superCount: superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var superCountLens: BoundLens<TestCDModel, Int> {
     return BoundLens<TestCDModel, Int>(instance: self, lens: TestCDModel.superCountLens)
  }
  static let urlsLens = Lens<TestCDModel, [URL]?>(
    get: { $0.urls },
    set: { urls, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, superCount: testCDModel.superCount, urls: urls, subModel: testCDModel.subModel, children: testCDModel.children)
    }
  )
  var urlsLens: BoundLens<TestCDModel, [URL]?> {
     return BoundLens<TestCDModel, [URL]?>(instance: self, lens: TestCDModel.urlsLens)
  }
  static let subModelLens = Lens<TestCDModel, TestSubModel?>(
    get: { $0.subModel },
    set: { subModel, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: subModel, children: testCDModel.children)
    }
  )
  var subModelLens: BoundLens<TestCDModel, TestSubModel?> {
     return BoundLens<TestCDModel, TestSubModel?>(instance: self, lens: TestCDModel.subModelLens)
  }
  static let childrenLens = Lens<TestCDModel, [TestModel]?>(
    get: { $0.children },
    set: { children, testCDModel in
       TestCDModel(id: testCDModel.id, index: testCDModel.index, name: testCDModel.name, count: testCDModel.count, superCount: testCDModel.superCount, urls: testCDModel.urls, subModel: testCDModel.subModel, children: children)
    }
  )
  var childrenLens: BoundLens<TestCDModel, [TestModel]?> {
     return BoundLens<TestCDModel, [TestModel]?>(instance: self, lens: TestCDModel.childrenLens)
  }
}
extension TestModel {
  static let idLens = Lens<TestModel, Int>(
    get: { $0.id },
    set: { id, testModel in
       TestModel(id: id, index: testModel.index, name: testModel.name, count: testModel.count, superCount: testModel.superCount, urls: testModel.urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var idLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.idLens)
  }
  static let indexLens = Lens<TestModel, Int?>(
    get: { $0.index },
    set: { index, testModel in
       TestModel(id: testModel.id, index: index, name: testModel.name, count: testModel.count, superCount: testModel.superCount, urls: testModel.urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var indexLens: BoundLens<TestModel, Int?> {
     return BoundLens<TestModel, Int?>(instance: self, lens: TestModel.indexLens)
  }
  static let nameLens = Lens<TestModel, String>(
    get: { $0.name },
    set: { name, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: name, count: testModel.count, superCount: testModel.superCount, urls: testModel.urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var nameLens: BoundLens<TestModel, String> {
     return BoundLens<TestModel, String>(instance: self, lens: TestModel.nameLens)
  }
  static let countLens = Lens<TestModel, Int>(
    get: { $0.count },
    set: { count, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: count, superCount: testModel.superCount, urls: testModel.urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var countLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.countLens)
  }
  static let superCountLens = Lens<TestModel, Int>(
    get: { $0.superCount },
    set: { superCount, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, superCount: superCount, urls: testModel.urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var superCountLens: BoundLens<TestModel, Int> {
     return BoundLens<TestModel, Int>(instance: self, lens: TestModel.superCountLens)
  }
  static let urlsLens = Lens<TestModel, [URL]?>(
    get: { $0.urls },
    set: { urls, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, superCount: testModel.superCount, urls: urls, subModel: testModel.subModel, children: testModel.children)
    }
  )
  var urlsLens: BoundLens<TestModel, [URL]?> {
     return BoundLens<TestModel, [URL]?>(instance: self, lens: TestModel.urlsLens)
  }
  static let subModelLens = Lens<TestModel, TestSubModel?>(
    get: { $0.subModel },
    set: { subModel, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, superCount: testModel.superCount, urls: testModel.urls, subModel: subModel, children: testModel.children)
    }
  )
  var subModelLens: BoundLens<TestModel, TestSubModel?> {
     return BoundLens<TestModel, TestSubModel?>(instance: self, lens: TestModel.subModelLens)
  }
  static let childrenLens = Lens<TestModel, [TestModel]?>(
    get: { $0.children },
    set: { children, testModel in
       TestModel(id: testModel.id, index: testModel.index, name: testModel.name, count: testModel.count, superCount: testModel.superCount, urls: testModel.urls, subModel: testModel.subModel, children: children)
    }
  )
  var childrenLens: BoundLens<TestModel, [TestModel]?> {
     return BoundLens<TestModel, [TestModel]?>(instance: self, lens: TestModel.childrenLens)
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
  static let titleLens = Lens<TestSubModel, String>(
    get: { $0.title },
    set: { title, testSubModel in
       TestSubModel(userId: testSubModel.userId, userName: testSubModel.userName, userAvatar: testSubModel.userAvatar, title: title, count: testSubModel.count)
    }
  )
  var titleLens: BoundLens<TestSubModel, String> {
     return BoundLens<TestSubModel, String>(instance: self, lens: TestSubModel.titleLens)
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
}
