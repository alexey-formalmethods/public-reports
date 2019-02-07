CREATE TABLE [dbo].[s_log] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [create_date]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [init_sql]     NVARCHAR (255) NOT NULL,
    [message_text] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_s_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

