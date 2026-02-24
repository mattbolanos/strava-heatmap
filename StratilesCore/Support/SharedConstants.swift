import Foundation

public enum SharedConstants {
    public static let appGroupIdentifier = "group.com.mattbolanos.stratiles"
    public static let keychainAccessGroup = "$(AppIdentifierPrefix)com.mattbolanos.stratiles"
    public static let selectedActivityTypesDefaultsKey = "selectedActivityTypes"
    public static let cacheFileName = "activity-cache.json"

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
}

public enum SharedActivityTypeSettings {
    public static func loadSelectedTypes() -> Set<ActivityType> {
        let defaults = SharedConstants.sharedDefaults
        let raw = defaults?.stringArray(forKey: SharedConstants.selectedActivityTypesDefaultsKey) ?? []
        let parsed = Set(raw.compactMap(ActivityType.init(rawValue:)))
        return parsed.isEmpty ? ActivityType.defaultSelected : parsed
    }

    public static func saveSelectedTypes(_ types: Set<ActivityType>) {
        let raw = types.map(\.rawValue).sorted()
        SharedConstants.sharedDefaults?.set(raw, forKey: SharedConstants.selectedActivityTypesDefaultsKey)
    }
}
