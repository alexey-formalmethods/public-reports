CREATE TABLE [dbo].[t_pr_tag_synonym] (
    [pr_tag_id_from] INT NOT NULL,
    [pr_tag_id_to]   INT NOT NULL,
    CONSTRAINT [PK_t_pr_tag_synonym] PRIMARY KEY CLUSTERED ([pr_tag_id_from] ASC, [pr_tag_id_to] ASC)
);

