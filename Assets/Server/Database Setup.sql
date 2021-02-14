create database cs_buddies;
\c cs_buddies;
create extension if not exists "uuid-ossp";

create table account(
user_id uuid primary key default uuid_generate_v4(),
email varchar(320) not null unique,
username varchar(20) not null unique,

small_image varchar(30000) not null,
big_image varchar(300000) not null,
gender smallint not null,    -- 0 is male, 1 is female, 2 is other, and 3 is private.
birthday date not null,
country smallint not null,
intro varchar(256) not null,
github varchar(39) not null,
linkedin varchar(100) not null,
interests varchar(1000) not null,
other_interests varchar(100) not null,

-- Apply settings to all bytes instead of individual bytes since users get spammed by byte like notifications to all their bytes if even one of their bytes become popular.
notify_likes boolean not null default true,
notify_comments boolean not null default true,
notify_messages boolean not null default true,

fcm varchar(1000) not null default '',
badges smallint not null default 0,

last_synced_at timestamp(3) not null default current_timestamp,
last_visited_at timestamp(3) not null default current_timestamp,
last_updated_at timestamp(3) not null default current_timestamp,
last_signed_in_at timestamp(3) not null default current_timestamp,
last_signed_out_at timestamp(3),
signed_up_at timestamp(3) not null default current_timestamp,

user_outdated_at timestamp(3),
became_admin_at timestamp(3),
became_premium_at timestamp(3),
banned_at timestamp(3),
disabled_at timestamp(3),
deleted_at timestamp(3)

deletion_reason smallint,    -- 0 = Nobody talked to me, 1 = The users are mean, 2 = I saw inappropriate content, 3 = I got spammed, 4 = The app is buggy, 5 = I need a break, and 6 = Other.
deletion_comments varchar(1000)
);

create table byte(
byte_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
content varchar(256) not null,
posted_at timestamp(3) not null default current_timestamp,
deleted_at timestamp(3)
);

create table byte_like(
byte_like_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
byte_id uuid not null,
last_updated_at timestamp(3) not null default current_timestamp,
is_liked boolean not null default true
);

create table comment(
comment_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
byte_id uuid not null,
parent_comment_id uuid not null,
content varchar(256) not null,
posted_at timestamp(3) not null default current_timestamp,
deleted_at timestamp(3)
);

create table comment_like(
comment_like_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
comment_id uuid not null,
last_updated_at timestamp(3) not null default current_timestamp,
is_liked boolean not null default true
);

create table message(
message_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
buddy_id uuid not null,
content varchar(1000) not null,
sent_at timestamp(3) not null default current_timestamp
);

create table read_receipt(
read_receipt_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
buddy_id uuid not null,
last_read_at timestamp(3) not null default current_timestamp
);

create table block(
block_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
buddy_id uuid not null,
blocked_at timestamp(3) not null default current_timestamp
);

create table report(
report_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
buddy_id uuid not null,
reason smallint not null,    -- 0 = Inappropriate Photo, 1 = Inappropriate Intro, 2 = Inappropriate Byte, 3 = Inappropriate Comment, 4 = Inappropriate Message, 5 = Inappropriate Activity, 6 = Other
comments varchar(1000) not null,
reported_at timestamp(3) not null default current_timestamp,
reviewed_at timestamp(3),
is_approved boolean not null default false
);

create table username_change_request(
username_change_request_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
username varchar(30) not null,
new_username varchar(30) not null,
reason smallint not null,    -- 0 = Typo, 1 = Name Changed, and 2 = Other.
comments varchar(1000) not null,
requested_at timestamp(3) not null default current_timestamp,
reviewed_at timestamp(3),
is_approved boolean not null default false
);

create table time_format_2(
time_format_id uuid primary key default uuid_generate_v4(),
user_id uuid not null,
bottom_last_visited_at_string varchar(100) not null,
created_at timestamp(3) not null default current_timestamp
);
