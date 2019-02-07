CREATE TABLE [dbo].[t_dvach_thread_tag] (
    [pr_tag_id]       INT NOT NULL,
    [dvach_thread_id] INT NOT NULL,
    CONSTRAINT [PK_t_2ch_tag_log] PRIMARY KEY CLUSTERED ([pr_tag_id] ASC, [dvach_thread_id] ASC)
);

