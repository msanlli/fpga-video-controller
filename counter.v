// --------------------------------------------------------------------
// Universitat Politècnica de València
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2025-26
// --------------------------------------------------------------------
// Nombre del archivo: counter.v
//
// Descripción: Contador parametrizable.
//
// Entradas y salidas:
//    clk      : Reloj activo flanco de subida
//		rst		: Reset activo flanco de bajada
//    en       : Enable activo alto
//    count    : Cuenta en binario
//    tc       : Terminal count activo alto
//
// --------------------------------------------------------------------
// Versión: v1.0 | Fecha Modificación: 06/03/2026
//
// Autor: Marc Sanchis Llinares
//
// --------------------------------------------------------------------
module counter #(
    parameter WIDTH = 11,
    parameter MOD   = 1056
) (
    input  wire                clk,
    input  wire                rst,
    input  wire                en,
    output reg  [WIDTH-1:0]    count,
    output wire                tc
);
    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (count == MOD-1)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end

    assign tc = (count == MOD-1);
endmodule
