# coding: utf-8

Gem::Specification.new do |s|
  s.name    = 'cpatin10-rubycalc'
  s.version = '0.0.2'
  s.date    = '2016-05-11'
  s.summary = 'Another calculator in ruby'
  s.description = 'An implementation of a basic calculator on ruby'
  s.author  = 'Kent D. Lee - Catalina Patiño Forero'
  s.email   = 'cpatin10@eafit.edu.co'
  s.homepage = 'https://svn.riouxsvn.com/244stalvare1/proyecto/rubycalc/'
  s.files    = ["lib/token.rb",
                "lib/scanner.rb",
                "lib/ast.rb",
                "lib/parser.rb",
                "lib/calculator.rb",
                "lib/calcex.rb"]
  s.license  = 'ARTISTIC'
  s.executables << 'rubycalc'
end
