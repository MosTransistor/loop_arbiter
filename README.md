# loop_arb  
[Verilog] loop arbiter, round-robin's expanded design  

## 概述/Overview  
基于round-robin仲裁器基础的拓展设计，支持参数化配置请求数量  
>An expanded design based on the round-robin arbiter that supports parameterized configuration of the number of requests
>
优先级变化规则：每次仲裁结束后，获得准许的请求，变为最低优先级，比其优先级小的请求，优先级变高一位，比其优先级大的请求，优先级不变;  
>Priority change rules: After each arbitration, the approved request becomes the lowest priority, the priority of requests smaller than its priority becomes one higher, and the priority of requests larger than its priority remains unchanged.
>
以A,B,C,D四个请求者举例，电路复位后优先级为“DCBA”，按照round-robin的规则，只有4种优先级顺序存在；但根据loop的规则，将会存在A(4,4)=24种优先级顺序，所以其设计会变得复杂
>Take four requesters A, B, C, and D as an example. After the circuit is reset, the default priority is "DCBA". According to the round-robin rules, there are only 4 priority orders; but according to the loop rules, there will be Arrangement(4,4)=24 priority orders, so its design will become complicated
>
为了支持请求者数量的参数化配置，采用：请求重新排序->固定优先级仲裁->排序还原的方法
>Because design suuport parameterized configuration, the rule: rotate -> fixed priority -> rotate

| DCBA | round-robin | loop | 
| --- | --- | --- |
| hit A | ADCB | ADCB |
| hit B | BADC | BDCA |
| hit C | CBAD | CDBA |
| hit D | DCBA | DCBA |

## 思路图/idea diagram 
<img src="https://github.com/MosTransistor/loop_arb/assets/143840188/66f69dcb-bc19-4c64-92dc-0dacf55d8937" width="800" height="80" atl="loop_arb">

## 数据结构/database
src -> 源代码    
sim(Icarus Verilog + gtkwave) -> 仿真   
syn(yosys) -> 综合  
>verilog code in "src" folder, simulation in "sim" folder, synthesis in "syn" folder
>
## 备注/comment
仿真目录：“make sim”执行编译，“make wave”打开波形；综合目录：“make syn”执行综合  
> in "sim" folder, "make sim" for compile, "make wave" for open waveform; in "syn" folder, "make syn" for synthesis
> 
