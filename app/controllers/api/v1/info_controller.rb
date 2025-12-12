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
            },
            documents: {
              upload_resume: {
                method: "POST",
                path: "/api/v1/documents/upload_resume",
                description: "Upload resume PDF file",
                parameters: {
                  file: "multipart/form-data file (required)"
                }
              }
            }
          }
        }, status: :ok
      end
    end
  end
end
