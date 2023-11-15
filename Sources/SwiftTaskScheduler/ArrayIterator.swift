import Foundation

internal protocol ArrayIterator<Element> {
    associatedtype Element
    
    var current: Element? { get }
    var hasNext: Bool { get }
    func next() -> Element
    func drop()
}

internal extension Array {
    func makeArrayIterator() -> any ArrayIterator<Element> where Element == Self.Element {
        return ArrayIteratorImpl(self)
    }
}

fileprivate class ArrayIteratorImpl<ArrayElement>: ArrayIterator {
    typealias Element = ArrayElement
    
    let array: [ArrayElement]
    
    var index: Int = 0
    
    var current: ArrayElement?
    
    var hasNext: Bool {
        array.count >= index + 1
    }
    
    init(_ array: [ArrayElement]) {
        self.array = array
        self.current = nil
    }
    
    func next() -> ArrayElement {
        defer { index += 1 }
        current = array[index]
        return array[index]
    }
    
    func drop() {
        index = 0
        current = nil
    }
}
