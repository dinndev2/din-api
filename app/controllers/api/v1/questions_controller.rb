module Api
  module V1
    class QuestionsController < BaseController
      def ask
        answer = QuestionService.new.generate_response(params[:question])
        if answer
          render json: {
            answer: answer
          }, status: :created
        else
          render json: {
            error: "Failed to generate answer"
          }, status: :unprocessable_entity
        end
      end

      private

      def question_params
        params.require(:question).permit(:body)
      end

      def question_json(question)
        {
          id: question.id,
          body: question.body,
          answer: question.answer,
          created_at: question.created_at,
          updated_at: question.updated_at
        }
      end
    end
  end
end
