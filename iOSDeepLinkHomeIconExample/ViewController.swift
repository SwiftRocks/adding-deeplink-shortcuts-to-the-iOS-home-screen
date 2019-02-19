//
//  ViewController.swift
//  iOSDeepLinkHomeIconExample
//
//  Created by Bruno Rocha on 2/1/19.
//  Copyright © 2019 rockbruno. All rights reserved.
//

import UIKit
import SafariServices
import Swifter

class ViewController: UIViewController {

    var server: HttpServer!

    override func viewDidLoad() {
        super.viewDidLoad()
        server = HttpServer()
        let deepLinkUrl = URL(string: "shortcutTestApp://")!
        let iconBase64 = UIImage(named: "sIcon")!.jpegData(compressionQuality: 0)!.base64EncodedString()
        let pSplashBase64 = UIImage(named: "sPortrait")!.jpegData(compressionQuality: 0)!.base64EncodedString()
        let lSplashBase64 = UIImage(named: "sLandscape")!.jpegData(compressionQuality: 0)!.base64EncodedString()
        let html = htmlFor(title: "MyShortcut", urlToRedirect: deepLinkUrl, iconBase64: iconBase64, pSplashBase64: pSplashBase64, lSplashBase64: lSplashBase64)
        let base64 = html.data(using: .utf8)!.base64EncodedString()
        server["/s"] = { request in
            return .movedPermanently("data:text/html;base64,\(base64)")
        }
        try! server.start(8245)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func shortcutButtonTouched(_ sender: Any) {
        UIApplication.shared.open(URL(string: "http://localhost:8245/s")!)
    }

    func htmlFor(title: String, urlToRedirect: URL, iconBase64: String, pSplashBase64: String, lSplashBase64: String) -> String {
        return """
        <html>
        <head>
        <title>\(title)</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="#ffffff">
        <meta name="apple-mobile-web-app-title" content="\(title)">
        <link rel="apple-touch-icon-precomposed" href="data:image/jpeg;base64,\(iconBase64)"/>
        <link rel="apple-touch-startup-image" media="(orientation: landscape)" href="data:image/jpeg;base64,\(lSplashBase64)"/>
        <link rel="apple-touch-startup-image" media="(orientation: portrait)" href="data:image/jpeg;base64,\(pSplashBase64)"/>
        </head>
        <body>
        <a id="redirect" href="\(urlToRedirect.absoluteString)"></a>
        </body>
        </html>
        <script type="text/javascript">
            if (window.navigator.standalone) {
                var element = document.getElementById('redirect');
                var event = document.createEvent('MouseEvents');
                event.initEvent('click', true, true, document.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, null);
                document.body.style.backgroundColor = '#FFFFFF';
                setTimeout(function() { element.dispatchEvent(event); }, 25);
            } else {
                var p = document.createElement('p');
                var node = document.createTextNode('Click the share button and then ~Add to Home Screen~ to add the shortcut to your home screen!');
                p.appendChild(node);
                document.body.appendChild(p);
            }
        </script>
"""
    }
}
