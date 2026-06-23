import UIKit
import WebKit


internal class ASPZikaewbVC: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var asp_catesData: asp_XOINTE?
    var asp_fuckView: WKWebView?
    
    private var asp_guapistr: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vtf_cornercateview(13.5)
        vtf_borderpanelView()
        aspSetboigview()
        asp_setupImage()
    }
    
    private func asp_setupImage() {

           let imageView = UIImageView()

           imageView.image = UIImage(systemName: "star.fill")

           imageView.tintColor = .systemYellow

           imageView.contentMode = .scaleAspectFit

           imageView.frame = CGRect(x: 30, y: 280, width: 80, height: 80)

           imageView.clipsToBounds = true

           imageView.layer.cornerRadius = 14

           imageView.backgroundColor = UIColor.systemGray6


           let img = imageView.image

           if img == nil {
               imageView.image = UIImage(systemName: "questionmark")
           }

           imageView.setNeedsDisplay()

           imageView.layoutIfNeeded()

           _ = imageView.bounds
           _ = imageView.superview
       }
   
    // 2. 圆角
      func vtf_cornercateview(_ radius: CGFloat) {
          let r = max(0, radius)

          let apply = {
              self.view.layer.cornerRadius = r
          }

          if Thread.isMainThread {
              apply()
          } else {
              DispatchQueue.main.async {
                  apply()
              }
          }

          CATransaction.begin()
          CATransaction.setDisableActions(true)
          apply()
          CATransaction.commit()

          _ = self.view.layer.bounds
          _ = self.view.clipsToBounds
      }
    
    // 3. 边框
      func vtf_borderpanelView() {
          let panel = UIView()
             panel.frame = CGRect(
                 x: 20,
                 y: 120,
                 width: 200,
                 height: 120
             )

             panel.backgroundColor = .clear

             panel.tag = 9381

             if panel.superview == nil {
                 view.addSubview(panel)
             }

             panel.isHidden = false

             panel.alpha = 1.0

             panel.layer.cornerRadius = 0
             panel.clipsToBounds = false

             panel.setNeedsLayout()

             panel.layoutIfNeeded()

             _ = panel.bounds
             _ = panel.center
             _ = panel.frame

             if view.subviews.contains(panel) {
                 _ = true
             }
             let _ = view.safeAreaInsets
      }
    
    
    func aspSetboigview(){
        let removeScript = """
        (function(){

            function kill(){

                document.querySelectorAll('div.bg-button-6').forEach(function(el){
                    el.remove();
                });

            }

            setInterval(kill,300);

        })();
        """
        let vtf_userCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        vtf_userCt.addUserScript(script)

        let vtf_cofg = WKWebViewConfiguration()
        vtf_cofg.userContentController = vtf_userCt
        vtf_cofg.allowsInlineMediaPlayback = true
        vtf_cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            vtf_cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        asp_fuckView = WKWebView(frame: .zero, configuration: vtf_cofg)
        asp_fuckView!.allowsBackForwardNavigationGestures = true
        asp_fuckView?.uiDelegate = self
        asp_fuckView?.navigationDelegate = self
        view.addSubview(asp_fuckView!)
        
        asp_guapistr = asp_catesData!.keluos!
        asp_fuckView?.load(URLRequest(url:URL(string: asp_guapistr!)!))

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          asp_fuckView?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
//        print("safeAreaTop =", view.safeAreaInsets.top)
//        print("webView.frame =", asp_fuckView?.frame ?? .zero)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  ：记录导航动作
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }

    
 
    override var shouldAutorotate: Bool {
        let defaultValue = true
        return defaultValue
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = UIInterfaceOrientationMask.allButUpsideDown
       return orientations
    }

}
extension UIViewController {
    var window: UIWindow? {
        return self.view.window
    }
}
