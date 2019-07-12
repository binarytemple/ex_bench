# PocEventTimer

## Drift

```text
^Cnenavishu:poc_event_timer b$ iex -S mix
Erlang/OTP 22 [erts-10.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

starting Elixir.PocEventTimer.Signaler
Interactive Elixir (1.8.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 
nil
iex(2)> 
17:55:57.461 [debug] drift :  0.416,  corrected: 1000 
do_work: 1562950557468183000
handle_info: {#Reference<0.3061465571.2785542151.212778>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542151.212778>, :process, #PID<0.187.0>, :normal}

nil
iex(3)> 
17:55:58.460 [debug] drift :  0.806,  corrected: 999 
do_work: 1562950558460939000
handle_info: {#Reference<0.3061465571.2785542147.213750>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542147.213750>, :process, #PID<0.189.0>, :normal}

nil
iex(4)> 
17:55:59.460 [debug] drift :  -0.04,  corrected: 1000 
do_work: 1562950559460929000
handle_info: {#Reference<0.3061465571.2785542147.213764>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542147.213764>, :process, #PID<0.191.0>, :normal}

nil
iex(5)> 
17:56:00.461 [debug] drift :  0.932,  corrected: 999 
handle_info: {#Reference<0.3061465571.2785542147.213778>, :ok}
do_work: 1562950560461939000
handle_info: {:DOWN, #Reference<0.3061465571.2785542147.213778>, :process, #PID<0.193.0>, :normal}

17:56:01.461 [debug] drift :  0.104,  corrected: 1000 
do_work: 1562950561461953000
handle_info: {#Reference<0.3061465571.2785542147.213786>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542147.213786>, :process, #PID<0.194.0>, :normal}

17:56:02.462 [debug] drift :  1.129,  corrected: 999 
do_work: 1562950562463116000
handle_info: {#Reference<0.3061465571.2785542151.212793>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542151.212793>, :process, #PID<0.195.0>, :normal}

17:56:03.462 [debug] drift :  -0.081,  corrected: 1000 
do_work: 1562950563463104000
handle_info: {#Reference<0.3061465571.2785542147.213796>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542147.213796>, :process, #PID<0.196.0>, :normal}

17:56:04.463 [debug] drift :  0.952,  corrected: 999 
do_work: 1562950564463958000
handle_info: {#Reference<0.3061465571.2785542151.212805>, :ok}
handle_info: {:DOWN, #Reference<0.3061465571.2785542151.212805>, :process, #PID<0.197.0>, :normal}

```