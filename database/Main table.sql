USE [PayrollSystem]
GO

/****** Object:  Table [dbo].[ExcelImportPayroll]    Script Date: 2/2/2025 12:43:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExcelImportPayroll](
	[EmployeeName] [nvarchar](255) NOT NULL,
	[Department] [nvarchar](255) NULL,
	[Designation] [nvarchar](255) NULL,
	[PayPeriodStartDate] [date] NULL,
	[PayPeriodEndDate] [date] NULL,
	[BasicPay] [decimal](18, 2) NULL,
	[DearnessAllowance] [decimal](18, 2) NULL,
	[HouseRentAllowance] [decimal](18, 2) NULL,
	[ConveyanceAllowance] [decimal](18, 2) NULL,
	[MedicalAllowance] [decimal](18, 2) NULL,
	[SpecialAllowance] [decimal](18, 2) NULL,
	[OtherEarnings] [decimal](18, 2) NULL,
	[ProvidentFund] [decimal](18, 2) NULL,
	[IncomeTax] [decimal](18, 2) NULL,
	[ProfessionalTax] [decimal](18, 2) NULL,
	[OtherDeductions] [decimal](18, 2) NULL,
	[LeavesTaken] [int] NULL,
	[LeaveDeductionAmount] [decimal](18, 2) NULL,
	[PaymentDate] [date] NULL,
	[BilledHours] [decimal](18, 2) NULL,
	[TotalHoursWorked] [decimal](18, 2) NULL,
	[TotalRevenue] [decimal](18, 2) NULL,
	[TotalGrossProfit] [decimal](18, 2) NULL,
	[EmployerTax] [decimal](18, 2) NULL,
	[ActualERTax] [decimal](18, 2) NULL,
	[Remarks] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

