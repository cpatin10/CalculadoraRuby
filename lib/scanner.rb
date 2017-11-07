require 'stringio'
require 'calcex'
require 'set'

class Scanner
  def initialize(filename)
    setIStream(filename)
    @keywords = Set.new(["S","R","M","P","C","let"])
    @lineCount = 1
    @colCount = -1
    @needToken = true
    @lastToken = nil
  end
  
  def putBackToken()
    @needToken = false
  end

  def getToken()
    if !@needToken
      @needToken = true
      return @lastToken
    end
    
    state = 0
    foundOne = false
    c = @istream.getc()
    
    if @istream.eof() then
      @lastToken = Token.new(:eof,@lineCount,@colCount)
      return @lastToken
    end
    
    until foundOne do
      @colCount = @colCount + 1
      case state
      when 0
        lex = ""
        column = @colCount
        line = @lineCount
        if isLetter(c) then state=1
        elsif isDigit(c) then state=2
        elsif c == ?+ then state = 3
        elsif c == ?- then state = 4
        elsif c == ?* then state = 5
        elsif c == ?/ then state = 6
        elsif c == ?( then state = 7
        elsif c == ?) then state = 8
        elsif c == ?% then state = 9
        elsif c == ?= then state = 10
        elsif c == ?\n then state = 11
        elsif isWhiteSpace(c) then state = state #ignore whitespace
        elsif @istream.eof() then
          @foundOne = true
          type = :eof
        else
          type = :unrecognized
          foundOne = true
        end
      when 1
        if isLetter(c) or isDigit(c) then state = 1
        else
          if @keywords.include?(lex) then
            foundOne = true
            type = :keyword
          else
            foundOne = true
            type = :identifier
          end
        end
      when 2
        if isDigit(c) then state = 2
        else
          type = :number
          foundOne = true
        end
      when 3
        type = :add
        foundOne = true
      when 4
        type = :sub
        foundOne = true
      when 5
        type = :times
        foundOne = true
      when 6
        type = :divide
        foundOne = true
      when 7
        type = :lparen
        foundOne = true
      when 8
        type = :rparen
        foundOne = true
      when 9
        type = :mod
        foundOne = true
      when 10
        type = :equals
        foundOne = true
      when 11
        @colCount = 0
        @lineCount = @lineCount+1
        type = :eol
        foundOne = true
      end

      if !foundOne then
        lex.concat(c)
        c = @istream.getc()
      end

    end
   
    @istream.ungetc(c)   
    @colCount = @colCount - 1
    if type == :number or type == :identifier or type == :keyword then
      t = LexicalToken.new(type,lex,line,column)
    else
      t = Token.new(type,line,column)
    end

    @lastToken = t
    return t 
  end

  def terminalLine
    print "> "
    line = gets
    unless line == nil then
      line += "\n"
    else
      line = "\0"
    end
    @istream = StringIO.new(line)
  end

  private
  
  def isLetter(c)
    if c.nil?
      false
    else
      (?a <= c and c <= ?z) or (?A <= c and c <= ?Z)
    end
  end
  
  def isDigit(c)
    if c.nil?
      false
    else
      ?0 <= c and c <= ?9
    end
  end
  
  def isWhiteSpace(c)
    if c.nil?
      false
    else
      c == ?\  or c == ?\n or c == ?\t
    end
  end

  def fileContent(file)
    cont = ""
    inFile = File.open(file, "r")
    inFile.each_line do |l|
      cont += l
    end
    inFile.close
    cont
  end

  def setIStream(file)
    if (file == "") then
      terminalLine
    else
      @istream = StringIO.new(fileContent(file))
    end    
  end
end
