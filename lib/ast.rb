require 'set'

class BinaryNode
  attr_reader :left, :right
  
  def initialize(left,right)
    @left = left
    @right = right
  end
end
   
class UnaryNode
  attr_reader :subTree
   
  def initialize(subTree)
    @subTree = subTree
  end
end

class AddNode < BinaryNode
  def initialize(left, right)
    super(left,right)
  end
   
  def evaluate() 
    @left.evaluate() + @right.evaluate()
  end

  def eweCompiler
    binaryOperations("+", @left, @right)
  end
end

class SubNode < BinaryNode
  def initialize(left, right)
    super(left,right)
  end
   
  def evaluate() 
    @left.evaluate() - @right.evaluate()
  end

  def eweCompiler
    binaryOperations("-", @left, @right)
  end
end

class TimesNode < BinaryNode
  def initialize(left, right)
    super(left,right)
  end
   
  def evaluate() 
    @left.evaluate() * @right.evaluate()
  end

  def eweCompiler
    binaryOperations("*", @left, @right)
  end
end

class DivideNode < BinaryNode
  def initialize(left, right)
    super(left,right)
  end
   
  def evaluate() 
    @left.evaluate() / @right.evaluate()
  end

  def eweCompiler
    binaryOperations("/", @left, @right)
  end
end

class ModNode < BinaryNode
  def initialize(left, right)
    super(left, right)
  end

  def evaluate()
    @left.evaluate() % @right.evaluate()
  end

  def eweCompiler
    binaryOperations("%", @left, @right)
  end
end
      
class NumNode 
  def initialize(num)
    @num = num
  end
   
  def evaluate() 
    @num
  end

  def eweCompiler
    valOperation(@num)
  end
end

class RecallNode
  def evaluate()
    $calc.memory
  end

  def eweCompiler
    ss = "# Recall\n"
    ss << minussp
    ss << "  M[sp+0] := memory\n"
  end
end

class ClearNode
  def evaluate()
    $calc.memory = 0
  end

  def eweCompiler
    evaluate
    ss = "# Clear\n"
    ss << "  memory := zero\n"
    ss << minussp
    ss << "  M[sp+0] := memory\n"
  end
end

class IdentNode
  def initialize(s)
    @name = s
  end

  def evaluate()
    $calc.identifiers[@name]
  end

  def eweCompiler
    $calc.setIdent.add(@name)
    valOperation(@name)
  end
end

class EmptyNode
  def evaluate()
    0
  end

  def eweCompiler
    valOperation("0")
  end
end

class ListNode
  attr_accessor :list

  def initialize()
    @list = Array.new
  end

  def evaluate()
    0
  end

  def eweCompiler
    ss = ""
    ss << "start:\n"
    ss << "  one := 1\n"
    ss << "  zero := 0\n"
    ss << eweValMem
    ss << mapDeclaration
    for i in 0...@list.length do
      ss << "expr#{i + 1}:\n"
      ss << @list[i].eweCompiler
    end
    ss << eweEnd
  end
end  

class StoreNode < UnaryNode
  def initialize(sub)
    super(sub)
  end

  def evaluate()
    $calc.memory = @subTree.evaluate()
  end

  def eweCompiler
    evaluate
    ss = "# Store\n"
    ss << "  memory := M[sp+0]\n"
    ss = @subTree.eweCompiler + ss
  end
end

class PlusNode < UnaryNode
  def initialize(sub)
    super(sub)
  end

  def evaluate()
    $calc.memory = @subTree.evaluate() + $calc.memory
  end

  def eweCompiler
    evaluate
    memOperation("+", @subTree)
  end
end

class MinusNode < UnaryNode
  def initialize(sub)
    super(sub)
  end

  def evaluate()
    n = @subTree.evaluate()
    $calc.memory = $calc.memory - n
  end

  def eweCompiler
    evaluate
    memOperation("-", @subTree)
  end  
end

class NegativeNode < UnaryNode
  def initialize(sub)
    super(sub)
  end

  def evaluate()
    -1 * @subTree.evaluate()
  end

  def eweCompiler
    ss = "# Negate\n"
    ss << "  operator1 := zero - operator1\n"
    ss << "  M[sp+0] := operator1\n"
    ss = @subTree.eweCompiler + ss
  end
end

class EqualsNode < UnaryNode
  def initialize(i, sub)
    super(sub)
    @ident = i
  end

  def evaluate()
    $calc.identifiers[@ident] = @subTree.evaluate()
  end

  def eweCompiler
    # el evaluate se hace para mantener la dependencia entre ficheros, cuando son mas de uno
    $calc.setIdent.add(@ident)
    evaluate()
    ss = "# Assign\n"
    ss << "  #{@ident} := M[sp+0]\n"
    ss = @subTree.eweCompiler + ss
  end
end

class InitNode < UnaryNode
  def initialize(sub)
    super(sub)
  end

  def evaluate()
    @subTree.evaluate()
  end

  def eweCompiler
    ss = eweBegin
    ss << @subTree.eweCompiler
    ss << eweExprEnd
  end
end

private

def binaryOperations(op, left, right)
  nameop = ""

  case op
  when '+'
    nameop = "Add"
  when '-'
    nameop = "Sub"
  when '*'
    nameop = "Times"
  when '/'
    nameop = "Divide"
  when '%'
    nameop = "Module"
  end

  ss = "# #{nameop}\n"
  ss << "  operator2 := M[sp+0]\n"
  ss << "  operator1 := M[sp+1]\n"
  ss << "  operator1 := operator1 #{op} operator2\n"
  ss << plussp()
  ss << "  M[sp+0] := operator1\n"
  ss = left.eweCompiler + right.eweCompiler + ss
end

def valOperation(id)
  ss = "# push(#{id})\n"
  ss << minussp()
  ss << "  operator1 := #{id}\n"
  ss << "  M[sp+0] := operator1\n"
end

def memOperation(op, sub)
  nameop = ""
  ss = ""
  if op == "+" then
    nameop = "Plus"
  else
    nameop = "Minus#"
  end
  ss << "# Memory #{nameop}\n"
  ss << "  operator1 := M[sp+0]\n"
  ss << "  memory := memory #{op} operator1\n"
  ss << "  M[sp+0] := memory\n"
  ss = sub.eweCompiler + ss
end

def eweBegin
  ss = ""
  ss << "# Instrucciones antes del recorrido del arbol abstracto sintactico\n"
  ss << "  sp := 1000\n"
  ss << "# Comienza el recorrido del arbol\n"
end

def eweExprEnd
  ss = ""
  ss << "# Write Result\n"
  ss << "  operator1 := M[sp+0]\n"
  ss << minussp()
  ss << "  writeInt(operator1)\n"
end

def eweEnd
  ss = ""
  ss << "end: halt\n"

  ss << equ("memory", 0)
  ss << equ("one", 1)
  ss << equ("zero", 2)
  ss << equ("operator1", 3)
  ss << equ("operator2", 4)
  ss << equ("sp", 5)
  ss << equ("memoryAux", 6)
  ss << equIdent(7)
  ss << equ("stack", 100)  
end

def minussp
  "  sp := sp - one\n"
end

def plussp
  "  sp := sp + one\n"
end

def equ(param, i)
  "equ #{param} M[#{i}]\n"
end

def equIdent(count)
  ss = ""
  $calc.setIdent.each do |key|
    ss << equ(key, count)
    count += 1
  end
  ss
end

def mapDeclaration
  ss = ""
  $calc.identifiers.each do |key, value|
    ss << "  #{key} := #{value}\n"    
  end
  ss
end

def eweValMem
  if $calc.memory >= 0 then
    ss = "  memory := #{$calc.memory}"
  else
    ss = "  memoryAux := #{$calc.memory * -1}\n"
    ss << "  memory := zero - memoryAux"
  end
  ss << "\n"
end
