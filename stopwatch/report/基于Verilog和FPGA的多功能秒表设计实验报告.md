#	基于 Verilog 和 FPGA/CPLD 的多功能秒表设计实验报告
姓名：况羿  
学号：517030910343
##	实验目的
1.	初步掌握利用 Verilog 硬件描述语言进行逻辑功能设计的原理和方法。 
2.	理解和掌握运用大规模可编程逻辑器件进行逻辑设计的原理和方法。  
3.	理解硬件实现方法中的并行性，联系软件实现方法中的并发性。 
4.	理解硬件和软件是相辅相成、并在设计和应用方法上的优势互补的特点。
5.	本实验学习积累的 Verilog 硬件描述语言和对 FPGA/CPLD 的编程操作，是进 行后续《计算机组成原理》部分课程实验，设计实现计算机逻辑的基础。 

##	实验内容和任务
1.	运用 Verilog 硬件描述语言，基于 DE1-SOC 实验板，设计实现一个具有较多功能的计时秒表。 
2.	要求将 6 个数码管设计为具有“分：秒：毫秒”显示，按键的控制动作有： “计时复位”、“计数/暂停”、“显示暂停/显示继续”等。功能能够满足马拉 松或长跑运动员的计时需要。
3.	利用示波器观察按键的抖动，设计按键电路的消抖方法。 
4.	在实验报告中详细报告自己的设计过程、步骤及 Verilog 代码。

##	实验仪器
*	DE1-SOC 实验板 1 套 
*	示波器 1 台 
*	数字万用表 1 台 

##	设计过程
###	1. 正常计时
我们有6个7段数码管，6位的秒表每两位分别代表分，秒以及毫秒，由于毫秒仅有2位，因此仅可表示其百位和十位。对于给定的50MHz的时钟信号的情况下，每一个时钟脉冲是20ns，因此并不是每一次时钟脉冲都需要更新相应的数码管对应的数值的，只有当经过的时间每有10ms的时候才有更新数值的必要，因此，我们需要每500000个脉冲更新一次相应的数值。因此我们需要一个寄存器来记录经过的脉冲次数，每当该寄存器的值到达了500000（假设开始时即是一个时钟信号的上升沿）时，将其置零，并更新相应的时间数值。进一步考虑到有6个数码管，因此我们可以用6个寄存器来分别表示每个七段数码管的值。这样每50个时钟信号以后，我们更新代表最低位的寄存器的数值，当其达到进位条件时，将其置零，其高位加一，并判断其高位是否满足进位条件直至最高位。当最高位（十分）位到达6，则将其置为0，即该秒表最多只能计量59分59秒990毫秒，代码如下：
```verilog
if(counter_50M == ONE_MS)
 	begin
	msecond_low <= msecond_low + 1;
	if(msecond_low == 9)
		begin
		msecond_low <= 0;
		msecond_high <= msecond_high + 1;
		if(msecond_high == 9)
			begin
			msecond_high <= 0;
			second_low <= second_low + 1;
			if(second_low == 9)
				begin
				second_low <= 0;
				second_high <= second_high + 1;
				if(second_high == 5)
					begin
					second_high <= 0;
					minute_low <= minute_low + 1;
					if(minute_low == 9)
						begin
						minute_low <= 0;
						minute_high <= minute_high + 1;
						if(minute_high == 5)
							minute_high <= 0;
						end
					end
				end
			end
		end
	else
		counter_50M <= counter_50M + 1;
    end
```
###	2. 按键功能设置
#####	1）重置
按下对应重置按钮的键，以后，将时间归零同时停止计时。首先为了排除按键抖动影响（消抖），不能仅当收到按键按下时信息时就判定重置，而是应该加入延迟（此处我设置延迟为20ms），如果在延迟时间内按钮始终保持按下状态，则判定重置生效，重置所有数码管对应数值寄存器的值，同时为了使秒表停止计时，应加入计时许可判定，引入一位寄存器作为判定依据，此时将其置为非法，即不允许计时。代码如下（其中led为显式检测按键是否按下的指标，以排除按键故障引起的错误信息传递导致的计数失败）：
```verilog
if(key_start_pause == 0)
	begin
	led2 <= 1;
	counter_start <= counter_start + 1;
	if(counter_start == DELAY_TIME)//wait 20ms to debounce
		start_1_time = 1;
	if(counter_start < DELAY_TIME)
		start_1_time = 0;
	end
else
	begin
	counter_start <= 0;
	led2 <= 0;
	end
...
if(key_reset == 0 && reset_1_time == 1)
	begin
	msecond_low <= 0;
	msecond_high <= 0;
	second_low <= 0;
	second_high <= 0;
	minute_low <= 0;
	minute_high <= 0;
	counter_work = 0;
	reset_1_time = 0;
	end
```
#####	2）暂停/继续
该部分整体与与重置类似，通过修改counter_work即可实现。代码如下：
```verilog
if(key_start_pause == 0)
	begin
	led2 <= 1;
	counter_start <= counter_start + 1;
	if(counter_start == DELAY_TIME)//wait 20ms to debounce
		start_1_time = 1;
	if(counter_start < DELAY_TIME)
		start_1_time = 0;
	end
else
	begin
	counter_start <= 0;
	led2 <= 0;
	end
...
if(key_start_pause == 0 && start_1_time == 1)
	begin
	counter_work = !counter_work;
	start_1_time = 0;
	end
```
#####	3）显示暂停/显示继续
该部分整体与暂停/继续类似，但需注意的是，该暂停行为暂停的仅仅是显示，实际上计数过程仍在继续。因此需要增加一组表示六个数码管的数值的寄存器，作为显示用，另一组作为计数用，为区别两者，重命名先前的寄存器组为_counter_，该寄存器组为_display_同时应加入显示判定以确定是否同步计数寄存器的值到显示寄存器。代码如下：
```verilog
if(key_display_stop == 0)
	begin
	led3 <= 1;
	counter_display <= counter_display + 1;
	if(counter_display == DELAY_TIME)//wait 20ms to debounce
		display_1_time = 1;
	if(counter_display < DELAY_TIME)
		display_1_time = 0;
	end
else
	begin
	counter_display <= 0;
	led3 <= 0;
	end
...
if(key_display_stop == 0 && display_1_time == 1)
	begin
	display_work = !display_work;
	display_1_time = 0;
	end
...
if(display_work == 1)
	begin
	msecond_display_low <= msecond_counter_low;
	msecond_display_high <= msecond_counter_high;
	second_display_low <= second_counter_low;
	second_display_high <= second_counter_high;
	minute_display_low <= minute_counter_low;
	minute_display_high <= minute_counter_high;
	end
```

###	3. 代码综合
最终代码如下：
```verilog
// ============================================================== 
//  
// This stopwatch is just to test the work of LED and KEY on DE1-SOC board. 
// The counter is designed by a series mode.  / asynchronous mode. 即异步进位 
// use "=" to give value to hour_counter_high and so on. 异步操作/阻塞赋值方式 
// 
// 3 key: key_reset/系统复位,  key_start_pause/暂停计时,  key_display_stop/暂停显示 
// 
// ============================================================== 
module stopwatch_01(clk,key_reset,key_start_pause,key_display_stop,    
// 时钟输入 + 3 个按键；按键按下为 0 。板上利用施密特触发器做了一定消抖，效果待测试。                     
				hex0,hex1,hex2,hex3,hex4,hex5, // 板上的 6 个 7 段数码管，每个数码管有 7 位控制信号。            
				led0,led1,led2,led3                            );    
// LED 发光二极管指示灯，用于指示/测试程序按键状态，若需要，可增加。 高电平亮。 
   input         clk,key_reset,key_start_pause,key_display_stop;      
	output  [6:0]  hex0,hex1,hex2,hex3,hex4,hex5;   
	output        led0,led1,led2,led3;      
	reg           led0,led1,led2,led3;        
	reg           display_work;    
	  // 显示刷新，即显示寄存器的值 实时 更新为 计数寄存器 的值。   
	reg           counter_work;    
	  // 计数（计时）工作 状态，由按键 “计时/暂停” 控制。   
	parameter     DELAY_TIME = 1000000;     
	  // 定义一个常量参数。   1000000 ->20ms；  
	parameter	  ONE_MS = 500000;
	  // 定义一毫秒
 
// 定义 6 个显示数据（变量）寄存器： 
 
   reg  [3:0]  minute_display_high;      
	reg  [3:0]  minute_display_low;      
	reg  [3:0]  second_display_high;      
	reg  [3:0]  second_display_low;      
	reg  [3:0]  msecond_display_high;      
	reg  [3:0]  msecond_display_low; 
 
// 定义 6 个计时数据（变量）寄存器：      
	reg  [3:0]  minute_counter_high;      
	reg  [3:0]  minute_counter_low;      
	reg  [3:0]  second_counter_high;      
	reg  [3:0]  second_counter_low;      
	reg  [3:0]  msecond_counter_high;      
	reg  [3:0]  msecond_counter_low;          
	reg  [31:0]  counter_50M;  
// 计时用计数器， 每个 50MHz 的 clock 为 20ns。 
// DE1-SOC 板上有 4 个时钟， 都为 50MHz，所以需要 ONE_MS 次 20ns 之后，才是 10ms。 
 
 
   reg         reset_1_time;      
	  // 消抖动用状态寄存器  -- for reset KEY      
	reg  [31:0]  counter_reset;      
	  // 按键状态时间计数器      
	reg         start_1_time;       
	  //消抖动用状态寄存器  -- for counter/pause KEY      
	reg  [31:0]  counter_start;       
	  //按键状态时间计数器      
	reg         display_1_time;    
	  //消抖动用状态寄存器 -- for KEY_display_refresh/pause      
	reg  [31:0]  counter_display;    
	  //按键状态时间计数器 
 
   reg         start;      
	  // 工作状态寄存器      
	reg         display;    
	  // 工作状态寄存器   
	  // sevenseg 模块为 4 位的 BCD 码至 7 段 LED 的译码器， 
	  //下面实例化 6 个 LED 数码管的各自译码器。   
	sevenseg  LED8_minute_display_high ( minute_display_high, hex5 );   
	sevenseg  LED8_minute_display_low ( minute_display_low,  hex4 );        
	sevenseg  LED8_second_display_high( second_display_high,  hex3 );   
	sevenseg  LED8_second_display_low ( second_display_low,   hex2 );        
	sevenseg  LED8_msecond_display_high( msecond_display_high, hex1 );   
	sevenseg  LED8_msecond_display_low ( msecond_display_low,  hex0 );

	initial
		begin
		counter_work = 0; //初始不计时，按下start/stop以后才开始计时
		display_work = 1;//初始显示不冻结
		end
	
	always @ (posedge clk)     
	  // 每一个时钟上升沿开始触发下面的逻辑， 
	  // 进行计时后各部分的刷新工作          
		begin
		//		计时复位按钮消抖检测
		if(key_reset == 0)
			begin
			led1 <= 1;
			counter_reset <= counter_reset + 1;
			if(counter_reset == DELAY_TIME)//等待20ms消抖
				reset_1_time = 1;
			if(counter_reset < DELAY_TIME)
				reset_1_time = 0;
			end
		else
			begin
			counter_reset <= 0;
			led1 <= 0;
			end
		
		//		计数/暂停
		if(key_start_pause == 0)
			begin
			led2 <= 1;
			counter_start <= counter_start + 1;
			if(counter_start == DELAY_TIME)//wait 20ms to debounce
				start_1_time = 1;
			if(counter_start < DELAY_TIME)
				start_1_time = 0;
			end
		else
			begin
			counter_start <= 0;
			led2 <= 0;
			end
		
		//		refresh/pause
		if(key_display_stop == 0)
			begin
			led3 <= 1;
			counter_display <= counter_display + 1;
			if(counter_display == DELAY_TIME)//wait 20ms to debounce
				display_1_time = 1;
			if(counter_display < DELAY_TIME)
				display_1_time = 0;
			end
		else
			begin
			counter_display <= 0;
			led3 <= 0;
			end
		
		
		//计时
		if(counter_50M == ONE_MS)
			begin
			counter_50M <= 0;
			if(key_reset == 0 && reset_1_time == 1)
				begin
				msecond_counter_low <= 0;
				msecond_counter_high <= 0;
				second_counter_low <= 0;
				second_counter_high <= 0;
				minute_counter_low <= 0;
				minute_counter_high <= 0;
				counter_work = 0;
				reset_1_time = 0;
				end
			
			if(key_display_stop == 0 && display_1_time == 1)
				begin
				display_work = !display_work;
				display_1_time = 0;
				end
			
			if(key_start_pause == 0 && start_1_time == 1)
				begin
				counter_work = !counter_work;
				start_1_time = 0;
				end
			
			if(counter_work == 1)
				begin
				msecond_counter_low <= msecond_counter_low + 1;
				if(msecond_counter_low == 9)
					begin
					msecond_counter_low <= 0;
					msecond_counter_high <= msecond_counter_high + 1;
					if(msecond_counter_high == 9)
						begin
						msecond_counter_high <= 0;
						second_counter_low <= second_counter_low + 1;
						if(second_counter_low == 9)
							begin
							second_counter_low <= 0;
							second_counter_high <= second_counter_high + 1;
							if(second_counter_high == 5)
								begin
								second_counter_high <= 0;
								minute_counter_low <= minute_counter_low + 1;
								if(minute_counter_low == 9)
									begin
									minute_counter_low <= 0;
									minute_counter_high <= minute_counter_high + 1;
									if(minute_counter_high == 5)
										minute_counter_high <= 0;
									end
								end
							end
						end
					end
				end
			if(display_work == 1)
				begin
				msecond_display_low <= msecond_counter_low;
				msecond_display_high <= msecond_counter_high;
				second_display_low <= second_counter_low;
				second_display_high <= second_counter_high;
				minute_display_low <= minute_counter_low;
				minute_display_high <= minute_counter_high;
				minute_display_high <= minute_counter_high;
				end
			end
		else
			counter_50M <= counter_50M + 1;
      end
endmodule 
 
 
 
//4bit 的 BCD 码至 7 段 LED 数码管译码器模块 
//可供实例化共 6 个显示译码模块 
module  sevenseg ( data, ledsegments);     
	input [3:0] data;  
	output [6:0] ledsegments;  
	reg [6:0] ledsegments;         
	always @ (*)      
		case(data)                      
//     gfe_dcba     
// 7 段 LED 数码管的位段编号                
//     654_3210    
// DE1-SOC 板上的信号位编号        
			0: ledsegments = 7'b100_0000;    // DE1-SOC 板上的数码管为共阳极接法。        
			1: ledsegments = 7'b111_1001;        
			2: ledsegments = 7'b010_0100;        
			3: ledsegments = 7'b011_0000; 
			4: ledsegments = 7'b001_1001;        
			5: ledsegments = 7'b001_0010;        
			6: ledsegments = 7'b000_0010;        
			7: ledsegments = 7'b111_1000;        
			8: ledsegments = 7'b000_0000;        
			9: ledsegments = 7'b001_0000;                  
			default: ledsegments = 7'b111_1111;  
// 其它值时全灭。    
		endcase   
endmodule 
```