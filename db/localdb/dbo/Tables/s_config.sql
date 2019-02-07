CREATE TABLE [dbo].[s_config] (
    [id]    INT            IDENTITY (1, 1) NOT NULL,
    [name]  NVARCHAR (255) NOT NULL,
    [value] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_s_config] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_s_config]
    ON [dbo].[s_config]([name] ASC);

