//
//  ViewController.swift
//  ExampleApp
//
//  Created by wang_wang164@163.com on 2022/3/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    
    func setUI() {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let btnW = 200.0
        let btnH = 30.0
        let button1 = UIButton(frame: CGRect(x: w/2 - btnW/2, y: h/3 + btnH/2, width: btnW, height: btnH))
        button1.setTitle("go to page1", for: .normal)
        button1.setTitleColor(.blue, for: .normal)
        button1.addTarget(self, action: #selector(goToPage1), for: .touchUpInside)
        self.view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRect(x: w/2 - btnW/2, y: 2*h/3 + btnH/2, width: btnW, height: btnH))
        button2.setTitle("tap to trigger crash", for: .normal)
        button2.setTitleColor(.blue, for: .normal)
        button2.addTarget(self, action: #selector(tapCauseCrash), for: .touchUpInside)
        self.view.addSubview(button2)
        
        self.view.backgroundColor = .white
    }
    
    @objc func goToPage1() {
        let page1 = UIViewController()
        page1.title = "page1"
        self.navigationController?.pushViewController(page1, animated: true)
    }
    
    @objc func tapCauseCrash() {
        let array = [1,2]
        print(array[3]) // This will trigger a crash.
    }
    
}

