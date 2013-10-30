group 'backend' do
  guard 'spork', :wait => 30 do
    watch('lib/magpie-gem.rb')
    watch(%r{^lib/extensions/.*\.rb$})
    watch(%r{^lib/magpie-gem/.*\.rb$})
    watch('Gemfile')
    watch('Gemfile.lock')
    watch('spec/spec_helper.rb')
  end
  
  guard 'bundler' do
    watch('Gemfile')
  end

  guard 'rspec', :cli => '--color --format documentation --fail-fast', :all_after_pass => false do
    watch('spec/spec_helper.rb')                        { "spec" }
    watch('lib/magpie-gem.rb')                          { "spec" }    
    watch(%r{^lib/magpie-gem/(.+)\.rb$})                { |m| "spec/#{m[1]}_spec.rb" }
  end

  guard 'pow' do
    watch('.powrc')
    watch('.powenv')
    watch('.rvmrc')
    watch('Gemfile')
    watch('Gemfile.lock')
  end

end

guard 'ctags-bundler' do
  watch('Gemfile.lock')
end
