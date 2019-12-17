import Foundation

protocol Edit {
    var active: Bool { get }
 
    func activate()
    func resign()
    func click()
    func right()
}

final class Block: Edit {
    private(set) var active = false
    
    func activate() {
        active = true
    }
    
    func resign() {
        active = false
    }
    
    func click() {
        active = true
    }
    
    func right() {
        active = true
    }
}

final class Active: Edit {
    private(set) var active = true
    
    func activate() { }
    func resign() { }
    func click() { }
    func right() { }
}

final class Editable: Edit {
    private(set) var active = false
    
    func activate() {
        active = false
    }
    
    func resign() {
        active = false
    }
    
    func click() {
        active = false
    }
    
    func right() {
        active = true
    }
}

final class Off: Edit {
    let active = false
    
    func activate() { }
    func resign() { }
    func click() { }
    func right() { }
}
