import SwiftUI

enum DiveMode {
    case divePlanning, surfaceInterval, maxDepth
}

struct ContentView: View {
    var body: some View {
        ERDPMLCalculatorUI()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ERDPMLCalculatorUI: View {
    @State private var selectedMode: DiveMode = .divePlanning
    @State private var depth = ""
    @State private var bottomTime = ""
    @State private var surfaceIntervalHours = ""
    @State private var surfaceIntervalMinutes = ""
    @State private var calculatedNDL = "NDL not calculated"
    @State private var calculatedANDL = "ANDL not calculated"
    @State private var maxTime = "Max Time not calculated"
    @State private var isMultilevelDiving = false
    @State private var isFirstDiveOfTheDay = false

    var body: some View {
        ZStack {
            LinearGradient(Color.darkStart, Color.darkEnd).edgesIgnoringSafeArea(.all)

            VStack {
                // Mode Selection
                Picker("Select Mode", selection: $selectedMode) {
                    Text("Dive Planning").tag(DiveMode.divePlanning)
                    Text("Surface Interval").tag(DiveMode.surfaceInterval)
                    Text("Max Depth").tag(DiveMode.maxDepth)
                }.pickerStyle(SegmentedPickerStyle())
                .padding()
                // Additional Questions
                if selectedMode == .divePlanning {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Are you doing multilevel diving?")
                            .foregroundColor(.white)
                        HStack {
                            Toggle(isOn: $isMultilevelDiving) {
                                Text("Yes")
                                    .foregroundColor(.white)
                            }
                            Toggle(isOn: .constant(!isMultilevelDiving)) {
                                Text("No")
                                    .foregroundColor(.white)
                            }
                        }

                        Text("Is this your first dive of the day?")
                            .foregroundColor(.white)
                        HStack {
                            Toggle(isOn: $isFirstDiveOfTheDay) {
                                Text("Yes")
                                    .foregroundColor(.white)
                            }
                            Toggle(isOn: .constant(!isFirstDiveOfTheDay)) {
                                Text("No")
                                    .foregroundColor(.white)
                            }
                        }

                        HStack {
                            Text("Surface Interval")
                                .foregroundColor(.white)
                            
                            // Text field for hours
                            TextField("Hours", text: $surfaceIntervalHours)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .foregroundColor(.black)
                            
                            Text("hours")
                                .foregroundColor(.white)
                            
                            // Text field for minutes
                            TextField("Minutes", text: $surfaceIntervalMinutes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .foregroundColor(.black)
                            
                            Text("minutes")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                

                }

                // Display based on Mode Selection
                Spacer()
                switch selectedMode {
                case .divePlanning:
                    divePlanningView()
                case .surfaceInterval:
                    surfaceIntervalView()
                case .maxDepth:
                    Text("Max Depth Mode")
                        .foregroundColor(.black)
                        .font(.title)
                        .padding()
                }

                Spacer()
            }
        }
        .navigationBarTitle("Dive Calculator", displayMode: .inline)
    }

    @ViewBuilder
    private func divePlanningView() -> some View {
        // Input Fields for Depth and Bottom Time
        VStack(alignment: .leading, spacing: 20) {
            Text("Depth (meters)")
                .foregroundColor(.white)
            TextField("Enter Depth", text: $depth)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)

            Text("Bottom Time (minutes)")
                .foregroundColor(.white)
            TextField("Enter Bottom Time", text: $bottomTime)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
        }.padding()

        // Display Calculated NDL, ANDL, and Max Time
        VStack {
            Spacer()
            Text("NDL: \(calculatedNDL)")
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .padding()

            Text("ANDL: \(calculatedANDL)")
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .padding()

            Text("Max Time: \(maxTime)")
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .padding()
            Spacer()
        }

        // Calculate Button
        Button(action: {
            calculateValues()
        }) {
            Text("Calculate NDL/ANDL/Max Time")
                .font(.title)
                .foregroundColor(.black)
                .frame(width: 400, height: 60) // Button
                .background(Color.orange)
                .cornerRadius(15)
        }
    }

    private func surfaceIntervalView() -> some View {
        Text("Surface Interval Mode")
    }

    private func calculateValues() {
        guard let depthInt = Int(self.depth), let bottomTimeInt = Int(self.bottomTime),
              let surfaceIntervalHoursInt = Int(self.surfaceIntervalHours),
              let surfaceIntervalMinutesInt = Int(self.surfaceIntervalMinutes) else {
            self.calculatedNDL = "Invalid Input"
            self.calculatedANDL = "Invalid Input"
            self.maxTime = "Invalid Input"
            return
        }

        let surfaceIntervalTotalMinutes = surfaceIntervalHoursInt * 60 + surfaceIntervalMinutesInt
        self.calculatedNDL = calculateNDL(depth: depthInt, bottomTime: bottomTimeInt, surfaceInterval: surfaceIntervalTotalMinutes, isMultilevelDiving: self.isMultilevelDiving, isFirstDiveOfTheDay: self.isFirstDiveOfTheDay)
        self.calculatedANDL = calculateANDL(depth: depthInt, bottomTime: bottomTimeInt, surfaceInterval: surfaceIntervalTotalMinutes, isMultilevelDiving: self.isMultilevelDiving, isFirstDiveOfTheDay: self.isFirstDiveOfTheDay)
        self.maxTime = calculateMaxTime(depth: depthInt)
    }

    private func calculateMaxTime(depth: Int) -> String {
        // Define a dictionary for max times corresponding to depth
        let maxTimeTable = [10: 170, 12: 100, 15: 60, 18: 45, 20: 35, 25: 25, 30: 20, 35: 15, 40: 10]

        // Check if the provided depth exists in the dictionary
        if let maxTime = maxTimeTable[depth] {
            return "\(maxTime) minutes" // Return the max time as a string
        } else {
            return "Depth not in Max Time table" // If depth is not found, return this message. In case this part can be edit.
        }
    }

    private func calculateNDL(depth: Int, bottomTime: Int, surfaceInterval: Int, isMultilevelDiving: Bool, isFirstDiveOfTheDay: Bool) -> String {
        let ndlTable = [10: 219, 12: 147, 15: 80, 18: 56, 20: 45, 25: 25, 30: 20, 35: 8, 40: 5]

        if let ndl = ndlTable[depth] {
            var adjustedBottomTime = bottomTime
            if !isMultilevelDiving && isFirstDiveOfTheDay {
                adjustedBottomTime = bottomTime / 2
            }

            if surfaceInterval < 120 {
            } else if surfaceInterval < 180 {
                adjustedBottomTime = adjustedBottomTime / 2
            } else {
                adjustedBottomTime = adjustedBottomTime / 3
            }

            if adjustedBottomTime <= ndl {
                return "Safe: Within NDL"
            } else {
                return "Warning: Exceeds NDL"
            }
        } else {
            return "Depth not in NDL table"
        }
    }

    private func calculateANDL(depth: Int, bottomTime: Int, surfaceInterval: Int, isMultilevelDiving: Bool, isFirstDiveOfTheDay: Bool) -> String {
        let andlTable = [10: 109, 12: 77, 15: 48, 18: 33, 20: 25, 25: 15, 30: 12, 35: 5, 40: 3]

        if let andl = andlTable[depth] {
            var adjustedBottomTime = bottomTime
            if !isMultilevelDiving && isFirstDiveOfTheDay {
                adjustedBottomTime = bottomTime / 2
            }

            if surfaceInterval < 120 {
                // No adjustment needed for surface interval less than 2 hours
            } else if surfaceInterval < 180 {
                adjustedBottomTime = adjustedBottomTime / 2
            } else {
                adjustedBottomTime = adjustedBottomTime / 3
            }

            if adjustedBottomTime <= andl {
                return "Safe: Within ANDL"
            } else {
                return "Warning: Exceeds ANDL"
            }
        } else {
            return "Depth not in ANDL table"
        }
    }
}

extension Color {
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topTrailing, endPoint: .bottomTrailing)
    }
}
