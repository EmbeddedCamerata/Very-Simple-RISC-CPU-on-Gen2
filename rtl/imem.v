`include "config.vh"

module imem(
	input		[31:0]	a,
    output wire [31:0]	rd
);

	reg [31:0] RAM[63:0];

	assign rd = RAM[a[31:2]]; // word aligned

/*
	1. Test the RISC-V processor.  
	add, sub, and, or, slt, addi, lw, sw, beq, jal
	If successful, it should write the value 25 to address 100
	
	#       RISC-V Assembly         Description               Address   Machine Code
	main:   addi x2, x0, 5          # x2 = 5                  00		0x00500113	# 0000000_00101_00000_000_00010_0010011
			addi x3, x0, 12         # x3 = 12                 04		0x00C00193	# 0000000_01100_00000_000_00011_0010011
			addi x7, x3, -9         # x7 = (12 - 9) = 3       08		0xFF718393	# 1111111_10111_00011_000_00111_0010011
			or   x4, x7, x2         # x4 = (3 OR 5) = 7       0C		0x0023E233	# 0000000_00010_00111_110_00100_0110011
			and  x5, x3, x4         # x5 = (12 AND 7) = 4     10		0x0041F2B3	# 0000000_00100_00011_111_00101_0110011
			add  x5, x5, x4         # x5 = (4 + 7) = 11       14		0x004282B3	# 0000000_00100_00101_000_00101_0110011
			beq  x5, x7, end        # shouldn't be taken      18		0x02728863	# 0000001_00111_00101_000_10000_1100011
			slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C		0x0041A233	# 0000000_00100_00011_010_00100_0110011
			beq  x4, x0, around     # should be taken         20		0x00020463	# 0000000_00000_00100_000_01000_1100011
			addi x5, x0, 0          # shouldn't happen        24		0x00000293	# 0000000_00000_00000_000_00101_0010011
	around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28		0x0023A233	# 0000000_00010_00111_010_00100_0110011
			add  x7, x4, x5         # x7 = (1 + 11) = 12      2C		0x005203B3	# 0000000_00101_00100_000_00111_0110011
			sub  x7, x7, x2         # x7 = (12 - 5) = 7       30		0x402383B3	# 0100000_00010_00111_000_00111_0110011
			sw   x7, 84(x3)         # [96] = 7                34		0x0471AA23	# 0000010_00111_00011_010_10100_0100011
			lw   x2, 96(x0)         # x2 = [96] = 7           38		0x06002103	# 0000011_00000_00000_010_00010_0000011
			add  x9, x2, x5         # x9 = (7 + 11) = 18      3C		0x005104B3	# 0000000_00101_00010_000_01001_0110011
			jal  x3, end            # jump to end, x3 = 0x44  40		0x008001EF	# 0000_0000_1000_0000_0000_00011_1101111
			addi x2, x0, 1          # shouldn't happen        44		0x00100113	# 0000000_00001_00000_000_00010_0010011
	end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48		0x00910133	# 0000000_01001_00010_000_00010_0110011
			sw   x2, 0x20(x3)       # mem[100] = 25           4C		0x0221A023	# 0000001_00010_00011_010_00000_0100011
	done:   beq  x2, x2, done       # infinite loop           50		0x00210063	# 0000000_00010_00010_000_00000_1100011
	
	2. rotating leds.
	If successful, 8 Leds will rotating orderly all the time.

	#        	RISC-V Assembly 		Description  					Address		Machine Code
	init:       addi t5, x0, 2047       # count_max, t5 = 2047          00			0x7FF00F13	# 0111_1111_1111_00000_000_11110_0010011
				add  t5, t5, t5         # count_max, t5 = 2047*2        04			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*4        08			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*8        0C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*16       10			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*32       14			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*64       18			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*128      1C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*256      20			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*512      24			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*1024     28			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*2048     2C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*4096     30			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				add  t5, t5, t5         # count_max, t5 = 2047*8192     34			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
				addi t6, x0, 256        # led_max, t6 = 256             38			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
	clean_led:  addi t4, x0, 1          # init led value, t4 = 1        3C			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011
	clean_cnt:  addi t3, x0, 0          # clear count(t3).              40			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
	count:      addi t3, t3, 1          # count++  						44			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
				beq  t3, t5, mov_led    # if count==max, jump mov_led   48			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
				jal count               # 								4C			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
	mov_led:    add t4, t4, t4          # led << 1.						50			0x01DE8EB3	# 0000_000_11101_11101_000_11101_0110011
				beq t4, t6, clean_led   # 								54			0xFFFE84E3	# 1111111_11111_11101_000_01001_1100011
				jal clean_cnt           # 								58			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111
	
	For simulation, t5 = 8(short enough):
	#        	RISC-V Assembly 		Description  					Address		Machine Code
	init:       addi t5, x0, 8       	# count_max, t5 = 8 			00			0x00800F13	# 0000_0000_1000_00000_000_11110_0010011
				addi t6, x0, 256        # led_max, t6 = 256             04			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
	clean_led:  addi t4, x0, 1          # init led value, t4 = 1        08			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011
	clean_cnt:  addi t3, x0, 0          # clear count(t3).              0C			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
	count:      addi t3, t3, 1          # count++  						10			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
				beq  t3, t5, mov_led    # if count==max, jump mov_led   14			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
				jal count               # 								18			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
	mov_led:    add t4, t4, t4          # led << 1.						1C			0x01DE8EB3	# 0000_000_11101_11101_000_11101_0110011
				beq t4, t6, clean_led   # 								20			0xFFFE84E3	# 1111111_11111_11101_000_01001_1100011
				jal clean_cnt           # 								24			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111

	3. Double-side rotating leds.
	If successful, 8 Leds will rotating back and forth all the time.
	
	Register	Address 	Meaning
	t3 			11100 		counter of t5
	t4 			11101 		LED result
	t5 			11110 		0.5s time count
	t6 			11111 		pow of LED count
	x2 			00010 		counter of t6
	x3 			00011 		shadow register of t4
	x4 			00100 		indicate to increase(0) or decrease(1)
	x5			00101 		temporary register

	#           RISC-V Assembly         Description                     Address     Machine Code
	init:       addi t5, x0, 2047       # count_max, t5 = 2047          00			0x7FF00F13	# 0111_1111_1111_00000_000_11110_0010011
				addi t3, x0, 13			# loop_cnt = 13 				04			0x00D00E13	# 0000_0000_1101_00000_000_11100_0010011
				addi x5, x0, 0 			# x5 = 0 						08			0x00000293	# 0000_0000_0000_00000_000_00101_0010011
	init_loop:  addi x5, x5, 1 			# x5 += 1 						0C			0x00128293	# 0000_0000_0001_00101_000_00101_0010011
				add  t5, t5, t5 		# t5 *= 2 						10			0x01EF0F33	# 0000000_11110_11110_000_11110_0110011
				beq  x5, t3, start		# if x5 == t3, jump start 		14			0x005E0463	# 0000000_00101_11100_000_01000_1100011
				jal  init_loop 			# 								18			0xFF5FF06F	# 1111_1111_0101_1111_1111_00000_1101111
	start: 		addi t6, x0, 8        	# pow_max, t6 = 8           	1C			0x00800F93	# 0000_0000_1000_00000_000_11111_0010011
				addi x2, x0, 0          # init pow count, x2 = 0        20			0x00000113	# 0000_0000_0000_00000_000_00010_0010011
				addi x4, x0, 0 			# x4 = 0 						24			0x00000213	# 0000_0000_0000_00000_000_00100_0010011
				addi t4, x0, 0 			# t4 = 0 						28			0x00000E93	# 0000_0000_0000_00000_000_11101_0010011
	clean_cnt:  addi t3, x0, 0          # clear count(t3).              2C			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
	count_add:  addi t3, t3, 1          # count++                       30			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
	            beq  t3, t5, judge 		# if count==max, jump judge 	34			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
	            jal  count_add          #                               38			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
	judge:		beq  x2, t6, dec_pow  	# if x2 == 8, jump dec_pow 		3C			0x002F8463	# 0000000_00010_11111_000_01000_1100011
				beq  x4, x0, add_pow 	# if x4 == 0, jump add_pow 		40			0x00400A63	# 0000000_00100_00000_000_10100_1100011	
	dec_pow:	addi x4, x0, 1 			# x4 = 1 						44			0x00100213	# 0000_0000_0001_00000_000_00100_0010011
				beq  x2, x4, add_pow 	# if x2 == x4, jump add_pow 	48			0x00220663	# 0000000_00010_00100_000_01100_1100011
				sub  x2, x2, x4 		# x2 -= 1 						4C			0x40410133	# 0100000_00100_00010_000_00010_0110011
				jal  get_led 			#								50			0x00C0006F	# 0000_0000_1100_0000_0000_00000_1101111
	add_pow:    addi x4, x0, 0 			# x4 = 0 						54			0x00000213	# 0000_0000_0000_00000_000_00100_0010011
				addi x2, x2, 1        	# x2 += 1 		              	58			0x00110113	# 0000_0000_0001_00010_000_00010_0010011
	get_led:	addi x5, x0, 1			# x5 = 1 						5C			0x00100293	# 0000_0000_0001_00000_000_00101_0010011
				addi x3, x0, 1 			# x3 = 1 						60			0x00100193	# 0000_0000_0001_00000_000_00011_0010011
	led_loop:	beq  x5, x2, show_led	# if x5 == x2, jump show_led 	64			0x00228863	# 0000000_00010_00101_000_10000_1100011
				addi x5, x5, 1 			# x5 += 1 						68			0x00128293	# 0000_0000_0001_00101_000_00101_0010011
				add  x3, x3, x3 		# x3 *= 2 						6C			0x003181B3	# 0000000_00011_00011_000_00011_0110011
				jal  led_loop 			#								70			0xFF5FF06F	# 1111_1111_0101_1111_1111_00000_1101111
	show_led: 	addi t4, x3, 0 			# t4 = x3 						74			0x00018E93	# 0000_0000_0000_00011_000_11101_0010011
				jal  clean_cnt  		# 								78			0xFB5FF06F	# 1111_1011_0101_1111_1111_00000_1101111
	
	For simulation, t5 = 16:
				RISC-V Assembly         Description                     Address     Machine Code
	init:       addi t5, x0, 1      	# count_max, t5 = 1				00			0x00100F13	# 0000_0000_0001_00000_000_11110_0010011
				addi t3, x0, 4			# loop_cnt = 4					04			0x00400E13	# 0000_0000_0100_00000_000_11100_0010011
				addi x5, x0, 0 			# x5 = 0 						08			0x00000293	# 0000_0000_0000_00000_000_00101_0010011
	init_loop:  addi x5, x5, 1 			# x5 += 1 						0C			0x00128293	# 0000_0000_0001_00101_000_00101_0010011
				add  t5, t5, t5 		# t5 *= 2 						10			0x01EF0F33	# 0000000_11110_11110_000_11110_0110011
				beq  x5, t3, start		# if x5 == t3, jump start 		14			0x005E0463	# 0000000_00101_11100_000_01000_1100011
				jal  init_loop 			# 								18			0xFF5FF06F	# 1111_1111_0101_1111_1111_00000_1101111
	start: 		addi t6, x0, 8        	# pow_max, t6 = 8           	1C			0x00800F93	# 0000_0000_1000_00000_000_11111_0010011
				addi x2, x0, 0          # init pow count, x2 = 0        20			0x00000113	# 0000_0000_0000_00000_000_00010_0010011
				addi x4, x0, 0 			# x4 = 0 						24			0x00000213	# 0000_0000_0000_00000_000_00100_0010011
				addi t4, x0, 0 			# t4 = 0 						28			0x00000E93	# 0000_0000_0000_00000_000_11101_0010011	
	clean_cnt:  addi t3, x0, 0          # clear count(t3).              2C			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
	count_add:  addi t3, t3, 1          # count++                       30			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
	            beq  t3, t5, judge 		# if t3==count_max, jump judge 	34			0x01CF0463	# 0000000_11100_11110_000_01000_1100011
	            jal  count_add          #                               38			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
	judge:		beq  x2, t6, dec_pow  	# if x2 == 8, jump dec_pow 		3C			0x002F8463	# 0000000_00010_11111_000_01000_1100011
				beq  x4, x0, add_pow 	# if x4 == 0, jump add_pow 		40			0x00400A63	# 0000000_00100_00000_000_10100_1100011	
	dec_pow:	addi x4, x0, 1 			# x4 = 1 						44			0x00100213	# 0000_0000_0001_00000_000_00100_0010011
				beq  x2, x4, add_pow 	# if x2 == x4, jump add_pow 	48			0x00220663	# 0000000_00010_00100_000_01100_1100011
				sub  x2, x2, x4 		# x2 -= 1 						4C			0x40410133	# 0100000_00100_00010_000_00010_0110011
				jal  get_led 			#								50			0x00C0006F	# 0000_0000_1100_0000_0000_00000_1101111	
	add_pow:    addi x4, x0, 0 			# x4 = 0 						54			0x00000213	# 0000_0000_0000_00000_000_00100_0010011
				addi x2, x2, 1        	# x2 += 1 		              	58			0x00110113	# 0000_0000_0001_00010_000_00010_0010011
	get_led:	addi x5, x0, 1			# x5 = 1 						5C			0x00100293	# 0000_0000_0001_00000_000_00101_0010011
				addi x3, x0, 1 			# x3 = 1 						60			0x00100193	# 0000_0000_0001_00000_000_00011_0010011
	led_loop:	beq  x5, x2, show_led	# if x5 == x2, jump show_led 	64			0x00228863	# 0000000_00010_00101_000_10000_1100011
				addi x5, x5, 1 			# x5 += 1 						68			0x00128293	# 0000_0000_0001_00101_000_00101_0010011
				add  x3, x3, x3 		# x3 *= 2 						6C			0x003181B3	# 0000000_00011_00011_000_00011_0110011
				jal  led_loop 			#								70			0xFF5FF06F	# 1111_1111_0101_1111_1111_00000_1101111
	show_led: 	addi t4, x3, 0 			# t4 = x3 						74			0x00018E93	# 0000_0000_0000_00011_000_11101_0010011
				jal  clean_cnt  		# 								78			0xFB5FF06F	# 1111_1011_0101_1111_1111_00000_1101111
*/

`ifndef SIM_ON_IVERILOG
`ifdef USE_ROTATING_LEDS_EXAMPLE
	assign RAM[0]  = 32'h7FF00F13;
	assign RAM[1]  = 32'h01EF0F33;
	assign RAM[2]  = 32'h01EF0F33;
	assign RAM[3]  = 32'h01EF0F33;
	assign RAM[4]  = 32'h01EF0F33;
	assign RAM[5]  = 32'h01EF0F33;
	assign RAM[6]  = 32'h01EF0F33;
	assign RAM[7]  = 32'h01EF0F33;
	assign RAM[8]  = 32'h01EF0F33;
	assign RAM[9]  = 32'h01EF0F33;
	assign RAM[10] = 32'h01EF0F33;
	assign RAM[11] = 32'h01EF0F33;
	assign RAM[12] = 32'h01EF0F33;
	assign RAM[13] = 32'h01EF0F33;
	assign RAM[14] = 32'h10000f93;
	assign RAM[15] = 32'h00100e93;
	assign RAM[16] = 32'h00000e13;
	assign RAM[17] = 32'h001E0E13;
	assign RAM[18] = 32'h01EE0463;
	assign RAM[19] = 32'hFF9FF06F;
	assign RAM[20] = 32'h01DE8EB3;
	assign RAM[21] = 32'hFFFE84E3;
	assign RAM[22] = 32'hFE9FF06F;
`else
	assign RAM[0]  = 32'h7FF00F13;
	assign RAM[1]  = 32'h00D00E13;
	assign RAM[2]  = 32'h00000293;
	assign RAM[3]  = 32'h00128293;
	assign RAM[4]  = 32'h01EF0F33;
	assign RAM[5]  = 32'h005E0463;
	assign RAM[6]  = 32'hFF5FF06F;
	assign RAM[7]  = 32'h00800F93;
	assign RAM[8]  = 32'h00000113;
	assign RAM[9]  = 32'h00000213;
	assign RAM[10] = 32'h00000E93;
	assign RAM[11] = 32'h00000E13;
	assign RAM[12] = 32'h001E0E13;
	assign RAM[13] = 32'h01EE0463;
	assign RAM[14] = 32'hFF9FF06F;
	assign RAM[15] = 32'h002F8463;
	assign RAM[16] = 32'h00400A63;
	assign RAM[17] = 32'h00100213;
	assign RAM[18] = 32'h00220663;
	assign RAM[19] = 32'h40410133;
	assign RAM[20] = 32'h00C0006F;
	assign RAM[21] = 32'h00000213;
	assign RAM[22] = 32'h00110113;
	assign RAM[23] = 32'h00100293;
	assign RAM[24] = 32'h00100193;
	assign RAM[25] = 32'h00228863;
	assign RAM[26] = 32'h00128293;
	assign RAM[27] = 32'h003181B3;
	assign RAM[28] = 32'hFF5FF06F;
	assign RAM[29] = 32'h00018E93;
	assign RAM[30] = 32'hFB5FF06F;
`endif
`endif

endmodule