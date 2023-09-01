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
    @StateObject private var coordinator = LiveSessionCoordinator<AppRegistries>(
        {
            #if DEBUG
            let baseURL = URL(string: "http://localhost:4000/")!
            #else
            let baseURL = URL(string: "https://chat.elixirconf.com/")!
            #endif

            if let token = UserDefaults.standard.value(forKey: "token") {
                return baseURL.appending(path: "/chat/\(token)")
            }
            return baseURL
        }(),
        config: LiveSessionConfiguration(navigationMode: .replaceOnly)
    )
    
    var body: some View {
        LiveView(session: coordinator)
            .onReceive(coordinator.receiveEvent("persist_token"), perform: { coordinator, payload in
                UserDefaults.standard.setValue(payload["token"], forKey: "token")
            })
    }
}
