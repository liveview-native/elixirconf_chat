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

    static func loadingView(for url: URL, state: LiveSessionState) -> some View {
        ProgressView()
    }
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
            .localhost(path: "/"),
            configuration: LiveSessionConfiguration(navigationMode: .replaceOnly)
        )
    }
}
