--
-- PostgreSQL database dump
--

-- Dumped from database version 10.23 (Ubuntu 10.23-0ubuntu0.18.04.2+esm1)
-- Dumped by pg_dump version 12.18 (Ubuntu 12.18-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: annotations; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.annotations (
    annotationid integer NOT NULL,
    tablereferenced character varying(255),
    recordid integer,
    note text,
    dateadded date DEFAULT CURRENT_DATE
);


ALTER TABLE public.annotations OWNER TO c370_s129;

--
-- Name: annotations_annotationid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.annotations_annotationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_annotationid_seq OWNER TO c370_s129;

--
-- Name: annotations_annotationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.annotations_annotationid_seq OWNED BY public.annotations.annotationid;


--
-- Name: campaign; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.campaign (
    campaignid integer NOT NULL,
    name character varying(255),
    focus character varying(255),
    startdate date,
    enddate date
);


ALTER TABLE public.campaign OWNER TO c370_s129;

--
-- Name: campaign_campaignid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.campaign_campaignid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.campaign_campaignid_seq OWNER TO c370_s129;

--
-- Name: campaign_campaignid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.campaign_campaignid_seq OWNED BY public.campaign.campaignid;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.donations (
    donationid integer NOT NULL,
    campaignid integer,
    memberid integer,
    date date,
    amount numeric(10,2)
);


ALTER TABLE public.donations OWNER TO c370_s129;

--
-- Name: donations_donationid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.donations_donationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donations_donationid_seq OWNER TO c370_s129;

--
-- Name: donations_donationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.donations_donationid_seq OWNED BY public.donations.donationid;


--
-- Name: donor; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.donor (
    memberid integer NOT NULL,
    islargedonor boolean,
    isanon boolean
);


ALTER TABLE public.donor OWNER TO c370_s129;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.employee (
    memberid integer NOT NULL,
    organizationrole character varying(255)
);


ALTER TABLE public.employee OWNER TO c370_s129;

--
-- Name: event; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.event (
    eventid integer NOT NULL,
    name character varying(255),
    date date,
    location character varying(255),
    campaignid integer
);


ALTER TABLE public.event OWNER TO c370_s129;

--
-- Name: event_eventid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.event_eventid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_eventid_seq OWNER TO c370_s129;

--
-- Name: event_eventid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.event_eventid_seq OWNED BY public.event.eventid;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.expenses (
    financeid integer NOT NULL,
    campaignid integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    date date NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.expenses OWNER TO c370_s129;

--
-- Name: finances; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.finances (
    financeid integer NOT NULL,
    amount numeric(10,2),
    date date
);


ALTER TABLE public.finances OWNER TO c370_s129;

--
-- Name: finances_financeid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.finances_financeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.finances_financeid_seq OWNER TO c370_s129;

--
-- Name: finances_financeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.finances_financeid_seq OWNED BY public.finances.financeid;


--
-- Name: member; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.member (
    memberid integer NOT NULL,
    name character varying(255),
    email character varying(255),
    number character varying(50)
);


ALTER TABLE public.member OWNER TO c370_s129;

--
-- Name: member_memberid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.member_memberid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_memberid_seq OWNER TO c370_s129;

--
-- Name: member_memberid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.member_memberid_seq OWNED BY public.member.memberid;


--
-- Name: query1; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query1 AS
 SELECT expenses.campaignid,
    sum(expenses.amount) AS totalspent
   FROM public.expenses
  GROUP BY expenses.campaignid;


ALTER TABLE public.query1 OWNER TO c370_s129;

--
-- Name: query10; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query10 AS
 SELECT donations.memberid,
    sum(donations.amount) AS totaldonated
   FROM public.donations
  GROUP BY donations.memberid
  ORDER BY (sum(donations.amount)) DESC
 LIMIT 3;


ALTER TABLE public.query10 OWNER TO c370_s129;

--
-- Name: query11; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query11 AS
 SELECT c.campaignid,
    c.name
   FROM public.campaign c
  WHERE (EXISTS ( SELECT d.amount AS donationamount
           FROM public.donations d
          WHERE ((d.campaignid = c.campaignid) AND (d.amount >= (1250)::numeric))));


ALTER TABLE public.query11 OWNER TO c370_s129;

--
-- Name: query2; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query2 AS
 SELECT count(event.campaignid) AS totalevents
   FROM public.event
  GROUP BY event.campaignid;


ALTER TABLE public.query2 OWNER TO c370_s129;

--
-- Name: query3; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query3 AS
 SELECT avg(eventcounts.totalevents) AS avgeventspercampaign
   FROM ( SELECT count(event.campaignid) AS totalevents
           FROM public.event
          GROUP BY event.campaignid) eventcounts;


ALTER TABLE public.query3 OWNER TO c370_s129;

--
-- Name: query4; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query4 AS
 SELECT count(DISTINCT event.campaignid) AS numofcampaignswithevents
   FROM public.event;


ALTER TABLE public.query4 OWNER TO c370_s129;

--
-- Name: query5; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query5 AS
 SELECT d1.campaignid,
    sum(d1.amount) AS totaldonations
   FROM public.donations d1
  GROUP BY d1.campaignid
 HAVING (sum(d1.amount) > ( SELECT avg(d2.amount) AS avg
           FROM public.donations d2));


ALTER TABLE public.query5 OWNER TO c370_s129;

--
-- Name: query6; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query6 AS
 SELECT d1.campaignid,
    d1.amount
   FROM public.donations d1
  WHERE (d1.amount > ( SELECT avg(d2.amount) AS avg
           FROM public.donations d2
          WHERE (d1.campaignid = d1.campaignid)));


ALTER TABLE public.query6 OWNER TO c370_s129;

--
-- Name: volsfor; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.volsfor (
    campaignid integer,
    memberid integer
);


ALTER TABLE public.volsfor OWNER TO c370_s129;

--
-- Name: query7; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query7 AS
 SELECT v.memberid
   FROM (public.volsfor v
     JOIN public.member m ON ((v.memberid = m.memberid)))
  GROUP BY v.memberid, m.name
 HAVING (count(DISTINCT v.campaignid) = ( SELECT count(*) AS count
           FROM public.campaign));


ALTER TABLE public.query7 OWNER TO c370_s129;

--
-- Name: query8; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query8 AS
 SELECT campaign.campaignid,
    campaign.name,
    (campaign.enddate - campaign.startdate) AS duration
   FROM public.campaign
  ORDER BY (campaign.enddate - campaign.startdate);


ALTER TABLE public.query8 OWNER TO c370_s129;

--
-- Name: workson; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.workson (
    campaignid integer,
    memberid integer
);


ALTER TABLE public.workson OWNER TO c370_s129;

--
-- Name: query9; Type: VIEW; Schema: public; Owner: c370_s129
--

CREATE VIEW public.query9 AS
 SELECT workson.memberid,
    count(*) AS numofcampaigns
   FROM public.workson
  GROUP BY workson.memberid
  ORDER BY (count(*)) DESC;


ALTER TABLE public.query9 OWNER TO c370_s129;

--
-- Name: salary; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.salary (
    financeid integer NOT NULL,
    memberid integer NOT NULL
);


ALTER TABLE public.salary OWNER TO c370_s129;

--
-- Name: volunteer; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.volunteer (
    memberid integer NOT NULL,
    numberofcampaigns integer
);


ALTER TABLE public.volunteer OWNER TO c370_s129;

--
-- Name: website; Type: TABLE; Schema: public; Owner: c370_s129
--

CREATE TABLE public.website (
    websiteid integer NOT NULL,
    campaignid integer,
    datetopublish date,
    description text
);


ALTER TABLE public.website OWNER TO c370_s129;

--
-- Name: website_websiteid_seq; Type: SEQUENCE; Schema: public; Owner: c370_s129
--

CREATE SEQUENCE public.website_websiteid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.website_websiteid_seq OWNER TO c370_s129;

--
-- Name: website_websiteid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c370_s129
--

ALTER SEQUENCE public.website_websiteid_seq OWNED BY public.website.websiteid;


--
-- Name: annotations annotationid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.annotations ALTER COLUMN annotationid SET DEFAULT nextval('public.annotations_annotationid_seq'::regclass);


--
-- Name: campaign campaignid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.campaign ALTER COLUMN campaignid SET DEFAULT nextval('public.campaign_campaignid_seq'::regclass);


--
-- Name: donations donationid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donations ALTER COLUMN donationid SET DEFAULT nextval('public.donations_donationid_seq'::regclass);


--
-- Name: event eventid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.event ALTER COLUMN eventid SET DEFAULT nextval('public.event_eventid_seq'::regclass);


--
-- Name: finances financeid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.finances ALTER COLUMN financeid SET DEFAULT nextval('public.finances_financeid_seq'::regclass);


--
-- Name: member memberid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.member ALTER COLUMN memberid SET DEFAULT nextval('public.member_memberid_seq'::regclass);


--
-- Name: website websiteid; Type: DEFAULT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.website ALTER COLUMN websiteid SET DEFAULT nextval('public.website_websiteid_seq'::regclass);


--
-- Data for Name: annotations; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.annotations (annotationid, tablereferenced, recordid, note, dateadded) FROM stdin;
\.


--
-- Data for Name: campaign; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.campaign (campaignid, name, focus, startdate, enddate) FROM stdin;
1	Clean the Beach	Environment	2023-04-01	2023-04-30
2	Plant a Tree	Reforestation	2023-05-01	2023-05-31
3	Evergreen Lovers	Saving the evergreens	2025-01-01	2025-02-02
4	timber lovers	love to timb	2024-01-01	2025-01-01
\.


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.donations (donationid, campaignid, memberid, date, amount) FROM stdin;
1	1	8	2023-04-02	500.00
2	1	9	2023-04-03	150.00
3	1	10	2023-04-04	1250.00
4	1	11	2023-04-05	300.00
5	1	12	2023-04-06	1200.00
6	1	8	2023-04-07	500.00
7	2	9	2023-05-02	100.00
8	2	10	2023-05-03	1200.00
9	2	11	2023-05-04	150.00
10	2	12	2023-05-05	1250.00
\.


--
-- Data for Name: donor; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.donor (memberid, islargedonor, isanon) FROM stdin;
8	t	f
9	f	t
10	t	t
11	f	f
12	t	f
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.employee (memberid, organizationrole) FROM stdin;
5	Coordinator
6	Project Manager
7	Outreach Specialist
\.


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.event (eventid, name, date, location, campaignid) FROM stdin;
1	Beach Cleanup Kickoff	2023-04-01	Sunny Beach	1
2	Educational Workshop	2023-04-08	Community Center	1
3	Recycling Drive	2023-04-15	Sunny Beach	1
4	Beach Cleanup Wrap-up	2023-04-22	Sunny Beach	1
5	Celebration Event	2023-04-29	Local Park	1
6	evergreen planting	2025-01-15	victoria	3
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.expenses (financeid, campaignid, amount, date, description) FROM stdin;
1	1	1000.00	2023-04-01	Marketing for Beach Cleanup
3	1	1500.00	2023-04-02	Cleanup Supplies
2	2	800.00	2023-05-01	Tree Planting Supplies
4	2	700.00	2023-05-02	Rental Equipment for Tree Planting
14	3	750.00	2024-04-11	test123
\.


--
-- Data for Name: finances; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.finances (financeid, amount, date) FROM stdin;
1	1000.00	2023-04-01
2	800.00	2023-05-01
3	1500.00	2023-04-02
4	700.00	2023-05-02
5	500.00	2023-04-15
6	500.00	2023-04-30
7	500.00	2023-05-15
8	500.00	2023-05-30
9	500.00	2023-04-15
10	500.00	2023-05-15
11	250.00	2023-05-30
12	1000.00	2024-04-11
13	1000.00	2024-04-11
14	1000.00	2024-04-11
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.member (memberid, name, email, number) FROM stdin;
1	Alice Smith	alice@example.com	111-000-0100
2	Bob Jones	bob@example.com	111-000-0101
3	Carol Danvers	carol@example.com	111-000-0102
4	Dave Brown	dave@example.com	111-000-0103
5	Eve Adams	eve@example.com	111-000-0200
6	Frank Castle	frank@example.com	111-000-0201
7	Grace Lee	grace@example.com	111-000-0202
8	Henry Ford	henry@example.com	111-000-0300
9	Isabel Wright	isabel@example.com	111-000-0301
10	Jack Black	jack@example.com	111-000-0302
11	Karen Hill	karen@example.com	111-000-0303
12	Liam Neeson	liam@example.com	111-000-0304
\.


--
-- Data for Name: salary; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.salary (financeid, memberid) FROM stdin;
5	5
6	5
7	5
8	5
9	6
10	6
11	7
\.


--
-- Data for Name: volsfor; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.volsfor (campaignid, memberid) FROM stdin;
1	1
1	2
2	1
2	2
1	3
2	4
\.


--
-- Data for Name: volunteer; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.volunteer (memberid, numberofcampaigns) FROM stdin;
1	2
2	2
3	1
4	1
\.


--
-- Data for Name: website; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.website (websiteid, campaignid, datetopublish, description) FROM stdin;
1	1	2023-03-30	Join our Clean the Beach campaign!
2	2	2023-04-30	Help us plant a tree this May!
3	1	2023-04-15	Beach Cleanup halfway point - progress update!
\.


--
-- Data for Name: workson; Type: TABLE DATA; Schema: public; Owner: c370_s129
--

COPY public.workson (campaignid, memberid) FROM stdin;
1	5
1	6
1	7
2	7
\.


--
-- Name: annotations_annotationid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.annotations_annotationid_seq', 1, true);


--
-- Name: campaign_campaignid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.campaign_campaignid_seq', 4, true);


--
-- Name: donations_donationid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.donations_donationid_seq', 10, true);


--
-- Name: event_eventid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.event_eventid_seq', 6, true);


--
-- Name: finances_financeid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.finances_financeid_seq', 14, true);


--
-- Name: member_memberid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.member_memberid_seq', 14, true);


--
-- Name: website_websiteid_seq; Type: SEQUENCE SET; Schema: public; Owner: c370_s129
--

SELECT pg_catalog.setval('public.website_websiteid_seq', 3, true);


--
-- Name: annotations annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (annotationid);


--
-- Name: campaign campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.campaign
    ADD CONSTRAINT campaign_pkey PRIMARY KEY (campaignid);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (donationid);


--
-- Name: donor donor_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donor
    ADD CONSTRAINT donor_pkey PRIMARY KEY (memberid);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (memberid);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (eventid);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (financeid);


--
-- Name: finances finances_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_pkey PRIMARY KEY (financeid);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (memberid);


--
-- Name: salary salary_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT salary_pkey PRIMARY KEY (financeid);


--
-- Name: volsfor volsfor_campaignid_memberid_key; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.volsfor
    ADD CONSTRAINT volsfor_campaignid_memberid_key UNIQUE (campaignid, memberid);


--
-- Name: volunteer volunteer_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_pkey PRIMARY KEY (memberid);


--
-- Name: website website_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.website
    ADD CONSTRAINT website_pkey PRIMARY KEY (websiteid);


--
-- Name: workson workson_campaignid_memberid_key; Type: CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.workson
    ADD CONSTRAINT workson_campaignid_memberid_key UNIQUE (campaignid, memberid);


--
-- Name: donations donations_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: donations donations_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.donor(memberid);


--
-- Name: donor donor_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.donor
    ADD CONSTRAINT donor_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.member(memberid);


--
-- Name: employee employee_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.member(memberid);


--
-- Name: event event_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: expenses expenses_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: expenses expenses_financeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_financeid_fkey FOREIGN KEY (financeid) REFERENCES public.finances(financeid);


--
-- Name: salary salary_financeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT salary_financeid_fkey FOREIGN KEY (financeid) REFERENCES public.finances(financeid);


--
-- Name: salary salary_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT salary_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.employee(memberid);


--
-- Name: volsfor volsfor_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.volsfor
    ADD CONSTRAINT volsfor_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: volsfor volsfor_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.volsfor
    ADD CONSTRAINT volsfor_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.volunteer(memberid);


--
-- Name: volunteer volunteer_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.member(memberid);


--
-- Name: website website_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.website
    ADD CONSTRAINT website_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: workson workson_campaignid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.workson
    ADD CONSTRAINT workson_campaignid_fkey FOREIGN KEY (campaignid) REFERENCES public.campaign(campaignid);


--
-- Name: workson workson_memberid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s129
--

ALTER TABLE ONLY public.workson
    ADD CONSTRAINT workson_memberid_fkey FOREIGN KEY (memberid) REFERENCES public.employee(memberid);


--
-- PostgreSQL database dump complete
--

