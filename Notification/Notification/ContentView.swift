//
//  ContentView.swift
//  Notification
//
//  Created by Sangmok Han on 10/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                Button("Show Notification") {
                    UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 5, swipeToClose: true) {
                        HStack{
                            Spacer()
                            VStack{
                                Spacer()
                                Text("Hello world")
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }.padding(15)
                            Spacer()
                        }
                        .padding(15)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)
                        }
                    }
                }
            }
            .navigationTitle("Notification")
        }
    }
}

#Preview {
    ContentView()
}
