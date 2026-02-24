import Foundation

// MARK: - Property Wrapper (@ Decoration)

// A property wrapper is declared with @propertyWrapper
// It must have a `wrappedValue` property.
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>

    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - Usage

struct PlayerStats {
    // @Clamped ensures health stays between 0 and 100
    @Clamped(0...100) var health: Int = 100
    // @Clamped ensures speed stays between 1 and 10
    @Clamped(1...10) var speed: Int = 5
}

var player = PlayerStats()

print("Initial health: \(player.health)")   // 100
print("Initial speed:  \(player.speed)")    // 5

player.health = 150   // clamped to 100
print("After setting health to 150: \(player.health)")  // 100

player.health = -20   // clamped to 0
print("After setting health to -20: \(player.health)")  // 0

player.speed = 0      // clamped to 1
print("After setting speed to 0:  \(player.speed)")     // 1

// MARK: - projectedValue (optional, exposes extra info via $)

@propertyWrapper
struct Tracked<Value> {
    private(set) var projectedValue: Bool = false   // accessible via $varName
    var wrappedValue: Value {
        didSet { projectedValue = true }
    }

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

struct Form {
    @Tracked var username: String = ""
}

var form = Form()
print("\nusername modified? \(form.$username)")  // false
form.username = "pascale"
print("username modified? \(form.$username)")   // true
