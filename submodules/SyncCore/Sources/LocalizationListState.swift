import Postbox

public struct LocalizationInfoDefault{
public static let sc = LocalizationInfo(languageCode: "zh-hans-raw",
                                        baseLanguageCode: "zh-hans-raw",
                                        customPluralizationCode: "zh",
                                        title: "Chinese (Simplified)",
                                        localizedTitle: "简体中文",
                                        isOfficial: true,
                                        totalStringCount: 3362,
                                        translatedStringCount: 3108,
                                        platformUrl: "https://translations.telegram.org/classic-zh-cn/")
public static let tc = LocalizationInfo(languageCode: "zh-hant-raw",
                                        baseLanguageCode: "zh-hant-raw",
                                        customPluralizationCode: "zh",
                                        title: "Chinese (Traditional)",
                                        localizedTitle: "繁體中文",
                                        isOfficial: true,
                                        totalStringCount: 3460,
                                        translatedStringCount: 3399,
                                        platformUrl: "https://translations.telegram.org/zh-hant/")

public static let en = LocalizationInfo(languageCode: "en",
                                        baseLanguageCode: "en",
                                        customPluralizationCode: "en",
                                        title: "English",
                                        localizedTitle: "English",
                                        isOfficial: true,
                                        totalStringCount: 3394,
                                        translatedStringCount: 3394,
                                        platformUrl: "https://translations.telegram.org/en/")
}

public struct LocalizationListState: PreferencesEntry, Equatable {
    public var availableOfficialLocalizations: [LocalizationInfo]
    public var availableSavedLocalizations: [LocalizationInfo]
    
    public static var defaultSettings: LocalizationListState {
        return LocalizationListState(
            availableOfficialLocalizations: [LocalizationInfoDefault.sc,
                                             LocalizationInfoDefault.tc,
                                             LocalizationInfoDefault.en],
            availableSavedLocalizations: [])
    }
    
    public init(availableOfficialLocalizations: [LocalizationInfo], availableSavedLocalizations: [LocalizationInfo]) {
        self.availableOfficialLocalizations = availableOfficialLocalizations
        self.availableSavedLocalizations = availableSavedLocalizations
        
        guard self.availableOfficialLocalizations.count == 0 else {return}
        hardCodeLocalizationInfo()
    }
    
    public init(decoder: PostboxDecoder) {
        self.availableOfficialLocalizations = decoder.decodeObjectArrayWithDecoderForKey("availableOfficialLocalizations")
        self.availableSavedLocalizations = decoder.decodeObjectArrayWithDecoderForKey("availableSavedLocalizations")
        
        guard self.availableOfficialLocalizations.count == 0 else {return}
        hardCodeLocalizationInfo()
    }
    
    /// 写死简繁英3中语言
    private mutating func hardCodeLocalizationInfo(){
        
        self.availableOfficialLocalizations = [LocalizationInfoDefault.sc,
                                               LocalizationInfoDefault.tc,
                                               LocalizationInfoDefault.en]
        self.availableSavedLocalizations = []
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeObjectArray(self.availableOfficialLocalizations, forKey: "availableOfficialLocalizations")
        encoder.encodeObjectArray(self.availableSavedLocalizations, forKey: "availableSavedLocalizations")
    }
    
    public func isEqual(to: PreferencesEntry) -> Bool {
        guard let to = to as? LocalizationListState else {
            return false
        }
        
        return self == to
    }
}
