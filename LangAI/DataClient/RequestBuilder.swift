import Foundation

struct RequestBuilder {
    func createLLMRequest(endpoint: String, model: String, message: String, bearer: String, stream: Bool) -> URLRequest {
        let components = URLComponents(string: endpoint)!

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let input = ChatInput(
            model: model,
            store: false,
            stream: stream,
            messages: [.init(role: "user", content: message)]
        )
        request.httpBody = try? JSONEncoder().encode(input)
        return request
    }
}
