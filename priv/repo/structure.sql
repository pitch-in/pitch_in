--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answers (
    id integer NOT NULL,
    message text,
    user_id integer,
    ask_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_reason character varying(255),
    direct_campaign_id integer
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: asks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE asks (
    id integer NOT NULL,
    role character varying(255),
    length integer,
    profession character varying(255),
    description text,
    campaign_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    years_experience integer,
    archived_reason character varying(255),
    hours integer
);


--
-- Name: asks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE asks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE asks_id_seq OWNED BY asks.id;


--
-- Name: campaign_staff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaign_staff (
    user_id integer,
    campaign_id integer
);


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE campaigns (
    id integer NOT NULL,
    name character varying(255),
    type integer,
    state character varying(255),
    district character varying(255),
    candidate_name character varying(255),
    measure_name character varying(255),
    measure_position character varying(255),
    short_pitch character varying(255),
    long_pitch text,
    website_url character varying(255),
    twitter_url character varying(255),
    facebook_url character varying(255),
    candidate_profession character varying(255),
    election_date date,
    is_partisan boolean DEFAULT false NOT NULL,
    current_party integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255),
    archived_reason character varying(255),
    is_verified boolean DEFAULT false NOT NULL,
    file_number character varying(255),
    shown_whats_next boolean DEFAULT true NOT NULL,
    img_url character varying(255)
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE issues (
    id integer NOT NULL,
    issue character varying(255),
    campaign_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;


--
-- Name: need_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE need_searches (
    id integer NOT NULL,
    profession character varying(255),
    years_experience integer,
    issue character varying(255),
    user_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    issues character varying(255)[] DEFAULT ARRAY[]::character varying[]
);


--
-- Name: need_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE need_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: need_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE need_searches_id_seq OWNED BY need_searches.id;


--
-- Name: pros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pros (
    id integer NOT NULL,
    linkedin_url character varying(255),
    profession character varying(255),
    address_zip character varying(255),
    phone character varying(255),
    experience_starts_at date,
    user_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    twitter_handle character varying(255),
    github_handle character varying(255),
    issues character varying(255),
    intro character varying(255),
    has_campaign_experience boolean DEFAULT false NOT NULL
);


--
-- Name: pros_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pros_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pros_id_seq OWNED BY pros.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: search_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE search_alerts (
    id integer NOT NULL,
    profession character varying(255),
    role character varying(255),
    years_experience integer,
    issue character varying(255),
    user_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: search_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE search_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE search_alerts_id_seq OWNED BY search_alerts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    is_admin boolean DEFAULT false NOT NULL,
    email character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    password_hash character varying(255),
    archived_reason character varying(255),
    reset_digest character varying(255),
    reset_time timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY asks ALTER COLUMN id SET DEFAULT nextval('asks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY need_searches ALTER COLUMN id SET DEFAULT nextval('need_searches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pros ALTER COLUMN id SET DEFAULT nextval('pros_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_alerts ALTER COLUMN id SET DEFAULT nextval('search_alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: asks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asks
    ADD CONSTRAINT asks_pkey PRIMARY KEY (id);


--
-- Name: campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: need_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY need_searches
    ADD CONSTRAINT need_searches_pkey PRIMARY KEY (id);


--
-- Name: pros_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pros
    ADD CONSTRAINT pros_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: search_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_alerts
    ADD CONSTRAINT search_alerts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: answers_archived_reason_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answers_archived_reason_index ON answers USING btree (archived_reason);


--
-- Name: answers_ask_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answers_ask_id_index ON answers USING btree (ask_id);


--
-- Name: answers_direct_campaign_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answers_direct_campaign_id_index ON answers USING btree (direct_campaign_id);


--
-- Name: answers_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answers_user_id_index ON answers USING btree (user_id);


--
-- Name: asks_archived_reason_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asks_archived_reason_index ON asks USING btree (archived_reason);


--
-- Name: asks_campaign_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asks_campaign_id_index ON asks USING btree (campaign_id);


--
-- Name: campaign_staff_campaign_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX campaign_staff_campaign_id_index ON campaign_staff USING btree (campaign_id);


--
-- Name: campaign_staff_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX campaign_staff_user_id_index ON campaign_staff USING btree (user_id);


--
-- Name: campaigns_archived_reason_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX campaigns_archived_reason_index ON campaigns USING btree (archived_reason);


--
-- Name: campaigns_current_party_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX campaigns_current_party_index ON campaigns USING btree (current_party) WHERE (is_partisan = true);


--
-- Name: campaigns_state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX campaigns_state_index ON campaigns USING btree (state);


--
-- Name: issues_campaign_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issues_campaign_id_index ON issues USING btree (campaign_id);


--
-- Name: issues_issue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issues_issue_index ON issues USING btree (issue);


--
-- Name: pros_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pros_user_id_index ON pros USING btree (user_id);


--
-- Name: search_alerts_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX search_alerts_user_id_index ON search_alerts USING btree (user_id);


--
-- Name: unique_alerts; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_alerts ON search_alerts USING btree ((COALESCE(profession, ' '::character varying)), (COALESCE(role, ' '::character varying)), (COALESCE(years_experience, '-1'::integer)), (COALESCE(issue, ' '::character varying)), (COALESCE(user_id, '-1'::integer)));


--
-- Name: users_archived_reason_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_archived_reason_index ON users USING btree (archived_reason);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON users USING btree (email);


--
-- Name: answers_ask_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_ask_id_fkey FOREIGN KEY (ask_id) REFERENCES asks(id);


--
-- Name: answers_direct_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_direct_campaign_id_fkey FOREIGN KEY (direct_campaign_id) REFERENCES campaigns(id);


--
-- Name: answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: asks_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asks
    ADD CONSTRAINT asks_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES campaigns(id);


--
-- Name: campaign_staff_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_staff
    ADD CONSTRAINT campaign_staff_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES campaigns(id);


--
-- Name: campaign_staff_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_staff
    ADD CONSTRAINT campaign_staff_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: issues_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES campaigns(id);


--
-- Name: need_searches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY need_searches
    ADD CONSTRAINT need_searches_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: pros_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pros
    ADD CONSTRAINT pros_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: search_alerts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_alerts
    ADD CONSTRAINT search_alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170103105041), (20170103105108), (20170103105120), (20170103105226), (20170103105410), (20170103112246), (20170107084713), (20170110103734), (20170115080533), (20170131090755), (20170213010034), (20170213085404), (20170214070629), (20170217091648), (20170219002838), (20170224080238), (20170227095728), (20170306065436), (20170306065857), (20170306100000), (20170306103847), (20170315074520), (20170327094309), (20170409234430), (20170416014304);

