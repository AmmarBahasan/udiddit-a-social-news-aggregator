-- Migrate topic name

INSERT INTO "topics" ("topic_name") SELECT DISTINCT "topic" FROM "bad_posts" ;


-- Migrate Usernames

INSERT INTO "users" ("username")
SELECT "username" FROM "bad_posts"
UNION
SELECT "username" FROM "bad_comments"
UNION
SELECT regexp_split_to_table("upvotes",',') FROM "bad_posts"
UNION
SELECT regexp_split_to_table("upvotes",',') FROM "bad_posts" ; 

-- Adding user id and topic id coloumn to bad_posts table

ALTER TABLE "bad_posts"
ADD COLUMN "user_id" INTEGER,
ADD COLUMN "topic_id" INTEGER;


-- update the value of user_id joining the value from the users table

UPDATE "bad_posts" SET "user_id" = (
SELECT "id"
FROM "users"
WHERE "users"."username" = "bad_posts"."username"
) ;


-- update the value of topic_id, joining the value from the topics table

UPDATE "bad_posts" SET "topic_id"=(
SELECT "id"
FROM "topics"
WHERE "topics"."topic_name"="bad_posts"."topic"
);


-- insert the records into the posts table

INSERT INTO "posts" ("title","url","text_content","user_id","topic_id")
SELECT LEFT("title",100),
"url",
"text_content",
"user_id",
"topic_id"
FROM "bad_posts" ;


-- Insert the records into the comments table

INSERT INTO "comments" ("comment","user_id","post_id")
SELECT "bc"."text_content",
"po"."id",
"bc"."post_id"
FROM "bad_comments" bc
JOIN "users" us
ON "us"."username" = "bc"."username"
JOIN "posts" po
ON "po"."id" = "bc"."post_id" ; 


-- Insert the votes into the post_votes

INSERT INTO "post_votes" ("post_vote","post_id","user_id")
SELECT 1,"up"."id", "us"."id"
FROM (SELECT "id" , regexp_split_to_table("upvotes",',') AS user_list
FROM "bad_posts") AS up
LEFT JOIN "users" us
ON "us"."username" = "up"."user_list"
LEFT JOIN "posts" po
ON "po"."id" = "up"."id"
UNION ALL
SELECT -1,"up"."id", "us"."id"
FROM (SELECT "id" , regexp_split_to_table("downvotes",',') AS user_list
FROM "bad_posts") AS up
LEFT JOIN "users" us
ON "us"."username" = "up"."user_list"
LEFT JOIN "posts" po
ON "po"."id" = "up"."id" ; 


-- Removing the added coulmn that helped during the migration

ALTER TABLE "bad_posts"
DROP COLUMN "user_id" ,
DROP COLUMN "topic_id" ;