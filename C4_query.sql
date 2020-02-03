/* This query gets the number of residential structures and the number of residential units for each parcel.
It also provides a break-down of the structure types on the parcel.
Author: Garin Wally, 11/20/2019
SQL Flavor: MSSQL

TODO: include non-res structs/units
*/

-- MS SQL Studio might require this first.
USE {{db}};

SELECT
	p.GeoCodeSearch AS ParcelID,
	p.PropertyID,
	p.PropType,
	p.LivUnits,  -- Optional; shows that mobile homes aren't counted here
	--ISNULL(r.ResStructs, 0) AS ResStructs,  -- Count of Single-Unit Structures from Res Table; Optional
	--ISNULL(c.ComStructs, 0) AS ComStructs,  -- Count of Structures from Com Table; Optional
	--ISNULL(c.ComUnits, 0) AS ComUnits,    -- Count of Units from Com Table; Optional
	ISNULL(r.ResStructs, 0) + ISNULL(c.ComStructs, 0) AS ResStructs,
	ISNULL(r.ResStructs, 0) + ISNULL(c.ComUnits, 0) AS ResUnits,
	ISNULL(nonres.ComStructs, 0) AS NonResStr,
	ISNULL(nonres.ComUnits, 0) AS NonResUnt,
	ISNULL(r.SFR, 0) + ISNULL(c.SFR, 0) AS SFR,
	ISNULL(r.MH, 0) + ISNULL(c.MH, 0) AS MH,
	ISNULL(r.Condo, 0) + ISNULL(c.Condo, 0) AS Condo,
	ISNULL(c.Multi, 0) AS Multi,
	ISNULL(c.Nursing, 0) AS Nursing,
	ISNULL(r.SFR, 0) + ISNULL(c.SFR, 0) + ISNULL(r.MH, 0) + ISNULL(c.MH, 0) + ISNULL(r.Condo, 0) + ISNULL(c.Condo, 0) + ISNULL(c.Multi, 0) + ISNULL(c.Nursing, 0) AS SumOfTypes
FROM Property p

LEFT JOIN (
	SELECT
		PropertyID,
		COUNT(ResID) AS ResStructs,
		SUM(CASE WHEN ResType = 'SFR' THEN 1 ELSE 0 END) AS 'SFR',
		SUM(CASE WHEN ResType = 'MOB' THEN 1 ELSE 0 END) AS 'MH',
		SUM(CASE WHEN ResType LIKE 'condo%' OR ResType LIKE 'town%' THEN 1 ELSE 0 END) AS 'Condo'
	FROM Res
	WHERE
		TaxYear = 2018
	GROUP BY PropertyID
) r
	ON p.PropertyID=r.PropertyID

LEFT JOIN (
	SELECT
		PropertyID,
		COUNT(ComID) AS ComStructs,
		SUM(UnitsPerBldg) AS ComUnits,
		SUM(CASE WHEN StructureType = 101 THEN 1 ELSE 0 END) AS 'SFR',
		SUM(CASE WHEN StructureType IN (701, 702, 703) THEN 1 ELSE 0 END) AS 'MH',
		SUM(CASE WHEN StructureType IN (106, 107, 108) THEN 1 ELSE 0 END) AS 'Condo',
		SUM(CASE WHEN StructureType IN (102, 103, 104, 105, 211, 212, 213, 319) THEN 1 ELSE 0 END) AS 'Multi',
		SUM(CASE WHEN StructureType IN (316, 318) THEN 1 ELSE 0 END) AS 'Nursing'
	FROM Com
	WHERE
		TaxYear = 2018
		AND StructureType IN (
			-- Living Oriented
			101, 102, 103, 104, 105, 106, 107, 108,
			-- Apartments
			211, 212, 213,
			-- Accommodations
			316, 318, 319,
			-- Mobile Home Parks
			701, 702, 703
			)
		GROUP BY PropertyID
) c
	ON p.PropertyID=c.PropertyID

LEFT JOIN (
	SELECT
		PropertyID,
		COUNT(ComID) AS ComStructs,
		SUM(UnitsPerBldg) AS ComUnits
	FROM Com
	WHERE
		TaxYear = 2018
		AND StructureType NOT IN (  -- NOTE: the 'NOT'
			-- Living Oriented
			101, 102, 103, 104, 105, 106, 107, 108,
			-- Apartments
			211, 212, 213,
			-- Accommodations
			316, 318, 319,
			-- Mobile Home Parks
			701, 702, 703
			)
		GROUP BY PropertyID
) nonres
	ON p.PropertyID=nonres.PropertyID

WHERE
	p.TaxYear = 2018
	--AND p.GeoCodeSearch IN ('04220029343790000', '04220029343700000', '04220029343530000')  -- Test data
	--AND ISNULL(r.ResStructs, 0) + ISNULL(c.ComUnits, 0) > 0  -- Optionally filter residential only; comment out if you want all parcels
	-- Assert that ResStructs = SumOfTypes
	--AND ISNULL(r.SFR, 0) + ISNULL(c.SFR, 0) + ISNULL(r.MH, 0) + ISNULL(c.MH, 0) + ISNULL(r.Condo, 0) + ISNULL(c.Condo, 0) + ISNULL(c.Multi, 0) + ISNULL(c.Nursing, 0) <> ISNULL(r.ResStructs, 0) + ISNULL(c.ComStructs, 0)
	--AND ISNULL(r.ResStructs, 0) + ISNULL(c.ComUnits, 0) <> p.LivUnits
	--AND ISNULL(r.ResStructs, 0) + ISNULL(c.ComUnits, 0) > 0
-- TODO: fix DOR issues like with '04220021307050000'
;