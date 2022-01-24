import Foundation


private class _AnyPredicateBase<PredicateModelType: KeyPathConvertible>: Predicate {
    typealias ModelType = PredicateModelType

    init() {
        guard type(of: self) != _AnyPredicateBase.self else {
            fatalError("_AnyPredicateBase<PredicateModelType> instances can not be created; create a subclass instance instead")
        }
    }

    var predicate: NSPredicate { fatalError("Must override") }
}


private final class _AnyPredicateBox<Concrete: Predicate>: _AnyPredicateBase<Concrete.ModelType> {
    var concrete: Concrete
    typealias ModelType = Concrete.ModelType

    init(_ concrete: Concrete) {
        self.concrete = concrete
    }

    override var predicate: NSPredicate { concrete.predicate }
}


public struct AnyPredicate<PredicateModelType: KeyPathConvertible>: Predicate {
    public typealias ModelType = PredicateModelType
    private let box: _AnyPredicateBase<ModelType>

    public init<Concrete: Predicate>(_ concrete: Concrete) where Concrete.ModelType == PredicateModelType {
        box = _AnyPredicateBox(concrete)
    }

    public var predicate: NSPredicate { box.predicate }
}


extension Predicate {
    public var anyPredicate: AnyPredicate<ModelType> { AnyPredicate(self) }
}
