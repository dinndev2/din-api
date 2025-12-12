require 'pdf-reader'

class Document < ApplicationRecord
  vectorsearch

  after_save :upsert_to_vectorsearch

  has_one_attached :file

  validates :name, presence: true

  def cosine_similarity(vec1, vec2)
    dot = vec1.zip(vec2).map { |a,b| a*b }.sum
    norm1 = Math.sqrt(vec1.map { |x| x**2 }.sum)
    norm2 = Math.sqrt(vec2.map { |x| x**2 }.sum)
    dot / (norm1 * norm2)
  end

  def self.ranked(question_embedding)
    Document.all.map do |doc|
      { doc: doc, score: doc.cosine_similarity(doc.embedding, question_embedding) }
    end.sort_by { |result| -result[:score] }.first(3).map { |d| d[:doc] }
  end

  def text_content
    return "" unless file.attached?
    
    begin
      file_data = file.download
      reader = PDF::Reader.new(StringIO.new(file_data))
      reader.pages.map(&:text).join("\n")
    rescue ActiveStorage::FileNotFoundError, Errno::ENOENT => e
      Rails.logger.error "File not found for document #{id}: #{e.message}"
      ""
    rescue => e
      Rails.logger.error "Error reading PDF for document #{id}: #{e.message}"
      ""
    end
  end
end
