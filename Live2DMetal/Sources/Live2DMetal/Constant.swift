enum Constant {
    static let viewScale: Float = 1.0
    static let viewMaxScale: Float = 2.0
    static let viewMinScale: Float = 0.8

    static let viewLogicalLeft: Float = -1.0
    static let viewLogicalRight: Float = 1.0
    static let viewLogicalBottom: Float = -1.0
    static let viewLogicalTop: Float = 1.0

    static let viewLogicalMaxLeft: Float = -2.0
    static let viewLogicalMaxRight: Float = 2.0
    static let viewLogicalMaxBottom: Float = -2.0
    static let viewLogicalMaxTop: Float = 2.0

    static let resourcesPath = "res/"

    // Image file for the background behind the model
    static let backImageName = "back_class_normal.png"
    // Gear icon
    static let gearImageName = "icon_gear.png"

    // Match with the external definition file (json)
    static let hitAreaNameHead = "Head"
    static let hitAreaNameBody = "Body"
    static let motionGroupIdle = "Idle" // Idle
    static let motionGroupTapBody = "TapBody" // When tapping body

    // Log display option for debugging
    static let debugLogEnable = true
    static let debugTouchLogEnable = false
}
