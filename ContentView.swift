import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.66, green: 0.85, blue: 0.92)
                .ignoresSafeArea()
            Text("YESSSS BABY")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
        }
    }
}