// Source: https://qiita.com/YoshihisaMasaki/items/87e1acf383127b706e03

import SwiftUI
import Combine
import Firebase

final class AdmobNativeAds: NSObject, UIViewControllerRepresentable {
    var adLoader: GADAdLoader?
    var templateView: GADTSmallTemplateView?
    let adUnitId = "INSERT ADMOB AD UNIT ID HERE"
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AdmobNativeAds>) -> UIViewController {
        let templateView = GADTSmallTemplateView()
        self.templateView = templateView

        let viewController = UIViewController()
        viewController.view.addSubview(templateView)
        templateView.addHorizontalConstraintsToSuperviewWidth()
        templateView.addVerticalCenterConstraintToSuperview()
        
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        let loader = GADAdLoader(adUnitID: adUnitId, rootViewController: rootViewController, adTypes: [GADAdLoaderAdType.unifiedNative], options: nil)
        loader.delegate = self

        adLoader = loader
        loader.load(GADRequest())
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AdmobNativeAds>) {}
}

extension AdmobNativeAds: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        templateView?.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {}
}

struct AdmobNativeAdsView: View {
    var body: some View {
        AdmobNativeAds()
            .frame(height: 100)
    }
}
