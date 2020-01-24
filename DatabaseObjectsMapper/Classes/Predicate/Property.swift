//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


public protocol AnyProperty {
}


public protocol AnyEquatableProperty: AnyProperty {
}


public protocol AnyComparableProperty: AnyEquatableProperty {
}


extension Bool: AnyEquatableProperty {
}


extension Int: AnyComparableProperty {
}


extension Int8: AnyComparableProperty {
}


extension Int16: AnyComparableProperty {
}


extension Int32: AnyComparableProperty {
}


extension Int64: AnyComparableProperty {
}


extension Float: AnyComparableProperty {
}


extension Double: AnyComparableProperty {
}


extension Date: AnyComparableProperty {
}


extension NSDate: AnyComparableProperty {
}


extension String: AnyEquatableProperty {
}


extension NSString: AnyEquatableProperty {
}


extension Data: AnyEquatableProperty {
}


extension NSData: AnyEquatableProperty {
}

// String
public protocol StringEquatableProperty: AnyEquatableProperty {
}


extension String: StringEquatableProperty {
}

// String
public protocol NumericComparableProperty: AnyEquatableProperty, Comparable, CustomStringConvertible {
}

extension Int: NumericComparableProperty {
}


extension Int8: NumericComparableProperty {
}


extension Int16: NumericComparableProperty {
}


extension Int32: NumericComparableProperty {
}


extension Int64: NumericComparableProperty {
}


extension Float: NumericComparableProperty {
}


extension Double: NumericComparableProperty {
}
