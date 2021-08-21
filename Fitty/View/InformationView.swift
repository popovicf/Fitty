//
//  PostView.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI

struct InformationView: View {
    
    @StateObject var settingsData = SettingsViewModel()
    @State var size1 = UIScreen.main.bounds.width - 100
    @State var size2 = UIScreen.main.bounds.width - 100
    @State var progress1: CGFloat = 0
    @State var progress2: CGFloat = 0
    @State var angle1: Double = 0
    @State var angle2: Double = 0
    @State var angleValueWeight: CGFloat = 0.0
    @State var angleValueHeight: CGFloat = 0.0
    var bmiCalculator = BMICalculator()
    var color: Color = .white
    let radius: CGFloat = 110
    let knobRadius: CGFloat = 20
    let configHeight = CircularProgressConfig(minimumValue: 0, maximumValue: 2.50, totalValue: 2.50)
    let configWeight = CircularProgressConfig(minimumValue: 0, maximumValue: 150, totalValue: 150)
    let strokeWidth: CGFloat = 40
    
    var body: some View {
        NoSepratorList{
            VStack(spacing: 40){
                HStack(){
                    VStack(alignment: .leading){
                        Text("Weight:")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding(.trailing)
                    .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                    
                    VStack(){
                        Text(settingsData.userInfo.weight + "kg")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                }
                .padding()
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    ProgressBackgroundView(radius: radius)
                    Circle()
                        .trim(from: 0.0, to: progress1/configWeight.totalValue)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: strokeWidth + 5, lineCap: .round))
                        .frame(width: radius * 2, height: radius * 2)
                        .rotationEffect(.degrees(-90))
                    
                    KnobView(radius: knobRadius)
                        .offset(y: -radius)
                        .rotationEffect(.degrees(Double(angleValueWeight)))
                        .animation(.easeInOut)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: -4)
                        .gesture(DragGesture(minimumDistance: 10)
                                    .onChanged({ value in self.changeProgress(locaton: value.location, config: configWeight) }) )
                        .rotationEffect(.degrees(0))
                    
                    ProgressIndicatorsView(progress: $progress1, totalValue: configWeight.totalValue)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(String.init(format: "%.0f", progress1))kg")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.top, 60)
                Spacer()
            }
            .padding(.top, 30)
            
            VStack(spacing: 40){
                HStack(){
                    VStack(alignment: .leading){
                        Text("Height:")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding(.trailing)
                    .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .leading)
                    
                    VStack(){
                        Text(settingsData.userInfo.height + "m")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.size.width/2), maxHeight: .infinity, alignment: .trailing)
                }
                .padding()
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    ProgressBackgroundView(radius: radius)
                    Circle()
                        .trim(from: 0.0, to: progress2/configHeight.totalValue)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: strokeWidth + 5, lineCap: .round))
                        .frame(width: radius * 2, height: radius * 2)
                        .rotationEffect(.degrees(-90))
                    
                    KnobView(radius: knobRadius)
                        .offset(y: -radius)
                        .rotationEffect(.degrees(Double(angleValueHeight)))
                        .animation(.easeInOut)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: -4)
                        .gesture(DragGesture(minimumDistance: 10)
                                    .onChanged({ value in self.changeProgress(locaton: value.location, config: configHeight) }))
                        .rotationEffect(.degrees(0))
                    
                    ProgressIndicatorsView(progress: $progress2, totalValue: configHeight.totalValue)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(String.init(format: "%.2f", progress2))m")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.top, 60)
                Spacer()
            }
            .background(settingsData.color)
            
            HStack(spacing: 20) {
                Text("BMI: \(String(format: "%.1f", Float(settingsData.userInfo.bmiValue) ?? 0.0))")
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .bold()
                
                Text("\(settingsData.userInfo.bmiAdvice)")
                    .bold()
                    .font(.system(size: 28))
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(Color.white).clipShape(Capsule())
                    .foregroundColor(settingsData.color)
            }
            .padding(.bottom, 50)
            .padding(.top, 50)
            
            VStack() {
                Button(action: {
                    let weight = String(format: "%.0f", progress1)
                    let height = String(format: "%.2f", progress2)
                    settingsData.updateUserInfo(key: "height", value: height)
                    settingsData.updateUserInfo(key: "weight", value: weight)
                    settingsData.height = height
                    settingsData.weight = weight
                    settingsData.calculateBmi()
                }) {
                    Text("Submit")
                        .bold()
                        .font(.system(size: 20))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                .padding()
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(40)
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 40, trailing: 30))
        }
        .onAppear{
            updateInitialValueWeight()
            updateInitialValueHeight()
        }
        .onChange(of: settingsData.userInfo.bmiAdvice) { advice in
            if advice == "Normal" {
                settingsData.color = .green
            } else if advice == "Underweight" {
                settingsData.color = .blue
            } else {
                settingsData.color = .red
            }
        }
        .padding(.top, 80)
        .background(settingsData.color)
    }
    
    func updateInitialValueWeight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            angle1 = Double(settingsData.userInfo.weight) ?? 10
            progress1 = CGFloat(Double(settingsData.userInfo.weight) ?? 10)
            angleValueWeight = CGFloat(progress1/configWeight.totalValue) * 360
        }
    }
    
    func updateInitialValueHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            angle2 = Double(settingsData.userInfo.height) ?? 0
            progress2 = CGFloat(Double(settingsData.userInfo.height) ?? 0)
            angleValueHeight = CGFloat(progress2/configHeight.totalValue) * 360
        }
    }
    
    private func changeProgress(locaton: CGPoint, config: CircularProgressConfig) {
        let vector = CGVector(dx: locaton.x, dy: locaton.y)
        let angle = atan2(vector.dy - knobRadius, vector.dx - knobRadius) + .pi/2.0
        
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = fixedAngle / (2.0 * .pi) * config.totalValue
        
        if value > config.minimumValue && value < config.maximumValue {
            if config.totalValue == configWeight.totalValue {
                progress1 = value
                angleValueWeight = fixedAngle * 180 / .pi
            } else {
                progress2 = value
                angleValueHeight = fixedAngle * 180 / .pi
            }
        }
    }
}

struct NoSepratorList<Content>: View where Content: View {
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView {
                LazyVStack(spacing: 30) {
                    self.content()
                }
            }
        } else {
            List {
                self.content()
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
        }
    }
}

struct ProgressBackgroundView: View {
    let radius: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: radius * 2, height: radius * 2)
                .scaleEffect(1.3)
                .shadow(color: .sliderTopShadow, radius: 10, x: -5, y: -5)
                .shadow(color: .sliderBottomShadow, radius: 10, x: 5, y: 5)
            
            Circle()
                .stroke(Color.white, lineWidth: 52)
                .frame(width: radius * 2, height: radius * 2)
        }
    }
}

struct KnobView: View {
    let radius: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: radius * 2, height: radius * 2)
            
            Circle()
                .fill(Color.orange)
                .frame(width: 4, height: 4)
        }
    }
}

struct CircularProgressConfig {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
}

struct ProgressIndicatorsView: View {
    @Binding var progress: CGFloat
    let totalValue: CGFloat
    let indicatorCount = 8
    var body: some View {
        ZStack {
            ForEach(Array(stride(from: 0, to: indicatorCount, by: 1)), id: \.self) { i in
                IndicatorView(
                    isOn: progress >= CGFloat(i) * totalValue/CGFloat(indicatorCount),
                    offsetValue: 160)
                    .rotationEffect(.degrees(Double(i * 360/indicatorCount)))
            }
        }
    }
}

struct IndicatorView: View {
    let isOn: Bool
    let offsetValue: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isOn ? Color.orange : Color.white)
            .frame(width: 15, height: 3)
            .offset(x: offsetValue)
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}

extension Color {
    static let textPrimary              = Color.init(red: 253/255, green: 253/255, blue: 253/255)
    
    static let sliderIndicator          = Color.init(red: 23/255, green: 24/255, blue: 28/255)
    
    static let sliderBackgroundEnd      = Color.init(red: 19/255, green: 19/255, blue: 20/255)
    static let sliderInnerBackground    = Color.init(red: 31/255, green: 33/255, blue: 36/255)
    
    static let sliderTopShadow          = Color.init(red: 72/255, green: 80/255, blue: 87/255)
    static let sliderBottomShadow       = Color.init(red: 20/255, green: 20/255, blue: 21/255)
    
    static let blueIndicaor             = Color.init(red: 14/255, green: 155/255, blue: 239/255)
    
    static let knobStart                = Color.init(red: 20/255, green: 21/255, blue: 21/255)
    static let knobEnd                  = Color.init(red: 46/255, green: 50/255, blue: 54/255)
    
    static let knobLinear = LinearGradient(
        gradient: Gradient(
            colors: [knobStart,knobEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
}
