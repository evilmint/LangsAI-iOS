import ComposableArchitecture
import Foundation

struct ChatOutput {
    let message: String
}

enum ClientError: Error {
    case invalidURL
    case dataDecodingFailed
}

@DependencyClient
struct LLMClient {
    var chat: @Sendable (_ endpoint: String, _ model: String, _ bearer: String, _ input: String) async throws -> ChatOutput
    var streamChat: @Sendable (_ endpoint: String, _ model: String, _ bearer: String, _ input: String) async throws -> AsyncStream<ChatOutput>
}

enum LLMClientError: Error {
    case noResponses
}

extension LLMClient: DependencyKey {
    static let liveValue: Self = .init(
        chat: { endpoint, model, bearer, input in
            let client = LLMStreamingClient(endpoint: endpoint, model: model, apiKey: bearer)
            return try ChatOutput(message: await client.sendMessage(input).choices.first!.message.content)
        },
        streamChat: { endpoint, model, bearer, input in
            let client = LLMStreamingClient(endpoint: endpoint, model: model, apiKey: bearer)

            return AsyncStream(ChatOutput.self) { continuation in
                Task { @MainActor in
                    client.output = { message in
                        continuation.yield(ChatOutput(message: message))
                    }

                    client.startStreamWithMessage(input)
                }
            }
        }
    )
}
