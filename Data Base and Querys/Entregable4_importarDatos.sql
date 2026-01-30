SELECT name FROM sys.tables; -- Comprobar que están cargadas las tablas

-- Vamos a importar los datos de nuestros archivos CSV
-- Con bulk

----------------------------- CATEGORY
BULK INSERT DIM_CATEGORY
FROM 'C:\ventas\DIM_CATEGORY.csv'
WITH (
    FIRSTROW = 2,           -- Si la fila 1 tiene encabezados
    FIELDTERMINATOR = ',',  -- separador de columnas
    ROWTERMINATOR = '\n',   -- fin de fila
    TABLOCK
);
GO

---------------------------------- CALENDAR
BULK INSERT dbo.DIM_CALENDAR
FROM 'C:\ventas\DIM_CALENDAR (4).csv'
WITH (
    FIRSTROW = 2,              -- la fila 1 trae WEEK,YEAR,MONTH...
    FIELDTERMINATOR = ',',     -- CSV por comas
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

------------------------------ SEGMENT
BULK INSERT dbo.DIM_SEGMENT
FROM 'C:\ventas\DIM_SEGMENT.csv'
WITH (
    FIRSTROW = 2,              -- saltar encabezado
    FIELDTERMINATOR = ',',     -- CSV por comas
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

------------------------------- product
BULK INSERT dbo.DIM_PRODUCT
FROM 'C:\ventas\DIM_PRODUCT.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

------------------------------------- SALES Tabla para cargar todo en varchar
BULK INSERT dbo.FACT_SALES_STG
FROM 'C:\ventas\FACT_SALES.csv'
WITH (
    FIRSTROW      = 2,          -- saltar encabezado
    FIELDTERMINATOR = ',',      -- separado por comas
    ROWTERMINATOR   = '0x0a',   -- fin de línea
    FIELDQUOTE      = '"',      -- para quitar comillas "34-22"
    TABLOCK
);
GO
------------------------------------- SALES quitar las comillas ("")

UPDATE dbo.FACT_SALES_STG
SET 
    TOTAL_UNIT_SALES_STR      = REPLACE(LTRIM(RTRIM(TOTAL_UNIT_SALES_STR))      , '"', ''),
    TOTAL_VALUE_SALES_STR     = REPLACE(LTRIM(RTRIM(TOTAL_VALUE_SALES_STR))     , '"', ''),
    TOTAL_UNIT_AVG_WEEKLY_STR = REPLACE(LTRIM(RTRIM(TOTAL_UNIT_AVG_WEEKLY_STR)) , '"', '');
GO

------------------------------------- SALES Tabla para insertar los datos en la verdadera
INSERT INTO dbo.FACT_SALES (
    WEEK,
    ITEM_CODE,
    TOTAL_UNIT_SALES,
    TOTAL_VALUE_SALES,
    TOTAL_UNIT_AVG_WEEKLY_SALES,
    REGION
)
SELECT
    WEEK,
    ITEM_CODE,
    CAST(TOTAL_UNIT_SALES_STR      AS DECIMAL(18,3)),
    CAST(TOTAL_VALUE_SALES_STR     AS DECIMAL(18,3)),
    CAST(TOTAL_UNIT_AVG_WEEKLY_STR AS DECIMAL(18,3)),
    REGION
FROM dbo.FACT_SALES_STG;
GO

------------------------------------- SALES Tabla Verdadera, quitar las comillas que quedaron
UPDATE dbo.FACT_SALES
SET 
    WEEK      = REPLACE(LTRIM(RTRIM(WEEK))      , '"', ''),
    ITEM_CODE     = REPLACE(LTRIM(RTRIM(ITEM_CODE))     , '"', '');
GO


EXEC sp_help 'dbo.DIM_PRODUCT'; -- Información sobre nuestras tablas
GO

