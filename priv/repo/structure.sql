--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: assign_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assign_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  max_number integer;
BEGIN
  SELECT coalesce(MAX(number), 0) INTO max_number FROM tasks WHERE project_id = NEW.project_id;
  NEW.number := max_number + 1;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: auth_token; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE auth_token (
    id bigint NOT NULL,
    value character varying(255),
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: auth_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE auth_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE auth_token_id_seq OWNED BY auth_token.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id bigint NOT NULL,
    body text NOT NULL,
    markdown text,
    user_id bigint NOT NULL,
    task_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    modified_at timestamp without time zone,
    created_from character varying(255) DEFAULT 'code_corps'::character varying,
    modified_from character varying(255) DEFAULT 'code_corps'::character varying,
    github_comment_id bigint
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: donation_goals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE donation_goals (
    id bigint NOT NULL,
    amount integer,
    description text,
    project_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    current boolean DEFAULT false
);


--
-- Name: donation_goals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE donation_goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donation_goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE donation_goals_id_seq OWNED BY donation_goals.id;


--
-- Name: github_app_installations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_app_installations (
    id bigint NOT NULL,
    github_id integer,
    installed boolean DEFAULT true,
    state character varying(255),
    project_id bigint,
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    access_token character varying(255),
    access_token_expires_at timestamp without time zone,
    sender_github_id integer,
    origin character varying(255) DEFAULT 'codecorps'::character varying NOT NULL,
    github_account_avatar_url character varying(255),
    github_account_id integer,
    github_account_login character varying(255),
    github_account_type character varying(255)
);


--
-- Name: github_app_installations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_app_installations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_app_installations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_app_installations_id_seq OWNED BY github_app_installations.id;


--
-- Name: github_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_comments (
    id bigint NOT NULL,
    body text,
    github_created_at timestamp without time zone,
    github_id integer,
    github_updated_at timestamp without time zone,
    html_url text,
    url text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    github_issue_id bigint
);


--
-- Name: github_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_comments_id_seq OWNED BY github_comments.id;


--
-- Name: github_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_events (
    id bigint NOT NULL,
    action character varying(255),
    github_delivery_id character varying(255),
    status character varying(255),
    type character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    payload jsonb,
    failure_reason character varying(255)
);


--
-- Name: github_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_events_id_seq OWNED BY github_events.id;


--
-- Name: github_issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_issues (
    id bigint NOT NULL,
    body text,
    closed_at timestamp without time zone,
    comments_url text,
    events_url text,
    github_created_at timestamp without time zone,
    github_id integer,
    github_updated_at timestamp without time zone,
    html_url text,
    labels_url text,
    locked boolean,
    number integer,
    state character varying(255),
    title text,
    url text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    github_repo_id bigint,
    github_pull_request_id bigint
);


--
-- Name: github_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_issues_id_seq OWNED BY github_issues.id;


--
-- Name: github_pull_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_pull_requests (
    id bigint NOT NULL,
    additions integer,
    body text,
    changed_files integer,
    closed_at timestamp without time zone,
    comments integer,
    comments_url text,
    commits integer,
    commits_url text,
    deletions integer,
    diff_url text,
    github_created_at timestamp without time zone,
    github_id integer,
    github_updated_at timestamp without time zone,
    html_url text,
    issue_url text,
    locked boolean DEFAULT false NOT NULL,
    merge_commit_sha text,
    mergeable_state text,
    merged boolean DEFAULT false NOT NULL,
    merged_at timestamp without time zone,
    number integer,
    patch_url text,
    review_comment_url text,
    review_comments integer,
    review_comments_url text,
    state character varying(255),
    statuses_url text,
    title text,
    url text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    github_repo_id bigint
);


--
-- Name: github_pull_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_pull_requests_id_seq OWNED BY github_pull_requests.id;


--
-- Name: github_repos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_repos (
    id bigint NOT NULL,
    github_id integer,
    name character varying(255),
    github_account_id integer,
    github_account_login character varying(255),
    github_account_avatar_url character varying(255),
    github_account_type character varying(255),
    github_app_installation_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sync_state character varying(255) DEFAULT 'unsynced'::character varying,
    syncing_comments_count integer DEFAULT 0,
    syncing_issues_count integer DEFAULT 0,
    syncing_pull_requests_count integer DEFAULT 0
);


--
-- Name: github_repos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE github_repos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_repos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE github_repos_id_seq OWNED BY github_repos.id;


--
-- Name: organization_github_app_installations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organization_github_app_installations (
    id bigint NOT NULL,
    organization_id bigint,
    github_app_installation_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_github_app_installations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organization_github_app_installations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_github_app_installations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organization_github_app_installations_id_seq OWNED BY organization_github_app_installations.id;


--
-- Name: organization_invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organization_invites (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    organization_name character varying(255) NOT NULL,
    fulfilled boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organization_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organization_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organization_invites_id_seq OWNED BY organization_invites.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id bigint NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    slug character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean DEFAULT false,
    cloudinary_public_id character varying(255),
    default_color character varying(255),
    owner_id bigint
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    id bigint NOT NULL,
    markdown text NOT NULL,
    body text NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: previews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE previews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: previews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE previews_id_seq OWNED BY previews.id;


--
-- Name: project_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_categories (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    category_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_categories_id_seq OWNED BY project_categories.id;


--
-- Name: project_github_repos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_github_repos (
    id bigint NOT NULL,
    project_id bigint,
    github_repo_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_github_repos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_github_repos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_github_repos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_github_repos_id_seq OWNED BY project_github_repos.id;


--
-- Name: project_skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_skills (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    skill_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_skills_id_seq OWNED BY project_skills.id;


--
-- Name: project_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_users (
    id bigint NOT NULL,
    role character varying(255) NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_users_id_seq OWNED BY project_users.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id bigint NOT NULL,
    description text,
    long_description_body text,
    long_description_markdown text,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    organization_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    total_monthly_donated integer DEFAULT 0,
    approved boolean DEFAULT false,
    cloudinary_public_id character varying(255),
    default_color character varying(255),
    website character varying(255),
    should_link_externally boolean DEFAULT false,
    github_repo character varying(255),
    github_owner character varying(255),
    CONSTRAINT set_long_description_markdown_if_approved CHECK (((long_description_markdown IS NOT NULL) OR (approved = false)))
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: role_skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE role_skills (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    skill_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cat integer
);


--
-- Name: role_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE role_skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE role_skills_id_seq OWNED BY role_skills.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    ability character varying(255) NOT NULL,
    kind character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE skills (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    original_row integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE skills_id_seq OWNED BY skills.id;


--
-- Name: slugged_routes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slugged_routes (
    id bigint NOT NULL,
    slug character varying(255) NOT NULL,
    organization_id bigint,
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: slugged_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slugged_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slugged_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slugged_routes_id_seq OWNED BY slugged_routes.id;


--
-- Name: stripe_connect_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_accounts (
    id bigint NOT NULL,
    business_name character varying(255),
    business_url character varying(255),
    charges_enabled boolean,
    country character varying(255),
    default_currency character varying(255),
    details_submitted boolean,
    display_name character varying(255),
    email character varying(255),
    id_from_stripe character varying(255) NOT NULL,
    managed boolean,
    support_email character varying(255),
    support_phone character varying(255),
    support_url character varying(255),
    transfers_enabled boolean,
    organization_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    verification_disabled_reason character varying(255),
    verification_fields_needed character varying(255)[],
    external_account character varying(255),
    legal_entity_address_city character varying(255),
    legal_entity_address_country character varying(255),
    legal_entity_address_line1 character varying(255),
    legal_entity_address_line2 character varying(255),
    legal_entity_address_postal_code character varying(255),
    legal_entity_address_state character varying(255),
    legal_entity_business_name character varying(255),
    legal_entity_business_tax_id_provided boolean DEFAULT false,
    legal_entity_business_vat_id_provided boolean DEFAULT false,
    legal_entity_first_name character varying(255),
    legal_entity_last_name character varying(255),
    legal_entity_gender character varying(255),
    legal_entity_maiden_name character varying(255),
    legal_entity_personal_address_city character varying(255),
    legal_entity_personal_address_country character varying(255),
    legal_entity_personal_address_line1 character varying(255),
    legal_entity_personal_address_line2 character varying(255),
    legal_entity_personal_address_postal_code character varying(255),
    legal_entity_personal_address_state character varying(255),
    legal_entity_phone_number character varying(255),
    legal_entity_personal_id_number_provided boolean DEFAULT false,
    legal_entity_ssn_last_4_provided boolean DEFAULT false,
    legal_entity_type character varying(255),
    legal_entity_verification_details character varying(255),
    legal_entity_verification_details_code character varying(255),
    legal_entity_verification_document character varying(255),
    legal_entity_verification_status character varying(255),
    legal_entity_dob_day integer,
    legal_entity_dob_month integer,
    legal_entity_dob_year integer,
    tos_acceptance_ip character varying(255),
    tos_acceptance_user_agent character varying(255),
    tos_acceptance_date integer,
    verification_due_by integer
);


--
-- Name: stripe_connect_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_accounts_id_seq OWNED BY stripe_connect_accounts.id;


--
-- Name: stripe_connect_cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_cards (
    id bigint NOT NULL,
    id_from_stripe character varying(255) NOT NULL,
    stripe_connect_account_id bigint NOT NULL,
    stripe_platform_card_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_connect_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_cards_id_seq OWNED BY stripe_connect_cards.id;


--
-- Name: stripe_connect_charges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_charges (
    id bigint NOT NULL,
    amount integer,
    amount_refunded integer,
    application_id_from_stripe character varying(255),
    application_fee_id_from_stripe character varying(255),
    balance_transaction_id_from_stripe character varying(255),
    captured boolean,
    created integer,
    currency character varying(255),
    customer_id_from_stripe character varying(255),
    description character varying(255),
    failure_code character varying(255),
    failure_message character varying(255),
    id_from_stripe character varying(255),
    invoice_id_from_stripe character varying(255),
    paid boolean,
    refunded boolean,
    review_id_from_stripe character varying(255),
    source_transfer_id_from_stripe character varying(255),
    statement_descriptor character varying(255),
    status character varying(255),
    stripe_connect_account_id bigint,
    stripe_connect_customer_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_connect_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_charges_id_seq OWNED BY stripe_connect_charges.id;


--
-- Name: stripe_connect_customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_customers (
    id bigint NOT NULL,
    id_from_stripe character varying(255) NOT NULL,
    stripe_connect_account_id bigint NOT NULL,
    stripe_platform_customer_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: stripe_connect_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_customers_id_seq OWNED BY stripe_connect_customers.id;


--
-- Name: stripe_connect_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_plans (
    id bigint NOT NULL,
    amount integer,
    id_from_stripe character varying(255) NOT NULL,
    name character varying(255),
    project_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created integer
);


--
-- Name: stripe_connect_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_plans_id_seq OWNED BY stripe_connect_plans.id;


--
-- Name: stripe_connect_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_connect_subscriptions (
    id bigint NOT NULL,
    application_fee_percent numeric,
    customer_id_from_stripe character varying(255),
    id_from_stripe character varying(255) NOT NULL,
    plan_id_from_stripe character varying(255) NOT NULL,
    quantity integer,
    status character varying(255),
    stripe_connect_plan_id bigint NOT NULL,
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cancelled_at integer,
    created integer,
    current_period_end integer,
    current_period_start integer,
    ended_at integer,
    start integer
);


--
-- Name: stripe_connect_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_connect_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_connect_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_connect_subscriptions_id_seq OWNED BY stripe_connect_subscriptions.id;


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_events (
    id bigint NOT NULL,
    id_from_stripe character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'unprocessed'::character varying,
    type character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    endpoint character varying(255) NOT NULL,
    user_id character varying(255),
    object_id character varying(255) NOT NULL,
    object_type character varying(255) NOT NULL,
    ignored_reason character varying(255)
);


--
-- Name: stripe_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_events_id_seq OWNED BY stripe_events.id;


--
-- Name: stripe_external_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_external_accounts (
    id bigint NOT NULL,
    id_from_stripe character varying(255) NOT NULL,
    account_id_from_stripe character varying(255) NOT NULL,
    account_holder_name character varying(255),
    account_holder_type character varying(255),
    bank_name character varying(255),
    country character varying(255),
    currency character varying(255),
    fingerprint character varying(255),
    last4 character varying(255),
    routing_number character varying(255),
    status character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_for_currency boolean,
    stripe_connect_account_id bigint
);


--
-- Name: stripe_external_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_external_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_external_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_external_accounts_id_seq OWNED BY stripe_external_accounts.id;


--
-- Name: stripe_file_upload; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_file_upload (
    id bigint NOT NULL,
    id_from_stripe character varying(255) NOT NULL,
    purpose character varying(255),
    size integer,
    type character varying(255),
    url character varying(255),
    stripe_connect_account_id bigint,
    created integer
);


--
-- Name: stripe_file_upload_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_file_upload_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_file_upload_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_file_upload_id_seq OWNED BY stripe_file_upload.id;


--
-- Name: stripe_invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_invoices (
    id bigint NOT NULL,
    amount_due integer,
    application_fee integer,
    attempt_count integer,
    attempted boolean,
    charge_id_from_stripe character varying(255) NOT NULL,
    closed boolean,
    currency character varying(255),
    customer_id_from_stripe character varying(255) NOT NULL,
    date integer,
    description character varying(255),
    ending_balance integer,
    forgiven boolean,
    id_from_stripe character varying(255) NOT NULL,
    next_payment_attempt integer,
    paid boolean,
    period_end integer,
    period_start integer,
    receipt_number character varying(255),
    starting_balance integer,
    statement_descriptor character varying(255),
    subscription_id_from_stripe character varying(255) NOT NULL,
    subscription_proration_date integer,
    subtotal integer,
    tax integer,
    tax_percent double precision,
    total integer,
    webhooks_delievered_at integer,
    stripe_connect_subscription_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_invoices_id_seq OWNED BY stripe_invoices.id;


--
-- Name: stripe_platform_cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_platform_cards (
    id bigint NOT NULL,
    brand character varying(255),
    customer_id_from_stripe character varying(255),
    cvc_check character varying(255),
    exp_month integer,
    exp_year integer,
    id_from_stripe character varying(255) NOT NULL,
    last4 character varying(255),
    name character varying(255),
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_platform_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_platform_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_platform_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_platform_cards_id_seq OWNED BY stripe_platform_cards.id;


--
-- Name: stripe_platform_customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_platform_customers (
    id bigint NOT NULL,
    currency character varying(255),
    delinquent boolean,
    email character varying(255),
    id_from_stripe character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created integer
);


--
-- Name: stripe_platform_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_platform_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_platform_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_platform_customers_id_seq OWNED BY stripe_platform_customers.id;


--
-- Name: task_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_lists (
    id bigint NOT NULL,
    name character varying(255),
    "order" integer,
    project_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inbox boolean DEFAULT false
);


--
-- Name: task_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_lists_id_seq OWNED BY task_lists.id;


--
-- Name: task_skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_skills (
    id bigint NOT NULL,
    skill_id bigint NOT NULL,
    task_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_skills_id_seq OWNED BY task_skills.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tasks (
    id bigint NOT NULL,
    body text,
    markdown text,
    number integer NOT NULL,
    status character varying(255) DEFAULT 'open'::character varying NOT NULL,
    title text NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    task_list_id bigint,
    "order" integer,
    github_repo_id bigint,
    closed_at timestamp without time zone,
    created_at timestamp without time zone,
    modified_at timestamp without time zone,
    created_from character varying(255) DEFAULT 'code_corps'::character varying,
    modified_from character varying(255) DEFAULT 'code_corps'::character varying,
    archived boolean DEFAULT false NOT NULL,
    github_issue_id bigint
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: user_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_categories (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    category_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_categories_id_seq OWNED BY user_categories.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: user_skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_skills (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    skill_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_skills_id_seq OWNED BY user_skills.id;


--
-- Name: user_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_tasks (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_tasks_id_seq OWNED BY user_tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id bigint NOT NULL,
    username character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    website character varying(255),
    twitter character varying(255),
    biography text,
    admin boolean DEFAULT false NOT NULL,
    state character varying(255) DEFAULT 'signed_up'::character varying,
    cloudinary_public_id character varying(255),
    default_color character varying(255),
    sign_up_context character varying(255) DEFAULT 'default'::character varying,
    github_auth_token character varying(255),
    github_avatar_url character varying(255),
    github_email character varying(255),
    github_username character varying(255),
    github_id integer,
    type character varying(255) DEFAULT 'user'::character varying
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

ALTER TABLE ONLY auth_token ALTER COLUMN id SET DEFAULT nextval('auth_token_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY donation_goals ALTER COLUMN id SET DEFAULT nextval('donation_goals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_app_installations ALTER COLUMN id SET DEFAULT nextval('github_app_installations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_comments ALTER COLUMN id SET DEFAULT nextval('github_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_events ALTER COLUMN id SET DEFAULT nextval('github_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_issues ALTER COLUMN id SET DEFAULT nextval('github_issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_pull_requests ALTER COLUMN id SET DEFAULT nextval('github_pull_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_repos ALTER COLUMN id SET DEFAULT nextval('github_repos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_github_app_installations ALTER COLUMN id SET DEFAULT nextval('organization_github_app_installations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_invites ALTER COLUMN id SET DEFAULT nextval('organization_invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews ALTER COLUMN id SET DEFAULT nextval('previews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_categories ALTER COLUMN id SET DEFAULT nextval('project_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_github_repos ALTER COLUMN id SET DEFAULT nextval('project_github_repos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_skills ALTER COLUMN id SET DEFAULT nextval('project_skills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_users ALTER COLUMN id SET DEFAULT nextval('project_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_skills ALTER COLUMN id SET DEFAULT nextval('role_skills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY skills ALTER COLUMN id SET DEFAULT nextval('skills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slugged_routes ALTER COLUMN id SET DEFAULT nextval('slugged_routes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_accounts ALTER COLUMN id SET DEFAULT nextval('stripe_connect_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_cards ALTER COLUMN id SET DEFAULT nextval('stripe_connect_cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_charges ALTER COLUMN id SET DEFAULT nextval('stripe_connect_charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_customers ALTER COLUMN id SET DEFAULT nextval('stripe_connect_customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_plans ALTER COLUMN id SET DEFAULT nextval('stripe_connect_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_subscriptions ALTER COLUMN id SET DEFAULT nextval('stripe_connect_subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_events ALTER COLUMN id SET DEFAULT nextval('stripe_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_external_accounts ALTER COLUMN id SET DEFAULT nextval('stripe_external_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_file_upload ALTER COLUMN id SET DEFAULT nextval('stripe_file_upload_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_invoices ALTER COLUMN id SET DEFAULT nextval('stripe_invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_platform_cards ALTER COLUMN id SET DEFAULT nextval('stripe_platform_cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_platform_customers ALTER COLUMN id SET DEFAULT nextval('stripe_platform_customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_lists ALTER COLUMN id SET DEFAULT nextval('task_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_skills ALTER COLUMN id SET DEFAULT nextval('task_skills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_categories ALTER COLUMN id SET DEFAULT nextval('user_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_skills ALTER COLUMN id SET DEFAULT nextval('user_skills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tasks ALTER COLUMN id SET DEFAULT nextval('user_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: auth_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY auth_token
    ADD CONSTRAINT auth_token_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: donation_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY donation_goals
    ADD CONSTRAINT donation_goals_pkey PRIMARY KEY (id);


--
-- Name: github_app_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_app_installations
    ADD CONSTRAINT github_app_installations_pkey PRIMARY KEY (id);


--
-- Name: github_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_comments
    ADD CONSTRAINT github_comments_pkey PRIMARY KEY (id);


--
-- Name: github_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_events
    ADD CONSTRAINT github_events_pkey PRIMARY KEY (id);


--
-- Name: github_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_issues
    ADD CONSTRAINT github_issues_pkey PRIMARY KEY (id);


--
-- Name: github_pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_pull_requests
    ADD CONSTRAINT github_pull_requests_pkey PRIMARY KEY (id);


--
-- Name: github_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_repos
    ADD CONSTRAINT github_repos_pkey PRIMARY KEY (id);


--
-- Name: organization_github_app_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organization_github_app_installations
    ADD CONSTRAINT organization_github_app_installations_pkey PRIMARY KEY (id);


--
-- Name: organization_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organization_invites
    ADD CONSTRAINT organization_invites_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_pkey PRIMARY KEY (id);


--
-- Name: project_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_categories
    ADD CONSTRAINT project_categories_pkey PRIMARY KEY (id);


--
-- Name: project_github_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_github_repos
    ADD CONSTRAINT project_github_repos_pkey PRIMARY KEY (id);


--
-- Name: project_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_skills
    ADD CONSTRAINT project_skills_pkey PRIMARY KEY (id);


--
-- Name: project_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: role_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY role_skills
    ADD CONSTRAINT role_skills_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: slugged_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slugged_routes
    ADD CONSTRAINT slugged_routes_pkey PRIMARY KEY (id);


--
-- Name: stripe_connect_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_connect_cards
    ADD CONSTRAINT stripe_connect_cards_pkey PRIMARY KEY (id);


--
-- Name: stripe_connect_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_connect_charges
    ADD CONSTRAINT stripe_connect_charges_pkey PRIMARY KEY (id);


--
-- Name: stripe_connect_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_connect_customers
    ADD CONSTRAINT stripe_connect_customers_pkey PRIMARY KEY (id);


--
-- Name: stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: stripe_external_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_external_accounts
    ADD CONSTRAINT stripe_external_accounts_pkey PRIMARY KEY (id);


--
-- Name: stripe_file_upload_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_file_upload
    ADD CONSTRAINT stripe_file_upload_pkey PRIMARY KEY (id);


--
-- Name: stripe_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_invoices
    ADD CONSTRAINT stripe_invoices_pkey PRIMARY KEY (id);


--
-- Name: task_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_lists
    ADD CONSTRAINT task_lists_pkey PRIMARY KEY (id);


--
-- Name: task_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_skills
    ADD CONSTRAINT task_skills_pkey PRIMARY KEY (id);


--
-- Name: user_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_categories
    ADD CONSTRAINT user_categories_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_skills
    ADD CONSTRAINT user_skills_pkey PRIMARY KEY (id);


--
-- Name: user_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_tasks
    ADD CONSTRAINT user_tasks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: auth_token_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auth_token_user_id_index ON auth_token USING btree (user_id);


--
-- Name: auth_token_value_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auth_token_value_index ON auth_token USING btree (value);


--
-- Name: comments_github_comment_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comments_github_comment_id_index ON comments USING btree (github_comment_id);


--
-- Name: comments_task_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comments_task_id_index ON comments USING btree (task_id);


--
-- Name: comments_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comments_user_id_index ON comments USING btree (user_id);


--
-- Name: donation_goals_current_unique_to_project; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX donation_goals_current_unique_to_project ON donation_goals USING btree (project_id) WHERE current;


--
-- Name: donation_goals_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX donation_goals_project_id_index ON donation_goals USING btree (project_id);


--
-- Name: github_app_installations_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_app_installations_github_id_index ON github_app_installations USING btree (github_id);


--
-- Name: github_app_installations_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_app_installations_project_id_index ON github_app_installations USING btree (project_id);


--
-- Name: github_app_installations_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_app_installations_user_id_index ON github_app_installations USING btree (user_id);


--
-- Name: github_comments_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_comments_github_id_index ON github_comments USING btree (github_id);


--
-- Name: github_comments_github_issue_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_comments_github_issue_id_index ON github_comments USING btree (github_issue_id);


--
-- Name: github_events_github_delivery_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_events_github_delivery_id_index ON github_events USING btree (github_delivery_id);


--
-- Name: github_events_status_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_events_status_index ON github_events USING btree (status);


--
-- Name: github_issues_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_issues_github_id_index ON github_issues USING btree (github_id);


--
-- Name: github_issues_github_pull_request_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_issues_github_pull_request_id_index ON github_issues USING btree (github_pull_request_id);


--
-- Name: github_issues_github_repo_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_issues_github_repo_id_index ON github_issues USING btree (github_repo_id);


--
-- Name: github_pull_requests_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_pull_requests_github_id_index ON github_pull_requests USING btree (github_id);


--
-- Name: github_pull_requests_github_repo_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_pull_requests_github_repo_id_index ON github_pull_requests USING btree (github_repo_id);


--
-- Name: github_repos_github_app_installation_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_repos_github_app_installation_id_index ON github_repos USING btree (github_app_installation_id);


--
-- Name: github_repos_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX github_repos_github_id_index ON github_repos USING btree (github_id);


--
-- Name: github_repos_sync_state_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_repos_sync_state_index ON github_repos USING btree (sync_state);


--
-- Name: index_categories_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_categories_on_slug ON categories USING btree (lower((slug)::text));


--
-- Name: index_projects_on_role_id_skill_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_role_id_skill_id ON role_skills USING btree (role_id, skill_id);


--
-- Name: index_projects_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_slug ON projects USING btree (lower((slug)::text));


--
-- Name: index_projects_on_user_id_skill_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_user_id_skill_id ON user_skills USING btree (user_id, skill_id);


--
-- Name: index_skills_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_skills_on_title ON skills USING btree (lower((title)::text));


--
-- Name: organization_github_app_installations_github_app_installation_i; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX organization_github_app_installations_github_app_installation_i ON organization_github_app_installations USING btree (github_app_installation_id);


--
-- Name: organization_github_app_installations_organization_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX organization_github_app_installations_organization_id_index ON organization_github_app_installations USING btree (organization_id);


--
-- Name: organization_invites_code_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX organization_invites_code_index ON organization_invites USING btree (code);


--
-- Name: organization_invites_email_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX organization_invites_email_index ON organization_invites USING btree (email);


--
-- Name: organizations_approved_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX organizations_approved_index ON organizations USING btree (approved);


--
-- Name: organizations_lower_slug_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX organizations_lower_slug_index ON organizations USING btree (lower((slug)::text));


--
-- Name: organizations_owner_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX organizations_owner_id_index ON organizations USING btree (owner_id);


--
-- Name: previews_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX previews_user_id_index ON previews USING btree (user_id);


--
-- Name: project_categories_category_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_categories_category_id_index ON project_categories USING btree (category_id);


--
-- Name: project_categories_project_id_category_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX project_categories_project_id_category_id_index ON project_categories USING btree (project_id, category_id);


--
-- Name: project_categories_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_categories_project_id_index ON project_categories USING btree (project_id);


--
-- Name: project_github_repos_github_repo_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_github_repos_github_repo_id_index ON project_github_repos USING btree (github_repo_id);


--
-- Name: project_github_repos_project_id_github_repo_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX project_github_repos_project_id_github_repo_id_index ON project_github_repos USING btree (project_id, github_repo_id);


--
-- Name: project_github_repos_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_github_repos_project_id_index ON project_github_repos USING btree (project_id);


--
-- Name: project_skills_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_skills_project_id_index ON project_skills USING btree (project_id);


--
-- Name: project_skills_project_id_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX project_skills_project_id_skill_id_index ON project_skills USING btree (project_id, skill_id);


--
-- Name: project_skills_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_skills_skill_id_index ON project_skills USING btree (skill_id);


--
-- Name: project_users_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_users_project_id_index ON project_users USING btree (project_id);


--
-- Name: project_users_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX project_users_user_id_index ON project_users USING btree (user_id);


--
-- Name: project_users_user_id_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX project_users_user_id_project_id_index ON project_users USING btree (user_id, project_id);


--
-- Name: projects_approved_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX projects_approved_index ON projects USING btree (approved);


--
-- Name: projects_organization_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX projects_organization_id_index ON projects USING btree (organization_id);


--
-- Name: role_skills_role_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX role_skills_role_id_index ON role_skills USING btree (role_id);


--
-- Name: role_skills_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX role_skills_skill_id_index ON role_skills USING btree (skill_id);


--
-- Name: slugged_routes_lower_slug_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX slugged_routes_lower_slug_index ON slugged_routes USING btree (lower((slug)::text));


--
-- Name: slugged_routes_organization_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX slugged_routes_organization_id_index ON slugged_routes USING btree (organization_id);


--
-- Name: slugged_routes_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX slugged_routes_user_id_index ON slugged_routes USING btree (user_id);


--
-- Name: stripe_connect_accounts_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_accounts_id_from_stripe_index ON stripe_connect_accounts USING btree (id_from_stripe);


--
-- Name: stripe_connect_accounts_organization_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_accounts_organization_id_index ON stripe_connect_accounts USING btree (organization_id);


--
-- Name: stripe_connect_accounts_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_accounts_pkey ON stripe_connect_accounts USING btree (id);


--
-- Name: stripe_connect_cards_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_cards_id_from_stripe_index ON stripe_connect_cards USING btree (id_from_stripe);


--
-- Name: stripe_connect_cards_stripe_connect_account_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_cards_stripe_connect_account_id_index ON stripe_connect_cards USING btree (stripe_connect_account_id);


--
-- Name: stripe_connect_cards_stripe_connect_account_id_stripe_platform_; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_cards_stripe_connect_account_id_stripe_platform_ ON stripe_connect_cards USING btree (stripe_connect_account_id, stripe_platform_card_id);


--
-- Name: stripe_connect_charges_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_charges_id_from_stripe_index ON stripe_connect_charges USING btree (id_from_stripe);


--
-- Name: stripe_connect_charges_stripe_connect_account_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_charges_stripe_connect_account_id_index ON stripe_connect_charges USING btree (stripe_connect_account_id);


--
-- Name: stripe_connect_charges_stripe_connect_customer_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_charges_stripe_connect_customer_id_index ON stripe_connect_charges USING btree (stripe_connect_customer_id);


--
-- Name: stripe_connect_charges_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_charges_user_id_index ON stripe_connect_charges USING btree (user_id);


--
-- Name: stripe_connect_customers_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_customers_id_from_stripe_index ON stripe_connect_customers USING btree (id_from_stripe);


--
-- Name: stripe_connect_customers_stripe_connect_account_id_stripe_platf; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_customers_stripe_connect_account_id_stripe_platf ON stripe_connect_customers USING btree (stripe_connect_account_id, stripe_platform_customer_id);


--
-- Name: stripe_connect_customers_stripe_platform_customer_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_customers_stripe_platform_customer_id_index ON stripe_connect_customers USING btree (stripe_platform_customer_id);


--
-- Name: stripe_connect_customers_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_customers_user_id_index ON stripe_connect_customers USING btree (user_id);


--
-- Name: stripe_connect_plans_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_plans_id_from_stripe_index ON stripe_connect_plans USING btree (id_from_stripe);


--
-- Name: stripe_connect_plans_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_plans_pkey ON stripe_connect_plans USING btree (id);


--
-- Name: stripe_connect_plans_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_plans_project_id_index ON stripe_connect_plans USING btree (project_id);


--
-- Name: stripe_connect_subscriptions_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_subscriptions_id_from_stripe_index ON stripe_connect_subscriptions USING btree (id_from_stripe);


--
-- Name: stripe_connect_subscriptions_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_connect_subscriptions_pkey ON stripe_connect_subscriptions USING btree (id);


--
-- Name: stripe_connect_subscriptions_plan_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_subscriptions_plan_id_from_stripe_index ON stripe_connect_subscriptions USING btree (plan_id_from_stripe);


--
-- Name: stripe_connect_subscriptions_stripe_connect_plan_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_subscriptions_stripe_connect_plan_id_index ON stripe_connect_subscriptions USING btree (stripe_connect_plan_id);


--
-- Name: stripe_connect_subscriptions_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_connect_subscriptions_user_id_index ON stripe_connect_subscriptions USING btree (user_id);


--
-- Name: stripe_events_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_events_id_from_stripe_index ON stripe_events USING btree (id_from_stripe);


--
-- Name: stripe_external_accounts_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_external_accounts_id_from_stripe_index ON stripe_external_accounts USING btree (id_from_stripe);


--
-- Name: stripe_external_accounts_stripe_connect_account_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_external_accounts_stripe_connect_account_id_index ON stripe_external_accounts USING btree (stripe_connect_account_id);


--
-- Name: stripe_file_upload_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_file_upload_id_from_stripe_index ON stripe_file_upload USING btree (id_from_stripe);


--
-- Name: stripe_file_upload_stripe_connect_account_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_file_upload_stripe_connect_account_id_index ON stripe_file_upload USING btree (stripe_connect_account_id);


--
-- Name: stripe_invoices_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_invoices_id_from_stripe_index ON stripe_invoices USING btree (id_from_stripe);


--
-- Name: stripe_invoices_stripe_connect_subscription_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_invoices_stripe_connect_subscription_id_index ON stripe_invoices USING btree (stripe_connect_subscription_id);


--
-- Name: stripe_invoices_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stripe_invoices_user_id_index ON stripe_invoices USING btree (user_id);


--
-- Name: stripe_platform_cards_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_cards_id_from_stripe_index ON stripe_platform_cards USING btree (id_from_stripe);


--
-- Name: stripe_platform_cards_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_cards_pkey ON stripe_platform_cards USING btree (id);


--
-- Name: stripe_platform_cards_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_cards_user_id_index ON stripe_platform_cards USING btree (user_id);


--
-- Name: stripe_platform_customers_id_from_stripe_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_customers_id_from_stripe_index ON stripe_platform_customers USING btree (id_from_stripe);


--
-- Name: stripe_platform_customers_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_customers_pkey ON stripe_platform_customers USING btree (id);


--
-- Name: stripe_platform_customers_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX stripe_platform_customers_user_id_index ON stripe_platform_customers USING btree (user_id);


--
-- Name: task_lists_inbox_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_lists_inbox_index ON task_lists USING btree (inbox);


--
-- Name: task_lists_order_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_lists_order_index ON task_lists USING btree ("order");


--
-- Name: task_lists_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_lists_project_id_index ON task_lists USING btree (project_id);


--
-- Name: task_skills_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_skills_skill_id_index ON task_skills USING btree (skill_id);


--
-- Name: task_skills_task_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_skills_task_id_index ON task_skills USING btree (task_id);


--
-- Name: task_skills_task_id_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX task_skills_task_id_skill_id_index ON task_skills USING btree (task_id, skill_id);


--
-- Name: tasks_archived_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_archived_index ON tasks USING btree (archived);


--
-- Name: tasks_github_issue_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_github_issue_id_index ON tasks USING btree (github_issue_id);


--
-- Name: tasks_github_repo_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_github_repo_id_index ON tasks USING btree (github_repo_id);


--
-- Name: tasks_number_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_number_index ON tasks USING btree (number);


--
-- Name: tasks_number_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX tasks_number_project_id_index ON tasks USING btree (number, project_id);


--
-- Name: tasks_order_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_order_index ON tasks USING btree ("order");


--
-- Name: tasks_pkey; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX tasks_pkey ON tasks USING btree (id);


--
-- Name: tasks_project_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_project_id_index ON tasks USING btree (project_id);


--
-- Name: tasks_status_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_status_index ON tasks USING btree (status);


--
-- Name: tasks_task_list_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_task_list_id_index ON tasks USING btree (task_list_id);


--
-- Name: tasks_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_user_id_index ON tasks USING btree (user_id);


--
-- Name: user_categories_category_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_categories_category_id_index ON user_categories USING btree (category_id);


--
-- Name: user_categories_user_id_category_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_categories_user_id_category_id_index ON user_categories USING btree (user_id, category_id);


--
-- Name: user_categories_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_categories_user_id_index ON user_categories USING btree (user_id);


--
-- Name: user_roles_role_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_roles_role_id_index ON user_roles USING btree (role_id);


--
-- Name: user_roles_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_roles_user_id_index ON user_roles USING btree (user_id);


--
-- Name: user_roles_user_id_role_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_roles_user_id_role_id_index ON user_roles USING btree (user_id, role_id);


--
-- Name: user_skills_skill_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_skills_skill_id_index ON user_skills USING btree (skill_id);


--
-- Name: user_skills_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_skills_user_id_index ON user_skills USING btree (user_id);


--
-- Name: user_tasks_task_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_tasks_task_id_index ON user_tasks USING btree (task_id);


--
-- Name: user_tasks_user_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_tasks_user_id_index ON user_tasks USING btree (user_id);


--
-- Name: user_tasks_user_id_task_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_tasks_user_id_task_id_index ON user_tasks USING btree (user_id, task_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX users_email_index ON users USING btree (email);


--
-- Name: users_github_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX users_github_id_index ON users USING btree (github_id);


--
-- Name: users_lower_username_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX users_lower_username_index ON users USING btree (lower((username)::text));


--
-- Name: task_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER task_created BEFORE INSERT ON tasks FOR EACH ROW EXECUTE PROCEDURE assign_number();


--
-- Name: auth_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY auth_token
    ADD CONSTRAINT auth_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: comments_github_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_github_comment_id_fkey FOREIGN KEY (github_comment_id) REFERENCES github_comments(id);


--
-- Name: comments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE;


--
-- Name: comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: donation_goals_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY donation_goals
    ADD CONSTRAINT donation_goals_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: github_app_installations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_app_installations
    ADD CONSTRAINT github_app_installations_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: github_app_installations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_app_installations
    ADD CONSTRAINT github_app_installations_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: github_comments_github_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_comments
    ADD CONSTRAINT github_comments_github_issue_id_fkey FOREIGN KEY (github_issue_id) REFERENCES github_issues(id);


--
-- Name: github_issues_github_pull_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_issues
    ADD CONSTRAINT github_issues_github_pull_request_id_fkey FOREIGN KEY (github_pull_request_id) REFERENCES github_pull_requests(id);


--
-- Name: github_issues_github_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_issues
    ADD CONSTRAINT github_issues_github_repo_id_fkey FOREIGN KEY (github_repo_id) REFERENCES github_repos(id);


--
-- Name: github_pull_requests_github_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_pull_requests
    ADD CONSTRAINT github_pull_requests_github_repo_id_fkey FOREIGN KEY (github_repo_id) REFERENCES github_repos(id);


--
-- Name: github_repos_github_app_installation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_repos
    ADD CONSTRAINT github_repos_github_app_installation_id_fkey FOREIGN KEY (github_app_installation_id) REFERENCES github_app_installations(id);


--
-- Name: organization_github_app_installations_github_app_installation_i; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_github_app_installations
    ADD CONSTRAINT organization_github_app_installations_github_app_installation_i FOREIGN KEY (github_app_installation_id) REFERENCES github_app_installations(id);


--
-- Name: organization_github_app_installations_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_github_app_installations
    ADD CONSTRAINT organization_github_app_installations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: organizations_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users(id);


--
-- Name: previews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: project_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_categories
    ADD CONSTRAINT project_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: project_categories_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_categories
    ADD CONSTRAINT project_categories_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: project_github_repos_github_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_github_repos
    ADD CONSTRAINT project_github_repos_github_repo_id_fkey FOREIGN KEY (github_repo_id) REFERENCES github_repos(id) ON DELETE CASCADE;


--
-- Name: project_github_repos_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_github_repos
    ADD CONSTRAINT project_github_repos_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_skills_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_skills
    ADD CONSTRAINT project_skills_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: project_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_skills
    ADD CONSTRAINT project_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: project_users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_users
    ADD CONSTRAINT project_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: project_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_users
    ADD CONSTRAINT project_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: role_skills_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_skills
    ADD CONSTRAINT role_skills_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: role_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_skills
    ADD CONSTRAINT role_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: slugged_routes_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slugged_routes
    ADD CONSTRAINT slugged_routes_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: slugged_routes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slugged_routes
    ADD CONSTRAINT slugged_routes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_connect_accounts_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_accounts
    ADD CONSTRAINT stripe_connect_accounts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: stripe_connect_cards_stripe_connect_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_cards
    ADD CONSTRAINT stripe_connect_cards_stripe_connect_account_id_fkey FOREIGN KEY (stripe_connect_account_id) REFERENCES stripe_connect_accounts(id) ON DELETE CASCADE;


--
-- Name: stripe_connect_cards_stripe_platform_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_cards
    ADD CONSTRAINT stripe_connect_cards_stripe_platform_card_id_fkey FOREIGN KEY (stripe_platform_card_id) REFERENCES stripe_platform_cards(id);


--
-- Name: stripe_connect_charges_stripe_connect_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_charges
    ADD CONSTRAINT stripe_connect_charges_stripe_connect_account_id_fkey FOREIGN KEY (stripe_connect_account_id) REFERENCES stripe_connect_accounts(id);


--
-- Name: stripe_connect_charges_stripe_connect_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_charges
    ADD CONSTRAINT stripe_connect_charges_stripe_connect_customer_id_fkey FOREIGN KEY (stripe_connect_customer_id) REFERENCES stripe_connect_customers(id);


--
-- Name: stripe_connect_charges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_charges
    ADD CONSTRAINT stripe_connect_charges_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_connect_customers_stripe_connect_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_customers
    ADD CONSTRAINT stripe_connect_customers_stripe_connect_account_id_fkey FOREIGN KEY (stripe_connect_account_id) REFERENCES stripe_connect_accounts(id) ON DELETE CASCADE;


--
-- Name: stripe_connect_customers_stripe_platform_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_customers
    ADD CONSTRAINT stripe_connect_customers_stripe_platform_customer_id_fkey FOREIGN KEY (stripe_platform_customer_id) REFERENCES stripe_platform_customers(id);


--
-- Name: stripe_connect_customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_customers
    ADD CONSTRAINT stripe_connect_customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_connect_plans_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_plans
    ADD CONSTRAINT stripe_connect_plans_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: stripe_connect_subscriptions_stripe_connect_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_subscriptions
    ADD CONSTRAINT stripe_connect_subscriptions_stripe_connect_plan_id_fkey FOREIGN KEY (stripe_connect_plan_id) REFERENCES stripe_connect_plans(id);


--
-- Name: stripe_connect_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_connect_subscriptions
    ADD CONSTRAINT stripe_connect_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_external_accounts_stripe_connect_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_external_accounts
    ADD CONSTRAINT stripe_external_accounts_stripe_connect_account_id_fkey FOREIGN KEY (stripe_connect_account_id) REFERENCES stripe_connect_accounts(id);


--
-- Name: stripe_file_upload_stripe_connect_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_file_upload
    ADD CONSTRAINT stripe_file_upload_stripe_connect_account_id_fkey FOREIGN KEY (stripe_connect_account_id) REFERENCES stripe_connect_accounts(id);


--
-- Name: stripe_invoices_stripe_connect_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_invoices
    ADD CONSTRAINT stripe_invoices_stripe_connect_subscription_id_fkey FOREIGN KEY (stripe_connect_subscription_id) REFERENCES stripe_connect_subscriptions(id);


--
-- Name: stripe_invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_invoices
    ADD CONSTRAINT stripe_invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_platform_cards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_platform_cards
    ADD CONSTRAINT stripe_platform_cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stripe_platform_customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_platform_customers
    ADD CONSTRAINT stripe_platform_customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: task_lists_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_lists
    ADD CONSTRAINT task_lists_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: task_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_skills
    ADD CONSTRAINT task_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: task_skills_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_skills
    ADD CONSTRAINT task_skills_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id);


--
-- Name: tasks_github_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_github_issue_id_fkey FOREIGN KEY (github_issue_id) REFERENCES github_issues(id);


--
-- Name: tasks_github_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_github_repo_id_fkey FOREIGN KEY (github_repo_id) REFERENCES github_repos(id);


--
-- Name: tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: tasks_task_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_task_list_id_fkey FOREIGN KEY (task_list_id) REFERENCES task_lists(id);


--
-- Name: tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_categories
    ADD CONSTRAINT user_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: user_categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_categories
    ADD CONSTRAINT user_categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_skills
    ADD CONSTRAINT user_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: user_skills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_skills
    ADD CONSTRAINT user_skills_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_tasks_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tasks
    ADD CONSTRAINT user_tasks_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id);


--
-- Name: user_tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tasks
    ADD CONSTRAINT user_tasks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20160723215749), (20160804000000), (20160804001111), (20160805132301), (20160805203929), (20160808143454), (20160809214736), (20160810124357), (20160815125009), (20160815143002), (20160816020347), (20160816034021), (20160817220118), (20160818000944), (20160818132546), (20160820113856), (20160820164905), (20160822002438), (20160822004056), (20160822011624), (20160822020401), (20160822044612), (20160830081224), (20160830224802), (20160911233738), (20160912002705), (20160912145957), (20160918003206), (20160928232404), (20161003185918), (20161019090945), (20161019110737), (20161020144622), (20161021131026), (20161031001615), (20161121005339), (20161121014050), (20161121043941), (20161121045709), (20161122015942), (20161123081114), (20161123150943), (20161124085742), (20161125200620), (20161126045705), (20161127054559), (20161205024856), (20161207112519), (20161209192504), (20161212005641), (20161214005935), (20161215052051), (20161216051447), (20161218005913), (20161219160401), (20161219163909), (20161220141753), (20161221085759), (20161226213600), (20161231063614), (20170102130055), (20170102181053), (20170104113708), (20170104212623), (20170104235423), (20170106013143), (20170115035159), (20170115230549), (20170121014100), (20170131234029), (20170201014901), (20170201025454), (20170201035458), (20170201183258), (20170220032224), (20170224233516), (20170226050552), (20170228085250), (20170308214128), (20170308220713), (20170308222552), (20170313130611), (20170318032449), (20170318082740), (20170324194827), (20170424215355), (20170501225441), (20170505224222), (20170526095401), (20170602000208), (20170622205732), (20170626231059), (20170628092119), (20170628213609), (20170629183404), (20170630140136), (20170706132431), (20170707213648), (20170711122252), (20170717092127), (20170725060612), (20170727052644), (20170731130121), (20170814131722), (20170913114958), (20170921014405), (20170925214512), (20170925230419), (20170926134646), (20170927100300), (20170928234412), (20171003134956), (20171003225853), (20171006063358), (20171006161407), (20171012215106), (20171012221231), (20171016125229), (20171016125516), (20171016223356), (20171016235656), (20171017235433), (20171019191035), (20171025184225), (20171026010933), (20171027061833), (20171028011642), (20171028173508), (20171030182857);

