CREATE FUNCTION [dbo].[fn_clr_process_web_request]
(@url NVARCHAR (MAX) NULL, @web_method_name NVARCHAR (MAX) NULL, @content_type NVARCHAR (MAX) NULL, @body NVARCHAR (MAX) NULL, @code_page INT NULL, @headers_in_url_format NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (MAX)
WITH EXECUTE AS OWNER
AS
 EXTERNAL NAME [Sql.Extensions].[Sql.Extensions.Web.Utils].[ProcessWebRequest]

