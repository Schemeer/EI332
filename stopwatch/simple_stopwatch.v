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