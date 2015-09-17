require_relative "../parser_helper"

class RootTestClassDef < MiniTest::Test
  # include the magic (setup and parse -> test method translation), see there
  include ParserHelper

  def test_simplest_class
    @string_input    = <<HERE
class Foo
  5
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Foo", :derived_name=>nil, :class_expressions=>[{:integer=>"5"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Foo", nil, [s(:int, 5)])])
  end

  def test_class_ops
    @string_input    = <<HERE
class Opers
  int foo(int x)
    int abba = 5
    abba + 5
  end
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Opers", :derived_name=>nil, :class_expressions=>[{:type=>"int", :function_name=>{:name=>"foo"}, :parameter_list=>[{:parameter=>{:type=>"int", :name=>"x"}}], :expressions=>[{:name=>"int"}, {:l=>{:name=>"abba"}, :o=>"= ", :r=>{:integer=>"5"}}, {:l=>{:name=>"abba"}, :o=>"+ ", :r=>{:integer=>"5"}}], :end=>"end"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Opers", nil, [s(:function, :int, s(:name, "foo"), [s(:field, :int, :x)], [s(:name, "int"), s(:assign, s(:name, "abba"), s(:int, 5)), s(:operator, "+", s(:name, "abba"), s(:int, 5))])])])
  end

  def test_class_if
    @string_input    = <<HERE
class Ifi
  int ofthen(int n)
    if(0)
      isit = 42
    else
      maybenot = 667
    end
  end
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Ifi", :derived_name=>nil, :class_expressions=>[{:type=>"int", :function_name=>{:name=>"ofthen"}, :parameter_list=>[{:parameter=>{:type=>"int", :name=>"n"}}], :expressions=>[{:if=>"if", :conditional=>{:integer=>"0"}, :if_true=>{:expressions=>[{:l=>{:name=>"isit"}, :o=>"= ", :r=>{:integer=>"42"}}], :else=>"else"}, :if_false=>{:expressions=>[{:l=>{:name=>"maybenot"}, :o=>"= ", :r=>{:integer=>"667"}}], :end=>"end"}}], :end=>"end"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Ifi", nil, [s(:function, :int, s(:name, "ofthen"), [s(:field, :int, :n)], [s(:if, s(:int, 0), [s(:assign, s(:name, "isit"), s(:int, 42))], [s(:assign, s(:name, "maybenot"), s(:int, 667))])])])])
  end

  def test_class_function
    @string_input    = <<HERE
class Pifi
  ofthen(3+4 , var)
  int ofthen(int n , ref m)
    44
  end
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Pifi", :derived_name=>nil, :class_expressions=>[{:call_site=>{:name=>"ofthen"}, :argument_list=>[{:argument=>{:l=>{:integer=>"3"}, :o=>"+", :r=>{:integer=>"4"}}}, {:argument=>{:name=>"var"}}]}, {:type=>"int", :function_name=>{:name=>"ofthen"}, :parameter_list=>[{:parameter=>{:type=>"int", :name=>"n"}}, {:parameter=>{:type=>"ref", :name=>"m"}}], :expressions=>[{:integer=>"44"}], :end=>"end"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Pifi", nil, [s(:call, s(:name, "ofthen"), [s(:operator, "+", s(:int, 3), s(:int, 4)), s(:name, "var")]), s(:function, :int, s(:name, "ofthen"), [s(:field, :int, :n), s(:field, :ref, :m)], [s(:int, 44)])])])
  end
  def test_class_module
    @string_input    = <<HERE
class Foo
  module Boo
    funcall(3+4 , var)
  end
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Foo", :derived_name=>nil, :class_expressions=>[{:module_name=>"Boo", :module_expressions=>[{:call_site=>{:name=>"funcall"}, :argument_list=>[{:argument=>{:l=>{:integer=>"3"}, :o=>"+", :r=>{:integer=>"4"}}}, {:argument=>{:name=>"var"}}]}], :end=>"end"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Foo", nil, [s(:module, "Boo", [s(:call, s(:name, "funcall"), [s(:operator, "+", s(:int, 3), s(:int, 4)), s(:name, "var")])])])])
  end
  def test_class_derived
    @string_input    = <<HERE
class Foo < Object
  ofthen(3+4 , var)
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Foo", :derived_name=>{:module_name=>"Object"}, :class_expressions=>[{:call_site=>{:name=>"ofthen"}, :argument_list=>[{:argument=>{:l=>{:integer=>"3"}, :o=>"+", :r=>{:integer=>"4"}}}, {:argument=>{:name=>"var"}}]}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Foo", s(:module, "Object"), [s(:call, s(:name, "ofthen"), [s(:operator, "+", s(:int, 3), s(:int, 4)), s(:name, "var")])])])
  end
  def test_class_method
    @string_input    = <<HERE
class Foo < Object
  int Foo.test()
    43
  end
end
HERE
    @parse_output = {:expression_list=>[{:module_name=>"Foo", :derived_name=>{:module_name=>"Object"}, :class_expressions=>[{:type=>"int", :receiver=>{:module_name=>"Foo"}, :function_name=>{:name=>"test"}, :parameter_list=>[], :expressions=>[{:integer=>"43"}], :end=>"end"}], :end=>"end"}]}
    @transform_output = s(:list, [s(:class, "Foo", s(:module, "Object"), [s(:function, :int, s(:name, "test"), [], [s(:int, 43)], s(:module, "Foo"))])])
  end

end
