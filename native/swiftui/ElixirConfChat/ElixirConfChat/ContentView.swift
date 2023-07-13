//
//  ContentView.swift
//  ElixirConfChat
//
//  Created by May Matyi on 7/13/23.
//

import SwiftUI
import LiveViewNative

struct ContentView: View {
    var body: some View {
        LiveView(
            .localhost(path: "hello"),
            configuration: LiveSessionConfiguration(navigationMode: .enabled)
        )
    }
}
