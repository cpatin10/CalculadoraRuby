# coding: utf-8
require 'parser'
require 'ast'
require 'set'

class Calculator
  attr_accessor :memory, :identifiers, :readingFiles, :initialIdentifiers, :setIdent
  attr_writer :ewecomp, :readFile
  
  def initialize()
    @memory = 0
    @identifiers = Hash.new(0)
    @setIdent = Set.new #facilita manejo identificadores compilador ewe
    @ewecomp = false
    @readingFiles = Array.new()
    @readFile = false
  end
  
  def eval()
    if @readFile then
      @readingFiles.each do |f|
        evalTree(f)
      end
    else
      evalTree("")
    end
  end

  def setterIdent(key, value)
    @identifiers[key] = value
    @setIdent.add(key)
  end
  
  private

  def evalTree(filename)
    if @readFile then
      parser = Parser.new(@ewecomp, filename)
    else
      parser = Parser.new(@ewecomp, "")
    end
    ast = parser.parse
    writeFile(filename, ast)
  end

  def writeFile(name, tree)
    if @ewecomp then
      unless name == "" then
        name = limitFileName(name)
        name += ".ewe"
        outFile = File.new(name, "w+")
        outFile.puts tree.eweCompiler
        outFile.close
      else
        outFile = File.new("a.ewe", "w+")
        outFile.puts tree.eweCompiler
        outFile.close
      end       
    end
  end

  def limitFileName(file)
    posExt = file.index('.calc')
    unless posExt == nil then
      file = file[0..(posExt - 1)]
    end
    file
  end
end
