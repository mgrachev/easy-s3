# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy-s3/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy-s3'
  spec.version       = EasyS3::VERSION
  spec.authors       = ['Mikhail Grachev']
  spec.email         = ['i@mgrachev.com']
  spec.description   = %q{Easy use Amazon S3}
  spec.summary       = %q{Easy use Amazon S3}
  spec.homepage      = 'https://github.com/mgrachev/easy-s3'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'fog', '~> 1.15'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.99'
end
