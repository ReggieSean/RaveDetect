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
    
    var body: some View {
        let _ = Self._printChanges()
        VStack {
            Button(action:{vm.advertising = !vm.advertising}){
                Text(vm.advertising ? "Stop advertising" : "Start advertising")
            }
            Text("Time left : \(vm.timeRemaining)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
