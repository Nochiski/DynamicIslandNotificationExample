//
//  InAppNotificationExtension.swift
//  Notification
//
//  Created by Sangmok Han on 10/30/23.
//

import SwiftUI

extension UIApplication {
    func inAppNotification<Content: View>(adaptForDynamicIsland: Bool = false, timeout: CGFloat = 5, swipeToClose: Bool = true,
                           @ViewBuilder content: @escaping () -> Content) {
        // Fetching Active Window VIA WindowScene
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
            $0.isKeyWindow }){
            // Frame and SafeArea Values
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets
            
            let checkForDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
            
            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(),
                    safeArea: safeArea,
                    adaptForDynamicIsland: checkForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose
                )
                .frame(width: frame.width-(checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
                .contentShape(.rect)
            }
            
            let view = config.makeContentView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            activeWindow.addSubview(view)
            
            view.centerXAnchor.constraint(equalTo: activeWindow.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: activeWindow.centerYAnchor, constant: (-(frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
        }
    }
}

fileprivate struct AnimatedNotificationView<Content: View>: View{
    var content: Content
    var safeArea: UIEdgeInsets
    var adaptForDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    
    @State private var animateNotification: Bool = false
    var body: some View{
        content
            .blur(radius: animateNotification ? 0 : 10)
            .disabled(!animateNotification)
            .mask {
                if adaptForDynamicIsland {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                } else {
                    Rectangle()
                }
            }
        // Scaling Animation only For Dynamic Island Notification
            .scaleEffect(adaptForDynamicIsland ? (animateNotification ? 1 : 0.01) : 1, anchor: .init(x:0.5, y:0.01))
        // Offset Animation for Non Dynamic Island Notification
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 50 && swipeToClose {
                            withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                                animateNotification = false
                            } completion: {
                                
                            }
                        }
                    })
            )
            .onAppear(perform: {
                Task {
                    guard !animateNotification else { return }
                    withAnimation(.smooth) {
                        animateNotification = true
                    }
                    
                    try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
                    
                    guard animateNotification else { return }
                    
                    withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                        animateNotification = false
                    } completion: {
                        
                    }
                }
            })

    }
    var offsetY: CGFloat {
        if adaptForDynamicIsland {
            return 0
        }
        return animateNotification ? 0 : -(safeArea.top + 130)
    }
}

#Preview {
    ContentView()
}
 
