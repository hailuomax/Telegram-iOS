import Foundation
import AppBundle

//public let defaultPresentationStrings = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: "en", localizedName: "English", pluralizationRulesCode: nil, dict: NSDictionary(contentsOf: URL(fileURLWithPath: getAppBundle().path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "en")!)) as! [String : String]), secondaryComponent: nil, groupingSeparator: "")
public let defaultPresentationStrings = PresentationStrings(primaryComponent: PresentationStringsComponent(languageCode: "zh-hans-raw", localizedName: "简体中文", pluralizationRulesCode: nil, dict: NSDictionary(contentsOf: URL(fileURLWithPath: getAppBundle().path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "zh-Hans")!)) as! [String : String]), secondaryComponent: nil, groupingSeparator: "")
