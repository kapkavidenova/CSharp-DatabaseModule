--11. Future Value Function
GO
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(18,4),@interestRate FLOAT, @num INT)
RETURNS DECIMAL(18,4)
AS
	BEGIN
		
		RETURN (@sum * (POWER((1 + @interestRate),@num)))
		
	END
SELECT dbo.ufn_CalculateFutureValue(1000,0.1,5)

GO