module Api
  module V1
    class DocumentsController < BaseController
      # POST /api/v1/documents/upload_resume
      def upload_resume
        unless params[:file].present?
          return render json: { error: "File parameter is required" }, status: :bad_request
        end

        document = Document.find_or_initialize_by(name: "Resume")
        
        # Remove existing attachment if it exists
        document.file.purge if document.file.attached?
        
        # Attach the new file
        document.file.attach(
          io: params[:file],
          filename: params[:file].original_filename || "resume.pdf",
          content_type: params[:file].content_type || "application/pdf"
        )
        
        if document.save
          # Generate embedding from text content
          embedding_generated = false
          if document.file.attached?
            text = document.text_content
            if text.present?
              begin
                client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
                response = client.embeddings(
                  parameters: {
                    model: "text-embedding-3-small",
                    input: text
                  }
                )
                embedding = response.dig("data", 0, "embedding")
                if embedding
                  document.update_column(:embedding, embedding)
                  embedding_generated = true
                end
              rescue => e
                Rails.logger.error "Error generating embedding: #{e.message}"
              end
            end
          end
          
          render json: {
            success: true,
            message: "Resume uploaded successfully",
            document: {
              id: document.id,
              name: document.name,
              file_attached: document.file.attached?,
              embedding_generated: embedding_generated,
              created_at: document.created_at
            }
          }, status: :created
        else
          render json: {
            success: false,
            error: "Failed to save resume",
            errors: document.errors.full_messages
          }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error uploading resume: #{e.message}"
        render json: {
          success: false,
          error: "Internal server error: #{e.message}"
        }, status: :internal_server_error
      end
    end
  end
end
