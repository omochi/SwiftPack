// c.swift

protocol DefaultProtocol {
    func dpf0()
}

public extension Int {
    func ie0() {}
}

extension Int : DefaultProtocol {
    func dpf0() {}
    
    var a: Int {
        return 3
    }
    
    var b: Int {
        get {
            return b
        }
        set {
            b = newValue
        }
    }
    
    func hoho() {}
}
