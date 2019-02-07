CREATE TABLE [dbo].[d_dvach_board] (
    [id]   INT          IDENTITY (1, 1) NOT NULL,
    [code] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_d_dvach_board] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_d_dvach_board]
    ON [dbo].[d_dvach_board]([code] ASC);

