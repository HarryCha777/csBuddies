// Source: https://medium.com/@michaelbarneyjr/how-to-integrate-admob-ads-in-swiftui-fbfd3d774c50

import SwiftUI
import Firebase

final class AdmobRewardedAdsFilter: NSObject, GADRewardedAdDelegate {
    var rewardedAd: GADRewardedAd = GADRewardedAd(adUnitID: "INSERT ADMOB AD UNIT ID HERE")
    var rewardFunction: (() -> Void)? = nil
    
    override init() {
        super.init()
        LoadRewarded()
    }
    
    func LoadRewarded() {
        let req = GADRequest()
        self.rewardedAd.load(req)
    }
    
    func showAd(rewardFunction: @escaping () -> Void) {
        if self.rewardedAd.isReady {
            self.rewardFunction = rewardFunction
            let root = UIApplication.shared.windows.first?.rootViewController
            self.rewardedAd.present(fromRootViewController: root!, delegate: self)
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rf = rewardFunction {
            rf()
        }
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.rewardedAd = GADRewardedAd(adUnitID: "INSERT ADMOB AD UNIT ID HERE")
        LoadRewarded()
    }
}

final class AdmobRewardedAdsNewChat: NSObject, GADRewardedAdDelegate {
    var rewardedAd: GADRewardedAd = GADRewardedAd(adUnitID: "INSERT ADMOB AD UNIT ID HERE")
    var rewardFunction: (() -> Void)? = nil
    
    override init() {
        super.init()
        LoadRewarded()
    }
    
    func LoadRewarded() {
        let req = GADRequest()
        self.rewardedAd.load(req)
    }
    
    func showAd(rewardFunction: @escaping () -> Void) {
        if self.rewardedAd.isReady {
            self.rewardFunction = rewardFunction
            let root = UIApplication.shared.windows.first?.rootViewController
            self.rewardedAd.present(fromRootViewController: root!, delegate: self)
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rf = rewardFunction {
            rf()
        }
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.rewardedAd = GADRewardedAd(adUnitID: "INSERT ADMOB AD UNIT ID HERE")
        LoadRewarded()
    }
}
