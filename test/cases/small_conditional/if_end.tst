if_zero(0)
  four = 42
end
-- -- --
s(:if_statement, :zero,
  s(:condition,
    s(:int, 0)),
  s(:true_statements,
    s(:assignment,
      s(:name, :four),
      s(:int, 42))),
  s(:false_statements, nil))
