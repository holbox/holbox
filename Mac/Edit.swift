import Foundation

protocol Edit {
    var active: Bool { get }
 
    func activate()
    func resign()
    func click()
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
}

final class Active: Edit {
    let active = true
    
    func activate() { }
    func resign() { }
    func click() { }
}

final class Off: Edit {
    let active = false
    
    func activate() { }
    func resign() { }
    func click() { }
}
