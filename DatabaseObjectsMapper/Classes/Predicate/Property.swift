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