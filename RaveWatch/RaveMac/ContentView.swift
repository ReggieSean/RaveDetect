//
//  ContentView.swift
//  RaveMac
//
//  Created by SeanHuang on 3/27/24.
//

import SwiftUI
import RavePackages

struct ContentView: View {
    @StateObject var peripheralVM = RavePackages.CBluetoothPeripherialVM()
    
    var body: some View {
        let _ = Self._printChanges()
        VStack {
            Button(action:{peripheralVM.flipAdvertising()}){
                Text(peripheralVM.advertising ? "Stop advertising" : "Start advertising")
            }
            Text("Time left : \(peripheralVM.timeRemaining)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
