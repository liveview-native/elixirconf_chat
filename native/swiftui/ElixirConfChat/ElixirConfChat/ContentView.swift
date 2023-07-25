//
//  ContentView.swift
//  ElixirConfChat
//
//  Created by May Matyi on 7/13/23.
//

import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm

struct MyRegistry: CustomRegistry {
    typealias Root = AppRegistries
}

struct AppRegistries: AggregateRegistry {
    typealias Registries = Registry2<
        MyRegistry,
        LiveFormRegistry<Self>
    >
}

struct ContentView: View {
    var body: some View {
        LiveView<AppRegistries>(
            .localhost(path: "auth"),
            configuration: LiveSessionConfiguration(navigationMode: .enabled)
        )
    }
}
