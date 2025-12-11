namespace :resume do
  desc "Load resume PDF into the database"
  task :load, [:file_path] => :environment do |_t, args|
    file_path = args[:file_path] || ENV["RESUME_PATH"] || Rails.root.join("storage", "resume.pdf")
    
    unless File.exist?(file_path)
      puts "Error: Resume file not found at #{file_path}"
      puts "Usage: rails resume:load[path/to/resume.pdf]"
      puts "   or: RESUME_PATH=path/to/resume.pdf rails resume:load"
      exit 1
    end

    puts "Loading resume from #{file_path}..."
    
    document = Document.find_or_initialize_by(name: "Resume")
    document.file.attach(
      io: File.open(file_path),
      filename: File.basename(file_path),
      content_type: "application/pdf"
    )
    
    if document.save
      puts "Resume loaded successfully!"
      puts "Document ID: #{document.id}"
      puts "Name: #{document.name}"
      
      # Generate embedding from text content
      if document.file.attached?
        text = document.text_content
        if text.present?
          puts "Generating embedding..."
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
              puts "Embedding generated and saved!"
            else
              puts "Warning: Could not generate embedding"
            end
          rescue => e
            puts "Error generating embedding: #{e.message}"
          end
        else
          puts "Warning: Could not extract text from PDF"
        end
      end
    else
      puts "Error: Failed to save resume"
      puts document.errors.full_messages.join(", ")
      exit 1
    end
  end
end
