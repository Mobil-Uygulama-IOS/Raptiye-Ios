//
//  MainAppView.swift
//  Task Flow Versiyon 2
//
//  Created on 13 Ekim 2025.
//

import SwiftUI

// MARK: - MainAppView

struct MainAppView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var projectManager = ProjectManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        print("🚀 MainAppView initialized")
    }
    
    var body: some View {
        let _ = print("🎨 MainAppView body called - User: \(authViewModel.userSession != nil ? "Logged in" : "Not logged in")")
        
        return Group {
            if authViewModel.userSession != nil {
                // User is logged in - show main app
                CustomTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(projectManager)
                    .environmentObject(notificationManager)
                    .onAppear {
                        print("✅ CustomTabView appeared")
                        // Kullanıcı giriş yaptı, listener'ları başlat
                        projectManager.setupListener()
                        notificationManager.setupListeners()
                    }
                    .onDisappear {
                        notificationManager.removeListeners()
                    }
            } else {
                // User is not logged in - show login
                EnhancedLoginView()
                    .environmentObject(authViewModel)
                    .onAppear {
                        print("✅ EnhancedLoginView appeared")
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainAppView()
}