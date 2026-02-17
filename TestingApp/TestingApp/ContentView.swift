//
//  ContentView.swift
//  TestingApp
//
//  Created by Cathal Doyle on 26/08/2025.
//
import SwiftUI
import Qualtrics

struct ContentView: View {
    @State private var initializationStatus: String = "Not initialized"
    @State private var displayStatus: String = "Awaiting intercept evaluation"
    @State private var isInitialized: Bool = false
    @State private var isDisplayed: Bool = false
    
    let brandID = "qcorpeu"
    let zoneID = "ZN_AjrGvOvcxpMpjwJ"
    let interceptID = "SI_bQTjH716jE5OOCq"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Qualtrics iOS SDK Test")
                .font(.title)
                .fontWeight(.bold)
            
            // Initialization Button
            Button {
                initializeQualtrics()
            } label: {
                Text("Initialize Qualtrics")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isInitialized ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Status indicator for initialization
            HStack {
                Circle()
                    .fill(isInitialized ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                Text(initializationStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.vertical, 10)
            
            // Display Intercept Button
            Button {
                evaluateAndDisplayIntercept()
            } label: {
                Text("Evaluate & Display Intercept")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isDisplayed ? Color.green : (isInitialized ? Color.blue : Color.gray))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isInitialized)
            
            // Status indicator for display
            HStack {
                Circle()
                    .fill(isDisplayed ? Color.green :
                          displayStatus.contains("Evaluating") ? Color.orange : Color.gray)
                    .frame(width: 12, height: 12)
                Text(displayStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Log output area
            Text("Logs:")
                .font(.caption)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                Text(initializationStatus + "\n" + displayStatus)
                    .font(.caption2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
            .frame(maxHeight: 150)
        }
        .padding()
    }
    
    private func initializeQualtrics() {
        displayStatus = "Initializing Qualtrics..."
        
        do {
            Qualtrics.shared.initializeProject(
                brandId: brandID,
                projectId: zoneID
            )
            //Add wait function, possibly a better way to run this also.
            
            isInitialized = true
            initializationStatus = "✓ Initialization passed successfully"
            print("Qualtrics: Project initialization passed - BrandId: " + brandID + ", ProjectId: " + zoneID)
            
        } catch {
            isInitialized = false
            initializationStatus = "✗ Initialization failed: \(error.localizedDescription)"
            print("[Qualtrics] ✗ Project initialization failed with error: \(error.localizedDescription)")
            displayStatus = "Please initialize Qualtrics first"
        }
    }
    
    private func evaluateAndDisplayIntercept() {
        displayStatus = "Evaluating intercept..."
        //Setting the Const Values here before we eval and display.
        Qualtrics.shared.properties.setString(string: "sdkTest", for: "test")
        //Time spent in app needs no further addition other than waiting the correct length of time
        
        //Need to add ViewController for ViewCounts
        //Needs XMD link for the Qualtrics Survey logic.
        
        
        Qualtrics.shared.evaluateIntercept(
            for: interceptID
        ) { targetingResult in
            DispatchQueue.main.async {
                if targetingResult.passed() {
                    isDisplayed = true
                    displayStatus = "✓ Intercept evaluation passed - Intercept ID: SI_bQTjH716jE5OOCq"
                    print("[Qualtrics] ✓ Intercept evaluation passed for ID: SI_bQTjH716jE5OOCq")
                    
                    
                    // Display the intercept
                    if let keyWindow = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                       let rootViewController = keyWindow.windows.first?.rootViewController {
                        
                        Qualtrics.shared.displayIntercept(
                            for: "SI_bQTjH716jE5OOCq",
                            viewController: rootViewController
                        )
                        
                        print("[Qualtrics] ✓ Intercept display passed - Displaying intercept on rootViewController")
                    } else {
                        displayStatus = "✗ Failed to display intercept: Could not find root view controller"
                        print("[Qualtrics] ✗ Failed to display intercept: Could not find root view controller")
                    }
                } else {
                    displayStatus = "✗ Intercept evaluation failed - User does not qualify for this intercept"
                    print("[Qualtrics] ✗ Intercept evaluation failed for ID: SI_bQTjH716jE5OOCq - Targeting result: \(targetingResult)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
