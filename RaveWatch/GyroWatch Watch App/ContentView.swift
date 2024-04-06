//
//  ContentView.swift
//  GyroWatch Watch App
//
//  Created by SeanHuang on 3/27/24.
//

import SwiftUI

import RavePackages

typealias CBVM =  RavePackages.CBluetoothCentralVM

struct ContentView: View {
    @StateObject var vm = CBVM()
    let topHeight  = 0.2
    let remain  = 0.8
    let colors = [Color.brown, Color.blue, Color.black ]
    @State var idx = 0
    var body: some View {
        let _ = Self._printChanges()
        VStack{
            GeometryReader{ geo in
                VStack{
                    Button(action: {idx = (idx + 1) % 3}, label: {
                        Text("BLT").font(.footnote)
                    }).frame(width : 50, height: 40)
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)).frame(height: geo.size.height * remain).foregroundColor(colors[idx]).overlay(
                        ScrollView{
                            Form{
//                                ForEach(vm.peripherials, id: \.self){per in
//                                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)).overlay(
//                                        Text(per.description)
//                                    )
//                                }
                            }
                        }.onAppear(
                        perform: {
                        print("Button appeared")
                    })
                    )
                }
            }
           
        }
    }
}

#Preview {
    ContentView()
}
