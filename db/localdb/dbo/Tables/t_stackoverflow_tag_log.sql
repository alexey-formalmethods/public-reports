CREATE TABLE [dbo].[t_stackoverflow_tag_log] (
    [event_date]           DATE NOT NULL,
    [stackoverflow_tag_id] INT  NOT NULL,
    [tag_count]            INT  NOT NULL,
    CONSTRAINT [PK_t_stackoverflow_tag_log] PRIMARY KEY CLUSTERED ([event_date] ASC, [stackoverflow_tag_id] ASC)
);

