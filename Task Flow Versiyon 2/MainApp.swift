//
//  MainAppView.swift
//  Task Flow Versiyon 2
//
//  Created on 13 Ekim 2025.
//

import SwiftUI
import Combine

// MARK: - MainAppView

struct MainAppView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var projectManager = ProjectManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isInitializing = true
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.userSession != nil {
                // User is logged in - show main app
                CustomTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(projectManager)
                    .environmentObject(notificationManager)
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
            // Simulate initialization ve listener'ları başlat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isInitializing = false
                }
                
                // Uygulama açıldığında kullanıcı zaten giriş yapmışsa listener'ları başlat
                if authViewModel.userSession != nil {
                    print("🚀 Uygulama açıldı, kullanıcı giriş yapmış, listener'lar başlatılıyor...")
                    projectManager.setupListener()
                    notificationManager.setupListeners()
                }
            }
        }
        .onChange(of: authViewModel.userSession) { _ in
            if authViewModel.userSession != nil {
                // Kullanıcı giriş yaptı - listener'ları başlat
                print("✅ Kullanıcı giriş yaptı, listener'lar başlatılıyor...")
                projectManager.setupListener()
                notificationManager.setupListeners()
            } else {
                // Kullanıcı çıkış yaptı - listener'ları kaldır
                print("👋 Kullanıcı çıkış yaptı, listener'lar kaldırılıyor...")
                notificationManager.removeListeners()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Uygulama ön plana geldiğinde listener'ları yeniden başlat
            if authViewModel.userSession != nil {
                print("📱 Uygulama ön plana geldi, listener'lar yenileniyor...")
                notificationManager.setupListeners()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainAppView()
}