require 'ast'
require 'scanner'
require 'token'
require 'calcex'

class Parser
  def initialize(ewe, filename)
    @scan = Scanner.new(filename)
    if filename == "" then
      @readFile = false
    else
      @readFile = true
    end
    @ewecomp = ewe
  end

  def parse()
    CppCalc()
  end
  
  def CppCalc()
    Lineas()
  end

  def Lineas()
    n = ListNode.new
    t = @scan.getToken

    until t.type == :eof do
      begin
        @scan.putBackToken
        inode = InitNode.new(Linea())
        n.list.insert(-1, inode)
        unless @ewecomp then
          puts n.list[-1].evaluate #res
        end
        unless @readFile then
          @scan.terminalLine
        end
        t = @scan.getToken
      rescue ParseError
        unless @readFile then
          @scan.terminalLine
        else
          until t.type == :eol or t.type == :eof do
            t = @scan.getToken
          end
        end
        t = @scan.getToken
      end      
    end
    n
  end

  def Linea()
    t = @scan.getToken
    unless t.type == :eol then
      if t.type == :keyword and t.lex == "let" then
        t = @scan.getToken
        if t.type == :identifier then
          ident = t.lex
          t = @scan.getToken
          if t.type == :equals then
            unless @ewecomp then
              print "= ", ident, "<-"
            end
            en = EqualsNode.new(ident, Expr())
            t = @scan.getToken
            unless t.type == :eol then
              @scan.putBackToken
            end
            return en
          end
        end
        throwExcp(t)
      end
      @scan.putBackToken
      e = Expr()
      unless @ewecomp then
        print "= "
      end
      t = @scan.getToken
      unless t.type == :eol then
        @scan.putBackToken
      end
      return e
    end
    unless @ewecomp then
      print "= "
    end
    EmptyNode.new()
  end
  
  def Expr() 
    RestExpr(Term())
  end
   
  def RestExpr(e) 
    t = @scan.getToken
    
    if t.type == :add then
      return RestExpr(AddNode.new(e,Term()))
    end
    
    if t.type == :sub then
      return RestExpr(SubNode.new(e,Term()))
    end
      
    @scan.putBackToken    
    e
  end
  
  def Term()
    RestTerm(Storable())
  end
   
  def RestTerm(e)
    t = @scan.getToken
    
    if t.type == :times then
      return RestTerm(TimesNode.new(e, Storable()))
    end
    if t.type == :divide then
      return RestTerm(DivideNode.new(e, Storable()))
    end
    if t.type == :mod then
      return RestTerm(ModNode.new(e, Storable()))
    end
    
    @scan.putBackToken    
    e        
  end
   
  def Storable()
    MemOperation(Negative())
  end

  def Negative()
    t = @scan.getToken
    if t.type == :sub
      return NegativeNode.new(Factor())
    end
    @scan.putBackToken
    return Factor()
  end

  def MemOperation(s)
    t = @scan.getToken
    if t.type == :keyword then
      if t.lex == "S" then
        return StoreNode.new(s)
      end
      if t.lex == "P" then
        return PlusNode.new(s)
      end
      if t.lex == "M" then
        return MinusNode.new(s)
      end
    end
    @scan.putBackToken
    s
  end
  
  def Factor() 
    t = @scan.getToken

    if t.type == :number then
      return NumNode.new(t.lex.to_i)
    end
    
    if t.type == :keyword then
      if t.lex == "R" then
        return RecallNode.new
      elsif t.lex == "C" then
        return ClearNode.new
      else
        throwExcp(t)
#        raise ParseError.new
      end
    end
    
    if t.type == :lparen then
      expr = Expr()
      t = @scan.getToken
      if t.type == :rparen then
        return expr
      else
        throwExcp(t)
#    raise ParseError.new
      end
    end

    if t.type == :identifier then
      return IdentNode.new(t.lex)
    end

    throwExcp(t)
#    raise ParseError.new
  end

  def throwExcp(t)
    print "* parse error line ", t.line, " and column ", t.col, "\n"
    raise ParseError.new
  end
end
