create database cs_buddies;
\c cs_buddies;
create extension if not exists "uuid-ossp";

create table account(
user_id uuid primary key default uuid_generate_v4(),
email varchar(320) not null unique,
username varchar(20) not null unique default '',
password varchar(1000) not null default '',
small_image varchar(30000) not null default '',
big_image varchar(300000) not null default '',
gender smallint not null default 0,    -- 0 is male, 1 is female, 2 is other, and 3 is private
birthday date not null default current_timestamp,
country smallint not null default 0,
interests varchar(1000) not null default '',
other_interests varchar(100) not null default '',
git_hub varchar(39) not null default '',
linked_in varchar(100) not null default '',
intro varchar(256) not null default '',

last_post_time timestamp not null default current_timestamp,
bytes_today smallint not null default 0,

last_first_chat_time timestamp not null default current_timestamp,
first_chats_today smallint not null default 0,

last_received_chat_time timestamp not null default current_timestamp,
fcm varchar(1000) not null default '',
badges smallint not null default 0,

last_sign_in_time timestamp not null default current_timestamp,
last_sign_out_time timestamp not null default current_timestamp,

last_visit_time timestamp not null default current_timestamp,
last_update_time timestamp not null default current_timestamp,
sign_up_time timestamp not null default current_timestamp,

-- have notification setting for all bytes instead of individual bytes since users will get spammed with byte like notification to all their other bytes anyway if even one of their bytes becomes popular
has_byte_notification boolean not null default true,
has_chat_notification boolean not null default true,

must_sync_with_server boolean not null default false,
is_premium boolean not null default false,
is_banned boolean not null default false,
is_invisible boolean not null default false,
is_deleted boolean not null default false
);

create table byte(
byte_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
content varchar(256) not null default '',
likes smallint not null default 0,
post_time timestamp not null default current_timestamp,
is_invisible boolean not null default false,
is_deleted boolean not null default false
);

create table byte_like(
byte_like_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
byte_id uuid not null default uuid_generate_v4(),
like_time timestamp not null default current_timestamp,
is_liked boolean not null default true
);

create table message(
message_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
buddy_id uuid not null default uuid_generate_v4(),
content varchar(1000) not null default '',
send_time timestamp not null default current_timestamp
);

create table block(
block_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
buddy_id uuid not null default uuid_generate_v4(),
block_time timestamp not null default current_timestamp
);

create table report(
report_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
buddy_id uuid not null default uuid_generate_v4(),
reason smallint not null default 0,    -- 0 is photo, 1 is intro, 2 is post, 3 is message, 4 is spam, and 5 is other
other_reason varchar(100) not null default '',
comments varchar(1000) not null default '',
report_time timestamp not null default current_timestamp,
review_time timestamp not null default current_timestamp,
is_reviewed boolean not null default false,
is_approved boolean not null default false
);

create table username_change_request(
username_change_request_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
username varchar(30) not null default '',
new_username varchar(30) not null default '',
reason varchar(100) not null default '',
comments varchar(1000) not null default '',
request_time timestamp not null default current_timestamp,
review_time timestamp not null default current_timestamp,
is_reviewed boolean not null default false,
is_approved boolean not null default false
);

create table time_format(
time_format_id uuid primary key default uuid_generate_v4(),
user_id uuid not null default uuid_generate_v4(),
bottom_last_visit_time timestamp not null default current_timestamp
);

create table sign_up(
sign_up_id uuid primary key default uuid_generate_v4(),
guest_id uuid not null unique,
user_id uuid not null unique,
first_launch_time timestamp not null default current_timestamp,
sign_up_time timestamp not null default current_timestamp
);