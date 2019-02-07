CREATE FUNCTION dbo.fn_get_config_value (
	 @config_name NVARCHAR(255)
	,@error_when_null BIT = 1
)
RETURNS NVARCHAR(MAX)
AS
BEGIN 
	DECLARE @result NVARCHAR(MAX) = (SELECT TOP 1 sc.value FROM s_config sc WHERE sc.name = @config_name);
	IF @result IS NULL AND @error_when_null = 1
	BEGIN 
		DECLARE @message NVARCHAR(MAX) = 'No such config name (' + ISNULL (@config_name, '') + ') found';
		RETURN CAST (@message AS INT);
	END 
	RETURN @result;
END
