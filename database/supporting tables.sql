-- ======================================
-- 1️⃣ Departments Table
-- ======================================
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(255) NOT NULL UNIQUE
);

-- ======================================
-- 2️⃣ Designations Table
-- ======================================
CREATE TABLE Designations (
    DesignationID INT IDENTITY(1,1) PRIMARY KEY,
    DesignationName NVARCHAR(255) NOT NULL UNIQUE
);

-- ======================================
-- 3️⃣ Employees Table
-- ======================================
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NULL UNIQUE,
    PhoneNumber NVARCHAR(30) NULL UNIQUE,
    DepartmentID INT NULL,
    DesignationID INT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (DesignationID) REFERENCES Designations(DesignationID)
);

-- ======================================
-- 4️⃣ Payroll Table
-- ======================================
CREATE TABLE Payroll (
    PayrollID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PayPeriodStartDate DATE NOT NULL,
    PayPeriodEndDate DATE NOT NULL,
    BasicPay DECIMAL(18,2) NULL,
    DearnessAllowance DECIMAL(18,2) NULL,
    HouseRentAllowance DECIMAL(18,2) NULL,
    ConveyanceAllowance DECIMAL(18,2) NULL,
    MedicalAllowance DECIMAL(18,2) NULL,
    SpecialAllowance DECIMAL(18,2) NULL,
    OtherEarnings DECIMAL(18,2) NULL,
    ProvidentFund DECIMAL(18,2) NULL,
    IncomeTax DECIMAL(18,2) NULL,
    ProfessionalTax DECIMAL(18,2) NULL,
    OtherDeductions DECIMAL(18,2) NULL,
    LeaveDeductionAmount DECIMAL(18,2) NULL,
    PaymentDate DATE NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- ======================================
-- 5️⃣ Timesheet Table
-- ======================================
CREATE TABLE Timesheet (
    TimesheetID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    BilledHours DECIMAL(18,2) NULL,
    TotalHoursWorked DECIMAL(18,2) NULL,
    TotalRevenue DECIMAL(18,2) NULL,
    TotalGrossProfit DECIMAL(18,2) NULL,
    EmployerTax DECIMAL(18,2) NULL,
    ActualERTax DECIMAL(18,2) NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- ======================================
-- 6️⃣ LeaveRecords Table
-- ======================================
CREATE TABLE LeaveRecords (
    LeaveID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    LeavesTaken INT NULL,
    LeaveDeductionAmount DECIMAL(18,2) NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
