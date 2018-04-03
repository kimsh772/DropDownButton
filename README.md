# DropDownButton
swift SnapKit using dropdown button

require SnapKit

var dataCount = ["2","4","6","8","10"]

let btnCount = DropDownButton()

btnCount.setTitleColor(UIColor.darkGray, for: .normal)

btnCount.backgroundColor = UIColor.white

btnCount.setData(data: dataCount )



// get data

let count = btnCount.getString()



// set delegate 

btnCount.delegate = self

extension Test:  DropDownDelegate {

    func dropDownPressed(target: DropDownButton? ,index:Int ,string: String) {
    
    }
    
}



//check open

btnCount.isOpen



//close dropdown list

btnCount.dismissDropDown()

