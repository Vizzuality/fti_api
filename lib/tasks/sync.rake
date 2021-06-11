class SyncTasks
  include Rake::DSL

  def initialize
    namespace :sync do
      desc 'Sync scores saved in score operator document'
      task scores: :environment do
        different_scores = 0
        # This helps to recalculate scores taking document history how it was a the date of the score to be saved
        ScoreOperatorDocument.find_each do |score|
          docs = OperatorDocumentHistory.from_operator_at_date(score.operator_id, score.date)

          sod = ScoreOperatorDocument.new date: Date.today, operator: score.operator, current: true
          presenter = ScoreOperatorPresenter.new(docs)
          sod.all = presenter.all
          sod.fmu = presenter.fmu
          sod.country = presenter.country
          sod.total = presenter.total
          sod.summary_private = presenter.summary_private
          sod.summary_public = presenter.summary_public

          if sod != score
            puts "SOD DIFFERENT: id: #{score.id}"
            score_json = score.as_json(only: [:all, :fmu, :country, :total, :summary_public, :summary_private])
            sod_json = sod.as_json(only: [:all, :fmu, :country, :total, :summary_public, :summary_private])

            compare(score_json, sod_json)
            different_scores += 1
          end
        end

        puts "TOTAL: #{ScoreOperatorDocument.count}"
        puts "DIFFERENT: #{different_scores}"
      end
    end
  end

  def compare(score_json, sod_json)
    score_json.each do |key, value|
      puts "#{key} - expected: #{value}, actual: #{sod_json[key]} " if value != sod_json[key]
    end
  end
end

SyncTasks.new
