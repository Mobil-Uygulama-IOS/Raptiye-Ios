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
    @State private var isInitializing = true
    
    private var notificationManager: NotificationManager {
        NotificationManager.shared
    }
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.userSession != nil {
                // User is logged in - show main app
                CustomTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(projectManager)
                    .environmentObject(notificationManager)
                    .onAppear {
                        // Kullanıcı giriş yaptı, listener'ı başlat
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
            }
            }
            
            // Initial loading overlay
            if isInitializing {
                Color(red: 0.11, green: 0.13, blue: 0.16)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Raptiye İkonu - Giriş ekranıyla aynı
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.40, green: 0.84, blue: 0.55).opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "pin.fill")
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundColor(Color(red: 0.40, green: 0.84, blue: 0.55))
                            .rotationEffect(.degrees(45))
                    }
                    
                    Text("Raptiye")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.40, green: 0.84, blue: 0.55)))
                        .scaleEffect(1.5)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            // Simulate initialization
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isInitializing = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainAppView()
}