LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

-- RASMUS' DESIGN
ENTITY lod74b IS
    PORT(
        A : IN STD_LOGIC_VECTOR(73 DOWNTO 0);
--         VALID : OUT STD_LOGIC;
--       Z : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        Z : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
         );
END lod74b;
             
ARCHITECTURE ARCH OF lod74b IS
TYPE LEVEL1 IS ARRAY(0 TO 18) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
TYPE LEVEL2 IS ARRAY(0 TO 9) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
TYPE LEVEL3 IS ARRAY(0 TO 4) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
TYPE LEVEL4 IS ARRAY(0 TO 2) OF STD_LOGIC_VECTOR(4 DOWNTO 0);
TYPE LEVEL5 IS ARRAY(0 TO 1) OF STD_LOGIC_VECTOR(5 DOWNTO 0);
--TYPE LEVEL6 IS ARRAY(0 TO 1) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    
BEGIN
    LOD_ALG : PROCESS(A)
    VARIABLE P0,V0 : STD_LOGIC_VECTOR(0 TO 36);
    VARIABLE P1 : LEVEL1;
    VARIABLE V1 : STD_LOGIC_VECTOR(0 TO 18);
    VARIABLE P2 : LEVEL2;
    VARIABLE V2 : STD_LOGIC_VECTOR(0 TO 9);
    VARIABLE P3 : LEVEL3;
    VARIABLE V3 : STD_LOGIC_VECTOR(0 TO 4);
    VARIABLE P4 : LEVEL4;
    VARIABLE V4 : STD_LOGIC_VECTOR(0 TO 2);
    VARIABLE P5 : LEVEL5;
    VARIABLE V5 : STD_LOGIC_VECTOR(0 TO 1);
    --VARIABLE P6 : LEVEL6;
    --VARIABLE V6 : STD_LOGIC_VECTOR(0 TO 1);
    VARIABLE P6 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    VARIABLE V6 : STD_LOGIC;
    BEGIN
        -- LEVEL 0
        FOR I IN 0 TO 36 LOOP
          P0(I) :=  NOT(A(73-2*I)) AND A(72-2*I);
          V0(I) := A(73-2*I) OR A(72-2*I);
        END LOOP;
        
        -- LEVEL 1
        FOR I IN 0 TO 17 LOOP
          V1(I) := V0(2*I) OR V0(2*I+1);
          IF V0(2*I) = '1' THEN
            P1(I) := '0' & P0(2*I);
          ELSIF V0(2*I+1) = '1' THEN
            P1(I) := '1' & P0(2*I+1);
          ELSE
            P1(I) := "00";
          END IF;
        END LOOP;
        P1(18) := '0' & P0(36);
        V1(18) := V0(36);
        
        --LEVEL 2
        FOR I IN 0 TO 8 LOOP
          V2(I) := V1(2*I) OR V1(2*I+1);
          IF V1(2*I) = '1' THEN
             P2(I) := '0' & P1(2*I);
          ELSIF V1(2*I+1) = '1' THEN
             P2(I) := '1' & P1(2*I+1);
          ELSE
             P2(I) := "000";
          END IF;
        END LOOP;
        P2(9) := '0' & P1(18);
        V2(9) := V1(18); 
        
        --LEVEL 3
        FOR I IN 0 TO 4 LOOP
          V3(I) := V2(2*I) OR V2(2*I+1);
          IF V2(2*I) = '1' THEN
             P3(I) := '0' & P2(2*I);
          ELSIF V2(2*I+1) = '1' THEN
             P3(I) := '1' & P2(2*I+1);
          ELSE
             P3(I) := "0000";
          END IF;
        END LOOP;
        --P3(10) := '0' & P2(20);
        --V3(10) := V2(20); 
        
        --LEVEL 4
        FOR I IN 0 TO 1 LOOP
          V4(I) := V3(2*I) OR V3(2*I+1);
          IF V3(2*I) = '1' THEN
             P4(I) := '0' & P3(2*I);
          ELSIF V3(2*I+1) = '1' THEN
             P4(I) := '1' & P3(2*I+1);
          ELSE
             P4(I) := "00000";
          END IF;
        END LOOP;
        P4(2) := '0' & P3(4);
        V4(2) := V3(4); 
        
        -- LEVEL5
        V5(0) := V4(0) OR V4(1);
        IF V4(0) = '1' THEN
           P5(0) := '0' & P4(0);
        ELSIF V4(1) = '1' THEN
           P5(0) := '1' & P4(1);
        ELSE
           P5(0) := "000000";
        END IF;
        P5(1) := '0' & P4(2);
        V5(1) := V4(2);
        
        -- LEVEL5
        V6 := V5(0) OR V5(1);
        IF V5(0) = '1' THEN
           P6 := '0' & P5(0);
        ELSIF V5(1) = '1' THEN
           P6 := '1' & P5(1);
        ELSE
           P6 := "0000000";
        END IF;
        
--        VALID <= V6;
        Z <= P6;

    END PROCESS;
END ARCH;
