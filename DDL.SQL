/*
Creating the users table
*/
CREATE TABLE "users" (
	"id" SERIAL PRIMARY KEY,
	"username" VARCHAR(25) UNIQUE NOT NULL,
	"signup_date" TIMESTAMP DEFAULT current_timestamp,
	
	CONSTRAINT "length not zero" CHECK (LENGTH(TRIM("username")) > 0),
	"login_timestamp" TIMESTAMP
);
--------------------------------------------------------------------------------------
/*
Creating the topics table
*/
CREATE TABLE "topics" (
	"id" SERIAL PRIMARY KEY,
	"topic_name" VARCHAR(30) UNIQUE NOT NULL,
	"description" VARCHAR(500),
	"user_id" INTEGER,
	
	CONSTRAINT "length not empty" CHECK (LENGTH(TRIM("topic_name")) > 0),
	CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL
);
--------------------------------------------------------------------------------------
/*
Creating the posts table
*/
CREATE TABLE "posts" (
	"id" SERIAL PRIMARY KEY,
	"title" VARCHAR(100) NOT NULL,
	"url" TEXT,
	"text_content" TEXT,
	"user_id" INTEGER,
	"topic_id" INTEGER NOT NULL,
	"post_date" TIMESTAMP DEFAULT current_timestamp,

	CONSTRAINT "title length not empty" CHECK (LENGTH(TRIM("title")) > 0),
	CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ,
	CONSTRAINT "fk_topic_id" FOREIGN KEY ("topic_id") REFERENCES "topics" ("id") ON DELETE CASCADE,
	CONSTRAINT "either url or text" CHECK ((("url") IS NULL AND ("text_content") IS NOT NULL) OR (("url") IS NOT NULL AND ("text_content")IS NULL))
);
--------------------------------------------------------------------------------------
/*
Creating the comments table
*/
CREATE TABLE "comments"(
	"id" SERIAL PRIMARY KEY,
	"comment" TEXT NOT NULL,
	"user_id" INTEGER,
	"post_id" INTEGER NOT NULL,
	"parent_comment_id" INTEGER DEFAULT NULL,

	CONSTRAINT "comment not empty" CHECK (LENGTH(TRIM("comment"))>0),
	CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
	CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE,
	CONSTRAINT "comment thread" FOREIGN KEY ("parent_comment_id") REFERENCES "comments" ("id") ON DELETE CASCADE
);
--------------------------------------------------------------------------------------
/*
Creating the vote table
*/
CREATE TABLE "post_votes"(
	"id" SERIAL PRIMARY KEY,
	"post_vote" INTEGER NOT NULL ,
	"post_id" INTEGER NOT NULL,
	"user_id" INTEGER,

	CONSTRAINT "vote_values" CHECK ("post_vote" =1 OR "post_vote" = -1 ), 
	CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE,
	CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
	CONSTRAINT "unique_user_post" UNIQUE ("user_id","post_id")
);
--------------------------------------------------------------------------------------
CREATE INDEX "find_users_not_logged_in_last_year" ON "users" ("username","login_timestamp");
CREATE INDEX "users_not_logged_in_last_year" ON "users" (LOWER("username"),"signup_date");
CREATE INDEX "find_user_ids_in_posts" ON "posts" ("user_id");
CREATE INDEX "topics_does_not_have_any_posts" ON "posts" ("topic_id");
CREATE INDEX "find_posts_by_title" ON "posts" (LOWER("title") VARCHAR_PATTERN_OPS);
CREATE INDEX "find_posts_by_title" ON "posts" ("url");
CREATE INDEX "find_posts_by_topic_and_date" ON "posts" ("topic_id", "post_date");
CREATE INDEX "find_direct_children_of_comment" ON "comments" ("comment","parent_comment_id");
CREATE INDEX "comment_by_user" ON "comments" ("user_id");
CREATE INDEX "score_of_post" ON "post_votes" ("post_vote","post_id");

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------