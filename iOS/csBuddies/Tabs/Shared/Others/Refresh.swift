// Source: https://github.com/siteline/SwiftUIRefresh

import SwiftUI
import Introspect

private struct Refresh: UIViewRepresentable {
    @Binding var isRefreshing: Bool
    
    public init(isRefreshing: Binding<Bool>) {
        _isRefreshing = isRefreshing
    }
    
    public class Coordinator {
        let isRefreshing: Binding<Bool>
        
        init(isRefreshing: Binding<Bool>) {
            self.isRefreshing = isRefreshing
        }
        
        @objc
        func onValueChanged() {
            isRefreshing.wrappedValue = true
        }
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Refresh>) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func tableView(entry: UIView) -> UITableView? {
        // Search in ancestors
        if let tableView = Introspect.findAncestor(ofType: UITableView.self, from: entry) {
            return tableView
        }
        
        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }
        
        // Search in siblings
        return Introspect.previousSibling(containing: UITableView.self, from: viewHost)
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Refresh>) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let tableView = self.tableView(entry: uiView) else {
                return
            }
            
            if let refreshControl = tableView.refreshControl {
                // Do not wait to end refreshing to prevent crashes by frequent refresh.
                // For example, the app crashes if user switches tabs rapidly right after app is launched.
                // Instead, show a loading screen in the view on refresh, just like when the view is first loaded.
                refreshControl.endRefreshing()
                return
                
                /*if self.isRefreshing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
                return*/
            }
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.onValueChanged), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(isRefreshing: $isRefreshing)
    }
}

extension View {
    public func refresh(isRefreshing: Binding<Bool>, isRefreshingBool: Bool, onRefresh: @escaping () -> Void) -> some View {
        self
            .overlay( // Simply animate loading instead of running onRefresh since the bottom overlay takes care of it.
                VStack {
                    Refresh(isRefreshing: isRefreshing)
                        .frame(width: 0, height: 0)
                }
            )
            .overlay( // Programmatically run refresh regardless of where you are on the screen.
                VStack {
                    if isRefreshingBool {
                        Spacer()
                            .onAppear {
                                onRefresh()
                            }
                    }
                }
            )
    }
}
