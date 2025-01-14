Rails.configuration.after_initialize do
  OpenfgaService.new.create_store()
end