module Api
  module V1
    class InfoController < BaseController
      def index
        render json: {
          version: "v1",
          endpoints: {
            questions: {
              ask: {
                method: "POST",
                path: "/api/v1/questions/ask",
                description: "Ask a question about documents",
                parameters: {
                  question: "string (required)"
                }
              }
            }
          }
        }, status: :ok
      end
    end
  end
end
