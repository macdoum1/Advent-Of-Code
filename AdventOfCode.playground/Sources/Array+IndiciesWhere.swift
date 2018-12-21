import Foundation

extension Array where Element: Equatable {
    public func indiciesWhere(_ filter: ((Element) -> Bool)) -> [Int] {
        return self.indices.filter {
            return filter(self[$0])
        }
    }
}
