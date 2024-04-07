//
//  ContentView.swift
//  RaveMac
//
//  Created by SeanHuang on 3/27/24.
//

import SwiftUI
import RavePackages

struct ContentView: View {
    @StateObject var vm = RavePackages.CBluetoothPeripherialVM()
    @State private var timeRemaining = 30
    @State private var counting = false
    @State var timer = Timer.publish(every:1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let _ = Self._printChanges()
        VStack {
            Button(action:{counting = !counting}){
                Text(counting ? "Stop advertising" : "Start advertising")
            }
            Text("Time left : \(timeRemaining)")
        }.onReceive(timer){_ in
            if(counting){
                timeRemaining = ((timeRemaining - 1) + 30) % 30
                timeRemaining = timeRemaining == 0 ?  30 : timeRemaining
                print(timeRemaining)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
