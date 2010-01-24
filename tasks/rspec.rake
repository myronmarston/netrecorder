desc "Run the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/../spec/spec.opts\""]
  t.spec_files = FileList["spec/**/*_spec.rb"]
end