defmodule ExBench.Capturer do

  def open_file(name), do {:ok, fh} = :file.open(file, [:append]), fh
  
  def close_file(fh), do :file.close(fh), fh
  
  def capture(fh, args \\ [trace_pattern: {:io, :format, 2}, count: 1]) do
    {:ok, fh} = :file.open(file, [:append])

    appender = fn {:trace, _pid, :call, {_m, _f, a}} ->
      :file.write(fh, :io_lib.format("~w.~n", [a]))
    end

    :recon_trace.calls(args[:trace_pattern], args[:count], formatter: appender)

    ### uh - how do I know when to close the file handle ? counting calls?
    ### I know - lets never bother - and wait for ferd to reply...
    ### I'm going to operate on the basis that nobody runs enough traces to exhaust
    ### system file handle allocation
  end
end
