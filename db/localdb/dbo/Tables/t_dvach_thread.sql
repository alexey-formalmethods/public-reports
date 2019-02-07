CREATE TABLE [dbo].[t_dvach_thread] (
    [id]             INT      IDENTITY (1, 1) NOT NULL,
    [thread_number]  INT      NOT NULL,
    [dvach_board_id] INT      NOT NULL,
    [create_date]    DATETIME NOT NULL,
    [post_count]     INT      NOT NULL,
    CONSTRAINT [PK_t_dvach_thread] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_t_dvach_thread]
    ON [dbo].[t_dvach_thread]([thread_number] ASC, [dvach_board_id] ASC);

