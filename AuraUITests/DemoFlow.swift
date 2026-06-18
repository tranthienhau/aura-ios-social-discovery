import XCTest

/// Drives the app through its key screens so an external screen recording
/// (xcrun simctl io recordVideo) captures a real demo of the running app.
final class DemoFlow: XCTestCase {

    func testWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-screen", "onboarding"]
        app.launch()

        sleep(2)
        // Onboarding -> main shell
        app.buttons["getStarted"].firstMatch.tapIfExists()
        sleep(2)

        // Discover: like / swipe a couple of cards
        app.buttons["tab_discover"].tapIfExists()
        sleep(1)
        app.buttons["likeButton"].firstMatch.tapIfExists()
        sleep(1)
        app.swipeLeftCard()
        sleep(1)

        // Map: join a meetup (spends credits)
        app.buttons["tab_map"].tapIfExists()
        sleep(2)
        app.buttons["joinMeetup"].firstMatch.tapIfExists()
        sleep(2)

        // Chat: open first conversation, send a message
        app.buttons["tab_chat"].tapIfExists()
        sleep(1)
        app.staticTexts["Alex"].tapIfExists()
        sleep(1)
        // Briefly focus the composer to reveal the keyboard, then move on.
        let field = app.textFields["Type a message..."]
        if field.waitForExistence(timeout: 2) {
            field.tap()
            sleep(2)
        }

        // Profile: open credit store
        app.buttons["tab_profile"].tapIfExists()
        sleep(1)
        app.buttons["buyCredits"].tapIfExists()
        sleep(2)
    }
}

extension XCUIElement {
    func tapIfExists() {
        if waitForExistence(timeout: 3) && isHittable { tap() }
    }
}

extension XCUIApplication {
    func swipeLeftCard() {
        let start = coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.45))
        let end = coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.4))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
