import SwiftUI
import AVKit
import CoreHaptics

// MARK: - Sound Manager
class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?

    // Function to play an embedded MP3 file named "Song.mp3"
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Song", withExtension: "mp3") else {
            print("Could not find sound file.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// MARK: - Affirmation Model
struct Affirmation: Codable {
    let affirmation: String
}


// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State private var affirmation: String = "Tap below to get a daily affirmation!"
    @State private var isLoading = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("customAffirmation") private var customAffirmation = ""
    
    
    var body: some View {
        TabView {
            // MARK: - Home Tab
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 20) {
                    // ✅ Put image view here
                    RandomImageView()
                        .padding(.top, 40)
                    
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text(affirmation)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // ...rest of buttons and logic
                    // Button to fetch new affirmation from API
                    Button(action: fetchAffirmation) {
                        Text("Get New Affirmation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    // Button to play music and give haptic feedback
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring()) {
                            SoundManager.instance.playSound()
                        }
                    }) {
                        Label("Play Music", systemImage: "play.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Sign out button
                    Button(action: {
                        mainViewModel.signOut()
                    }) {
                        Text("Sign out")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            // MARK: - Journal Tab
            JournalView()
                .tabItem {
                    Image(systemName: "book.closed.fill")
                    Text("Journal")
                }
            
            // MARK: - Contact Tab
            ContactView()
                .tabItem {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    Text("Contact")
                }
            
            // MARK: - Profile Tab
            ProfileView(profileViewModel: mainViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
            // MARK: - Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light) // Apply dark mode setting
    }
      struct RandomImageView: View {
            let imageNames = [
                "nate1", "nate2", "nate3", "natee4", "nate5", "nate6", "nate7", "nate8", "nate9",
                "nate10", "nate11", "nate12", "nate13", "nate14", "nate15", "nate16", "nate17",
                "nate18", "nate19", "nate20", "nate21", "nate22", "nate23", "nate24",
                "nate25", "nate26", "nate27", "nate28", "nate29", "nate30"
            ]

            @State private var currentImageName: String = ""
            @State private var timer: Timer?
            @State private var animateImage = false

            var body: some View {
                ZStack {
                    if let image = UIImage(named: currentImageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .opacity(animateImage ? 1 : 0)
                            .scaleEffect(animateImage ? 1.0 : 0.8)
                            .animation(.easeInOut(duration: 0.8), value: animateImage)
                    } else {
                        Text("No image found")
                            .foregroundColor(.white)
                    }
                }
                .onAppear {
                    pickRandomImage()
                    startImageLoop()
                }
                .onDisappear {
                    stopImageLoop()
                }
            }

            private func pickRandomImage() {
                if let newImage = imageNames.randomElement() {
                    currentImageName = newImage
                    animateImage = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        animateImage = true
                    }
                }
            }

            private func startImageLoop() {
                stopImageLoop()
                timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                    pickRandomImage()
                }
            }

            private func stopImageLoop() {
                timer?.invalidate()
                timer = nil
            }
        }
        
        // Function to fetch affirmation from API
        func fetchAffirmation() {
            isLoading = true
            let url = URL(string: "https://www.affirmations.dev/")!
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async { isLoading = false }
                guard let data = data, error == nil else {
                    DispatchQueue.main.async { affirmation = "Failed to load affirmation." }
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(Affirmation.self, from: data)
                    DispatchQueue.main.async { affirmation = decoded.affirmation }
                } catch {
                    DispatchQueue.main.async { affirmation = "Failed to parse affirmation." }
                }
            }.resume()
        }
    }
    
    // MARK: - Journal View
    struct JournalView: View {
        @AppStorage("gratitudeNote") private var note = ""
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Gratitude Journal")
                    .font(.largeTitle)
                    .bold()
                
                TextEditor(text: $note)
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Text("✅ Autosaved")
                    .foregroundColor(.green)
            }
            .padding()
        }
    }
    
    // MARK: - Animated Background View
    struct AnimatedBackground: View {
        @State private var animate = false
        
        var body: some View {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Contact View
    struct ContactView: View {
        @State private var name = ""
        @State private var email = ""
        @State private var message = ""
        @State private var isSubmitted = false
        
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Contact Us")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    TextField("Your Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Your Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.emailAddress)
                    
                    TextEditor(text: $message)
                        .frame(height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                    
                    Button(action: {
                        isSubmitted = true
                    }) {
                        Text("Send Message")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    if isSubmitted {
                        Text("✅ Message Sent!")
                            .foregroundColor(.white)
                            .bold()
                    }
                    
                    Spacer()
                }
                .padding(.top, 60)
            }
        }
    }
    
    // MARK: - Profile View Wrapper
    struct ProfileView: View {
        @ObservedObject var profileViewModel: MainViewModel
        var body: some View {
            ZStack {
                UserProfileView(mainViewModel: profileViewModel)
            }
        }
    }
    
    // MARK: - Settings View
    struct SettingsView: View {
        @AppStorage("isDarkMode") private var isDarkMode = false
        
        var body: some View {
            NavigationView {
                Form {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    Button("Reset My Affirmation") {
                        UserDefaults.standard.removeObject(forKey: "customAffirmation")
                    }
                    .foregroundColor(.red)
                }
                .navigationTitle("Settings")
            }
        }
    }
    
    // MARK: - Preview
    #Preview {
        ContentView(mainViewModel: MainViewModel())
    }
