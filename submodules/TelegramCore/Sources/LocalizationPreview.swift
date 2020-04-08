import Postbox
import SwiftSignalKit
import MtProtoKit
import TelegramApi

import SyncCore

public enum RequestLocalizationPreviewError {
    case generic
}

public func requestLocalizationPreview(network: Network, identifier: String) -> Signal<LocalizationInfo, RequestLocalizationPreviewError> {
    
    
    return Signal{ subscriber in
        
        let local = [LocalizationInfoDefault.sc, LocalizationInfoDefault.tc, LocalizationInfoDefault.en].filter{$0.baseLanguageCode == identifier}
        if local.count > 0 {
            subscriber.putNext(local.first!)
        }else{
            subscriber.putNext(LocalizationInfoDefault.sc)
        }
        subscriber.putCompletion()
        
        return ActionDisposable{}
    }
//
//    return network.request(Api.functions.langpack.getLanguage(langPack: "", langCode: identifier))
//    |> mapError { _ -> RequestLocalizationPreviewError in
//        return .generic
//    }
//    |> map { language -> LocalizationInfo in
//        return LocalizationInfo(apiLanguage: language)
//    }
}
