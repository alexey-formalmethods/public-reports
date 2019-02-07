CREATE TABLE [dbo].[d_pr_tag] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_d_stackoverflow_tag] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_d_stackoverflow_tag]
    ON [dbo].[d_pr_tag]([name] ASC);

