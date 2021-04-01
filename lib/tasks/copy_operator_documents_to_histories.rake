namespace :operator_documents do
  desc 'Creates anOperatorDocumentHistory for each OperatorDocument and deletes the ones that are not active'
  task copy_to_history: :environment do
    DocumentMigrationService.new(:documents).call
  end
end