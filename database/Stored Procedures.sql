CREATE OR ALTER PROCEDURE LoadPayroll
AS
BEGIN
    SET NOCOUNT ON;

    MERGE INTO Payroll AS target
    USING (
        SELECT 
            E.EmployeeID, 
            EIP.PayPeriodStartDate, EIP.PayPeriodEndDate, 
            EIP.BasicPay, EIP.DearnessAllowance, EIP.HouseRentAllowance, 
            EIP.ConveyanceAllowance, EIP.MedicalAllowance, EIP.SpecialAllowance, 
            EIP.OtherEarnings, EIP.ProvidentFund, EIP.IncomeTax, 
            EIP.ProfessionalTax, EIP.OtherDeductions, EIP.LeaveDeductionAmount, 
            EIP.PaymentDate,
            YEAR(EIP.PayPeriodStartDate) AS PayYear,
            MONTH(EIP.PayPeriodStartDate) AS PayMonth
        FROM ExcelImportPayroll EIP
        INNER JOIN Employees E ON EIP.Email = E.Email
    ) AS source
    ON target.EmployeeID = source.EmployeeID 
       AND YEAR(target.PayPeriodStartDate) = source.PayYear
       AND MONTH(target.PayPeriodStartDate) = source.PayMonth

    -- Update existing records for the same month
    WHEN MATCHED THEN 
        UPDATE SET 
            target.BasicPay = source.BasicPay,
            target.DearnessAllowance = source.DearnessAllowance,
            target.HouseRentAllowance = source.HouseRentAllowance,
            target.ConveyanceAllowance = source.ConveyanceAllowance,
            target.MedicalAllowance = source.MedicalAllowance,
            target.SpecialAllowance = source.SpecialAllowance,
            target.OtherEarnings = source.OtherEarnings,
            target.ProvidentFund = source.ProvidentFund,
            target.IncomeTax = source.IncomeTax,
            target.ProfessionalTax = source.ProfessionalTax,
            target.OtherDeductions = source.OtherDeductions,
            target.LeaveDeductionAmount = source.LeaveDeductionAmount,
            target.PaymentDate = source.PaymentDate

    -- Insert new records if no data exists for that month
    WHEN NOT MATCHED THEN 
        INSERT (EmployeeID, PayPeriodStartDate, PayPeriodEndDate, BasicPay, DearnessAllowance,
                HouseRentAllowance, ConveyanceAllowance, MedicalAllowance, SpecialAllowance,
                OtherEarnings, ProvidentFund, IncomeTax, ProfessionalTax, OtherDeductions,
                LeaveDeductionAmount, PaymentDate)
        VALUES (source.EmployeeID, source.PayPeriodStartDate, source.PayPeriodEndDate, 
                source.BasicPay, source.DearnessAllowance, source.HouseRentAllowance, 
                source.ConveyanceAllowance, source.MedicalAllowance, source.SpecialAllowance, 
                source.OtherEarnings, source.ProvidentFund, source.IncomeTax, 
                source.ProfessionalTax, source.OtherDeductions, source.LeaveDeductionAmount, 
                source.PaymentDate);

    PRINT ':D Payroll records merged successfully by Employee and Month.';
END;

CREATE OR ALTER PROCEDURE LoadTimesheet
AS
BEGIN
    SET NOCOUNT ON;

    MERGE INTO dbo.Timesheet AS target
    USING (
        SELECT 
            E.EmployeeID, 
            EIP.BilledHours, EIP.TotalHoursWorked, 
            EIP.TotalRevenue, EIP.TotalGrossProfit, 
            EIP.EmployerTax, EIP.ActualERTax
        FROM ExcelImportPayroll EIP
        INNER JOIN dbo.Employees E ON EIP.Email = E.Email
    ) AS source
    ON target.EmployeeID = source.EmployeeID

    -- Update existing records
    WHEN MATCHED THEN 
        UPDATE SET 
            target.BilledHours = source.BilledHours,
            target.TotalHoursWorked = source.TotalHoursWorked,
            target.TotalRevenue = source.TotalRevenue,
            target.TotalGrossProfit = source.TotalGrossProfit,
            target.EmployerTax = source.EmployerTax,
            target.ActualERTax = source.ActualERTax

    -- Insert new records
    WHEN NOT MATCHED THEN 
        INSERT (EmployeeID, BilledHours, TotalHoursWorked, TotalRevenue, 
                TotalGrossProfit, EmployerTax, ActualERTax)
        VALUES (source.EmployeeID, source.BilledHours, source.TotalHoursWorked, 
                source.TotalRevenue, source.TotalGrossProfit, 
                source.EmployerTax, source.ActualERTax);

    PRINT ':D Timesheet records merged successfully.';
END;

CREATE PROCEDURE LoadDepartments
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate data: Ensure there are no NULL values in the Department column
    IF EXISTS (SELECT 1 FROM ExcelImportPayroll WHERE Department IS NULL)
    BEGIN
        RAISERROR('Data validation failed: Missing required fields for Departments.', 16, 1);
        RETURN;
    END

    -- Use MERGE to insert only new department names
    MERGE INTO Departments AS target
    USING (SELECT DISTINCT Department FROM ExcelImportPayroll WHERE Department IS NOT NULL) AS source
    ON target.DepartmentName = source.Department
    WHEN NOT MATCHED THEN
        INSERT (DepartmentName) VALUES (source.Department);

    PRINT ':D Departments inserted successfully.';
END;

CREATE PROCEDURE LoadDesignations
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ExcelImportPayroll WHERE Designation IS NULL)
    BEGIN
        RAISERROR('Data validation failed: Missing required fields for Designations.', 16, 1);
        RETURN;
    END

    MERGE INTO Designations AS target
    USING (SELECT DISTINCT Designation FROM ExcelImportPayroll WHERE Designation IS NOT NULL) AS source
    ON target.DesignationName = source.Designation
    WHEN NOT MATCHED THEN
        INSERT (DesignationName) VALUES (source.Designation);

    PRINT ':D Designations inserted successfully.';
END;

CREATE PROCEDURE LoadEmployees
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert only new employees
    MERGE INTO Employees AS target
    USING (
        SELECT DISTINCT 
            EIP.EmployeeName,
            EIP.Email,
            EIP.PhoneNumber,
            D.DepartmentID,
            DS.DesignationID
        FROM ExcelImportPayroll EIP
        LEFT JOIN Departments D ON EIP.Department = D.DepartmentName
        LEFT JOIN Designations DS ON EIP.Designation = DS.DesignationName
        WHERE EIP.EmployeeName IS NOT NULL
    ) AS source
    ON target.Email = source.Email
    WHEN NOT MATCHED THEN
        INSERT (EmployeeName, Email, PhoneNumber, DepartmentID, DesignationID)
        VALUES (source.EmployeeName, source.Email, source.PhoneNumber, source.DepartmentID, source.DesignationID);

    PRINT ':D Employees inserted successfully.';
END;

CREATE OR ALTER PROCEDURE LoadLeaveRecords
AS
BEGIN
    SET NOCOUNT ON;

    MERGE INTO LeaveRecords AS target
    USING (
        SELECT 
            E.EmployeeID, 
            EIP.LeavesTaken, 
            EIP.LeaveDeductionAmount
        FROM ExcelImportPayroll EIP
        INNER JOIN Employees E ON EIP.Email = E.Email
    ) AS source
    ON target.EmployeeID = source.EmployeeID

    -- Update existing records
    WHEN MATCHED THEN 
        UPDATE SET 
            target.LeavesTaken = source.LeavesTaken,
            target.LeaveDeductionAmount = source.LeaveDeductionAmount

    -- Insert new records
    WHEN NOT MATCHED THEN 
        INSERT (EmployeeID, LeavesTaken, LeaveDeductionAmount)
        VALUES (source.EmployeeID, source.LeavesTaken, source.LeaveDeductionAmount);

    PRINT '✅ Leave records merged successfully.';
END;
