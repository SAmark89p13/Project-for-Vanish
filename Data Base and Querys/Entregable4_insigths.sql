-- VENTAS POR CATEGORIA 
SELECT 
    DISTINCT CATEGORY 
FROM DIM_PRODUCT; 
-- Solamente tenemos una categoría esperamos 
-- solamente una fila en las ventar por cat
-- Usando FACT_SALES + DIM_PRODUCT + DIM_CATEGORY.
--  Como en FACT_SALES a veces hay sufijos BP1, BP2, etc, limpio el ITEM_CODE al vuelo para poder hacer el JOIN
SELECT
    c.CATEGORY AS NombreCategoria,
    SUM(fs.TOTAL_VALUE_SALES) AS VentasTotales
FROM FACT_SALES AS fs
JOIN DIM_PRODUCT AS p
    ON REPLACE(REPLACE(REPLACE(fs.ITEM_CODE, 'BP1', ''), 'BP2', ''), 'BP', '') = p.ITEM
JOIN DIM_CATEGORY AS c
    ON p.CATEGORY = c.ID_CATEGORY
GROUP BY
    c.CATEGORY
ORDER BY
    VentasTotales DESC;
    

-- VENTAS TOTALES POR REGIÓN
SELECT
    REGION,
    SUM(TOTAL_VALUE_SALES) AS VentasTotales
FROM FACT_SALES
GROUP BY
    REGION
ORDER BY
    VentasTotales DESC;


-- Ventas por REGIÓN y PERIODO (YEAR, MONTH)
--Aquí metemos DIM_CALENDAR y agrupamos por año, mes y región
SELECT
    cal.YEAR,
    cal.MONTH,
    fs.REGION,
    SUM(fs.TOTAL_VALUE_SALES) AS VentasTotales
FROM FACT_SALES AS fs
JOIN DIM_CALENDAR AS cal
    ON fs.WEEK = cal.WEEK
GROUP BY
    cal.YEAR,
    cal.MONTH,
    fs.REGION
ORDER BY
    cal.YEAR,
    cal.MONTH,
    fs.REGION;

-- Considero valiosa la query así que la guardaré como una tabla:
SELECT
    cal.YEAR,
    cal.MONTH,
    fs.REGION,
    SUM(fs.TOTAL_VALUE_SALES) AS VentasTotales
INTO dbo.VENTAS_REGION_PERIODO   --  nombre de la nueva tabla
FROM FACT_SALES AS fs
JOIN DIM_CALENDAR AS cal
    ON fs.WEEK = cal.WEEK
GROUP BY
    cal.YEAR,
    cal.MONTH,
    fs.REGION;
GO


-- Mes con MAYOR ventas por año
SELECT
    YEAR,
    MONTH,
    VentasTotalesMes
FROM (
    SELECT
        YEAR,
        MONTH,
        SUM(VentasTotales) AS VentasTotalesMes,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR
            ORDER BY SUM(VentasTotales) DESC
        ) AS rn
    FROM dbo.VENTAS_REGION_PERIODO
    GROUP BY
        YEAR,
        MONTH
) AS T
WHERE rn = 1
ORDER BY YEAR;
