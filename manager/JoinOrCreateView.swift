import SwiftUI

struct JoinOrCreateView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Color.gray
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Spacer()
                    NavigationLink("招待された方はこちら") {
                        JoinView()
                    }
                    .padding()
                    .foregroundStyle(Color.black)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    Spacer()
                    NavigationLink("新しく始める方はこちら") {
                        CreateView()
                    }
                    .padding()
                    .foregroundStyle(Color.black)
                    .background(Color.orange)
                    .cornerRadius(10)
                    Spacer()
                    
                }
            }
        }
    }
}


struct JoinOrCreateView_Previews: PreviewProvider {
    static var previews: some View {
        JoinOrCreateView()
    }
}
