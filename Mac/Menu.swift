import AppKit

final class Menu: NSMenu {
    required init(coder: NSCoder) { fatalError() }
    init() {
        super.init(title: "")
        items = [holbox, edit, window, help]
    }

    private var holbox: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.argonaut"))
            $0.submenu!.items = [
                .init(title: .key("Menu.about"), action: #selector(Main.about), keyEquivalent: ","),
                .separator(),
                .init(title: .key("Menu.hide"), action: #selector(app.hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(app.hideOtherApplications(_:)), keyEquivalent: "h")),
                .init(title: .key("Menu.showAll"), action: #selector(app.unhideAllApplications(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.quit"), action: #selector(app.terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var edit: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                .separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                .init(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var window: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.window"))
            $0.submenu!.items = [
                .init(title: .key("Menu.minimize"), action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"),
                .init(title: .key("Menu.zoom"), action: #selector(Main.full), keyEquivalent: "p"),
                .separator(),
                .init(title: .key("Menu.bringAllToFront"), action: #selector(app.arrangeInFront(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var help: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.help"))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
}
