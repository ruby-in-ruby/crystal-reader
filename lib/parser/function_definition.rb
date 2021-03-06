module Parser
  module FunctionDefinition
    include Parslet

    rule(:function_definition) {
      type >> ((class_name|name).as(:receiver) >> str(".")).maybe >> #possibly qualified
                  name.as(:function_name) >> left_parenthesis >>
                  parameter_list.maybe >> right_parenthesis >> statements_end >> space?
    }

    rule(:parameter_list) {
      ((field_def.as(:parameter) >> (comma >> field_def.as(:parameter)).repeat(0)).repeat(0,1)).as(:parameter_list)
    }

  end
end
