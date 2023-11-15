internal extension Sequence {
  func unique<T: Hashable>(by taggingHandler: (_ element: Self.Iterator.Element) -> T) -> [Self.Iterator.Element] {
    var knownTags = Set<T>()
    
    return self.filter { element -> Bool in
      let tag = taggingHandler(element)
      
      if !knownTags.contains(tag) {
        knownTags.insert(tag)
        return true
      }
      
      return false
    }
  }
}
