// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2025-26
// --------------------------------------------------------------------
// Nombre del archivo: lcd_sync.v
//
// Descripción: Módulo generador de señales de sincronismo para la pantalla LCD.
//              Incluye un PLL para generar el reloj de 25 MHz, contadores
//              horizontal y vertical, y lógica para las señales HD, VD, DEN,
//              así como las coordenadas de fila y columna actuales.
//
// Entradas y salidas:
//   CLK      : Reloj de entrada de 50 MHz (desde el oscilador de la placa)
//   RST_n    : Reset asíncrono activo bajo
//   HD       : Sincronismo horizontal (activo bajo)
//   VD       : Sincronismo vertical (activo bajo)
//   GREST    : Reset global para la pantalla (activo bajo)
//   NCLK     : Reloj de salida de 25 MHz para la pantalla
//   DEN      : Enable de datos (activo alto en área visible)
//   Row      : Fila actual (0-524)
//   Column   : Columna actual (0-1055)
//
// --------------------------------------------------------------------
// Versión: v1.0 | Fecha Modificación: 06/03/2026
//
// Autor: Marc Sanchis Llinares
//
// --------------------------------------------------------------------
module lcd_sync (
    input  wire       CLK,      // 50 MHz from board
    input  wire       RST_n,    
    output wire       HD,       
    output wire       VD,       
    output wire       GREST,    
    output wire       NCLK,     
    output wire       DEN,      
    output wire [9:0] Row,      
    output wire [10:0] Column   
);

	`ifdef MODEL_TECH // High-level model of PLL as toggle flip-flop (fast simulation)
		reg nclk_sim;
		assign NCLK = nclk_sim;

		always @(posedge CLK or negedge RST_n)
			if (~RST_n)
				nclk_sim <= 0;
			else
				nclk_sim <= ~nclk_sim;
	`else // Actual PLL instantiation for synthesis
		pll_ltm pll_ltm_inst (
				.inclk0(CLK),
				.c0    (NCLK)
			);
	`endif

   // Synchronize the external reset to the 25 MHz clock domain
   reg [1:0] rst_sync;
   always @(posedge NCLK or negedge RST_n) begin
		if (!RST_n)
         rst_sync <= 2'b00;
      else
			rst_sync <= {rst_sync[0], 1'b1};
   end
   wire rst = ~rst_sync[1];   // active-high reset for counters

   // Horizontal counter (0 to 1055)
   wire [10:0] hcount;
   wire        tc_h;
   counter #(.WIDTH(11), .MOD(1056)) h_counter (
		.clk   (NCLK),
      .rst   (rst),
      .en    (1'b1),
		.count (hcount),
      .tc    (tc_h)
	);

   // Vertical counter (0 to 524)
   wire [9:0] vcount;
   wire       tc_v;
   counter #(.WIDTH(10), .MOD(525)) v_counter (
		.clk   (NCLK),
      .rst   (rst),
      .en    (tc_h),
      .count (vcount),
      .tc    (tc_v)
	);

   // Visible area boundaries (sized to match the counters)
   localparam [10:0] H_VIS_START = 216;
   localparam [10:0] H_VIS_END   = 1015;
   localparam [9:0]  V_VIS_START = 35;
   localparam [9:0]  V_VIS_END   = 514;

	// Output assignments
   assign HD     = ~tc_h;
   assign VD     = ~tc_v;
   assign GREST  = rst_sync[1];   // synchronized active-low reset
   assign DEN    = (hcount >= H_VIS_START) && (hcount <= H_VIS_END) &&
                   (vcount >= V_VIS_START) && (vcount <= V_VIS_END);
   assign Column = hcount;
   assign Row    = vcount;

endmodule
