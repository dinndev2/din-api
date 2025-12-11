class QuestionService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end


  def generate_question_embedding(question)
    @client.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: question
      }
    ).dig("data", 0, "embedding")
  end

  def resume_document
    @resume_document ||= Document.find_by(name: "Resume") || Document.first
  end

  def ranked_documents(question_embedding)
    return [] unless resume_document&.embedding
    
    # For a single document, we still calculate similarity but return it directly
    similarity = resume_document.cosine_similarity(resume_document.embedding, question_embedding)
    similarity > 0 ? [resume_document] : []
  end

  def generate_prompt(question)
    documents = ranked_documents(generate_question_embedding(question))
    return nil unless documents.any?
    
    context = documents.map { |doc| doc.text_content }.join("\n")
    prompt = <<~PROMPT
      You are a helpful assistant. Answer the question using only the provided context. Do not invent information.

      Context:
      #{context}

      Question:
      #{question}
      PROMPT
  end

  def generate_response(question)
    prompt = generate_prompt(question)
    
    unless prompt
      return "Error: Resume document not found or could not be processed. Please ensure the resume is loaded."
    end
  
    begin
      response = @client.chat(
        parameters: {
          model: "gpt-4",
          messages: [
            { role: "user", content: prompt }
          ]
        }
      )
  
      return response.dig("choices", 0, "message", "content")
  
    rescue Faraday::TooManyRequestsError => e
      Rails.logger.error "OpenAI rate limit hit: #{e.message}"
      return "Sorry, I'm getting rate limited right now. Try again in a moment!"
    
    rescue Faraday::Error => e
      Rails.logger.error "OpenAI API error: #{e.message}"
      return "Oops — something went wrong talking to OpenAI."
  
    rescue => e
      Rails.logger.error "Unexpected error: #{e.message}"
      return "Unexpected error. Please try again."
    end
  end
  
end