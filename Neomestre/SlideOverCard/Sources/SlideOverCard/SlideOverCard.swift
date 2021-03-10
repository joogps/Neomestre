//
//  SlideOverCard.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 30/10/20.
//

import SwiftUI

public struct SlideOverCardView<Content:View>: View {
    var isPresented: Binding<Bool>
    
    let onDismiss: (() -> Void)?
    
    var options: SOCOptions
    
    let content: Content
    
    public init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = SOCOptions(), content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.options = options
        self.content = content()
    }
    
    @GestureState private var viewOffset: CGFloat = 0.0
    
    var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
                
                VStack {
                    Spacer()
                    
                    card.padding(isiPad ? 0 : 6)
                    .conditionalAspectRatio(isiPad, 1.0, contentMode: .fit)
                    
                    if isiPad {
                        Spacer()
                    }
                }.ignoresSafeArea(.container, edges: .bottom)
                .transition(isiPad ? AnyTransition.opacity.combined(with: .offset(x: 0, y: 200)) : .move(edge: .bottom))
                .zIndex(2)
            }
        }.animation(.spring(response: 0.35, dampingFraction: 1))
    }
    
    private var card: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if !options.contains(.hideExitButton) {
                Button(action: {
                    isPresented.wrappedValue = false
                    if (onDismiss != nil) { onDismiss!() }
                }) {
                    SOCExitButton()
                }.frame(width: 24, height: 24)
            }
            content
                .padding([.horizontal, options.contains(.hideExitButton) ? .vertical : .bottom], 14)
        }.padding(20)
        .background(RoundedRectangle(cornerRadius: 38.5, style: .continuous)
                        .fill(Color(.systemGray6)))
        .clipShape(RoundedRectangle(cornerRadius: 38.5, style: .continuous))
        .offset(x: 0, y: viewOffset/pow(2, abs(viewOffset)/500+1))
        .gesture(
            options.contains(.disableDrag) ? nil :
                DragGesture()
                .updating($viewOffset) { value, state, transaction in
                    state = value.translation.height
                }
                .onEnded() { value in
                    if value.predictedEndTranslation.height > 175 && !options.contains(.disableDragToDismiss) {
                        isPresented.wrappedValue = false
                        if (onDismiss != nil) { onDismiss!() }
                    }
                }
        )
    }
}

public struct SOCOptions: OptionSet {
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
    static let disableDrag = SOCOptions(rawValue: 1)
    static let disableDragToDismiss = SOCOptions(rawValue: 1 << 1)
    static let hideExitButton = SOCOptions(rawValue: 1 << 2)
}

public struct SOCActionButton: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(Font.body.weight(.medium))
                .padding(.vertical, 20)
                .foregroundColor(.white)
            Spacer()
        }.background(Color.accentColor).overlay(configuration.isPressed ? Color.black.opacity(0.2) : nil).cornerRadius(12)
    }
}

public struct SOCAlternativeButton: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        SOCActionButton().makeBody(configuration: configuration).accentColor(Color(.systemGray5))
    }
}

public struct SOCEmptyButton: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.bold))
            .padding(.top, 18)
            .foregroundColor(.accentColor)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

public struct SOCExitButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .font(Font.body.weight(.bold))
                .scaleEffect(0.416)
                .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
        }
    }
}

struct SOCManager {
    static func present<Content:View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = SOCOptions(), @ViewBuilder content: @escaping () -> Content) {
        let rootCard = SlideOverCardView(isPresented: isPresented, onDismiss: {
            dismiss(isPresented: isPresented)
        }, options: options, content: content)
        
        let controller = UIHostingController(rootView: rootCard)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            isPresented.wrappedValue = true
        }
    }

    static func dismiss(isPresented: Binding<Bool>) {
        isPresented.wrappedValue = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: false)
        }
    }
}

extension View {
    public func slideOverCard<Content:View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = SOCOptions(), @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            
            SlideOverCardView(isPresented: isPresented,
                              onDismiss: onDismiss,
                              options: options) {
                content()
            }
        }
    }
    
    public func slideOverCard<Item:Identifiable, Content:View>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, options: SOCOptions = SOCOptions(), @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let binding = Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
        return self.slideOverCard(isPresented: binding, onDismiss: onDismiss, options: options, content: {
            if let item = item.wrappedValue {
                content(item)
            }
        })
    }
    
    fileprivate func conditionalAspectRatio(_ apply: Bool, _ aspectRatio: CGFloat? = .none, contentMode: ContentMode) -> some View {
        Group {
            if apply {
                self.aspectRatio(aspectRatio, contentMode: contentMode)
            } else { self }
        }
    }
}

struct SlideOverCard_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
        PreviewWrapper().environment(\.colorScheme, .dark)
    }
    
    struct PreviewWrapper: View {
        @State var isPresented = true
        
        @State var disableDrag = false
        @State var disableDragToDismiss = false
        @State var hideExitButton = false
        
        var body: some View {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack {
                    Button("Show card", action: { isPresented = true })
                    Toggle("Disable drag", isOn: $disableDrag)
                    Toggle("DIsable drag to dismiss", isOn: $disableDragToDismiss)
                    Toggle("Hide exit button", isOn: $hideExitButton)
                }
            }.slideOverCard(isPresented: $isPresented, options: options, content: {
                PlaceholderContent(isPresented: $isPresented)
            })
        }
        
        var options: SOCOptions {
            var options = SOCOptions()
            if disableDrag { options.insert(.disableDrag) }
            if disableDragToDismiss { options.insert(.disableDragToDismiss) }
            if hideExitButton { options.insert(.hideExitButton) }
            return options
        }
    }
    
    struct PlaceholderContent: View {
        @Binding var isPresented: Bool
        
        var body: some View {
            VStack(alignment: .center, spacing: 25) {
                HStack {
                    Spacer()
                    VStack {
                        Text("Large title").font(.system(size: 28, weight: .bold))
                        Text("A nice and brief description")
                    }
                    Spacer()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous).fill(Color.gray)
                    Text("Content").foregroundColor(.white)
                }
                
                VStack(spacing: 0) {
                    Button("Do something", action: {
                        isPresented = false
                    }).buttonStyle(SOCActionButton())
                    Button("Just skip it", action: {
                        isPresented = false
                    }).buttonStyle(SOCEmptyButton())
                }
            }.frame(height: 480)
        }
    }
}
