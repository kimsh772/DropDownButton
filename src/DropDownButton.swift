//
//  DropDownButton.swift
//
//  Created by Kim Sunghyun on 2017. 11. 30..
//  Copyright © 2017년 Zaraza Inc. All rights reserved.
//

import UIKit
import SnapKit

protocol DropDownDelegate: class {
    func dropDownPressed(target: DropDownButton? ,index: Int ,string: String)
}

class DropDownButton: UIButton, DropDownDelegate {
    
    func dropDownPressed(target: DropDownButton? ,index:Int ,string: String) {
        self.nowIndex = index
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
        delegate?.dropDownPressed(target: self, index: index, string: string)
    }
    
    weak var delegate: DropDownDelegate?
    var dropView = DropDownView()
    var bg = UIView().then {
        $0.backgroundColor = UIColor.clear
    }
    var height = NSLayoutConstraint()
    var nowIndex = 0
    let arrowLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        tap.cancelsTouchesInView = false
        bg.addGestureRecognizer(tap)
        bg.isHidden = true
        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func tapped(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        if dropView.frame.contains(point) == false {
            self.dismissDropDown()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: rect.width - 14.0, y: rect.height / 2.0 - 3.0))
        path.addLine(to: CGPoint.init(x: rect.width - 2.0, y: rect.height / 2.0 - 3.0))
        path.addLine(to: CGPoint.init(x: rect.width - 8.5, y: rect.height / 2.0 + 3.0))
        path.addLine(to: CGPoint.init(x: rect.width - 14.0, y: rect.height / 2.0 - 3.0))
        arrowLayer.path = path.cgPath
        arrowLayer.fillColor = UIColor.init(argb: 0xff777777).cgColor
        self.layer.addSublayer(arrowLayer)
    }
    
    override func didMoveToSuperview() {
        self.superview?.addSubview(bg)
        self.superview?.bringSubview(toFront: bg)
        self.superview?.addSubview(dropView)
        self.superview?.bringSubview(toFront: dropView)
        bg.snp.makeConstraints {
            $0.top.equalTo(0)
            $0.bottom.equalTo(UIScreen.main.bounds.size.height)
            $0.left.equalTo(0)
            $0.right.equalTo(UIScreen.main.bounds.size.width)
        }
        dropView.snp.makeConstraints {
            $0.top.equalTo(self.snp.bottom)
            $0.centerX.equalTo(self.snp.centerX)
            $0.width.equalTo(self.snp.width)
        }
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            isOpen = true
            bg.isHidden = false
            self.superview?.bringSubview(toFront: bg)
            self.superview?.bringSubview(toFront: dropView)
            NSLayoutConstraint.deactivate([self.height])
            if self.dropView.tableView.contentSize.height > 150 {
                self.height.constant = 150
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)
        } else {
            isOpen = false
            bg.isHidden = true
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        bg.isHidden = true
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setData(data: [String]) {
        self.dropView.dropDownOptions = data
        self.nowIndex = 0
        if data.count > 0 {
            self.setTitle(data[0], for: .normal)
        }
    }
    
    func setIndex(_ index:Int) {
        if self.dropView.dropDownOptions.count > index  {
            dropDownPressed(target: nil ,index: index ,string: self.dropView.dropDownOptions[index])
        } else {
            print("DropDownButton setIndex error !!")
        }
    }
    
    func getIndex() -> Int {
        return self.nowIndex
    }
    
    func getString() -> String {
        if self.dropView.dropDownOptions.count > nowIndex  {
            return self.dropView.dropDownOptions[nowIndex]
        }
        return ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    var dropDownOptions = [String]()
    var tableView = UITableView().then {
        $0.backgroundColor = UIColor.init(argb: 0xffeeeeee)
    }
    weak var delegate : DropDownDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(argb: 0xffeeeeee)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.bottom.equalTo(self.snp.bottom)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.textColor = UIColor.darkGray
        cell.backgroundColor = UIColor.init(argb: 0xffeeeeee)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownPressed(target: nil ,index: indexPath.row ,string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
