//
//  ContentView.swift
//  ElixirConfChatMac
//
//  Created by May Matyi on 8/21/23.
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
        .localhost(path: {
            if let token = UserDefaults.standard.value(forKey: "token") {
                return "/chat/\(token)"
            }
            return "/"
        }()),
        config: LiveSessionConfiguration(navigationMode: .replaceOnly)
    )
    
    var body: some View {
        LiveView(session: coordinator)
            .onReceive(coordinator.receiveEvent("persist_token"), perform: { coordinator, payload in
                print("persisting token...")

                UserDefaults.standard.setValue(payload["token"], forKey: "token")
            })
    }
}
