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
    @StateObject var centralVm = CBVM()
    let topHeight  = 0.2
    let remain  = 0.8
    let colors = [Color.brown, Color.blue, Color.black]
    @State var idx = 0
    var body: some View {
        ///let _ = Self._printChanges()
        VStack{
            GeometryReader{ geo in
                VStack{
                    Text(centralVm.gyroData)
                    Button(action: {centralVm.flipScanning()}, label: {
                        Text(centralVm.scanning ? "Stop" : "Start").font(.footnote)
                    }).frame(height: 40)
                    Section(header: Text("RaveDevices").frame(alignment: .leading).padding(EdgeInsets(top: 5, leading:0, bottom: 0, trailing: 0))){
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)).frame(height: geo.size.height * remain).foregroundColor(colors[idx]).overlay(
                            ScrollView{
                                Form{
                                    ForEach(centralVm.peripherials, id: \.identifier){per in
                                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)).overlay(
                                            Button(action:{centralVm.onPeripheralClicked(Peripheral: per)} ,
                                                   label: {Label(title: {Text("Peripheral:\(per.name ?? "no-name")").foregroundStyle(.black) },
                                                    icon: { Image(systemName: "42.circle") }
                                                )
                                            })
                                        )
                                    }
                                }.frame(width: geo.size.width, height: geo.size.height * remain )
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
}

#Preview {
    ContentView()
}
