-- Employees Table
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,  -- IDENTITY for auto-increment
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    DepartmentID INT NULL,  -- Foreign key
    DesignationID INT NULL, -- Foreign key
    HireDate DATE NULL,
    Email NVARCHAR(255) NULL,
    Phone NVARCHAR(20) NULL,
    Address NVARCHAR(MAX) NULL
);

-- Departments Table
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(255) NOT NULL
);

-- Designations Table
CREATE TABLE Designations (
    DesignationID INT IDENTITY(1,1) PRIMARY KEY,
    DesignationName NVARCHAR(255) NOT NULL
);

-- PayPeriods Table
CREATE TABLE PayPeriods (
    PayPeriodID INT IDENTITY(1,1) PRIMARY KEY,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

-- Earnings Types Table (for flexibility)
CREATE TABLE EarningsTypes (
    EarningsTypeID INT IDENTITY(1,1) PRIMARY KEY,
    EarningsTypeName NVARCHAR(255) NOT NULL  -- e.g., "Basic Pay", "DA", "HRA", "Bonus"
);

-- Deductions Types Table (for flexibility)
CREATE TABLE DeductionTypes (
    DeductionTypeID INT IDENTITY(1,1) PRIMARY KEY,
    DeductionTypeName NVARCHAR(255) NOT NULL -- e.g., "PF", "Income Tax", "Loan Repayment"
);

-- Payroll Table (the core table)
CREATE TABLE Payroll (
    PayrollID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,  -- Foreign key
    PayPeriodID INT NOT NULL, -- Foreign key
    PaymentDate DATE NULL,
    LeavesTaken INT NULL,
    LeaveDeductionAmount DECIMAL(18,2) NULL,  -- Calculated separately
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (PayPeriodID) REFERENCES PayPeriods(PayPeriodID)
);

-- Payroll Earnings Table (linking table)
CREATE TABLE PayrollEarnings (
    PayrollEarningsID INT IDENTITY(1,1) PRIMARY KEY,
    PayrollID INT NOT NULL,       -- Foreign key
    EarningsTypeID INT NOT NULL,  -- Foreign key
    Amount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (PayrollID) REFERENCES Payroll(PayrollID),
    FOREIGN KEY (EarningsTypeID) REFERENCES EarningsTypes(EarningsTypeID)
);

-- Payroll Deductions Table (linking table)
CREATE TABLE PayrollDeductions (
    PayrollDeductionsID INT IDENTITY(1,1) PRIMARY KEY,
    PayrollID INT NOT NULL,        -- Foreign key
    DeductionTypeID INT NOT NULL,   -- Foreign key
    Amount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (PayrollID) REFERENCES Payroll(PayrollID),
    FOREIGN KEY (DeductionTypeID) REFERENCES DeductionTypes(DeductionTypeID)
);

-- Performance/Financial Data Table (if applicable)
CREATE TABLE PerformanceData (
    PerformanceDataID INT IDENTITY(1,1) PRIMARY KEY,
    PayrollID INT,  -- Foreign key to Payroll table
    BilledHours DECIMAL(18,2) NULL,
    TotalHoursWorked DECIMAL(18,2) NULL,
    TotalRevenue DECIMAL(18,2) NULL,
    TotalGrossProfit DECIMAL(18,2) NULL,
    EmployerTax DECIMAL(18,2) NULL,
    ActualERTax DECIMAL(18,2) NULL,
    FOREIGN KEY (PayrollID) REFERENCES Payroll(PayrollID)
);
