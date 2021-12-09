//
//  ViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

class ViewController: NSViewController {

	var notchWindows: [NotchWindow] = []
	
	@IBOutlet weak var effectPopUpButton: NSPopUpButton!
	@IBOutlet weak var effectDescriptionTextField: NSTextField!
	@IBOutlet weak var debugButton: NSButton!
	
    //MARK: - Life Cycle

	deinit {
		// we don't want this view controller, and its notchWindows, to go away
		assert(false, "view controller can't be deallocated")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
        createNotchWindows()
    }

	override func viewWillDisappear() {
		debugLog()
		
		// NOTE: Turn on the debug button in the release build by holding down the Option key while closing the main window,
		// then reopen the window using the Dock icon.
		if NSEvent.modifierFlags.contains(.option) {
			debugButton.isHidden = false
		}
	}

    private func configureForDefaults() {
		Defaults.register()
		
		let menu = NSMenu(title: "Notch Effects")
		for effect in Effects.allCases {
			let menuItem = NSMenuItem(title: effect.displayName(), action: nil, keyEquivalent: "")
			menuItem.tag = effect.rawValue
			menu.addItem(menuItem)
		}
		effectPopUpButton.menu = menu
		
		guard let effect = Effects(rawValue: Defaults.selectedEffect) else { return }
		effectDescriptionTextField.stringValue = effect.displayDescription()
		effectPopUpButton.selectItem(withTag: effect.rawValue)
		
#if DEBUG
		debugButton.isHidden = false
#else
		debugButton.isHidden = true
#endif
    }
    
    private func createNotchWindows() {
        let padding: CGFloat = 50 // amount of padding around the notch that can be used for effect drawing
        
        for oldWindow in notchWindows {
            oldWindow.orderOut(self)
        }

        notchWindows.removeAll()
        
		for screen in NSScreen.notchedScreens {
			if let notchWindow = NotchWindow(screen: screen, padding: padding) {
				notchWindow.orderFront(self)
                notchWindows.append(notchWindow)
			}
		}
    }
    
	func updateConfiguration() {
		// called from DebugViewController to rebuild window and view hierarchies when settings change
		configureForDefaults()
		createNotchWindows()
	}
	
    //MARK: - Actions

	@IBAction func openDebugViewController(_ sender: Any) {
		guard let viewController = self.storyboard?.instantiateController(withIdentifier: "debugViewController") as? NSViewController else { return }
		self.present(viewController, asPopoverRelativeTo: debugButton.frame, of: view, preferredEdge: NSRectEdge.minX, behavior: .transient)
	}
	
	@IBAction func selectedEffectValueChanged(_ sender: Any) {
		Defaults.selectedEffect = effectPopUpButton.selectedTag()
		createNotchWindows()
		
		guard let effect = Effects(rawValue: Defaults.selectedEffect) else { return }
		effectDescriptionTextField.stringValue = effect.displayDescription()
	}
	
	@IBAction func openHelp(_ sender: Any) {
		let alert = NSAlert()
		alert.messageText = "Notchmeister Help"
		if NSScreen.hasNotchedScreen {
			alert.informativeText = Defaults.notchedHelp
		}
		else {
			alert.informativeText = Defaults.notchlessHelp + Defaults.notchlessHelpButton
		}
		alert.runModal()
	}
}

