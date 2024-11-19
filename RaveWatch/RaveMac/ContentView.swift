//
//  ContentView.swift
//  RaveMac
//
//  Created by SeanHuang on 3/27/24.
//
import SwiftUI
import RavePackages

struct ContentView: View {
    @StateObject var vm = CBluetoothPeripherialVM()
    
    var body: some View {
////Bluetooth transmission test
//        let _ = Self._printChanges()
                
        GeometryReader{proxy in
            
            VStack {
                ScrollView {
                    Text(vm.textOnScreen)
                        .fontWeight(.bold)
                        .font(.system(.title, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: proxy.size.height)  // << here !!
                }.padding()
                Button(action:{vm.flipAdvertising()}){
                    Text(vm.advertising ? "Stop advertising" : "Start advertising")
                }
                Text("Time left : \(vm.timeRemaining)")
            }
            .padding()
        }
        //Unix Socket transmission test
//        GeometryReader{proxy in
//            VStack(alignment: .center){
//                ScrollView {
//                    Text("This is a joke. Multiple line is supported. This is a joke. Multiple line is supported. This is a joke. Multiple line is supported. ")
//                        .fontWeight(.bold)
//                        .font(.system(.title, design: .rounded))
//                        .multilineTextAlignment(.leading)
//                        .frame(minHeight: proxy.size.height)  // << here !!
//                }.padding()
//                HStack{
//                    Button {
//                        print("trying to connect")
//                    } label: {
//                        Text("Connect")
//                    }
//
//                }.padding()
//
//            }
//        }
    }
}

#Preview {
    ContentView()
}
