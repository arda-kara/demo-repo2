library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package body func_pkg is
    -- Function implementation
    function log2ceil(val : natural) return natural is
    begin
        if val <= 1 then
            return 1;
        else
            return integer(ceil(log2(real(val))));
        end if;
    end function;
end func_pkg;
