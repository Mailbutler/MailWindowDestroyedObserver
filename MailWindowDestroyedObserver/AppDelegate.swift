//
//  AppDelegate.swift
//  MailWindowDestroyedObserver
//
//  Created by TJ on 29.01.25.
//

import AXSwift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    private var axObserver: Observer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let mailApp = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.mail").first else {
            let alert = NSAlert()
            alert.messageText = "Mail is not running."
            alert.informativeText = "Please launch Mail first, then try again."
            alert.runModal()
            exit(1)
        }

        guard AXSwift.checkIsProcessTrusted(prompt: true) else {
            let alert = NSAlert()
            alert.messageText = "Missing Accessibility permissions."
            alert.informativeText = "Please grant this application Accessibility permissions in System Settings, then try again."
            alert.runModal()
            exit(1)
        }

        addMailWindowCreatedObserver(mailPID: mailApp.processIdentifier)

        print("Please go to Mail and open a new Message Viewer window!")
        print("Observing creation of Mail Message Viewer windows…")
    }

    private func addMailWindowCreatedObserver(mailPID: pid_t) {
        guard let axMailApp = Application(forProcessID: mailPID) else {
            print("Unable to get AXUIElement for Mail application")
            exit(1)
        }

        guard let observer = axMailApp.createObserver({ [weak self] _, element, notification in
            switch notification {
            case .uiElementDestroyed:
                self?.mailWindowDestroyed(element)
            case .windowCreated:
                self?.mailWindowCreated(element)
            default:
                break
            }
        }) else {
            print("Unable to create observer")
            exit(1)
        }
        self.axObserver = observer

        do {
            try observer.addNotification(.windowCreated, forElement: axMailApp)
        } catch let error {
            NSApp.presentError(error)
            exit(1)
        }
    }

    private func mailWindowDestroyed(_ window: UIElement) {
        // ====================================================================
        // THIS FUNCTION IS NEVER CALLED WHEN GRAMMARLY IS RUNNING!
        // ====================================================================
        print("❌ Window destroyed: \(window)")
    }

    private func mailWindowCreated(_ window: UIElement) {
        print("✅ Window created: \(window)")

        do {
            try axObserver?.addNotification(.uiElementDestroyed, forElement: window)
            print("Added AXUIElementDestroyed observer for \(window)")
        } catch let error {
            print("Unable to add window observer %@", error.localizedDescription)
        }
    }
}

