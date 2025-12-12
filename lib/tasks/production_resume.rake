namespace :production do
  desc "Upload resume to production database"
  task :upload_resume => :environment do
    file_path = ENV["RESUME_PATH"] || Rails.root.join("storage", "resume.pdf")
    
    unless File.exist?(file_path)
      puts "Error: Resume file not found at #{file_path}"
      puts "Usage: RESUME_PATH=path/to/resume.pdf rails production:upload_resume"
      exit 1
    end

    puts "Uploading resume to production database..."
    puts "Database: #{ActiveRecord::Base.connection_config[:database]}"
    
    document = Document.find_or_initialize_by(name: "Resume")
    
    # Remove existing attachment if it exists
    document.file.purge if document.file.attached?
    
    document.file.attach(
      io: File.open(file_path),
      filename: File.basename(file_path),
      content_type: "application/pdf"
    )
    
    if document.save
      puts "✓ Resume uploaded successfully!"
      puts "  Document ID: #{document.id}"
      puts "  Name: #{document.name}"
      puts "  File attached: #{document.file.attached?}"
      
      # Generate embedding from text content
      if document.file.attached?
        text = document.text_content
        if text.present?
          puts "  Generating embedding..."
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
              puts "  ✓ Embedding generated and saved!"
            else
              puts "  ⚠ Warning: Could not generate embedding"
            end
          rescue => e
            puts "  ✗ Error generating embedding: #{e.message}"
          end
        else
          puts "  ⚠ Warning: Could not extract text from PDF"
        end
      end
    else
      puts "✗ Error: Failed to save resume"
      puts document.errors.full_messages.join(", ")
      exit 1
    end
  end
end
