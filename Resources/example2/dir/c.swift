// c.swift

protocol DefaultProtocol {
    func dpf0()
}

public extension Int {
    func ie0() {}
}

extension Int : DefaultProtocol {
    func dpf0() {}
}
