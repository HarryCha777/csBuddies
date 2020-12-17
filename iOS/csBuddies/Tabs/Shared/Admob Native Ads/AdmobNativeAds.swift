// Source: https://qiita.com/YoshihisaMasaki/items/87e1acf383127b706e03

import SwiftUI
import Combine
import Firebase

final class AdmobNativeAdsBuddiesUiView: NSObject, UIViewControllerRepresentable {
    var adLoader: GADAdLoader?
    var templateView: BuddiesGADTSmallTemplateView?
    let adUnitId = "INSERT ADMOB AD UNIT ID HERE"

    func makeUIViewController(context: UIViewControllerRepresentableContext<AdmobNativeAdsBuddiesUiView>) -> UIViewController {
        let templateView = BuddiesGADTSmallTemplateView()
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

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AdmobNativeAdsBuddiesUiView>) {}
}

final class AdmobNativeAdsBytesUiView: NSObject, UIViewControllerRepresentable {
    var adLoader: GADAdLoader?
    var templateView: BytesGADTSmallTemplateView?
    let adUnitId = "INSERT ADMOB AD UNIT ID HERE"

    func makeUIViewController(context: UIViewControllerRepresentableContext<AdmobNativeAdsBytesUiView>) -> UIViewController {
        let templateView = BytesGADTSmallTemplateView()
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

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AdmobNativeAdsBytesUiView>) {}
}

extension AdmobNativeAdsBuddiesUiView: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        templateView?.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {}
}

extension AdmobNativeAdsBytesUiView: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        templateView?.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {}
}

struct AdmobNativeAdsBuddiesView: View {
    var body: some View {
        AdmobNativeAdsBuddiesUiView()
            .frame(height: 140)
    }
}

struct AdmobNativeAdsBytesView: View {
    var body: some View {
        AdmobNativeAdsBytesUiView()
            .frame(height: 100)
    }
}
