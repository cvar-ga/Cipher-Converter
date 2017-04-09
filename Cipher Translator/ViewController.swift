//
//  ViewController.swift
//  Cipher Translator
//
//  Created by Charles Karoly Varga Jr on 4.8.17.
//  Copyright © 2017 Charles Karoly Varga Jr. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate {
    @IBOutlet weak var entryField: UITextView!
    @IBOutlet weak var convertFromControl: UISegmentedControl!
    @IBOutlet weak var convertToControl: UISegmentedControl!
    @IBOutlet weak var translateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func convert(_ sender: Any) {
        guard String(entryField.text!) != nil else{
            entryField.text=""
            return
        }
        switch(convertFromControl.selectedSegmentIndex){
        case 0:
            switch(convertToControl.selectedSegmentIndex){
            case 0: break
            default: entryField.text=encipher(input: entryField.text,toIndex:convertToControl.selectedSegmentIndex)
            }
        default:
            switch(convertToControl.selectedSegmentIndex){
            case 0: entryField.text=decipher(input:entryField.text,fromIndex:convertFromControl.selectedSegmentIndex)
            default: entryField.text=transcipher(input:entryField.text,fromIndex:convertFromControl.selectedSegmentIndex,toIndex:convertToControl.selectedSegmentIndex)
            }
        }
    }
    // Convert from English to cipher code
    private func encipher(input:String,toIndex:Int)->String{
        var temp=""
        switch(toIndex){
        case 0: return input
        case 1:
            for uni in input.unicodeScalars{
                var c=uni.value
                // Brute force
                if c==0x20{
                    temp.append(Character(UnicodeScalar(c)!))
                }else if (c >= 0x41 && c <= 0x57)||(c>=0x61&&c<=0x77) {
                    c += 2
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x58{
                    temp.append("Z")
                }else if c==0x78{
                    temp.append("z")
                }else if c==0x59{
                    c=0x41
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x5A{
                    c=0x42
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x79{
                    c=0x61
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x7A{
                    c=0x62
                    temp.append(Character(UnicodeScalar(c)!))
                }else{temp.append(Character(UnicodeScalar(c)!))}
            }
            break
        case 2:
            let reverse:[(key:String,value:String)]=[("A","Z"),("B","Y"),("C","X"),("D","W"),("E","V"),("F","U"),("G","T"),("H","S"),("I","R"),("J","Q"),("K","P"),("L","O"),("M","N"),("N","M"),("O","L"),("P","K"),("Q","J"),("R","I"),("S","H"),("T","G"),("U","F"),("V","E"),("W","D"),("X","C"),("Y","B"),("Z","A"),("a","z"),("b","y"),("c","x"),("d","w"),("e","v"),("f","u"),("g","t"),("h","s"),("i","r"),("j","q"),("k","p"),("l","o"),("m","n"),("n","m"),("o","l"),("p","k"),("q","j"),("r","i"),("s","h"),("t","g"),("u","f"),("v","e"),("w","d"),("x","c"),("y","b"),("z","a")]
            for char in input.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                if(str>=0x20&&str<=0x2F){
                    temp.append(newStr)
                }else{temp.append(reverse[sequentialSearch(char:newStr,array:reverse)].value)
                }
            }
        case 3:
            let polyibusSquare=[["","","","","",""],
                                ["","A","F","L","Q","V"],
                                ["","B","G","M","R","W"],
                                ["","C","H","N","S","X"],
                                ["","D","IJ","O","T","Y"],
                                ["","E","K","P","U","Z"]]
            for char in input.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                if(str>=0x20&&str<=0x2F){
                    temp.append(newStr)
                }else{
                    temp.append(twoDimArraySearch(char:newStr,array: polyibusSquare))
                }
            }
        case 4:
            var railRoad = [[String]](repeating:[String](repeating:".",count:input.characters.count),count:3)
            var i=0,j=0,incrementing=true
            for char in input.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                railRoad[i][j]=newStr
                if(i==1 && !incrementing){
                    i-=1
                }
                if(i==2){
                    i-=1
                    incrementing=false
                }
                if(i==1&&incrementing){
                    i+=1
                }
                if(i==0&&incrementing){
                    i+=1
                }
                if(i==0){
                    incrementing=true
                }
                j+=1
            }
            i=0
            while i<railRoad.count{
                j=0
                while j<railRoad[i].count{
                    temp.append(railRoad[i][j])
                    j+=1
                }
                temp.append("\n")
                i+=1
            }
        default:break
        }
        return temp
    }
    private func twoDimArraySearch(char:String,array:[[String]])->String{
        var value=""
        var i=1
        while i<array.count{
            var j=1
            while j<array[i].count{
                if char.caseInsensitiveCompare(array[i][j])==ComparisonResult.orderedSame{
                    value="\(i)\(j)"
                }
                j+=1
            }
            i+=1
        }
        if char.caseInsensitiveCompare("i")==ComparisonResult.orderedSame||char.caseInsensitiveCompare("j")==ComparisonResult.orderedSame{
            value="42"
        }
        return value
    }
    private func sequentialSearch(char:String,array:Array<(key:String,value:String)>)->Int{
        var i=0,returnValue=0
        for (input,_) in array{
            if char==input{
                returnValue=i
            }
            i+=1
        }
        return returnValue
    }
    // Convert from cipher code to English
    private func decipher(input:String,fromIndex:Int)->String{
        var temp=""
        switch(fromIndex){
        case 0:
            temp=input
        case 1:
            for uni in input.unicodeScalars{
                var c=uni.value
                // Brute force
                if c==0x20{
                    temp.append(Character(UnicodeScalar(c)!))
                }else if (c >= 0x43 && c <= 0x59)||(c>=0x63&&c<=0x79) {
                    c -= 2
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x5A{
                    temp.append("X")
                }else if c==0x7A{
                    temp.append("x")
                }else if c==0x41{
                    c=0x59
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x5A{
                    c=0x58
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x79{
                    c=0x77
                    temp.append(Character(UnicodeScalar(c)!))
                }else if c==0x7A{
                    c=0x78
                    temp.append(Character(UnicodeScalar(c)!))
                }else{temp.append(Character(UnicodeScalar(c)!))}
            }
        case 2:
            let reverse:[(key:String,value:String)]=[("Z","A"),("Y","B"),("X","C"),("W","D"),("V","E"),("U","F"),("T","G"),("S","H"),("R","I"),("Q","J"),("P","K"),("O","L"),("N","O"),("M","N"),("L","O"),("K","P"),("J","Q"),("I","R"),("H","S"),("G","T"),("F","U"),("E","V"),("D","W"),("C","X"),("B","Y"),("A","Z"),("z","a"),("y","b"),("x","c"),("w","d"),("v","e"),("u","f"),("t","g"),("s","h"),("r","i"),("q","j"),("p","k"),("o","l"),("n","m"),("m","n"),("l","o"),("k","p"),("j","q"),("i","r"),("h","s"),("g","t"),("f","u"),("e","v"),("d","w"),("c","x"),("b","y"),("a","z")]
            for char in input.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                if(str>=0x20&&str<=0x2F){
                    temp.append(newStr)
                }else{temp.append(reverse[sequentialSearch(char:newStr,array:reverse)].value)
                }
            }
        case 3:
            let polyibusSquare=[["","","","","",""],
                                ["","A","F","L","Q","V"],
                                ["","B","G","M","R","W"],
                                ["","C","H","N","S","X"],
                                ["","D","IJ","O","T","Y"],
                                ["","E","K","P","U","Z"]]
            var i=0,row=0,col=0
            var c:String=""
            for char in input.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                if(str>=0x20&&str<=0x2F){
                    temp.append(newStr)
                }else{
                    c=newStr
                    i+=1
                    if(i%2 != 0){
                        row=Int(c)!
                    }else{
                        col=Int(c)!
                    }
                    if(row != 0&&col != 0){
                        temp.append(polyibusSquare[row][col])
                        row=0
                        col=0
                    }
                }
            }
        case 4:
            var str0=input.replacingOccurrences(of: "\n", with: "")
            var railRoad = [[String]](repeating:[String](repeating:".",count:((str0.characters.count)/3)/*-1*/),count:3)
            var i=0,j=0,incrementing=true
            for char in str0.unicodeScalars{
                let str=char.value
                let newStr=(String(UnicodeScalar(str)!))
                if(j != railRoad[i].count){
                    if i==0{
                        railRoad[i][j]=newStr
                    }
                    if i==1&&j != railRoad[i].count-1{
                        railRoad[i][j+1]=newStr
                    }
                    if i==2&&j != railRoad[i].count-2{
                        railRoad[i][j+2]=newStr
                    }
                }
                if j<railRoad[i].count{
                    j+=1
                }else{
                    if i<railRoad.count{
                        i+=1
                    }
                    j=0
                }
            }
            i=0
            j=0
            while j<railRoad[0].count{
                if(i==0&&j==0){
                    temp.append(railRoad[i][j])
                }
                if(i==1 && !incrementing){
                    i-=1
                }
                if(i==2){
                    i-=1
                    incrementing=false
                }
                if(i==1&&incrementing){
                    i+=1
                }
                if(i==0&&incrementing){
                    i+=1
                }
                if(i==0){
                    incrementing=true
                }
                j+=1
                if(j != railRoad[0].count){
                    if(railRoad[i][j] != "."){
                        temp.append(railRoad[i][j])
                    }
                }
            }
        default:break
        }
        return temp
    }
    // WTF AM I DOING
    private func transcipher(input:String,fromIndex:Int,toIndex:Int)->String{
        var str0:String,str1:String
        if(fromIndex==toIndex){
            return input
        }else{
            str0=decipher(input:input,fromIndex:fromIndex)
            str1=encipher(input:str0,toIndex:toIndex)
        }
        return str1
    }
}
