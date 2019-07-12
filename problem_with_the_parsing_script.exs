


#IO.puts(line)

{:ok, input} = :erlang.binary_to_list(line)


{:ok, toks,_} =  :erl_scan.string(input) 

{:ok, exprs} = erl_parse.parse_exprs(toks)



{:ok, terms} = :erl_eval.exprs(exprs, :orddict.new)



  #
  #  #:erl_eval.exprs
  #(   elem
  #(:erl_parse.parse_exprs
  #(elem
  #(
  #  
  #  
  #  
  #  ,1)),1) , )
