class ApiController < ApplicationController
  def index
    render json: {
      name: "AI Doc Reader API",
      version: "v1",
      status: "online",
      endpoints: {
        health: "/up",
        api: {
          v1: {
            questions: {
              ask: {
                method: "POST",
                path: "/api/v1/questions/ask",
                description: "Ask a question about documents"
              }
            }
          }
        }
      }
    }, status: :ok
  end
end
