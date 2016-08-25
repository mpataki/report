# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'task_report'
  spec.version       = File.read('VERSION')
  spec.authors       = ['Mat Pataki']
  spec.email         = ['matpataki@gmail.com']

  spec.summary       = 'Task tracker with gist support'
  spec.homepage      = 'https://github.com/mpataki/task_report'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.2.3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['task']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
end
