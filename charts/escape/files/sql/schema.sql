--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)

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

--
-- Name: exp_tables; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA exp_tables;


ALTER SCHEMA exp_tables OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acctcat; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.acctcat (
    "group" character varying(1),
    id character varying(2),
    "desc" character varying(30)
);


ALTER TABLE exp_tables.acctcat OWNER TO postgres;

--
-- Name: acctsort; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.acctsort (
    account character varying(10),
    dept character varying(2),
    key character varying(25),
    debit double precision NOT NULL,
    credit double precision NOT NULL,
    source text,
    date timestamp without time zone,
    drilldown character varying(60)
);


ALTER TABLE exp_tables.acctsort OWNER TO postgres;

--
-- Name: actionlist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.actionlist (
    listid character varying(36),
    value character varying(60),
    type integer NOT NULL
);


ALTER TABLE exp_tables.actionlist OWNER TO postgres;

--
-- Name: activity; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.activity (
    activityid character varying(36),
    custno character varying(7),
    description text,
    status integer NOT NULL,
    emailto character varying(1000),
    emailsubject character varying(255),
    emailbody text,
    date timestamp without time zone,
    actionid character varying(36),
    quoteref character varying(10)
);


ALTER TABLE exp_tables.activity OWNER TO postgres;

--
-- Name: actsetup; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.actsetup (
    key character varying(1),
    package double precision NOT NULL,
    rwcompany character varying(3),
    rwpath character varying(40),
    navserver double precision NOT NULL,
    navconn character varying(80),
    navcustgb character varying(15),
    navcusttax character varying(15),
    navcustcus character varying(15),
    navvengb character varying(15),
    navventax character varying(15),
    navvenven character varying(15),
    navtaxmat character varying(10),
    navtaxlab character varying(10),
    navtaxsa character varying(10),
    navtaxot character varying(10),
    navsalejt character varying(10),
    navsalejb character varying(10),
    navinvpost character varying(10),
    navinvdisc character varying(10),
    navinvgen character varying(10),
    navjobjt character varying(10),
    navjobjb character varying(10),
    navitemjt character varying(10),
    navitemjb character varying(10),
    navgenjt character varying(10),
    navgenjb character varying(10),
    rwdistcode character varying(6),
    rwtaxlab double precision NOT NULL,
    rwtaxmat double precision NOT NULL,
    rwtaxother double precision NOT NULL,
    rwtaxsa double precision NOT NULL,
    rwtaxexemp double precision NOT NULL,
    rwvendist character varying(6),
    rwvenacct character varying(10),
    qbcountry double precision NOT NULL,
    rwappref double precision NOT NULL,
    rwapcompl integer NOT NULL,
    rwpojob integer NOT NULL,
    qbappref integer NOT NULL,
    qbapcompl integer NOT NULL,
    qbpospost smallint NOT NULL,
    qbcanada smallint NOT NULL,
    ptcompany character varying(100),
    ptsaclass character varying(40),
    rwsaclass character varying(40),
    qbdontpostmemos smallint NOT NULL,
    qbcanada2008 smallint NOT NULL,
    quickbooksserver character varying(80),
    peachtreeserver character varying(80)
);


ALTER TABLE exp_tables.actsetup OWNER TO postgres;

--
-- Name: agrestimate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrestimate (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    counter integer NOT NULL,
    product character varying(36),
    "desc" text,
    quantity double precision NOT NULL,
    cost double precision NOT NULL,
    billamt double precision NOT NULL
);


ALTER TABLE exp_tables.agrestimate OWNER TO postgres;

--
-- Name: agrinvoice; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrinvoice (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    counter integer NOT NULL,
    month integer NOT NULL,
    product character varying(36),
    "desc" text,
    quantity double precision NOT NULL,
    price double precision NOT NULL,
    amount double precision NOT NULL,
    print smallint NOT NULL,
    jbclass character varying(40),
    schedtask character varying(7)
);


ALTER TABLE exp_tables.agrinvoice OWNER TO postgres;

--
-- Name: agrparts; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrparts (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    mastertask character varying(7),
    part character varying(36),
    quantity double precision NOT NULL
);


ALTER TABLE exp_tables.agrparts OWNER TO postgres;

--
-- Name: agrrecur; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrrecur (
    transid character varying(36),
    lineid integer NOT NULL,
    task character varying(7),
    recurdesc text,
    recurtype integer NOT NULL,
    nextdate timestamp without time zone,
    subtype integer NOT NULL,
    "interval" integer NOT NULL,
    dayofmonth integer NOT NULL,
    dayofweek character varying(15),
    monthofyear character varying(15),
    dayinmonth character varying(15),
    recurmon smallint NOT NULL,
    recurtue smallint NOT NULL,
    recurwed smallint NOT NULL,
    recurthu smallint NOT NULL,
    recurfri smallint NOT NULL,
    recursat smallint NOT NULL,
    recursun smallint NOT NULL,
    taskid character varying(36),
    timeofday character varying(10),
    recurbegindate timestamp without time zone,
    recurjan smallint NOT NULL,
    recurfeb smallint NOT NULL,
    recurmar smallint NOT NULL,
    recurapr smallint NOT NULL,
    recurmay smallint NOT NULL,
    recurjun smallint NOT NULL,
    recurjul smallint NOT NULL,
    recuraug smallint NOT NULL,
    recursep smallint NOT NULL,
    recuroct smallint NOT NULL,
    recurnov smallint NOT NULL,
    recurdec smallint NOT NULL
);


ALTER TABLE exp_tables.agrrecur OWNER TO postgres;

--
-- Name: agrsched; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrsched (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    firstper integer NOT NULL,
    period character varying(2),
    taskno character varying(2),
    task character varying(7),
    date timestamp without time zone,
    datenyear timestamp without time zone,
    daydisp character varying(10)
);


ALTER TABLE exp_tables.agrsched OWNER TO postgres;

--
-- Name: agrtask; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrtask (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    mastertask character varying(7),
    counter character varying(3),
    task character varying(7),
    level character varying(2),
    skill character varying(2),
    "time" character varying(3),
    longdesc text,
    subtotal double precision NOT NULL
);


ALTER TABLE exp_tables.agrtask OWNER TO postgres;

--
-- Name: agrtempl; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrtempl (
    template character varying(20),
    "desc" character varying(60),
    data text
);


ALTER TABLE exp_tables.agrtempl OWNER TO postgres;

--
-- Name: agrtools; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.agrtools (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    mastertask character varying(7),
    tool character varying(12)
);


ALTER TABLE exp_tables.agrtools OWNER TO postgres;

--
-- Name: ahsstatus; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.ahsstatus (
    id character varying(36),
    created timestamp without time zone,
    handled smallint NOT NULL,
    dispatch character varying(15),
    status character varying(10)
);


ALTER TABLE exp_tables.ahsstatus OWNER TO postgres;

--
-- Name: appstats; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.appstats (
    id character varying(36),
    transaction character varying(80),
    dateadded timestamp without time zone
);


ALTER TABLE exp_tables.appstats OWNER TO postgres;

--
-- Name: calleridalt; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.calleridalt (
    custno character varying(7),
    locno character varying(5),
    phone character varying(12)
);


ALTER TABLE exp_tables.calleridalt OWNER TO postgres;

--
-- Name: coa; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.coa (
    account character varying(10),
    id character varying(2),
    "desc" character varying(40),
    dept character varying(2),
    div character varying(2),
    "group" character varying(4),
    type character varying(1),
    isdept integer NOT NULL,
    navbank character varying(20),
    acctlistid character varying(20),
    itemlistid character varying(20),
    accountid character varying(36),
    parentid character varying(36),
    accountsort character varying(10),
    inactive smallint NOT NULL,
    accrualvendor character varying(4),
    recondate timestamp without time zone,
    reconbeginbal double precision NOT NULL,
    reconendbal double precision NOT NULL,
    overheadmethod integer NOT NULL,
    wipaccount smallint NOT NULL,
    wipclosingaccountid character varying(36),
    category1099 integer NOT NULL
);


ALTER TABLE exp_tables.coa OWNER TO postgres;

--
-- Name: collactn; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.collactn (
    code character varying(6),
    "desc" character varying(30)
);


ALTER TABLE exp_tables.collactn OWNER TO postgres;

--
-- Name: collectn; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.collectn (
    custno character varying(7),
    date timestamp without time zone,
    note text,
    action character varying(6),
    followup timestamp without time zone
);


ALTER TABLE exp_tables.collectn OWNER TO postgres;

--
-- Name: colltemp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.colltemp (
    custno character varying(7),
    current double precision NOT NULL,
    ov30 double precision NOT NULL,
    ov60 double precision NOT NULL,
    ov90 double precision NOT NULL
);


ALTER TABLE exp_tables.colltemp OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.company (
    name character varying(30),
    address character varying(30),
    address2 character varying(30),
    city character varying(25),
    state character varying(2),
    zip character varying(10),
    phone character varying(12),
    fax character varying(12),
    fiscalbeg character varying(2),
    fedidnum character varying(12)
);


ALTER TABLE exp_tables.company OWNER TO postgres;

--
-- Name: counter; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.counter (
    name character varying(10),
    next character varying(15)
);


ALTER TABLE exp_tables.counter OWNER TO postgres;

--
-- Name: credcard; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.credcard (
    custno character varying(7),
    serial character varying(5),
    name character varying(30),
    number character varying(100),
    expire timestamp without time zone,
    auth character varying(15),
    card character varying(15),
    transid character varying(36)
);


ALTER TABLE exp_tables.credcard OWNER TO postgres;

--
-- Name: creditratings; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.creditratings (
    name character varying(7),
    inactive smallint NOT NULL,
    color integer NOT NULL,
    restrictdispatch smallint NOT NULL
);


ALTER TABLE exp_tables.creditratings OWNER TO postgres;

--
-- Name: custflds; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.custflds (
    tblname character varying(10),
    fldnum integer NOT NULL,
    fldlabel character varying(20),
    list1 character varying(40),
    list2 character varying(40),
    list3 character varying(40),
    list4 character varying(40),
    list5 character varying(40),
    list6 character varying(40),
    list7 character varying(40),
    list8 character varying(40),
    list9 character varying(40),
    list10 character varying(40),
    list11 character varying(40),
    list12 character varying(40),
    list13 character varying(40),
    list14 character varying(40),
    list15 character varying(40),
    list16 character varying(40),
    list17 character varying(40),
    list18 character varying(40),
    list19 character varying(40),
    list20 character varying(40)
);


ALTER TABLE exp_tables.custflds OWNER TO postgres;

--
-- Name: custlaborrate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.custlaborrate (
    id character varying(36),
    name character varying(10),
    labor double precision NOT NULL,
    helper double precision NOT NULL,
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.custlaborrate OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.customer (
    custno character varying(7),
    lastname character varying(35),
    firstname character varying(20),
    add1 character varying(30),
    add2 character varying(30),
    city character varying(25),
    state character varying(2),
    zip character varying(10),
    phone1 character varying(21),
    phone2 character varying(21),
    creditrate character varying(7),
    terms character varying(31),
    pricecode character varying(1),
    discount double precision NOT NULL,
    latecharge double precision NOT NULL,
    custref character varying(15),
    statement integer NOT NULL,
    lastpaid timestamp without time zone,
    requirepo integer NOT NULL,
    acctkey character varying(42),
    post character varying(1),
    navcustgb character varying(15),
    navcusttax character varying(15),
    navcustcus character varying(15),
    rwdistcode character varying(6),
    phone3 character varying(21),
    phone4 character varying(21),
    lblphone1 character varying(12),
    lblphone2 character varying(12),
    lblphone3 character varying(12),
    lblphone4 character varying(12),
    sort character varying(6),
    listid character varying(20),
    defpriority character varying(6),
    salesperson character varying(4),
    customerinactive smallint NOT NULL,
    dateadded timestamp without time zone,
    datemodified timestamp without time zone,
    fullname character varying(65),
    website character varying(128),
    prospectreference character varying(7)
);


ALTER TABLE exp_tables.customer OWNER TO postgres;

--
-- Name: customercontacts; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.customercontacts (
    id integer NOT NULL,
    custno character varying(7),
    locnum character varying(5),
    name character varying(50),
    phone character varying(21),
    email character varying(50)
);


ALTER TABLE exp_tables.customercontacts OWNER TO postgres;

--
-- Name: customview; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.customview (
    viewid character varying(36),
    name character varying(50),
    columns text,
    filters text,
    "order" text,
    type integer NOT NULL,
    "default" smallint NOT NULL
);


ALTER TABLE exp_tables.customview OWNER TO postgres;

--
-- Name: custsort; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.custsort (
    custno character varying(7),
    locno character varying(5),
    counter character varying(2),
    sort character varying(3)
);


ALTER TABLE exp_tables.custsort OWNER TO postgres;

--
-- Name: depinfo; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.depinfo (
    date timestamp without time zone,
    deposit character varying(6),
    key character varying(1)
);


ALTER TABLE exp_tables.depinfo OWNER TO postgres;

--
-- Name: deprecn; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.deprecn (
    type character varying(1),
    assetclass character varying(4),
    assetnum character varying(4),
    "desc" character varying(30),
    dateaquire timestamp without time zone,
    bookcost double precision NOT NULL,
    salvvalue double precision NOT NULL,
    deprmethod character varying(2),
    recovermn double precision NOT NULL,
    datedisp timestamp without time zone,
    deprmon double precision NOT NULL,
    deprytd double precision NOT NULL,
    deprltd double precision NOT NULL,
    deprbkval double precision NOT NULL
);


ALTER TABLE exp_tables.deprecn OWNER TO postgres;

--
-- Name: dispatch; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispatch (
    custno character varying(7),
    locno character varying(5),
    billloc character varying(5),
    zone character varying(7),
    dispatch character varying(15),
    calledinby character varying(20),
    terms character varying(5),
    ponum character varying(20),
    recdate timestamp without time zone,
    rectime character varying(8),
    recby character varying(10),
    priority character varying(6),
    invoice character varying(10),
    complete timestamp without time zone,
    techtime double precision NOT NULL,
    multitech character varying(1),
    servagrnum character varying(7),
    servagrper character varying(2),
    taskno character varying(2),
    skill character varying(2),
    notes text,
    invoiced integer NOT NULL,
    jobnumber character varying(41),
    sort character varying(6),
    ahsdispatch smallint NOT NULL,
    quotesource character varying(10),
    servfreqflag smallint NOT NULL,
    servagrorderparts smallint NOT NULL,
    trigger_bool bit(1)
);


ALTER TABLE exp_tables.dispatch OWNER TO postgres;

--
-- Name: dispatch_trigger; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispatch_trigger (
    id integer NOT NULL,
    dispatch character varying(15),
    changedate timestamp without time zone
);


ALTER TABLE exp_tables.dispatch_trigger OWNER TO postgres;

--
-- Name: dispatchpriority; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispatchpriority (
    name character varying(6),
    color integer NOT NULL,
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.dispatchpriority OWNER TO postgres;

--
-- Name: dispatchtype; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispatchtype (
    name character varying(5),
    billable smallint NOT NULL,
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.dispatchtype OWNER TO postgres;

--
-- Name: dispcomp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispcomp (
    dispatch character varying(15),
    complaint character varying(7),
    "desc" character varying(30),
    "time" character varying(3),
    count character varying(1)
);


ALTER TABLE exp_tables.dispcomp OWNER TO postgres;

--
-- Name: displock; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.displock (
    dispatch character varying(15),
    "user" character varying(10)
);


ALTER TABLE exp_tables.displock OWNER TO postgres;

--
-- Name: dispparts; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispparts (
    dispatch character varying(15),
    counter integer NOT NULL,
    wh character varying(4),
    prod character varying(36),
    "desc" text,
    quan double precision NOT NULL,
    noprint smallint NOT NULL,
    price double precision NOT NULL,
    jobclass character varying(40),
    frprepair character varying(15),
    accepted smallint NOT NULL
);


ALTER TABLE exp_tables.dispparts OWNER TO postgres;

--
-- Name: dispscrn; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispscrn (
    screen character varying(8),
    tech1 character varying(4),
    left1 character varying(1),
    tech2 character varying(4),
    left2 character varying(1),
    tech3 character varying(4),
    left3 character varying(1),
    tech4 character varying(4),
    left4 character varying(1),
    tech5 character varying(4),
    left5 character varying(1),
    tech6 character varying(4),
    left6 character varying(1),
    tech7 character varying(4),
    left7 character varying(1),
    tech8 character varying(4),
    left8 character varying(1),
    tech9 character varying(4),
    left9 character varying(1),
    tech10 character varying(4),
    left10 character varying(1),
    tech11 character varying(4),
    left11 character varying(1),
    tech12 character varying(4),
    left12 character varying(1),
    tech13 character varying(4),
    left13 character varying(1),
    tech14 character varying(4),
    left14 character varying(1),
    tech15 character varying(4),
    left15 character varying(1),
    tech16 character varying(4),
    left16 character varying(1),
    tech17 character varying(4),
    left17 character varying(1),
    tech18 character varying(4),
    left18 character varying(1),
    tech19 character varying(4),
    left19 character varying(1),
    tech20 character varying(4),
    left20 character varying(1),
    master integer NOT NULL,
    zonebegin character varying(7),
    zoneend character varying(7),
    priorbegin character varying(6),
    priorend character varying(6),
    display double precision NOT NULL,
    datemode double precision NOT NULL,
    terms character varying(10),
    schedincrement integer NOT NULL,
    schedfrom character varying(8),
    schedto character varying(8),
    incrementsize integer NOT NULL,
    techs text
);


ALTER TABLE exp_tables.dispscrn OWNER TO postgres;

--
-- Name: disptech; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.disptech (
    dispatch character varying(15),
    serviceman character varying(4),
    counter character varying(3),
    status character varying(10),
    dispdate timestamp without time zone,
    disptime character varying(8),
    timeon character varying(8),
    timeoff character varying(8),
    dateoff timestamp without time zone,
    dispatcher character varying(10),
    complete character varying(1),
    promdate character varying(10),
    tpromdate timestamp without time zone,
    tpromtime character varying(8),
    zone character varying(7),
    priority character varying(6),
    terms character varying(5),
    techtime double precision NOT NULL,
    sortdate timestamp without time zone,
    sorttime character varying(8),
    mobile integer NOT NULL,
    poreceived smallint NOT NULL,
    timeentrycreated smallint NOT NULL,
    hourspayed double precision NOT NULL
);


ALTER TABLE exp_tables.disptech OWNER TO postgres;

--
-- Name: dispuser; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.dispuser (
    "user" character varying(10),
    key character varying(1),
    dispatcher character varying(10),
    board1 character varying(8),
    board2 character varying(8),
    board3 character varying(8),
    board4 character varying(8),
    screen character varying(8),
    posboardsplit integer NOT NULL,
    posbottomsplit integer NOT NULL,
    posmapsplit integer NOT NULL,
    boardstyle integer NOT NULL
);


ALTER TABLE exp_tables.dispuser OWNER TO postgres;

--
-- Name: docattach; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.docattach (
    id character varying(36),
    name character varying(255),
    extension character varying(50),
    dateadded timestamp without time zone,
    addedby character varying(50),
    source integer,
    sourcetext character varying(255),
    custno character varying(7),
    locno character varying(5),
    equipcounter character varying(8),
    agrmtno character varying(7),
    invoice character varying(10),
    dispatch character varying(15),
    document character varying,
    modified timestamp without time zone,
    compressed smallint,
    archived timestamp without time zone,
    empno character varying(4)
);


ALTER TABLE exp_tables.docattach OWNER TO postgres;

--
-- Name: docattachidx; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.docattachidx (
    id character varying(36),
    word character varying(15)
);


ALTER TABLE exp_tables.docattachidx OWNER TO postgres;

--
-- Name: docwptemplate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.docwptemplate (
    id character varying(36),
    name character varying(255),
    source integer NOT NULL,
    document bytea
);


ALTER TABLE exp_tables.docwptemplate OWNER TO postgres;

--
-- Name: edbupdate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.edbupdate (
    "user" character varying(10),
    gps smallint NOT NULL,
    message smallint NOT NULL,
    dispatch smallint NOT NULL
);


ALTER TABLE exp_tables.edbupdate OWNER TO postgres;

--
-- Name: emailinv; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.emailinv (
    counter integer NOT NULL,
    custno character varying(7),
    custname character varying(60),
    email character varying(1000),
    invoice character varying(10),
    datesent timestamp without time zone,
    timesent character varying(8),
    sentby character varying(10)
);


ALTER TABLE exp_tables.emailinv OWNER TO postgres;

--
-- Name: emailpo; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.emailpo (
    counter integer NOT NULL,
    vendor character varying(4),
    venname character varying(70),
    email character varying(1000),
    po character varying(20),
    datesent timestamp without time zone,
    timesent character varying(8),
    sentby character varying(10)
);


ALTER TABLE exp_tables.emailpo OWNER TO postgres;

--
-- Name: emailtpl; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.emailtpl (
    name character varying(50),
    "user" character varying(10),
    "from" character varying(255),
    cc character varying(255),
    bcc character varying(255),
    template bytea,
    subject character varying(105),
    source character varying(1),
    readreceipt smallint NOT NULL
);


ALTER TABLE exp_tables.emailtpl OWNER TO postgres;

--
-- Name: emailusr; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.emailusr (
    "user" character varying(10),
    source character varying(1),
    name character varying(50)
);


ALTER TABLE exp_tables.emailusr OWNER TO postgres;

--
-- Name: empcommcodes; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.empcommcodes (
    itemid character varying(36),
    name character varying(15),
    range1low integer NOT NULL,
    range1high integer NOT NULL,
    range1percent double precision NOT NULL,
    range2low integer NOT NULL,
    range2high integer NOT NULL,
    range2percent double precision NOT NULL,
    range3low integer NOT NULL,
    range3high integer NOT NULL,
    range3percent double precision NOT NULL,
    inactive smallint NOT NULL,
    calculatetype integer NOT NULL
);


ALTER TABLE exp_tables.empcommcodes OWNER TO postgres;

--
-- Name: employee; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.employee (
    empno character varying(4),
    empname character varying(25),
    skill character varying(3),
    unassign character varying(1),
    pagerno character varying(21),
    servicenum character varying(21),
    search character varying(3),
    lastname character varying(20),
    firstname character varying(20),
    socsecnum character varying(11),
    add1 character varying(30),
    add2 character varying(30),
    city character varying(25),
    state character varying(2),
    zip character varying(10),
    license character varying(20),
    rate double precision NOT NULL,
    overhead double precision NOT NULL,
    percent integer NOT NULL,
    phone character varying(21),
    fax character varying(21),
    branch character varying(15),
    dept character varying(2),
    email character varying(60),
    inactive smallint NOT NULL,
    routefrom integer NOT NULL,
    monstart character varying(8),
    monend character varying(8),
    tuestart character varying(8),
    tueend character varying(8),
    wedstart character varying(8),
    wedend character varying(8),
    thustart character varying(8),
    thuend character varying(8),
    fristart character varying(8),
    friend character varying(8),
    satstart character varying(8),
    satend character varying(8),
    sunstart character varying(8),
    sunend character varying(8),
    crew character varying(15),
    gpstechlink character varying(36),
    maritalstatus integer NOT NULL,
    payperiodtype integer NOT NULL,
    workcomp character varying(36),
    prddname character varying(22),
    prddactive smallint NOT NULL,
    defaultwageitem character varying(36),
    suffix character varying(5),
    middlename character varying(20),
    country character varying(20),
    cellphone character varying(21),
    altphone character varying(21),
    emergencycontact character varying(40),
    emergencyphones character varying(255),
    emergencycontactrelation character varying(20),
    employeenotes text,
    sex integer NOT NULL,
    ethnicgroup integer NOT NULL,
    title character varying(40),
    birthdate timestamp without time zone,
    employdate timestamp without time zone,
    terminationdate timestamp without time zone,
    terminationreason character varying(255),
    vacationallowed integer NOT NULL,
    photo bytea,
    shift character varying(20),
    acctkey character varying(42),
    listid character varying(20),
    commcodeid character varying(36),
    qbsalesrepname character varying(5),
    biography character varying(5000),
    latitude integer NOT NULL,
    longitude integer NOT NULL
);


ALTER TABLE exp_tables.employee OWNER TO postgres;

--
-- Name: employeepay; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.employeepay (
    empno character varying(4),
    payitemid character varying(36),
    rate double precision NOT NULL,
    allowances integer NOT NULL,
    additional double precision NOT NULL,
    limitperemp double precision NOT NULL,
    secallowances integer NOT NULL,
    paydeptid character varying(36),
    payjobid character varying(36)
);


ALTER TABLE exp_tables.employeepay OWNER TO postgres;

--
-- Name: employeeraise; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.employeeraise (
    empno character varying(4),
    listid character varying(36),
    raisedate timestamp without time zone,
    raiseamount double precision NOT NULL,
    nextreview timestamp without time zone,
    note character varying(255)
);


ALTER TABLE exp_tables.employeeraise OWNER TO postgres;

--
-- Name: equip; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.equip (
    custno character varying(7),
    locno character varying(5),
    counter character varying(8),
    mfg character varying(20),
    model character varying(30),
    serial character varying(36),
    install timestamp without time zone,
    warranty timestamp without time zone,
    seragrno character varying(7),
    equiploc character varying(10),
    notes text,
    sortcode character varying(3),
    source character varying(1),
    invoice character varying(10),
    code character varying(25),
    eqtype character varying(15),
    custom1 character varying(40),
    custom2 character varying(40),
    custom3 character varying(40),
    custom4 character varying(40),
    custom5 character varying(40),
    custom6 character varying(40),
    custom7 character varying(40),
    custom8 character varying(40),
    id character varying(15),
    master smallint NOT NULL
);


ALTER TABLE exp_tables.equip OWNER TO postgres;

--
-- Name: equipatt; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.equipatt (
    dispatch character varying(15),
    invoice character varying(10),
    count character varying(8)
);


ALTER TABLE exp_tables.equipatt OWNER TO postgres;

--
-- Name: equiploc; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.equiploc (
    location character varying(10)
);


ALTER TABLE exp_tables.equiploc OWNER TO postgres;

--
-- Name: equiptyp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.equiptyp (
    eqtype character varying(15)
);


ALTER TABLE exp_tables.equiptyp OWNER TO postgres;

--
-- Name: fincashflow; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.fincashflow (
    "group" integer NOT NULL,
    accountid character varying(36),
    "order" integer NOT NULL
);


ALTER TABLE exp_tables.fincashflow OWNER TO postgres;

--
-- Name: findept; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.findept (
    dept character varying(2),
    "desc" character varying(20)
);


ALTER TABLE exp_tables.findept OWNER TO postgres;

--
-- Name: findiv; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.findiv (
    div character varying(2),
    "desc" character varying(20)
);


ALTER TABLE exp_tables.findiv OWNER TO postgres;

--
-- Name: finfiscal; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.finfiscal (
    fiscalid character varying(36),
    counter integer NOT NULL,
    fiscalstart timestamp without time zone,
    name character varying(15)
);


ALTER TABLE exp_tables.finfiscal OWNER TO postgres;

--
-- Name: fingroup; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.fingroup (
    "group" character varying(4),
    "desc" character varying(20)
);


ALTER TABLE exp_tables.fingroup OWNER TO postgres;

--
-- Name: finledger; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.finledger (
    entryid character varying(36),
    transid character varying(36),
    trancount integer NOT NULL,
    accountid character varying(36),
    amount double precision NOT NULL,
    source integer NOT NULL,
    transdesc character varying(60),
    transmemo text,
    transdate timestamp without time zone,
    periodid character varying(6),
    active smallint NOT NULL,
    voided smallint NOT NULL,
    voiddesc character varying(36),
    modified timestamp without time zone,
    modifiedby character varying(10),
    addeddate timestamp without time zone,
    jobid character varying(36),
    deptid character varying(36),
    jobclassid character varying(36),
    itemid character varying(36),
    costtype integer NOT NULL,
    units double precision NOT NULL,
    trannumber integer NOT NULL,
    cleared integer NOT NULL,
    docnum character varying(36),
    accrualtype integer NOT NULL,
    accruallinkentryid character varying(36),
    accrualvendor character varying(4),
    duedate timestamp without time zone,
    discountdate timestamp without time zone,
    discountamount double precision NOT NULL,
    docaddress text,
    cleareddate timestamp without time zone,
    transtype integer NOT NULL,
    checktietype integer NOT NULL,
    checktiecustno character varying(7),
    checktieempno character varying(4),
    checktievendorno character varying(4),
    reference character varying(15),
    deliverydate timestamp without time zone,
    termid character varying(36),
    contact character varying(36),
    discounttaken double precision NOT NULL,
    billreceived smallint NOT NULL,
    payitemid character varying(36),
    payrate double precision NOT NULL,
    relatedtransid character varying(36),
    accrualpaidoff smallint NOT NULL,
    workcompid character varying(36),
    workcomprate double precision NOT NULL,
    payperiodending timestamp without time zone,
    taxableamount double precision NOT NULL,
    payweeks double precision NOT NULL,
    grosspay double precision NOT NULL,
    backloaded smallint NOT NULL,
    depositcheckno character varying(12),
    depositpaymethod character varying(10),
    salestransid character varying(36),
    receivablestransid character varying(36)
);


ALTER TABLE exp_tables.finledger OWNER TO postgres;

--
-- Name: finoverhead; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.finoverhead (
    accountid character varying(36),
    deptid character varying(36),
    percent integer NOT NULL
);


ALTER TABLE exp_tables.finoverhead OWNER TO postgres;

--
-- Name: finperiod; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.finperiod (
    periodid character varying(6),
    fiscalid character varying(36),
    counter integer NOT NULL,
    datebegin timestamp without time zone,
    dateend timestamp without time zone
);


ALTER TABLE exp_tables.finperiod OWNER TO postgres;

--
-- Name: forms; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.forms (
    formtype integer NOT NULL,
    formname character varying(30),
    invtype integer NOT NULL,
    memotext text,
    "default" integer NOT NULL,
    version integer NOT NULL,
    invdata bytea,
    priority integer NOT NULL,
    inactive smallint NOT NULL,
    packlist integer NOT NULL,
    dispatchpostinv smallint NOT NULL,
    batch character varying(20),
    totaldesc character varying(60),
    emailaddress character varying(255),
    contact character varying(120)
);


ALTER TABLE exp_tables.forms OWNER TO postgres;

--
-- Name: frp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.frp (
    part character varying(36),
    reptype character varying(15),
    material double precision NOT NULL,
    labor double precision NOT NULL,
    tax double precision NOT NULL,
    trip double precision NOT NULL,
    matladdr double precision NOT NULL,
    total double precision NOT NULL,
    count character varying(1)
);


ALTER TABLE exp_tables.frp OWNER TO postgres;

--
-- Name: histled; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.histled (
    custno character varying(7),
    locno character varying(5),
    invoice character varying(10),
    counter character varying(4),
    code character varying(36),
    "desc" text,
    epa double precision NOT NULL,
    reference character varying(36),
    date timestamp without time zone,
    source character varying(1),
    refrlbs double precision NOT NULL
);


ALTER TABLE exp_tables.histled OWNER TO postgres;

--
-- Name: history; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.history (
    custno character varying(7),
    locno character varying(5),
    dept character varying(2),
    invoice character varying(10),
    date timestamp without time zone,
    empno character varying(4),
    invoiceamt double precision NOT NULL,
    cost double precision NOT NULL,
    sort character varying(20),
    agrmtno character varying(7)
);


ALTER TABLE exp_tables.history OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.images (
    key character varying(1),
    complogo bytea
);


ALTER TABLE exp_tables.images OWNER TO postgres;

--
-- Name: imslog; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.imslog (
    entryid character varying(36),
    created timestamp without time zone,
    message text,
    returned text
);


ALTER TABLE exp_tables.imslog OWNER TO postgres;

--
-- Name: inmarkup; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.inmarkup (
    markup character varying(2),
    price character varying(1),
    range character varying(1),
    morethan double precision NOT NULL,
    lessthan double precision NOT NULL,
    cost double precision NOT NULL
);


ALTER TABLE exp_tables.inmarkup OWNER TO postgres;

--
-- Name: integrationlog; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.integrationlog (
    source integer NOT NULL,
    dateadded timestamp without time zone,
    errorcondition smallint NOT NULL,
    message character varying(256),
    transid character varying(36)
);


ALTER TABLE exp_tables.integrationlog OWNER TO postgres;

--
-- Name: invassem; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invassem (
    part character varying(36),
    count character varying(3),
    subpart character varying(36),
    quan double precision NOT NULL
);


ALTER TABLE exp_tables.invassem OWNER TO postgres;

--
-- Name: invcat; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invcat (
    cat character varying(36)
);


ALTER TABLE exp_tables.invcat OWNER TO postgres;

--
-- Name: inven; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.inven (
    part character varying(36),
    "desc" text,
    type character varying(1),
    cat character varying(36),
    subcat character varying(36),
    averagec double precision NOT NULL,
    bprice double precision NOT NULL,
    lastprice double precision NOT NULL,
    cunits character varying(2),
    buysellr double precision NOT NULL,
    markupcode character varying(2),
    pricea double precision NOT NULL,
    priceb double precision NOT NULL,
    pricec double precision NOT NULL,
    runits character varying(2),
    costdb character varying(10),
    costcr character varying(10),
    salesdb character varying(10),
    salescr character varying(10),
    bin character varying(10),
    pricebook character varying(4),
    parttype character varying(8),
    posthist integer NOT NULL,
    vendor character varying(4),
    salestype character varying(1),
    notes text,
    billrate double precision NOT NULL,
    nontaxable integer NOT NULL,
    epatype character varying(10),
    jobclass character varying(3),
    fr character varying(2),
    equippost integer NOT NULL,
    wamonths double precision NOT NULL,
    aisle character varying(4),
    histcode character varying(36),
    mfg character varying(20),
    model character varying(30),
    reorderqua double precision NOT NULL,
    reorderlev double precision NOT NULL,
    refrtype character varying(10),
    search1 character varying(5),
    search2 character varying(5),
    search3 character varying(5),
    search4 character varying(5),
    search5 character varying(5),
    navinvpost character varying(10),
    navdispost character varying(10),
    navgenpost character varying(10),
    navunits character varying(10),
    bcost double precision NOT NULL,
    overhead double precision NOT NULL,
    frplabor double precision NOT NULL,
    inactive integer NOT NULL,
    eqtype character varying(15),
    ismarkup smallint NOT NULL,
    itemid character varying(36),
    shortdesc character varying(50),
    spiffmethod integer NOT NULL,
    spiffvalue double precision NOT NULL,
    nocommission smallint NOT NULL
);


ALTER TABLE exp_tables.inven OWNER TO postgres;

--
-- Name: invenact; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invenact (
    period character varying(6),
    part character varying(36),
    partdesc text,
    wh character varying(4),
    date timestamp without time zone,
    "time" character varying(8),
    count character varying(3),
    serial character varying(36),
    lot character varying(20),
    type character varying(1),
    "desc" character varying(20),
    quan double precision NOT NULL,
    quanout double precision NOT NULL,
    vendor character varying(4),
    cost double precision NOT NULL,
    debit character varying(10),
    credit character varying(10),
    ponum character varying(20),
    finperiod character varying(6),
    source character varying(1),
    key character varying(15),
    rdate timestamp without time zone,
    rtime character varying(8),
    rcount character varying(3),
    recby character varying(4),
    reason character varying(20),
    job character varying(41),
    terms character varying(31)
);


ALTER TABLE exp_tables.invenact OWNER TO postgres;

--
-- Name: invenactsum; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invenactsum (
    part character varying(36),
    wh character varying(4),
    date timestamp without time zone,
    quan double precision
);


ALTER TABLE exp_tables.invenactsum OWNER TO postgres;

--
-- Name: invenmon; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invenmon (
    period character varying(6),
    part character varying(36),
    wh character varying(4),
    begin double precision NOT NULL,
    "in" double precision NOT NULL,
    "out" double precision NOT NULL
);


ALTER TABLE exp_tables.invenmon OWNER TO postgres;

--
-- Name: invquan; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invquan (
    part character varying(36),
    wh character varying(4),
    aisle character varying(10),
    bin character varying(10),
    minquan double precision NOT NULL,
    reorder double precision NOT NULL
);


ALTER TABLE exp_tables.invquan OWNER TO postgres;

--
-- Name: invrec; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invrec (
    key character varying(10),
    count character varying(3),
    part character varying(36),
    "desc" text,
    cost double precision NOT NULL,
    quan double precision NOT NULL,
    recdate timestamp without time zone,
    ponum character varying(20),
    vendor character varying(4),
    job character varying(41),
    wh character varying(4),
    serial character varying(36),
    debitacct character varying(10),
    jbclass character varying(40),
    posted character varying(1),
    dispatchno character varying(15)
);


ALTER TABLE exp_tables.invrec OWNER TO postgres;

--
-- Name: invscat; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invscat (
    cat character varying(36),
    subcat character varying(36),
    applymarkp character varying(12),
    markupcode character varying(2),
    pricebk character varying(4)
);


ALTER TABLE exp_tables.invscat OWNER TO postgres;

--
-- Name: invsetup; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invsetup (
    key character varying(1),
    costdb character varying(10),
    costcr character varying(10),
    purchcr character varying(10),
    pricebook character varying(4),
    vendor character varying(4),
    markupcode character varying(2),
    wh character varying(4),
    tripcharge double precision NOT NULL,
    laborhr double precision NOT NULL,
    addltrip integer NOT NULL,
    addlperc double precision NOT NULL,
    matlperc integer NOT NULL,
    matladder double precision NOT NULL,
    sadisctype character varying(1),
    sadiscperc double precision NOT NULL,
    round integer NOT NULL,
    accttype double precision NOT NULL,
    applydisc character varying(1),
    expricedec smallint NOT NULL,
    staxcode character varying(8),
    barcodeamt integer NOT NULL,
    autojobtrans smallint NOT NULL,
    invprintequip smallint NOT NULL,
    invflatratetax smallint NOT NULL,
    gstpsttax smallint NOT NULL
);


ALTER TABLE exp_tables.invsetup OWNER TO postgres;

--
-- Name: invsign; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.invsign (
    invoice character varying(10),
    signature text
);


ALTER TABLE exp_tables.invsign OWNER TO postgres;

--
-- Name: jobclass; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.jobclass (
    jobclassid character varying(36),
    name character varying(40),
    inactive smallint NOT NULL,
    defworkcompid character varying(36)
);


ALTER TABLE exp_tables.jobclass OWNER TO postgres;

--
-- Name: jobs; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.jobs (
    name character varying(41),
    custno character varying(7),
    supervisor character varying(4),
    start timestamp without time zone,
    projend timestamp without time zone,
    post character varying(1),
    jobid character varying(36),
    location character varying(5),
    jobstatus integer NOT NULL,
    actualend timestamp without time zone,
    jobnotes text,
    inactive smallint NOT NULL,
    jobsalesperson character varying(4),
    defaultdeptid character varying(36),
    certifiedjob smallint NOT NULL,
    jobtype integer NOT NULL
);


ALTER TABLE exp_tables.jobs OWNER TO postgres;

--
-- Name: labelcfg; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.labelcfg (
    name character varying(20),
    top double precision NOT NULL,
    "left" double precision NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    across double precision NOT NULL,
    down double precision NOT NULL,
    landscape smallint NOT NULL
);


ALTER TABLE exp_tables.labelcfg OWNER TO postgres;

--
-- Name: listviews; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.listviews (
    itemid character varying(36),
    "user" character varying(10),
    name character varying(30),
    viewtype integer NOT NULL,
    viewdata text,
    view character varying(40)
);


ALTER TABLE exp_tables.listviews OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.location (
    custno character varying(7),
    locno character varying(5),
    add1 character varying(30),
    add2 character varying(30),
    city character varying(25),
    state character varying(2),
    zip character varying(10),
    phone1 character varying(21),
    phone2 character varying(21),
    fax character varying(12),
    notes text,
    taxcode character varying(8),
    laborrate double precision NOT NULL,
    helperrate double precision NOT NULL,
    zone character varying(7),
    contact character varying(40),
    extension character varying(4),
    salutation character varying(40),
    branch character varying(15),
    street character varying(20),
    tripcharge double precision NOT NULL,
    taxfrp integer NOT NULL,
    email character varying(1000),
    salesref character varying(15),
    streetnum character varying(20),
    phone3 character varying(21),
    phone4 character varying(21),
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    custom1 character varying(40),
    custom2 character varying(40),
    custom3 character varying(40),
    custom4 character varying(40),
    custom5 character varying(40),
    custom6 character varying(40),
    custom7 character varying(40),
    custom8 character varying(40),
    custom9 character varying(40),
    custom10 character varying(40),
    custom11 character varying(40),
    custom12 character varying(40),
    custom13 character varying(40),
    custom14 character varying(40),
    custom15 character varying(40),
    custom16 character varying(40),
    locname character varying(60),
    password character varying(150),
    laborid character varying(36),
    disableemails smallint NOT NULL,
    geofenceupdated smallint NOT NULL,
    phone5 character varying(21),
    phone6 character varying(21),
    contact2 character varying(40),
    contact3 character varying(40),
    contact4 character varying(40),
    contact5 character varying(40),
    contact6 character varying(40),
    email2 character varying(80),
    email3 character varying(80),
    email4 character varying(80),
    email5 character varying(80),
    email6 character varying(80),
    extension2 character varying(4),
    extension3 character varying(4),
    extension4 character varying(4),
    extension5 character varying(4),
    extension6 character varying(4),
    salutation2 character varying(40),
    salutation3 character varying(40),
    salutation4 character varying(40),
    salutation5 character varying(40),
    salutation6 character varying(40),
    jobtitle1 character varying(30),
    jobtitle2 character varying(30),
    jobtitle3 character varying(30),
    jobtitle4 character varying(30),
    jobtitle5 character varying(30),
    jobtitle6 character varying(30),
    locationinactive smallint NOT NULL,
    emailtasks1 integer NOT NULL,
    emailtasks2 integer NOT NULL,
    emailtasks3 integer NOT NULL,
    emailtasks4 integer NOT NULL,
    emailtasks5 integer NOT NULL,
    emailtasks6 integer NOT NULL,
    receivesnotifications smallint NOT NULL,
    trigger_bool bit(1)
);


ALTER TABLE exp_tables.location OWNER TO postgres;

--
-- Name: location_trigger; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.location_trigger (
    id integer NOT NULL,
    custno character varying(7),
    locno character varying(5),
    changedate timestamp without time zone
);


ALTER TABLE exp_tables.location_trigger OWNER TO postgres;

--
-- Name: manufact; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.manufact (
    mfg character varying(20)
);


ALTER TABLE exp_tables.manufact OWNER TO postgres;

--
-- Name: memorizetrans; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.memorizetrans (
    transid character varying(36),
    name character varying(60),
    inactive smallint NOT NULL,
    scheduled smallint NOT NULL,
    transtype integer NOT NULL,
    document text,
    recurtype integer NOT NULL,
    recurstartdate timestamp without time zone,
    recursubtype integer NOT NULL,
    recurinterval integer NOT NULL,
    recurdayofmonth integer NOT NULL,
    recurdayofweek character varying(15),
    recurmonthofyear character varying(15),
    recurdayinmonth character varying(15),
    recurmon smallint NOT NULL,
    recurtue smallint NOT NULL,
    recurwed smallint NOT NULL,
    recurthu smallint NOT NULL,
    recurfri smallint NOT NULL,
    recursat smallint NOT NULL,
    recursun smallint NOT NULL,
    recurnextdate timestamp without time zone,
    recurrangetype integer NOT NULL,
    recuroriginalbalance double precision NOT NULL,
    recuroccurances integer NOT NULL,
    recurenddate timestamp without time zone,
    recursourceid character varying(36),
    recurbalance double precision NOT NULL,
    recurjan smallint NOT NULL,
    recurfeb smallint NOT NULL,
    recurmar smallint NOT NULL,
    recurapr smallint NOT NULL,
    recurmay smallint NOT NULL,
    recurjun smallint NOT NULL,
    recurjul smallint NOT NULL,
    recuraug smallint NOT NULL,
    recursep smallint NOT NULL,
    recuroct smallint NOT NULL,
    recurnov smallint NOT NULL,
    recurdec smallint NOT NULL
);


ALTER TABLE exp_tables.memorizetrans OWNER TO postgres;

--
-- Name: mobhist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobhist (
    tech character varying(4),
    capdate timestamp without time zone,
    captime character varying(8),
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    status character varying(3),
    course double precision NOT NULL,
    speed double precision NOT NULL,
    location character varying(80),
    idletime integer NOT NULL
);


ALTER TABLE exp_tables.mobhist OWNER TO postgres;

--
-- Name: mobinv; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobinv (
    dispatch character varying(15),
    counter double precision NOT NULL,
    part character varying(36),
    "desc" text,
    repair character varying(15),
    price double precision NOT NULL,
    quan double precision NOT NULL,
    amount double precision NOT NULL,
    serial character varying(36),
    tax1 double precision NOT NULL,
    tax2 double precision NOT NULL,
    tax3 double precision NOT NULL,
    tax4 double precision NOT NULL,
    invtype character varying(1),
    frplab double precision NOT NULL,
    frpmat double precision NOT NULL,
    frpother double precision NOT NULL,
    notes text,
    wh character varying(4),
    tech character varying(4),
    promdate timestamp without time zone,
    promtime character varying(8),
    taxed smallint NOT NULL,
    tax5 double precision NOT NULL,
    tax6 double precision NOT NULL,
    quote smallint NOT NULL,
    noprint smallint NOT NULL,
    formname character varying(30),
    jobclass character varying(40),
    listid character varying(36),
    authorizeid character varying(36),
    acceptanceid character varying(36)
);


ALTER TABLE exp_tables.mobinv OWNER TO postgres;

--
-- Name: mobmsgque; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobmsgque (
    id character varying(32),
    date timestamp without time zone,
    "time" character varying(8),
    handled smallint NOT NULL,
    direction integer NOT NULL,
    msgtype integer NOT NULL,
    msg text,
    techid character varying(4),
    msgread smallint NOT NULL
);


ALTER TABLE exp_tables.mobmsgque OWNER TO postgres;

--
-- Name: mobpay; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobpay (
    dispatch character varying(15),
    cash double precision NOT NULL,
    "check" double precision NOT NULL,
    checknum character varying(12),
    checkdate timestamp without time zone,
    creditcard double precision NOT NULL,
    cardtype character varying(15),
    cardnum character varying(100),
    cardmo character varying(2),
    cardyr character varying(2),
    auth character varying(15),
    name character varying(30),
    transid character varying(36),
    listid character varying(36)
);


ALTER TABLE exp_tables.mobpay OWNER TO postgres;

--
-- Name: mobposition; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobposition (
    tech character varying(4),
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    captureddate timestamp without time zone,
    course double precision NOT NULL,
    speed double precision NOT NULL
);


ALTER TABLE exp_tables.mobposition OWNER TO postgres;

--
-- Name: mobprop; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobprop (
    compstatus character varying(10),
    maxcalls double precision NOT NULL,
    invtype double precision NOT NULL,
    copies double precision NOT NULL,
    frtax double precision NOT NULL,
    topoffset double precision NOT NULL,
    leftoffset double precision NOT NULL,
    checkpay character varying(10),
    cashpay character varying(10),
    ccpay character varying(10),
    mcpay character varying(10),
    visapay character varying(10),
    discpay character varying(10),
    amexpay character varying(10),
    histnmbr double precision NOT NULL,
    dayadv integer NOT NULL,
    newdisp smallint NOT NULL,
    newcust smallint NOT NULL,
    port character varying(4),
    custfld1 integer NOT NULL,
    custfld2 integer NOT NULL,
    custfld3 integer NOT NULL,
    custfld4 integer NOT NULL,
    custfld5 integer NOT NULL,
    custfld6 integer NOT NULL,
    custfld7 integer NOT NULL,
    custfld8 integer NOT NULL,
    custfld9 integer NOT NULL,
    custfld10 integer NOT NULL,
    equipfld1 integer NOT NULL,
    equipfld2 integer NOT NULL,
    equipfld3 integer NOT NULL,
    equipfld4 integer NOT NULL,
    equipfld5 integer NOT NULL,
    equipfld6 integer NOT NULL,
    equipfld7 integer NOT NULL,
    equipfld8 integer NOT NULL,
    equipfld9 integer NOT NULL,
    equipfld10 integer NOT NULL,
    safld1 integer NOT NULL,
    safld2 integer NOT NULL,
    safld3 integer NOT NULL,
    safld4 integer NOT NULL,
    safld5 integer NOT NULL,
    safld6 integer NOT NULL,
    safld7 integer NOT NULL,
    safld8 integer NOT NULL,
    safld9 integer NOT NULL,
    safld10 integer NOT NULL,
    histfld1 integer NOT NULL,
    histfld2 integer NOT NULL,
    histfld3 integer NOT NULL,
    histfld4 integer NOT NULL,
    histfld5 integer NOT NULL,
    histfld6 integer NOT NULL,
    histfld7 integer NOT NULL,
    histfld8 integer NOT NULL,
    histfld9 integer NOT NULL,
    histfld10 integer NOT NULL,
    msgsubj1 character varying(22),
    msgsubj2 character varying(22),
    msgsubj3 character varying(22),
    msgsubj4 character varying(22),
    msgsubj5 character varying(22),
    msgsubj6 character varying(22),
    msgsubj7 character varying(22),
    msgsubj8 character varying(22),
    msgsubj9 character varying(22),
    msgsubj10 character varying(22),
    msgbody1 character varying(154),
    msgbody2 character varying(154),
    msgbody3 character varying(154),
    msgbody4 character varying(154),
    msgbody5 character varying(154),
    msgbody6 character varying(154),
    msgbody7 character varying(154),
    msgbody8 character varying(154),
    msgbody9 character varying(154),
    msgbody10 character varying(154),
    gpsinterval integer NOT NULL,
    equipsend integer NOT NULL,
    mappointserverip character varying(60),
    mappointserverport integer NOT NULL,
    updateflags text,
    editstatustime smallint NOT NULL
);


ALTER TABLE exp_tables.mobprop OWNER TO postgres;

--
-- Name: mobreport; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobreport (
    tech character varying(4),
    capdate timestamp without time zone,
    captime character varying(8),
    latitude integer NOT NULL,
    longitude integer NOT NULL,
    gpsstatus character varying(3),
    course double precision NOT NULL,
    speed double precision NOT NULL,
    location character varying(80),
    dispatch character varying(15),
    status character varying(25),
    idletime integer NOT NULL,
    distance double precision NOT NULL
);


ALTER TABLE exp_tables.mobreport OWNER TO postgres;

--
-- Name: mobtech; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobtech (
    tech character varying(4),
    books text
);


ALTER TABLE exp_tables.mobtech OWNER TO postgres;

--
-- Name: mobupdate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mobupdate (
    deviceid character varying(4),
    updfields smallint NOT NULL,
    updmsg smallint NOT NULL,
    updmaster smallint NOT NULL
);


ALTER TABLE exp_tables.mobupdate OWNER TO postgres;

--
-- Name: mtequipmnt; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mtequipmnt (
    equipmntid character varying(15),
    groupid character varying(5),
    year character varying(4),
    make character varying(10),
    model character varying(8),
    edescription character varying(60),
    platenum character varying(10),
    plateexp timestamp without time zone,
    vin character varying(20),
    purchdate timestamp without time zone,
    purchprice double precision NOT NULL,
    technician character varying(4),
    primaryuse character varying(15),
    odometer double precision NOT NULL,
    currodometer double precision NOT NULL,
    hours integer NOT NULL,
    elasthour integer NOT NULL,
    lastupdt timestamp without time zone
);


ALTER TABLE exp_tables.mtequipmnt OWNER TO postgres;

--
-- Name: mtevents; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mtevents (
    equipmntid character varying(15),
    expenscode character varying(15),
    dateenterd timestamp without time zone,
    description character varying(60),
    daysbet integer NOT NULL,
    notice integer NOT NULL,
    lastodomtr double precision NOT NULL,
    nextodomtr double precision NOT NULL,
    hoursbetwn integer NOT NULL,
    lasthour integer NOT NULL,
    currhour integer NOT NULL,
    vendor character varying(4),
    lastdate timestamp without time zone,
    nextdate timestamp without time zone,
    milesbetwn integer NOT NULL,
    notes text,
    option character varying(1),
    unitcost double precision NOT NULL
);


ALTER TABLE exp_tables.mtevents OWNER TO postgres;

--
-- Name: mtexpnscod; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mtexpnscod (
    expenscode character varying(15),
    description character varying(60),
    unitcost double precision NOT NULL,
    miles integer NOT NULL,
    hours integer NOT NULL,
    days integer NOT NULL,
    notice integer NOT NULL,
    option character varying(1)
);


ALTER TABLE exp_tables.mtexpnscod OWNER TO postgres;

--
-- Name: mtgroups; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mtgroups (
    groupid character varying(5)
);


ALTER TABLE exp_tables.mtgroups OWNER TO postgres;

--
-- Name: mttasks; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.mttasks (
    tcounter character varying(15),
    tequipmntid character varying(15),
    texpenscode character varying(15),
    tdateposted timestamp without time zone,
    tdateenterd timestamp without time zone,
    tdescriptn character varying(60),
    lastodo double precision NOT NULL,
    todometer double precision NOT NULL,
    tunitcost double precision NOT NULL,
    tquantity double precision NOT NULL,
    ttotalcost double precision NOT NULL,
    tvendor character varying(4),
    thours integer NOT NULL,
    tamountpad double precision NOT NULL,
    tnotes text
);


ALTER TABLE exp_tables.mttasks OWNER TO postgres;

--
-- Name: pagehist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.pagehist (
    serial character varying(11),
    date timestamp without time zone,
    "time" character varying(8),
    tech character varying(4),
    pagerno character varying(12),
    servicenum character varying(12),
    message text,
    return character varying(25)
);


ALTER TABLE exp_tables.pagehist OWNER TO postgres;

--
-- Name: pagelib; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.pagelib (
    message character varying(100)
);


ALTER TABLE exp_tables.pagelib OWNER TO postgres;

--
-- Name: pagemsg; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.pagemsg (
    index character varying(2),
    fldname character varying(25),
    maxchars double precision NOT NULL
);


ALTER TABLE exp_tables.pagemsg OWNER TO postgres;

--
-- Name: paymethd; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.paymethd (
    paymethod character varying(10),
    account character varying(10),
    type character varying(1),
    "desc" character varying(50),
    paymethodinactive smallint NOT NULL
);


ALTER TABLE exp_tables.paymethd OWNER TO postgres;

--
-- Name: peachtreetime; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.peachtreetime (
    key character varying(1),
    nextticketid integer NOT NULL,
    hourly1 character varying(20),
    hourly2 character varying(20),
    hourly3 character varying(20),
    hourly4 character varying(20),
    hourly5 character varying(20),
    hourly6 character varying(20),
    hourly7 character varying(20),
    hourly8 character varying(20),
    hourly9 character varying(20),
    hourly10 character varying(20),
    hourly11 character varying(20),
    hourly12 character varying(20),
    hourly13 character varying(20),
    hourly14 character varying(20),
    hourly15 character varying(20),
    hourly16 character varying(20),
    hourly17 character varying(20),
    hourly18 character varying(20),
    hourly19 character varying(20),
    hourly20 character varying(20),
    salary1 character varying(20),
    salary2 character varying(20),
    salary3 character varying(20),
    salary4 character varying(20),
    salary5 character varying(20),
    salary6 character varying(20),
    salary7 character varying(20),
    salary8 character varying(20),
    salary9 character varying(20),
    salary10 character varying(20),
    salary11 character varying(20),
    salary12 character varying(20),
    salary13 character varying(20),
    salary14 character varying(20),
    salary15 character varying(20),
    salary16 character varying(20),
    salary17 character varying(20),
    salary18 character varying(20),
    salary19 character varying(20),
    salary20 character varying(20)
);


ALTER TABLE exp_tables.peachtreetime OWNER TO postgres;

--
-- Name: persist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.persist (
    userid character varying(10),
    formid character varying(20),
    date timestamp without time zone,
    memodata text
);


ALTER TABLE exp_tables.persist OWNER TO postgres;

--
-- Name: po; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.po (
    po character varying(20),
    date timestamp without time zone,
    vendor character varying(4),
    custno character varying(7),
    locno character varying(5),
    dispatch character varying(15),
    shipname character varying(60),
    shipaddr1 character varying(50),
    shipaddr2 character varying(50),
    shipaddr3 character varying(50),
    memo text,
    datereq timestamp without time zone,
    buyer character varying(4),
    terms character varying(31),
    shipvia character varying(10),
    confirmto character varying(15),
    status character varying(1),
    billed smallint NOT NULL,
    transtype integer NOT NULL,
    orderplaced smallint NOT NULL,
    vendorlocid character varying(36),
    periodid character varying(6)
);


ALTER TABLE exp_tables.po OWNER TO postgres;

--
-- Name: poled; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.poled (
    po character varying(20),
    counter character varying(3),
    part character varying(36),
    "desc" text,
    quan double precision NOT NULL,
    price double precision NOT NULL,
    amount double precision NOT NULL,
    received double precision NOT NULL,
    job character varying(41),
    jobid character varying(36),
    deptid character varying(36),
    jobclassid character varying(36),
    itemid character varying(36),
    costtype integer NOT NULL,
    accountid character varying(36),
    entrytype integer NOT NULL,
    cleared smallint NOT NULL,
    dispatchno character varying(15),
    jobclassext character varying(40),
    invoicetransid character varying(36)
);


ALTER TABLE exp_tables.poled OWNER TO postgres;

--
-- Name: poledsum; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.poledsum (
    part character varying(36),
    date timestamp without time zone,
    quan double precision
);


ALTER TABLE exp_tables.poledsum OWNER TO postgres;

--
-- Name: postockorder; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.postockorder (
    part character varying(36),
    date timestamp without time zone,
    quan double precision
);


ALTER TABLE exp_tables.postockorder OWNER TO postgres;

--
-- Name: prdirectdeposit; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prdirectdeposit (
    empno character varying(4),
    entryindex integer NOT NULL,
    inactive smallint NOT NULL,
    bankaccounttype integer NOT NULL,
    routingno character varying(9),
    bankaccountno character varying(17),
    distribvalue double precision NOT NULL,
    recordtype integer NOT NULL
);


ALTER TABLE exp_tables.prdirectdeposit OWNER TO postgres;

--
-- Name: pricebk; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.pricebk (
    bk character varying(4),
    bkdesc character varying(25)
);


ALTER TABLE exp_tables.pricebk OWNER TO postgres;

--
-- Name: prospect; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prospect (
    custno character varying(7),
    leadstatus integer NOT NULL,
    referredby character varying(60),
    createdby character varying(60),
    lastmodifiedby character varying(60),
    ratingid character varying(36),
    exported smallint NOT NULL,
    dateconverted timestamp without time zone
);


ALTER TABLE exp_tables.prospect OWNER TO postgres;

--
-- Name: prpayitem; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prpayitem (
    itemid character varying(36),
    name character varying(36),
    itemtype integer NOT NULL,
    paytype integer NOT NULL,
    paytypesub integer NOT NULL,
    inactive smallint NOT NULL,
    reportingtype integer NOT NULL,
    adddeducttype integer NOT NULL,
    taxbase integer NOT NULL,
    taxmethod integer NOT NULL,
    formulaname character varying(100),
    formula text,
    vendorid character varying(36),
    accountid character varying(36),
    taxpercent double precision NOT NULL,
    "limit" double precision NOT NULL,
    limittype integer NOT NULL,
    companypaid smallint NOT NULL,
    companyexpenseaccount character varying(36),
    taxformname character varying(5),
    stateidnumber character varying(36),
    processorder integer NOT NULL,
    thirdpartysickpay smallint NOT NULL
);


ALTER TABLE exp_tables.prpayitem OWNER TO postgres;

--
-- Name: prpayitemapply; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prpayitemapply (
    itemid character varying(36),
    applyitemid character varying(36)
);


ALTER TABLE exp_tables.prpayitemapply OWNER TO postgres;

--
-- Name: prtimeentry; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prtimeentry (
    id character varying(36),
    timesheetid character varying(36),
    empno character varying(4),
    date timestamp without time zone,
    hours double precision NOT NULL,
    payitemid character varying(36),
    dispatch character varying(15),
    jobid character varying(36),
    jobclassid character varying(36),
    deptid character varying(36),
    itemid character varying(36),
    "desc" text,
    billable smallint NOT NULL,
    invoiced smallint NOT NULL,
    timesheetorder integer NOT NULL,
    processed smallint NOT NULL,
    ledgertransid character varying(36),
    workcompid character varying(36),
    rateoverride double precision NOT NULL,
    ledgerentryid character varying(36)
);


ALTER TABLE exp_tables.prtimeentry OWNER TO postgres;

--
-- Name: prtimesheet; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prtimesheet (
    timesheetid character varying(36),
    date timestamp without time zone
);


ALTER TABLE exp_tables.prtimesheet OWNER TO postgres;

--
-- Name: prtimesheetded; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prtimesheetded (
    timesheetid character varying(36),
    payitemid character varying(36),
    lineid integer NOT NULL,
    rate double precision NOT NULL,
    paydeptid character varying(36),
    payjobid character varying(36)
);


ALTER TABLE exp_tables.prtimesheetded OWNER TO postgres;

--
-- Name: prworkcomp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.prworkcomp (
    id character varying(36),
    code character varying(8),
    "desc" character varying(60),
    rate double precision NOT NULL,
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.prworkcomp OWNER TO postgres;

--
-- Name: purgemon; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.purgemon (
    module character varying(10),
    months double precision NOT NULL
);


ALTER TABLE exp_tables.purgemon OWNER TO postgres;

--
-- Name: ratinglist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.ratinglist (
    listid character varying(36),
    value character varying(60)
);


ALTER TABLE exp_tables.ratinglist OWNER TO postgres;

--
-- Name: reasonlostlist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.reasonlostlist (
    listid character varying(36),
    value character varying(60),
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.reasonlostlist OWNER TO postgres;

--
-- Name: recage; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.recage (
    custno character varying(7),
    invoice character varying(10),
    invdate timestamp without time zone,
    invamt double precision NOT NULL,
    dept character varying(2),
    locno character varying(5),
    jobnumber character varying(41),
    agrmtno character varying(7),
    invtype character varying(1),
    invperiod character varying(6),
    lastpaid timestamp without time zone,
    source character varying(1),
    counter character varying(5),
    amount double precision NOT NULL,
    ckno character varying(12),
    ckdate timestamp without time zone,
    depno character varying(10),
    payperiod character varying(6),
    debit character varying(10),
    credit character varying(10),
    paytype character varying(1),
    entrydate timestamp without time zone,
    paymethod character varying(10),
    paidoff timestamp without time zone,
    "user" character varying(10)
);


ALTER TABLE exp_tables.recage OWNER TO postgres;

--
-- Name: recdel; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.recdel (
    custno character varying(7),
    invoice character varying(10),
    source character varying(1),
    counter character varying(5),
    amount double precision NOT NULL,
    ckno character varying(12),
    ckdate timestamp without time zone,
    depno character varying(6),
    period character varying(6),
    debit character varying(10),
    credit character varying(10),
    type character varying(1),
    notes text,
    crserial character varying(5),
    entrydate timestamp without time zone,
    post character varying(1)
);


ALTER TABLE exp_tables.recdel OWNER TO postgres;

--
-- Name: recdtbl; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.recdtbl (
    code character varying(2),
    recby character varying(7)
);


ALTER TABLE exp_tables.recdtbl OWNER TO postgres;

--
-- Name: receivab; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.receivab (
    custno character varying(7),
    invoice character varying(10),
    invdate timestamp without time zone,
    invamt double precision NOT NULL,
    dept character varying(2),
    locno character varying(5),
    jobnumber character varying(41),
    agrmtno character varying(7),
    paid double precision NOT NULL,
    type character varying(1),
    notes text,
    acct character varying(10),
    latecredit character varying(10),
    period character varying(6),
    paidoff timestamp without time zone,
    lastpaid timestamp without time zone,
    post character varying(1),
    prepaykey character varying(20),
    transid character varying(36)
);


ALTER TABLE exp_tables.receivab OWNER TO postgres;

--
-- Name: recled; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.recled (
    custno character varying(7),
    invoice character varying(10),
    source character varying(1),
    counter character varying(5),
    amount double precision NOT NULL,
    ckno character varying(12),
    ckdate timestamp without time zone,
    depno character varying(10),
    period character varying(6),
    debit character varying(10),
    credit character varying(10),
    type character varying(1),
    notes text,
    crserial character varying(5),
    entrydate timestamp without time zone,
    post character varying(1),
    paymethod character varying(10),
    entryid character varying(36),
    depositdate timestamp without time zone,
    appliedfromid character varying(36),
    qbcredittxnid character varying(36),
    paymentid character varying(36)
);


ALTER TABLE exp_tables.recled OWNER TO postgres;

--
-- Name: reportview; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.reportview (
    reportid character varying(36),
    viewid character varying(36),
    name character varying(60),
    reporttitle character varying(60),
    systemview smallint NOT NULL,
    orderby character varying(255),
    descending smallint NOT NULL,
    privateview smallint NOT NULL,
    username character varying(20),
    onlyicanmodify smallint NOT NULL,
    isdefault smallint NOT NULL
);


ALTER TABLE exp_tables.reportview OWNER TO postgres;

--
-- Name: reportviewcustomfield; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.reportviewcustomfield (
    reportid character varying(36),
    viewid character varying(36),
    fieldindex integer NOT NULL,
    fieldname character varying(40),
    "group" smallint NOT NULL,
    width double precision NOT NULL,
    sortdirection integer NOT NULL,
    groupaggregate integer NOT NULL,
    datatype integer NOT NULL
);


ALTER TABLE exp_tables.reportviewcustomfield OWNER TO postgres;

--
-- Name: reportviewfilter; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.reportviewfilter (
    reportid character varying(36),
    viewid character varying(36),
    filterid character varying(36),
    filterindex integer NOT NULL,
    fieldname character varying(40),
    caption character varying(40),
    filterlbound character varying(60),
    filterubound character varying(60),
    filterdatemacro integer NOT NULL,
    fieldtype integer NOT NULL,
    isrange smallint NOT NULL,
    isrequired smallint NOT NULL,
    datatype integer NOT NULL,
    filterperiodmacro integer NOT NULL
);


ALTER TABLE exp_tables.reportviewfilter OWNER TO postgres;

--
-- Name: rptfilter; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.rptfilter (
    reportname character varying(50),
    filters text
);


ALTER TABLE exp_tables.rptfilter OWNER TO postgres;

--
-- Name: rptlist; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.rptlist (
    counter integer NOT NULL,
    "group" character varying(60),
    item character varying(60)
);


ALTER TABLE exp_tables.rptlist OWNER TO postgres;

--
-- Name: sainvcod; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sainvcod (
    code character varying(10),
    "desc" character varying(40),
    jan double precision NOT NULL,
    feb double precision NOT NULL,
    mar double precision NOT NULL,
    apr double precision NOT NULL,
    may double precision NOT NULL,
    jun double precision NOT NULL,
    jul double precision NOT NULL,
    aug double precision NOT NULL,
    sep double precision NOT NULL,
    oct double precision NOT NULL,
    nov double precision NOT NULL,
    "dec" double precision NOT NULL,
    notes text,
    agrpost integer NOT NULL,
    agramount double precision NOT NULL,
    onhold double precision NOT NULL
);


ALTER TABLE exp_tables.sainvcod OWNER TO postgres;

--
-- Name: sales; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sales (
    invoice character varying(10),
    regid character varying(2),
    clerk character varying(4),
    dispatch character varying(15),
    custno character varying(7),
    locno character varying(5),
    pricecode character varying(1),
    dept character varying(2),
    invdate timestamp without time zone,
    entdate timestamp without time zone,
    period character varying(6),
    billloc character varying(5),
    shipname character varying(55),
    shipaddr1 character varying(30),
    shipaddr2 character varying(30),
    shipcsz character varying(40),
    invtype character varying(21),
    agrmtno character varying(7),
    salesman character varying(4),
    wh character varying(4),
    jobnumber character varying(41),
    jobclass character varying(3),
    ponum character varying(20),
    sort character varying(6),
    hold integer NOT NULL,
    taxcode character varying(8),
    laborcost double precision NOT NULL,
    printed integer NOT NULL,
    amtcash double precision NOT NULL,
    amtcharge double precision NOT NULL,
    amtcheck double precision NOT NULL,
    amtcreditc double precision NOT NULL,
    amtchng double precision NOT NULL,
    post character varying(1),
    exempt double precision NOT NULL,
    formname character varying(30),
    txnid text,
    invamount double precision NOT NULL,
    quoteorg character varying(10),
    billcompl smallint NOT NULL,
    billamount double precision NOT NULL,
    matcost double precision NOT NULL,
    othercost double precision NOT NULL,
    slterms character varying(31),
    duedate timestamp without time zone,
    dispnotes smallint NOT NULL,
    dispparts smallint NOT NULL,
    transid character varying(36),
    modified timestamp without time zone,
    araccountid character varying(36),
    drawrequestno integer NOT NULL,
    readonly smallint NOT NULL,
    quotestatus integer NOT NULL,
    rejectedreason text,
    ptdateexported timestamp without time zone,
    amtappliedcredits double precision NOT NULL,
    reasonlostid character varying(36),
    authorizeid character varying(36),
    acceptanceid character varying(36),
    taxrate1 double precision NOT NULL,
    taxrate2 double precision NOT NULL,
    taxrate3 double precision NOT NULL,
    taxrate4 double precision NOT NULL,
    taxrate5 double precision NOT NULL,
    taxrate6 double precision NOT NULL
);


ALTER TABLE exp_tables.sales OWNER TO postgres;

--
-- Name: salesemp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.salesemp (
    invoice character varying(10),
    count character varying(3),
    credit double precision NOT NULL,
    emp character varying(4),
    reghr double precision NOT NULL,
    othr double precision NOT NULL,
    labamt double precision NOT NULL,
    overhead double precision NOT NULL,
    dispatch character varying(15)
);


ALTER TABLE exp_tables.salesemp OWNER TO postgres;

--
-- Name: salesfrp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.salesfrp (
    invoice character varying(10),
    count character varying(3),
    labor double precision NOT NULL,
    mat double precision NOT NULL,
    other double precision NOT NULL,
    frprepair character varying(15)
);


ALTER TABLE exp_tables.salesfrp OWNER TO postgres;

--
-- Name: salesled; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.salesled (
    invoice character varying(10),
    count character varying(3),
    prod character varying(36),
    firstline integer NOT NULL,
    "desc" text,
    quan double precision NOT NULL,
    price double precision NOT NULL,
    amount double precision NOT NULL,
    wh character varying(4),
    ptype character varying(1),
    jbclass character varying(40),
    serial character varying(36),
    sdebit character varying(10),
    scredit character varying(10),
    cost double precision NOT NULL,
    cdebit character varying(10),
    ccredit character varying(10),
    tax1 double precision NOT NULL,
    tax2 double precision NOT NULL,
    tax3 double precision NOT NULL,
    tax4 double precision NOT NULL,
    epa double precision NOT NULL,
    miscnum double precision NOT NULL,
    warranty timestamp without time zone,
    refrlbs double precision NOT NULL,
    noprint integer NOT NULL,
    taxed smallint NOT NULL,
    costed smallint NOT NULL,
    eqcounter character varying(8),
    entryid character varying(36),
    tax5 double precision NOT NULL,
    tax6 double precision NOT NULL,
    assemblyid character varying(36),
    assemblyquan double precision NOT NULL,
    markupvalue double precision NOT NULL,
    spiff double precision NOT NULL,
    accepted smallint NOT NULL,
    quotecosttype integer NOT NULL
);


ALTER TABLE exp_tables.salesled OWNER TO postgres;

--
-- Name: salestemplate; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.salestemplate (
    itemid character varying(36),
    name character varying(36),
    type integer NOT NULL
);


ALTER TABLE exp_tables.salestemplate OWNER TO postgres;

--
-- Name: salestemplateitems; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.salestemplateitems (
    itemid character varying(36),
    "order" integer NOT NULL,
    partid character varying(36),
    description text,
    quantity double precision NOT NULL,
    printline smallint NOT NULL,
    taxed smallint NOT NULL,
    price double precision NOT NULL,
    cost double precision NOT NULL,
    repair character varying(15),
    jobclass character varying(40),
    markupvalue double precision NOT NULL
);


ALTER TABLE exp_tables.salestemplateitems OWNER TO postgres;

--
-- Name: sausebal; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sausebal (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    datebegin timestamp without time zone,
    openbal double precision NOT NULL,
    openbal2 double precision NOT NULL
);


ALTER TABLE exp_tables.sausebal OWNER TO postgres;

--
-- Name: servagr; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.servagr (
    custno character varying(7),
    locno character varying(5),
    agrmtno character varying(7),
    agrmttype character varying(3),
    invcode character varying(10),
    amortcode character varying(10),
    dept character varying(2),
    salesman character varying(4),
    tech character varying(4),
    contramt double precision NOT NULL,
    jobnumber character varying(41),
    origcontr timestamp without time zone,
    renewdate timestamp without time zone,
    expiredate timestamp without time zone,
    contrper character varying(6),
    lastinv timestamp without time zone,
    lastpaid timestamp without time zone,
    lastsrvc timestamp without time zone,
    weekbegin character varying(3),
    schtype double precision NOT NULL,
    notes text,
    jobclass character varying(40),
    usagelbl character varying(20),
    maxusage double precision NOT NULL,
    usageper integer NOT NULL,
    overcost double precision NOT NULL,
    usageytd double precision NOT NULL,
    usageper1 character varying(12),
    usageper2 character varying(12),
    usageper3 character varying(12),
    usageper4 character varying(12),
    usageper5 character varying(12),
    usageper6 character varying(12),
    usageper7 character varying(12),
    usageper8 character varying(12),
    usageper9 character varying(12),
    usageper10 character varying(12),
    usageper11 character varying(12),
    usageper12 character varying(12),
    usageamt1 double precision NOT NULL,
    usageamt2 double precision NOT NULL,
    usageamt3 double precision NOT NULL,
    usageamt4 double precision NOT NULL,
    usageamt5 double precision NOT NULL,
    usageamt6 double precision NOT NULL,
    usageamt7 double precision NOT NULL,
    usageamt8 double precision NOT NULL,
    usageamt9 double precision NOT NULL,
    usageamt10 double precision NOT NULL,
    usageamt11 double precision NOT NULL,
    usageamt12 double precision NOT NULL,
    begdate timestamp without time zone,
    sainactive smallint NOT NULL,
    estmarkup integer NOT NULL,
    invbegin timestamp without time zone,
    estcost double precision NOT NULL,
    usagelbl2 character varying(20),
    maxusage2 double precision NOT NULL,
    overcost2 double precision NOT NULL,
    usageytd2 double precision NOT NULL,
    usage2per1 character varying(12),
    usage2per2 character varying(12),
    usage2per3 character varying(12),
    usage2per4 character varying(12),
    usage2per5 character varying(12),
    usage2per6 character varying(12),
    usage2per7 character varying(12),
    usage2per8 character varying(12),
    usage2per9 character varying(12),
    usage2per10 character varying(12),
    usage2per11 character varying(12),
    usage2per12 character varying(12),
    usage2amt1 double precision NOT NULL,
    usage2amt2 double precision NOT NULL,
    usage2amt3 double precision NOT NULL,
    usage2amt4 double precision NOT NULL,
    usage2amt5 double precision NOT NULL,
    usage2amt6 double precision NOT NULL,
    usage2amt7 double precision NOT NULL,
    usage2amt8 double precision NOT NULL,
    usage2amt9 double precision NOT NULL,
    usage2amt10 double precision NOT NULL,
    usage2amt11 double precision NOT NULL,
    usage2amt12 double precision NOT NULL,
    memtransid character varying(36),
    recurschedid character varying(36),
    nextpostdate timestamp without time zone,
    modified timestamp without time zone
);


ALTER TABLE exp_tables.servagr OWNER TO postgres;

--
-- Name: serverstatus; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.serverstatus (
    key character varying(1),
    mpprocessmobhist timestamp without time zone,
    mpprocessdirrequest timestamp without time zone,
    mpprocesslatlngrequest timestamp without time zone,
    csmperror smallint NOT NULL,
    csmterror smallint NOT NULL,
    cssqerror smallint NOT NULL,
    cszoraerror smallint NOT NULL,
    msvettroerror smallint NOT NULL,
    msqbmserror smallint NOT NULL,
    csconnected smallint NOT NULL,
    msconnected smallint NOT NULL,
    mpversion character varying(20),
    csversion character varying(20),
    msversion character varying(20)
);


ALTER TABLE exp_tables.serverstatus OWNER TO postgres;

--
-- Name: setup; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.setup (
    key character varying(1),
    latecharge double precision NOT NULL,
    taxcode character varying(8),
    terms character varying(31),
    defaulttyp character varying(5),
    tripcharge double precision NOT NULL,
    leadtime double precision NOT NULL,
    edbcolors integer NOT NULL,
    defdept character varying(2),
    deftechsa character varying(4),
    custanddat integer NOT NULL,
    agrsequent integer NOT NULL,
    sequential integer NOT NULL,
    equipyes integer NOT NULL,
    equipno integer NOT NULL,
    historyyes integer NOT NULL,
    historyno integer NOT NULL,
    recacct character varying(10),
    recdeposit character varying(10),
    rectrade character varying(10),
    latechgmin double precision NOT NULL,
    latechgbal double precision NOT NULL,
    showpaid integer NOT NULL,
    latecredit character varying(10),
    qualsearch character varying(2),
    delinquent double precision NOT NULL,
    defstatus character varying(10),
    version character varying(14),
    defnordept character varying(2),
    deftechdi character varying(4),
    priority character varying(6),
    lblphone1 character varying(12),
    lblphone2 character varying(12),
    lblphone3 character varying(12),
    lblphone4 character varying(12),
    phonelst1 character varying(12),
    phonelst2 character varying(12),
    phonelst3 character varying(12),
    phonelst4 character varying(12),
    phonelst5 character varying(12),
    phonelst6 character varying(12),
    phonelst7 character varying(12),
    phonelst8 character varying(12),
    eqhistyes integer NOT NULL,
    blockmin double precision NOT NULL,
    lic character varying(45),
    usersin double precision NOT NULL,
    invlock smallint NOT NULL,
    defsasch integer NOT NULL,
    pagemode integer NOT NULL,
    pagecond smallint NOT NULL,
    backupdate timestamp without time zone,
    saautoupd smallint NOT NULL,
    usageon smallint NOT NULL,
    defusagelb character varying(20),
    sapostparts smallint NOT NULL,
    pagesubjec character varying(60),
    meterread smallint NOT NULL,
    smtpserver character varying(80),
    smtpsluser character varying(60),
    smtpsladdr character varying(80),
    smtppouser character varying(60),
    smtppoaddr character varying(80),
    labdraw character varying(36),
    matdraw character varying(36),
    otherdraw character varying(36),
    sendecpy smallint NOT NULL,
    smtpserveruser character varying(80),
    smtpserverpw character varying(30),
    finchglab character varying(20),
    dispinvprt smallint NOT NULL,
    dispinvhst smallint NOT NULL,
    disptoinv smallint NOT NULL,
    dispeq1 character varying(10),
    dispeq2 character varying(10),
    dispeq3 character varying(10),
    dispeq4 character varying(10),
    dispeq5 character varying(10),
    dispeq6 character varying(10),
    saestcost integer NOT NULL,
    saposthold smallint NOT NULL,
    paypalacct character varying(127),
    paypallogourl character varying(255),
    websmtpserver character varying(120),
    reqlostemail character varying(80),
    reqlostsubj character varying(80),
    reqlostbody text,
    errrepemail character varying(80),
    errrepsubj character varying(80),
    errrepbody text,
    errrepemailto character varying(80),
    servreqemail character varying(80),
    servreqsubj character varying(80),
    servreqbody text,
    servreqemailto character varying(80),
    confemail character varying(80),
    confsubj character varying(80),
    confbody text,
    saestmarkup integer NOT NULL,
    ammsgreason text,
    ammsgavail text,
    ammsgconfirm text,
    ampreftime1 character varying(20),
    amacttime1 character varying(8),
    ampreftime2 character varying(20),
    amacttime2 character varying(8),
    ampreftime3 character varying(20),
    amacttime3 character varying(8),
    ampreftime4 character varying(20),
    amacttime4 character varying(8),
    ampreftime5 character varying(20),
    amacttime5 character varying(8),
    ampreftime6 character varying(20),
    amacttime6 character varying(8),
    ampreftime7 character varying(20),
    amacttime7 character varying(8),
    ampreftime8 character varying(20),
    amacttime8 character varying(8),
    mcbilloverage character varying(15),
    usage1code character varying(36),
    usage2code character varying(36),
    defusagelb2 character varying(20),
    sendacctemail character varying(80),
    sendacctsubj character varying(80),
    sendacctbody text,
    laborid character varying(36),
    amoptreqservice smallint NOT NULL,
    amoptinvoicehistory smallint NOT NULL,
    amoptcustomerinfo smallint NOT NULL,
    amoptagreements smallint NOT NULL,
    amoptequipmentinfo smallint NOT NULL,
    recbalmanual smallint NOT NULL,
    retainedearnings character varying(36),
    openperiod character varying(6),
    netprofit character varying(36),
    discountstaken character varying(36),
    payrollweekstart integer NOT NULL,
    poolcorpcustno character varying(10),
    poolcorpcustkey character varying(36),
    poolcorpvendor character varying(4),
    qbmsconnticket character varying(150),
    prddlastpostdate timestamp without time zone,
    prddlastfileid character varying(1),
    prddtransitroutingno character varying(9),
    prddnameofbank character varying(23),
    prddserviceclass integer NOT NULL,
    prddeffectivedateoffs integer NOT NULL,
    prddbankroutingno character varying(8),
    prdddelimiter integer NOT NULL,
    payrollchecking character varying(36),
    contractdraw character varying(36),
    retainagedraw character varying(36),
    changeorderlab character varying(36),
    changeordermat character varying(36),
    changeorderother character varying(36),
    drawinvoiceform character varying(30),
    agreementreserve character varying(36),
    ahspopserver character varying(128),
    ahspopuser character varying(128),
    ahspoppassword character varying(128),
    ahsprocessedforward character varying(128),
    ahserrorforward character varying(128),
    ahscustomer character varying(128),
    ahsemailfromname character varying(128),
    ahsemailfromaddress character varying(128),
    smtpport integer NOT NULL,
    agreementreserveincome character varying(36),
    jobdrawinvdetail smallint NOT NULL,
    enablesilverlight smallint NOT NULL,
    prddincludeoffsetdebit smallint NOT NULL,
    ahslicensed smallint NOT NULL,
    sagequestweblicensed smallint NOT NULL,
    smtpusessl smallint NOT NULL,
    smtpusestarttls smallint NOT NULL,
    ahsusessl smallint NOT NULL,
    ahsusestarttls smallint NOT NULL,
    ahspopport integer NOT NULL,
    smtploginmethod integer NOT NULL,
    prddfedidleadingchar character varying(1),
    prddcompanytaxid character varying(10),
    prdddestbankname character varying(23),
    invequipinbody smallint NOT NULL,
    prddoffsetbankaccount character varying(17),
    prddtracenumber character varying(8),
    prddreceivingdfiid character varying(9),
    prddoffsettrace character varying(8),
    dispnotesinbody smallint NOT NULL,
    displocnotesinbody smallint NOT NULL,
    agrpostpartstoinvoice smallint NOT NULL,
    prddcompentrydesc character varying(10),
    dispatchnotesitem character varying(36),
    descdraw character varying(36),
    wipenabled smallint NOT NULL,
    servfreqtoken character varying(36),
    servfreqactivatestatus character varying(10),
    servfrequrl character varying(255),
    ahscompanyid character varying(36),
    ahsuserid character varying(36),
    ahspassword character varying(36),
    sadefpriority character varying(6),
    ptactionnewquote character varying(36),
    ptactionmodifyquote character varying(36),
    ptactionrejectquote character varying(36),
    prddinitialrecord text,
    invenallownegative integer NOT NULL,
    qbwizardcompleted smallint NOT NULL,
    travelbillable smallint NOT NULL,
    ccservice integer NOT NULL,
    mwsiteid character varying(72),
    mwkey character varying(72),
    mwname character varying(200),
    sainvamtpertask smallint NOT NULL,
    backloadperiodid character varying(6),
    warrantyreserveaccount character varying(36),
    warrantyreserveholding character varying(36),
    smtpnotifyuser character varying(60),
    smtpnotifyaddr character varying(80),
    prddexcludesocsecnum smallint NOT NULL,
    authorizecontracttitle text,
    authorizecontract text,
    acceptancecontracttitle text,
    acceptancecontract text,
    autoapplypaymethod character varying(10),
    ddallocaccount character varying(36),
    altconvertworkstation character varying(30),
    legacymode smallint NOT NULL,
    tripchargeitem character varying(36),
    quotecosttype integer NOT NULL,
    defaultfirstflatrate smallint NOT NULL,
    prddabn character varying(10),
    prddamro character varying(10),
    unearnacct character varying(10)
);


ALTER TABLE exp_tables.setup OWNER TO postgres;

--
-- Name: shipvia; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.shipvia (
    name character varying(10),
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.shipvia OWNER TO postgres;

--
-- Name: signature; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.signature (
    id character varying(36),
    signaturedata text,
    contracttitle text,
    contract text
);


ALTER TABLE exp_tables.signature OWNER TO postgres;

--
-- Name: sldept; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sldept (
    dept character varying(2),
    "desc" character varying(20),
    debit character varying(10),
    credit character varying(10),
    navcode character varying(10),
    rwcat character varying(2),
    deptid character varying(36),
    division character varying(36),
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.sldept OWNER TO postgres;

--
-- Name: slsort; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.slsort (
    code character varying(6),
    "desc" character varying(30),
    sortcodeinactive smallint NOT NULL
);


ALTER TABLE exp_tables.slsort OWNER TO postgres;

--
-- Name: sortdisp; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sortdisp (
    key character varying(30),
    dispatch character varying(15)
);


ALTER TABLE exp_tables.sortdisp OWNER TO postgres;

--
-- Name: sortlead; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sortlead (
    key character varying(77),
    custno character varying(7),
    locno character varying(5)
);


ALTER TABLE exp_tables.sortlead OWNER TO postgres;

--
-- Name: sortlock; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sortlock (
    key character varying(1),
    "user" character varying(10)
);


ALTER TABLE exp_tables.sortlock OWNER TO postgres;

--
-- Name: sortmast; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sortmast (
    code character varying(3),
    "desc" character varying(40)
);


ALTER TABLE exp_tables.sortmast OWNER TO postgres;

--
-- Name: statcode; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.statcode (
    code character varying(10),
    dispdate character varying(1),
    disptime character varying(1),
    name character varying(1),
    timeon character varying(1),
    timeoff character varying(1),
    transfer character varying(4),
    leave character varying(1),
    setassign character varying(1),
    setunassgn character varying(1),
    complcode character varying(8),
    "order" integer NOT NULL,
    mobile smallint NOT NULL,
    statusbillable smallint NOT NULL,
    ahsstatus integer NOT NULL,
    notify smallint NOT NULL,
    notifysubject character varying(255),
    notifybody bytea,
    notifyrawhtml text
);


ALTER TABLE exp_tables.statcode OWNER TO postgres;

--
-- Name: sysdiagrams; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.sysdiagrams (
    name character varying(256),
    principal_id integer NOT NULL,
    diagram_id integer NOT NULL,
    version integer,
    definition bytea
);


ALTER TABLE exp_tables.sysdiagrams OWNER TO postgres;

--
-- Name: task; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.task (
    task character varying(7),
    "desc" character varying(30),
    "time" character varying(3),
    longdesc text,
    skill character varying(2),
    taskenter integer NOT NULL,
    taskinactive smallint NOT NULL
);


ALTER TABLE exp_tables.task OWNER TO postgres;

--
-- Name: taskpart; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.taskpart (
    task character varying(7),
    part character varying(36),
    quantity double precision NOT NULL
);


ALTER TABLE exp_tables.taskpart OWNER TO postgres;

--
-- Name: tasksub; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.tasksub (
    task character varying(7),
    subtask character varying(7)
);


ALTER TABLE exp_tables.tasksub OWNER TO postgres;

--
-- Name: tasktool; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.tasktool (
    task character varying(7),
    tool character varying(12)
);


ALTER TABLE exp_tables.tasktool OWNER TO postgres;

--
-- Name: taxcodes; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.taxcodes (
    code character varying(8),
    "desc" character varying(40),
    sales integer NOT NULL,
    acct1 character varying(10),
    tdesc1 character varying(20),
    rate1 double precision NOT NULL,
    vendor1 character varying(4),
    acct2 character varying(10),
    tdesc2 character varying(20),
    rate2 double precision NOT NULL,
    vendor2 character varying(4),
    acct3 character varying(10),
    tdesc3 character varying(20),
    rate3 double precision NOT NULL,
    vendor3 character varying(4),
    acct4 character varying(10),
    tdesc4 character varying(20),
    rate4 double precision NOT NULL,
    vendor4 character varying(4),
    labor1 double precision NOT NULL,
    labor2 double precision NOT NULL,
    labor3 double precision NOT NULL,
    labor4 double precision NOT NULL,
    material1 double precision NOT NULL,
    material2 double precision NOT NULL,
    material3 double precision NOT NULL,
    material4 double precision NOT NULL,
    other1 double precision NOT NULL,
    other2 double precision NOT NULL,
    other3 double precision NOT NULL,
    other4 double precision NOT NULL,
    servagr1 double precision NOT NULL,
    servagr2 double precision NOT NULL,
    servagr3 double precision NOT NULL,
    servagr4 double precision NOT NULL,
    costacct character varying(10),
    navtaxarea character varying(20),
    rwtaxgroup character varying(10),
    listid character varying(20),
    piggy smallint NOT NULL,
    name1 character varying(36),
    name2 character varying(36),
    name3 character varying(36),
    name4 character varying(36),
    acct5 character varying(10),
    acct6 character varying(10),
    tdesc5 character varying(20),
    tdesc6 character varying(20),
    rate5 double precision NOT NULL,
    rate6 double precision NOT NULL,
    vendor5 character varying(4),
    vendor6 character varying(4),
    name5 character varying(36),
    name6 character varying(36),
    labor5 double precision NOT NULL,
    labor6 double precision NOT NULL,
    material5 double precision NOT NULL,
    material6 double precision NOT NULL,
    other5 double precision NOT NULL,
    other6 double precision NOT NULL,
    servagr5 double precision NOT NULL,
    servagr6 double precision NOT NULL,
    gstpsttax smallint NOT NULL
);


ALTER TABLE exp_tables.taxcodes OWNER TO postgres;

--
-- Name: terms; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.terms (
    term character varying(31),
    type double precision NOT NULL,
    netdue double precision NOT NULL,
    paidwithin double precision NOT NULL,
    netdueday double precision NOT NULL,
    nxtmoday double precision NOT NULL,
    discday double precision NOT NULL,
    discount double precision NOT NULL,
    termid character varying(36)
);


ALTER TABLE exp_tables.terms OWNER TO postgres;

--
-- Name: timesheet; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.timesheet (
    transid character varying(36),
    employee character varying(4),
    paydate timestamp without time zone
);


ALTER TABLE exp_tables.timesheet OWNER TO postgres;

--
-- Name: timesheetledger; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.timesheetledger (
    transid character varying(36),
    ledgerid character varying(36),
    counter integer NOT NULL,
    itemdate timestamp without time zone,
    billable smallint NOT NULL,
    billingitem character varying(15),
    jobid character varying(36),
    deptid character varying(36),
    costtype integer NOT NULL,
    jobclassid character varying(36),
    paytype integer NOT NULL,
    rate double precision NOT NULL,
    quantity double precision NOT NULL,
    amount double precision NOT NULL
);


ALTER TABLE exp_tables.timesheetledger OWNER TO postgres;

--
-- Name: tools; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.tools (
    tool character varying(12),
    "desc" character varying(50)
);


ALTER TABLE exp_tables.tools OWNER TO postgres;

--
-- Name: userled; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.userled (
    "user" character varying(10),
    privilege character varying(60)
);


ALTER TABLE exp_tables.userled OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.users (
    "user" character varying(10),
    password character varying(10),
    techid character varying(4),
    deviceid character varying(4),
    uncname character varying(255)
);


ALTER TABLE exp_tables.users OWNER TO postgres;

--
-- Name: vendor; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.vendor (
    vendor character varying(4),
    company character varying(35),
    firstname character varying(30),
    add1 character varying(30),
    add2 character varying(30),
    city character varying(25),
    state character varying(2),
    zip character varying(10),
    phone1 character varying(12),
    phone2 character varying(12),
    fax character varying(12),
    terms character varying(31),
    account character varying(20),
    discount double precision NOT NULL,
    acctkey character varying(42),
    post character varying(1),
    rwvendist character varying(6),
    rwvenacct character varying(10),
    listid character varying(20),
    email character varying(40),
    weburl character varying(255),
    vendornotes text,
    defaultlocationid character varying(36),
    print1099 smallint NOT NULL,
    taxid character varying(20),
    vendorinactive smallint NOT NULL,
    defaultaccountid character varying(36)
);


ALTER TABLE exp_tables.vendor OWNER TO postgres;

--
-- Name: vendor1099category; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.vendor1099category (
    category integer NOT NULL,
    threshold double precision NOT NULL
);


ALTER TABLE exp_tables.vendor1099category OWNER TO postgres;

--
-- Name: vendor1099paid; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.vendor1099paid (
    transid character varying(36),
    billtransid character varying(36),
    transdate timestamp without time zone,
    entryid character varying(36),
    accountid character varying(36),
    amount double precision NOT NULL,
    vendor character varying(4)
);


ALTER TABLE exp_tables.vendor1099paid OWNER TO postgres;

--
-- Name: vendorlocations; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.vendorlocations (
    vendor character varying(4),
    listid character varying(36),
    locname character varying(60),
    locadd1 character varying(30),
    locadd2 character varying(30),
    loccity character varying(25),
    locstate character varying(2),
    loczip character varying(10),
    contactname1 character varying(40),
    contactemail1 character varying(100),
    phone1 character varying(21),
    extension1 character varying(4),
    contactname2 character varying(40),
    contactemail2 character varying(100),
    phone2 character varying(21),
    extension2 character varying(4),
    contactname3 character varying(40),
    contactemail3 character varying(100),
    phone3 character varying(21),
    extension3 character varying(4),
    contactname4 character varying(40),
    contactemail4 character varying(100),
    phone4 character varying(21),
    extension4 character varying(4),
    contactname5 character varying(40),
    contactemail5 character varying(100),
    phone5 character varying(21),
    extension5 character varying(4),
    contactname6 character varying(40),
    contactemail6 character varying(100),
    phone6 character varying(21),
    extension6 character varying(4),
    locinactive smallint NOT NULL
);


ALTER TABLE exp_tables.vendorlocations OWNER TO postgres;

--
-- Name: venparts; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.venparts (
    vendor character varying(4),
    part character varying(36),
    venpart character varying(36),
    lastpurchaseprice double precision NOT NULL,
    datelastpurchase timestamp without time zone
);


ALTER TABLE exp_tables.venparts OWNER TO postgres;

--
-- Name: view1099; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.view1099 AS
 SELECT "1099 Data"."Print1099" AS print1099,
    "1099 Data"."1099 Category" AS "1099 category",
    "1099 Data"."Vendor" AS vendor,
    "1099 Data"."Company" AS company,
    "1099 Data"."First Name" AS "first name",
    "1099 Data"."Account Number" AS "account number",
    "1099 Data"."Account Description" AS "account description",
    "1099 Data"."Amount" AS amount,
    "1099 Data"."TransDate" AS transdate,
    "1099 Data".transid,
    vendor1099category.threshold,
        CASE "1099 Data"."1099 Category"
            WHEN 10 THEN 'Rents'::text
            WHEN 20 THEN 'Royalties'::text
            WHEN 30 THEN 'Other Income'::text
            WHEN 40 THEN 'Federal Income Tax Withheld'::text
            WHEN 50 THEN 'Fishing Boat Proceeds'::text
            WHEN 60 THEN 'Medical And Health Care Payments'::text
            WHEN 70 THEN 'NonemployeeCompensation'::text
            WHEN 80 THEN 'Substitute Payments In Lieu Of Dividends Or Interest'::text
            WHEN 90 THEN 'Direct Sales'::text
            WHEN 100 THEN 'Crop Insurance Proceeds'::text
            WHEN 110 THEN 'Foreign Tax Paid'::text
            WHEN 130 THEN 'Excess Golden Parachute Payments'::text
            WHEN 140 THEN 'Gross Proceeds Paid To An Attorney'::text
            WHEN 150 THEN 'Section 409A Deferrals'::text
            WHEN 160 THEN 'Section 409A Income'::text
            ELSE ''::text
        END AS "1099 category name"
   FROM (( SELECT vendor.print1099 AS "Print1099",
            coa.category1099 AS "1099 Category",
            vendor1099paid.vendor AS "Vendor",
            vendor.company AS "Company",
            vendor.firstname AS "First Name",
            coa.account AS "Account Number",
            coa."desc" AS "Account Description",
                CASE coa.category1099
                    WHEN 40 THEN (vendor1099paid.amount * ('-1'::integer)::double precision)
                    ELSE vendor1099paid.amount
                END AS "Amount",
            vendor1099paid.transdate AS "TransDate",
            vendor1099paid.billtransid AS transid
           FROM ((exp_tables.vendor1099paid
             JOIN exp_tables.coa ON (((vendor1099paid.accountid)::text = (coa.accountid)::text)))
             JOIN exp_tables.vendor ON (((vendor1099paid.vendor)::text = (vendor.vendor)::text)))
        UNION ALL
         SELECT vendor.print1099 AS "Print1099",
            coa.category1099 AS "1099 Category",
            finledger.checktievendorno AS vendor,
            vendor.company AS "Company",
            vendor.firstname AS "First Name",
            coa.account AS "Account Number",
            coa."desc" AS "Account Description",
                CASE coa.category1099
                    WHEN 40 THEN (finledger.amount * ('-1'::integer)::double precision)
                    ELSE finledger.amount
                END AS "Amount",
            finledger.transdate AS "TransDate",
            finledger.transid AS "TransID"
           FROM (((exp_tables.finledger
             JOIN exp_tables.coa ON (((finledger.accountid)::text = (coa.accountid)::text)))
             JOIN exp_tables.vendor ON (((finledger.checktievendorno)::text = (vendor.vendor)::text)))
             JOIN exp_tables.acctcat ON (((coa.id)::text = (acctcat.id)::text)))
          WHERE ((finledger.source > 100) AND (finledger.source <> 300) AND (finledger.voided = 0) AND (finledger.trancount > 1))) "1099 Data"
     LEFT JOIN exp_tables.vendor1099category ON (("1099 Data"."1099 Category" = vendor1099category.category)));


ALTER TABLE exp_tables.view1099 OWNER TO postgres;

--
-- Name: viewgeneraljournal; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewgeneraljournal AS
 SELECT finledger.entryid,
    finledger.transid,
    finledger.trancount,
    finledger.accountid,
    finledger.amount,
    finledger.source,
    finledger.transtype,
    finledger.transdesc,
    finledger.transmemo,
    finledger.transdate,
    finledger.active,
    finledger.voided,
    finledger.voiddesc,
    finledger.modified,
    finledger.modifiedby,
    finledger.addeddate,
    finledger.costtype,
    finledger.units,
    finledger.trannumber,
    finledger.deptid,
    finledger.cleared,
    finledger.cleareddate,
    finledger.docnum,
    finledger.docaddress,
    finledger.accrualtype,
    finledger.accrualpaidoff,
    finledger.accruallinkentryid,
    finledger.accrualvendor,
    finledger.duedate,
    finledger.discountdate,
    finledger.discountamount,
    finledger.checktietype,
    finledger.checktiecustno,
    finledger.checktieempno,
    finledger.checktievendorno,
    finledger.reference,
    finledger.deliverydate,
    finledger.termid,
    finledger.contact,
    finledger.discounttaken,
    finledger.billreceived,
    finledger.payitemid,
    finledger.payrate,
    finledger.relatedtransid,
    finledger.payperiodending,
    finledger.workcompid,
    finledger.workcomprate,
    finledger.taxableamount,
    finledger.payweeks,
    finledger.grosspay,
    finledger.backloaded,
    finledger.depositcheckno,
    finledger.depositpaymethod,
        CASE finledger.source
            WHEN 0 THEN 'Opening Balance'::text
            WHEN 50 THEN 'Budget'::text
            WHEN 100 THEN 'Estimate'::text
            WHEN 200 THEN 'Journal entry'::text
            WHEN 300 THEN 'Accounts payable'::text
            WHEN 400 THEN 'Sales'::text
            WHEN 500 THEN 'Receivables'::text
            WHEN 600 THEN 'Inventory'::text
            WHEN 700 THEN 'Payroll'::text
            WHEN 800 THEN 'Checking'::text
            WHEN 900 THEN 'Sales Tax'::text
            ELSE ''::text
        END AS sourcename,
        CASE finledger.transtype
            WHEN 0 THEN 'Journal'::text
            WHEN 300 THEN 'Vendor Bill'::text
            WHEN 305 THEN 'Vendor Credit'::text
            WHEN 400 THEN 'Invoice'::text
            WHEN 405 THEN 'Credit memo'::text
            WHEN 410 THEN 'Estimate'::text
            WHEN 500 THEN 'Payment'::text
            WHEN 502 THEN 'Receivables Debit'::text
            WHEN 505 THEN 'Receivables Credit'::text
            WHEN 600 THEN 'Purchase'::text
            WHEN 605 THEN 'Adjustment'::text
            WHEN 610 THEN 'Transfer'::text
            WHEN 615 THEN 'Vendor credit'::text
            WHEN 620 THEN 'Job Transfer'::text
            WHEN 800 THEN 'Check'::text
            WHEN 805 THEN 'Deposit'::text
            WHEN 810 THEN 'Interest income'::text
            WHEN 815 THEN 'Bank fee'::text
            WHEN 820 THEN 'Credit card fee'::text
            WHEN 825 THEN 'Interest expense'::text
            WHEN 830 THEN 'Credit card charge'::text
            ELSE ''::text
        END AS transtypename,
        CASE finledger.costtype
            WHEN 100 THEN 'Material'::text
            WHEN 150 THEN 'Equipment'::text
            WHEN 200 THEN 'Labor'::text
            WHEN 300 THEN 'Subcontractor'::text
            WHEN 400 THEN 'Permits'::text
            WHEN 500 THEN 'Other'::text
            ELSE ''::text
        END AS costtypename,
        CASE finledger.cleared
            WHEN 0 THEN 'Open'::text
            WHEN 50 THEN 'Marked'::text
            WHEN 100 THEN 'Cleared'::text
            WHEN 200 THEN 'Cleared Electronically'::text
            ELSE ''::text
        END AS clearedname,
        CASE
            WHEN (finledger.amount >= (0)::double precision) THEN finledger.amount
            ELSE (0)::double precision
        END AS debit,
        CASE
            WHEN (finledger.amount < (0)::double precision) THEN abs(finledger.amount)
            ELSE (0)::double precision
        END AS credit,
    coa.account,
    coa.id AS acctcatid,
    coa."desc" AS accountdesc,
    coa.type,
    coa.accountsort,
    coa.parentid,
    coa.recondate,
    coa.reconbeginbal,
    coa.reconendbal,
    coa.wipaccount,
    acctcat."group" AS acctcatgroup,
    acctcat."desc" AS acctcatdesc,
        CASE acctcat."group"
            WHEN 'I'::text THEN 'Income'::text
            WHEN 'E'::text THEN 'Expenses'::text
            WHEN 'A'::text THEN 'Assets'::text
            WHEN 'L'::text THEN 'Liabilities & Equity'::text
            ELSE ''::text
        END AS acctgroupname,
        CASE acctcat."group"
            WHEN 'A'::text THEN 1
            WHEN 'L'::text THEN 2
            WHEN 'I'::text THEN 3
            WHEN 'E'::text THEN 4
            ELSE 0
        END AS acctgrouporder,
        CASE acctcat.id
            WHEN '01'::text THEN 100
            WHEN '02'::text THEN 100
            WHEN '03'::text THEN 100
            WHEN '04'::text THEN 100
            WHEN '05'::text THEN 100
            WHEN '06'::text THEN 100
            WHEN '07'::text THEN 200
            WHEN '08'::text THEN 200
            WHEN '09'::text THEN 200
            WHEN '10'::text THEN 300
            ELSE 0
        END AS balancesheettotalorder,
        CASE acctcat.id
            WHEN '01'::text THEN 'Assets'::text
            WHEN '02'::text THEN 'Assets'::text
            WHEN '03'::text THEN 'Assets'::text
            WHEN '04'::text THEN 'Assets'::text
            WHEN '05'::text THEN 'Assets'::text
            WHEN '06'::text THEN 'Assets'::text
            WHEN '07'::text THEN 'Liabilities'::text
            WHEN '08'::text THEN 'Liabilities'::text
            WHEN '09'::text THEN 'Liabilities'::text
            WHEN '10'::text THEN 'Liabilities & Equity'::text
            ELSE ''::text
        END AS balancesheettotalname,
        CASE acctcat.id
            WHEN '01'::text THEN 100
            WHEN '02'::text THEN 100
            WHEN '03'::text THEN 100
            WHEN '04'::text THEN 100
            WHEN '05'::text THEN 200
            WHEN '06'::text THEN 300
            WHEN '07'::text THEN 400
            WHEN '08'::text THEN 400
            WHEN '09'::text THEN 500
            WHEN '10'::text THEN 600
            ELSE 0
        END AS balancesheetorder,
        CASE acctcat.id
            WHEN '01'::text THEN 'Current Assets'::text
            WHEN '02'::text THEN 'Current Assets'::text
            WHEN '03'::text THEN 'Current Assets'::text
            WHEN '04'::text THEN 'Current Assets'::text
            WHEN '05'::text THEN 'Fixed Assets'::text
            WHEN '06'::text THEN 'Other Assets'::text
            WHEN '07'::text THEN 'Current Liabilities'::text
            WHEN '08'::text THEN 'Current Liabilities'::text
            WHEN '09'::text THEN 'Long Term Liabilities'::text
            WHEN '10'::text THEN 'Owner Equity'::text
            ELSE ''::text
        END AS balancesheetname,
        CASE acctcat.id
            WHEN '01'::text THEN 200
            WHEN '02'::text THEN 200
            WHEN '03'::text THEN 200
            WHEN '04'::text THEN 200
            WHEN '05'::text THEN 200
            WHEN '06'::text THEN 300
            WHEN '07'::text THEN 100
            WHEN '08'::text THEN 100
            WHEN '09'::text THEN 100
            WHEN '11'::text THEN 100
            WHEN '13'::text THEN 100
            WHEN '14'::text THEN 200
            WHEN '12'::text THEN 300
            WHEN '15'::text THEN 300
            ELSE 0
        END AS incomestatementgroup,
        CASE acctcat.id
            WHEN '01'::text THEN 'Total Expenses'::text
            WHEN '02'::text THEN 'Total Expenses'::text
            WHEN '03'::text THEN 'Total Expenses'::text
            WHEN '04'::text THEN 'Total Expenses'::text
            WHEN '05'::text THEN 'Total Expenses'::text
            WHEN '06'::text THEN 'Total Other Inc. & Exp.'::text
            WHEN '07'::text THEN 'Gross Profit'::text
            WHEN '08'::text THEN 'Gross Profit'::text
            WHEN '09'::text THEN 'Gross Profit'::text
            WHEN '11'::text THEN 'Gross Profit'::text
            WHEN '13'::text THEN 'Gross Profit'::text
            WHEN '14'::text THEN 'Total Expenses'::text
            WHEN '12'::text THEN 'Total Other Inc. & Exp.'::text
            WHEN '15'::text THEN 'Total Other Inc. & Exp.'::text
            ELSE ''::text
        END AS incomestatementgroupname,
        CASE acctcat.id
            WHEN '01'::text THEN 300
            WHEN '02'::text THEN 300
            WHEN '03'::text THEN 300
            WHEN '04'::text THEN 300
            WHEN '05'::text THEN 300
            WHEN '06'::text THEN 400
            WHEN '07'::text THEN 100
            WHEN '08'::text THEN 100
            WHEN '09'::text THEN 100
            WHEN '11'::text THEN 100
            WHEN '13'::text THEN 200
            WHEN '14'::text THEN 300
            WHEN '12'::text THEN 400
            WHEN '15'::text THEN 500
            ELSE 0
        END AS incomestatementorder,
        CASE acctcat.id
            WHEN '01'::text THEN 'Expenses'::text
            WHEN '02'::text THEN 'Expenses'::text
            WHEN '03'::text THEN 'Expenses'::text
            WHEN '04'::text THEN 'Expenses'::text
            WHEN '05'::text THEN 'Expenses'::text
            WHEN '06'::text THEN 'Other Income'::text
            WHEN '07'::text THEN 'Income'::text
            WHEN '08'::text THEN 'Income'::text
            WHEN '09'::text THEN 'Income'::text
            WHEN '11'::text THEN 'Income'::text
            WHEN '13'::text THEN 'Cost of Goods'::text
            WHEN '14'::text THEN 'Expenses'::text
            WHEN '12'::text THEN 'Other Income'::text
            WHEN '15'::text THEN 'Other Expenses'::text
            ELSE ''::text
        END AS incomestatementname,
    finperiod.periodid,
    finperiod.counter AS periodcounter,
    finperiod.datebegin AS periodbegin,
    finperiod.dateend AS periodend,
    finfiscal.fiscalid,
    finfiscal.name AS fiscalname,
    finfiscal.counter AS fiscalcounter,
    jobs.jobid,
    jobs.name AS jobname,
    jobs.inactive AS jobinactive,
    jobs.jobstatus,
    jobs.jobtype,
    jobs.jobsalesperson,
    jobs.custno AS jobcustno,
    jobs.location AS joblocation,
    jobs.start AS jobstart,
    jobs.projend AS jobprojend,
    jobs.actualend AS jobactualend,
    jobs.certifiedjob,
    sldept.dept,
    sldept."desc" AS deptdesc,
    sldept.division,
    inven.itemid,
    inven.part,
    inven.shortdesc AS partdesc,
    jobclass.jobclassid,
    jobclass.name AS jobclassname,
    coaparent.account AS parentaccount,
    coaparent."desc" AS parentdesc,
    vendor.company AS vendorcompany,
    vendor.firstname AS vendorfirstname,
    vendor.phone1 AS vendorphone,
    prpayitem.name AS payitemname,
    prpayitem.taxformname,
    prpayitem.itemtype AS payitemtype,
    prpayitem.paytype,
    prpayitem.paytypesub,
    prpayitem.reportingtype AS payreportingtype,
    prpayitem.stateidnumber,
    prpayitem."limit" AS payitemlimit,
    prpayitem.taxpercent,
    location.locname AS joblocname,
        CASE finledger.source
            WHEN 50 THEN '-1'::integer
            ELSE 0
        END AS isbudget,
        CASE finledger.source
            WHEN 100 THEN '-1'::integer
            ELSE 0
        END AS isestimate
   FROM ((((((((((((exp_tables.finledger
     LEFT JOIN exp_tables.coa ON (((finledger.accountid)::text = (coa.accountid)::text)))
     JOIN exp_tables.finperiod ON (((finledger.periodid)::text = (finperiod.periodid)::text)))
     JOIN exp_tables.finfiscal ON (((finperiod.fiscalid)::text = (finfiscal.fiscalid)::text)))
     JOIN exp_tables.acctcat ON (((coa.id)::text = (acctcat.id)::text)))
     LEFT JOIN exp_tables.jobs ON (((finledger.jobid)::text = (jobs.jobid)::text)))
     LEFT JOIN exp_tables.sldept ON (((finledger.deptid)::text = (sldept.deptid)::text)))
     LEFT JOIN exp_tables.inven ON (((finledger.itemid)::text = (inven.itemid)::text)))
     LEFT JOIN exp_tables.jobclass ON (((finledger.jobclassid)::text = (jobclass.jobclassid)::text)))
     LEFT JOIN exp_tables.coa coaparent ON (((coa.parentid)::text = (coaparent.accountid)::text)))
     LEFT JOIN exp_tables.vendor ON (((finledger.accrualvendor)::text = (vendor.vendor)::text)))
     LEFT JOIN exp_tables.prpayitem ON (((finledger.payitemid)::text = (prpayitem.itemid)::text)))
     LEFT JOIN exp_tables.location ON ((((jobs.custno)::text = (location.custno)::text) AND ((jobs.location)::text = (location.locno)::text))));


ALTER TABLE exp_tables.viewgeneraljournal OWNER TO postgres;

--
-- Name: viewaccountbalances; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewaccountbalances AS
 SELECT viewgeneraljournal.fiscalid,
    viewgeneraljournal.fiscalname,
    viewgeneraljournal.accountid,
    viewgeneraljournal.account,
    viewgeneraljournal.acctcatgroup,
    sum(viewgeneraljournal.amount) AS accounttotal
   FROM exp_tables.viewgeneraljournal
  WHERE ((viewgeneraljournal.active = '-1'::integer) AND (viewgeneraljournal.voided = 0) AND (viewgeneraljournal.source <> 50))
  GROUP BY viewgeneraljournal.fiscalid, viewgeneraljournal.fiscalname, viewgeneraljournal.accountid, viewgeneraljournal.account, viewgeneraljournal.acctcatgroup;


ALTER TABLE exp_tables.viewaccountbalances OWNER TO postgres;

--
-- Name: viewagreementreserve; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewagreementreserve AS
 SELECT servagr.custno,
    servagr.locno,
    servagr.agrmtno,
    customer.lastname,
    customer.firstname,
    location.locname,
    finledger.transdate,
    finledger.amount,
    finledger.docnum,
    servagr.expiredate,
    servagr.sainactive,
    ( SELECT sum((- finledgersub.amount)) AS sum
           FROM exp_tables.finledger finledgersub
          WHERE (((finledgersub.relatedtransid)::text = (finledger.relatedtransid)::text) AND (finledgersub.voided = 0))) AS reservebalance
   FROM (((exp_tables.servagr
     JOIN exp_tables.finledger ON (((servagr.memtransid)::text = (finledger.relatedtransid)::text)))
     JOIN exp_tables.customer ON (((servagr.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((servagr.custno)::text = (location.custno)::text) AND ((servagr.locno)::text = (location.locno)::text))))
  WHERE (((servagr.memtransid)::text <> ''::text) AND (finledger.voided = 0));


ALTER TABLE exp_tables.viewagreementreserve OWNER TO postgres;

--
-- Name: viewchartofaccounts; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewchartofaccounts AS
 SELECT coa.account,
    coa.id,
    coa."desc",
    coa.type,
    coa.accountid,
    acctcat."group",
    acctcat."desc" AS acctcatdesc,
    coa.inactive,
    coa.accountsort,
    coa.parentid,
    coaparent.account AS parentaccount,
    coaparent."desc" AS parentdesc
   FROM ((exp_tables.coa
     JOIN exp_tables.acctcat ON (((coa.id)::text = (acctcat.id)::text)))
     LEFT JOIN exp_tables.coa coaparent ON (((coa.parentid)::text = (coaparent.accountid)::text)));


ALTER TABLE exp_tables.viewchartofaccounts OWNER TO postgres;

--
-- Name: viewdashboardagedpayables; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewdashboardagedpayables AS
 SELECT viewgeneraljournal_1.duedate AS "Due Date",
    ((viewgeneraljournal_1.amount * (100)::double precision))::numeric(12,0) AS "Amount",
    ( SELECT ((- sum((finledger.amount * (100)::double precision))))::numeric(12,0) AS sumamount
           FROM exp_tables.finledger
          WHERE (((finledger.accruallinkentryid)::text = (viewgeneraljournal_1.entryid)::text) AND (finledger.voided = 0) AND (finledger.transdate < (CURRENT_DATE + 1)))) AS "Accrual Paid Amount"
   FROM exp_tables.viewgeneraljournal viewgeneraljournal_1
  WHERE (((viewgeneraljournal_1.accrualtype = 100) OR (viewgeneraljournal_1.accrualtype = 250)) AND (viewgeneraljournal_1.voided = 0) AND (viewgeneraljournal_1.transdate < (CURRENT_DATE + 1)));


ALTER TABLE exp_tables.viewdashboardagedpayables OWNER TO postgres;

--
-- Name: viewdashboardagedreceivables; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewdashboardagedreceivables AS
 SELECT receivab.invdate AS "Invoice Date",
    receivab.invamt AS "Invoice Amount",
    recled.amount,
    recled.counter,
    receivab.type AS "Invoice Type"
   FROM (exp_tables.receivab
     LEFT JOIN exp_tables.recled ON ((((receivab.custno)::text = (recled.custno)::text) AND ((receivab.invoice)::text = (recled.invoice)::text))))
  WHERE (receivab.paidoff IS NULL);


ALTER TABLE exp_tables.viewdashboardagedreceivables OWNER TO postgres;

--
-- Name: viewdashboardsalesbydeptytd; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewdashboardsalesbydeptytd AS
 SELECT sales.dept AS "Department",
    sldept."desc" AS "Department Name",
    sum(salesled.amount) AS amount
   FROM ((exp_tables.sales
     JOIN exp_tables.salesled ON (((sales.invoice)::text = (salesled.invoice)::text)))
     JOIN exp_tables.sldept ON (((sales.dept)::text = (sldept.dept)::text)))
  WHERE (((sales.invtype)::text <> 'Quote'::text) AND ((salesled.prod)::text <> 'SUB'::text) AND (sales.hold = 0) AND (date_part('year'::text, CURRENT_DATE) = date_part('year'::text, sales.invdate)))
  GROUP BY sales.dept, sldept."desc";


ALTER TABLE exp_tables.viewdashboardsalesbydeptytd OWNER TO postgres;

--
-- Name: viewdashboardsalesbymonth; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewdashboardsalesbymonth AS
 SELECT (date_part('year'::text, sales.invdate))::integer AS year,
    (date_part('month'::text, sales.invdate))::integer AS month,
    sum(salesled.amount) AS amount,
    sum(salesled.cost) AS cost
   FROM ((exp_tables.sales
     JOIN exp_tables.salesled ON (((sales.invoice)::text = (salesled.invoice)::text)))
     JOIN exp_tables.sldept ON (((sales.dept)::text = (sldept.dept)::text)))
  WHERE (((sales.invtype)::text <> 'Quote'::text) AND ((salesled.prod)::text <> 'SUB'::text) AND (sales.hold = 0))
  GROUP BY ((date_part('year'::text, sales.invdate))::integer), ((date_part('month'::text, sales.invdate))::integer)
  ORDER BY ((date_part('year'::text, sales.invdate))::integer) DESC, ((date_part('month'::text, sales.invdate))::integer) DESC;


ALTER TABLE exp_tables.viewdashboardsalesbymonth OWNER TO postgres;

--
-- Name: viewdeposit; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewdeposit AS
 SELECT f.transid,
    f.entryid,
    f.transdate,
    f.transdesc,
    f.amount,
    c.lastname,
    c.firstname,
    r.paymethod,
    r.type,
    r.ckno,
    f.accountid,
    f.cleared,
    f.modified,
    f.docnum,
    f.relatedtransid,
    cc.name AS credcardname
   FROM (((exp_tables.finledger f
     LEFT JOIN exp_tables.recled r ON (((f.transid)::text = (r.entryid)::text)))
     LEFT JOIN exp_tables.customer c ON (((r.custno)::text = (c.custno)::text)))
     LEFT JOIN exp_tables.credcard cc ON ((((r.custno)::text = (cc.custno)::text) AND ((r.crserial)::text = (cc.serial)::text))))
  WHERE ((f.source = 500) AND (f.voided = 0));


ALTER TABLE exp_tables.viewdeposit OWNER TO postgres;

--
-- Name: viewlistpayablesbills; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistpayablesbills AS
 SELECT l.accrualvendor AS vendor,
    v.company,
    v.firstname AS "first name",
    l.docnum AS document,
    l.transid AS "internal id transid",
    l.entryid AS "internal id entryid",
    l.duedate AS "due date",
    (- (l.amount)::numeric(18,2)) AS amount,
    l.accrualpaidoff AS "paid off",
    (COALESCE(( SELECT sum(finledger.amount) AS sum
           FROM exp_tables.finledger
          WHERE ((finledger.voided = 0) AND ((finledger.accruallinkentryid)::text = (l.entryid)::text))), (0)::double precision) * ('-1'::integer)::double precision) AS "amount paid",
    (((- (l.amount)::numeric(18,2)))::double precision - COALESCE((( SELECT sum(finledger.amount) AS sum
           FROM exp_tables.finledger
          WHERE ((finledger.voided = 0) AND ((finledger.accruallinkentryid)::text = (l.entryid)::text))) * (1)::double precision), (0)::double precision)) AS balance,
    l.discountamount,
    l.discountdate,
    l.reference,
    l.transdate
   FROM (exp_tables.finledger l
     JOIN exp_tables.vendor v ON (((l.accrualvendor)::text = (v.vendor)::text)))
  WHERE ((l.voided = 0) AND (l.accrualtype = ANY (ARRAY[100, 250])));


ALTER TABLE exp_tables.viewlistpayablesbills OWNER TO postgres;

--
-- Name: viewlistbillpayments; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistbillpayments AS
 SELECT v.company AS description,
    v.document AS bill,
    vp.transid,
    vp.billtransid,
    vp.transdate,
    vp.entryid,
    vp.accountid,
    vp.amount,
    vp.vendor
   FROM (exp_tables.vendor1099paid vp
     LEFT JOIN exp_tables.viewlistpayablesbills v ON (((v."internal id transid")::text = (vp.billtransid)::text)));


ALTER TABLE exp_tables.viewlistbillpayments OWNER TO postgres;

--
-- Name: viewlistcustomerlocations; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistcustomerlocations AS
 SELECT customer.fullname AS "full name",
    customer.lastname AS "last name",
    customer.firstname AS "first name",
    customer.custno AS customer,
    customer.add1 AS "address 1",
    customer.add2 AS "address 2",
    customer.city,
    customer.state,
    customer.zip,
    customer.dateadded AS "date added",
    customer.datemodified AS "date modified",
    customer.lblphone1 AS "customer phone label 1",
    customer.phone1 AS "customer phone 1",
    customer.lblphone2 AS "customer phone label 2",
    customer.phone2 AS "customer phone 2",
    customer.lblphone3 AS "customer phone label 3",
    customer.phone3 AS "customer phone 3",
    customer.lblphone4 AS "customer phone label 4",
    customer.phone4 AS "customer phone 4",
    customer.salesperson AS "sales person",
    employee.empname AS "sales person name",
    customer.customerinactive AS "inactive customer",
    customer.website AS "web site",
    customer.creditrate AS "credit rating",
    customer.terms,
    location.locno AS location,
    location.locname AS "location name",
    location.add1 AS "location address 1",
    location.add2 AS "location address 2",
    location.city AS "location city",
    location.state AS "location state",
    location.zip AS "location zip",
    location.contact AS "contact 1",
    location.phone1 AS "phone 1",
    location.extension AS "ext 1",
    location.email AS "email 1",
    location.contact2 AS "contact 2",
    location.phone2 AS "phone 2",
    location.extension2 AS "ext 2",
    location.email2 AS "email 2",
    location.contact3 AS "contact 3",
    location.phone3 AS "phone 3",
    location.extension3 AS "ext 3",
    location.email3 AS "email 3",
    location.contact4 AS "contact 4",
    location.phone4 AS "phone 4",
    location.extension4 AS "ext 4",
    location.email4 AS "email 4",
    location.contact5 AS "contact 5",
    location.phone5 AS "phone 5",
    location.extension5 AS "ext 5",
    location.email5 AS "email 5",
    location.contact6 AS "contact 6",
    location.phone6 AS "phone 6",
    location.extension6 AS "ext 6",
    location.email6 AS "email 6",
    location.locationinactive AS "inactive location",
    location.taxcode AS "tax code",
    location.zone,
    location.tripcharge AS "trip charge",
    location.custom1 AS "location custom 1",
    location.custom2 AS "location custom 2",
    location.custom3 AS "location custom 3",
    location.custom4 AS "location custom 4",
    location.custom5 AS "location custom 5",
    location.custom6 AS "location custom 6",
    location.custom7 AS "location custom 7",
    location.custom8 AS "location custom 8",
    location.custom9 AS "location custom 9",
    location.custom10 AS "location custom 10",
    location.custom11 AS "location custom 11",
    location.custom12 AS "location custom 12",
    location.custom13 AS "location custom 13",
    location.custom14 AS "location custom 14",
    location.custom15 AS "location custom 15",
    location.custom16 AS "location custom 16",
    custlaborrate.name AS "labor code",
    custlaborrate.labor AS "labor rate",
    custlaborrate.helper AS "helper rate",
    location.disableemails AS "disable mass emailing",
    location.receivesnotifications AS "receives notifications",
    location.notes AS "location notes",
    customer.sort AS "sales sort"
   FROM (((exp_tables.customer
     JOIN exp_tables.location ON (((customer.custno)::text = (location.custno)::text)))
     LEFT JOIN exp_tables.employee ON (((customer.salesperson)::text = (employee.empno)::text)))
     LEFT JOIN exp_tables.custlaborrate ON (((location.laborid)::text = (custlaborrate.id)::text)));


ALTER TABLE exp_tables.viewlistcustomerlocations OWNER TO postgres;

--
-- Name: viewlistdispatches; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistdispatches AS
 SELECT dispatch.dispatch,
    dispatch.custno AS customer,
    customer.fullname AS "customer full name",
    customer.lastname AS "customer last name",
    customer.firstname AS "customer first name",
    dispatch.locno AS location,
    location.locname AS "location name",
    location.add1 AS "address 1",
    location.add2 AS "address 2",
    location.city,
    location.state,
    location.zip,
    dispatch.zone,
    dispatch.calledinby AS "called in by",
    dispatch.terms AS "dispatch type",
    dispatch.ponum AS "purchase order",
    dispatch.recdate AS "date received",
    dispatch.rectime AS "time received",
    dispatch.recby AS "received by",
    dispatch.priority,
    dispatch.invoice,
    dispatch.complete AS "date completed",
    dispatch.servagrnum AS agreement,
        CASE dispatch.servagrnum
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "has agreement",
    dispatch.invoiced,
    dispatch.jobnumber AS job,
    dispatch.sort AS "sales sort",
    dispatch.notes,
    disptech.serviceman AS tech,
    employee.empname AS "tech name",
    disptech.status,
    ((disptech.dispdate)::date + (NULLIF((disptech.disptime)::text, ''::text))::time without time zone) AS "date and time dispatched",
    ((disptech.dispdate)::date + (NULLIF((disptech.timeon)::text, ''::text))::time without time zone) AS "date and time on",
    ((disptech.dateoff)::date + (NULLIF((disptech.timeoff)::text, ''::text))::time without time zone) AS "date and time off",
    ((disptech.tpromdate)::date + (NULLIF((disptech.tpromtime)::text, ''::text))::time without time zone) AS "promised date and time",
    location.contact AS "contact 1",
    location.phone1 AS "phone 1",
    location.contact2 AS "contact 2",
    location.phone2 AS "phone 2",
    location.contact3 AS "contact 3",
    location.phone3 AS "phone 3",
    location.contact4 AS "contact 4",
    location.phone4 AS "phone 4",
    location.contact5 AS "contact 5",
    location.phone5 AS "phone 5",
    location.contact6 AS "contact 6",
    location.phone6 AS "phone 6",
        CASE
            WHEN ((dispatch.complete IS NOT NULL) AND (dispatch.invoiced = 0) AND ((dispatchtype.billable IS NULL) OR (dispatchtype.billable = '-1'::integer))) THEN '-1'::integer
            ELSE 0
        END AS "uninvoiced dispatch",
        CASE
            WHEN ((disptech.poreceived = '-1'::integer) AND ((disptech.complete)::text <> 'Y'::text)) THEN '-1'::integer
            ELSE 0
        END AS "po received",
    dispatch.quotesource AS quote
   FROM (((((exp_tables.dispatch
     JOIN exp_tables.disptech ON (((dispatch.dispatch)::text = (disptech.dispatch)::text)))
     JOIN exp_tables.customer ON (((dispatch.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((dispatch.custno)::text = (location.custno)::text) AND ((dispatch.locno)::text = (location.locno)::text))))
     JOIN exp_tables.employee ON (((disptech.serviceman)::text = (employee.empno)::text)))
     LEFT JOIN exp_tables.dispatchtype ON (((dispatch.terms)::text = (dispatchtype.name)::text)));


ALTER TABLE exp_tables.viewlistdispatches OWNER TO postgres;

--
-- Name: viewlistdispatches2; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistdispatches2 AS
 SELECT DISTINCT ON (dispatch.dispatch) dispatch.dispatch,
    dispatch.custno AS customer,
    customer.fullname AS "customer full name",
    customer.lastname AS "customer last name",
    customer.firstname AS "customer first name",
    dispatch.locno AS location,
    location.locname AS "location name",
    location.add1 AS "address 1",
    location.add2 AS "address 2",
    location.city,
    location.state,
    location.zip,
    dispatch.zone,
    dispatch.calledinby AS "called in by",
    dispatch.terms AS "dispatch type",
    dispatch.ponum AS "purchase order",
    dispatch.recdate AS "date received",
    dispatch.rectime AS "time received",
    dispatch.recby AS "received by",
    dispatch.priority,
    dispatch.invoice,
    dispatch.complete AS "date completed",
    dispatch.servagrnum AS agreement,
        CASE dispatch.servagrnum
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "has agreement",
    dispatch.invoiced,
    dispatch.jobnumber AS job,
    dispatch.sort AS "sales sort",
    dispatch.notes,
    disptech.serviceman AS tech,
    employee.empname AS "tech name",
    disptech.status,
    ((disptech.dispdate)::date + (NULLIF((disptech.disptime)::text, ''::text))::time without time zone) AS "date and time dispatched",
    ((disptech.dispdate)::date + (NULLIF((disptech.timeon)::text, ''::text))::time without time zone) AS "date and time on",
    ((disptech.dateoff)::date + (NULLIF((disptech.timeoff)::text, ''::text))::time without time zone) AS "date and time off",
    ((disptech.tpromdate)::date + (NULLIF((disptech.tpromtime)::text, ''::text))::time without time zone) AS "promised date and time",
    location.contact AS "contact 1",
    location.phone1 AS "phone 1",
    location.contact2 AS "contact 2",
    location.phone2 AS "phone 2",
    location.contact3 AS "contact 3",
    location.phone3 AS "phone 3",
    location.contact4 AS "contact 4",
    location.phone4 AS "phone 4",
    location.contact5 AS "contact 5",
    location.phone5 AS "phone 5",
    location.contact6 AS "contact 6",
    location.phone6 AS "phone 6",
        CASE
            WHEN ((dispatch.complete IS NOT NULL) AND (dispatch.invoiced = 0) AND ((dispatchtype.billable IS NULL) OR (dispatchtype.billable = '-1'::integer))) THEN '-1'::integer
            ELSE 0
        END AS "uninvoiced dispatch",
        CASE
            WHEN ((disptech.poreceived = '-1'::integer) AND ((disptech.complete)::text <> 'Y'::text)) THEN '-1'::integer
            ELSE 0
        END AS "po received",
    dispatch.quotesource AS quote
   FROM (((((exp_tables.dispatch
     JOIN exp_tables.disptech ON (((dispatch.dispatch)::text = (disptech.dispatch)::text)))
     JOIN exp_tables.customer ON (((dispatch.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((dispatch.custno)::text = (location.custno)::text) AND ((dispatch.locno)::text = (location.locno)::text))))
     JOIN exp_tables.employee ON (((disptech.serviceman)::text = (employee.empno)::text)))
     LEFT JOIN exp_tables.dispatchtype ON (((dispatch.terms)::text = (dispatchtype.name)::text)));


ALTER TABLE exp_tables.viewlistdispatches2 OWNER TO postgres;

--
-- Name: viewlistdispatchesnodetail; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistdispatchesnodetail AS
 SELECT dispatch.dispatch,
    dispatch.custno AS "Customer",
    customer.fullname AS "Customer Full Name",
    customer.lastname AS "Customer Last Name",
    customer.firstname AS "Customer First Name",
    dispatch.locno AS "Location",
    location.locname AS "Location Name",
    location.add1 AS "Address 1",
    location.add2 AS "Address 2",
    location.city,
    location.state,
    location.zip,
    dispatch.zone,
    dispatch.calledinby AS "Called In By",
    dispatch.terms AS "Dispatch Type",
    dispatch.ponum AS "Purchase Order",
    dispatch.recdate AS "Date Received",
    dispatch.rectime AS "Time Received",
    dispatch.recby AS "Received By",
    dispatch.priority,
    dispatch.invoice,
    dispatch.complete AS "Date Completed",
    dispatch.servagrnum AS "Agreement",
        CASE dispatch.servagrnum
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "Has Agreement",
    dispatch.invoiced,
    dispatch.jobnumber AS "Job",
    dispatch.sort AS "Sales Sort",
    dispatch.notes,
    location.contact AS "Contact 1",
    location.phone1 AS "Phone 1",
    location.contact2 AS "Contact 2",
    location.phone2 AS "Phone 2",
    location.contact3 AS "Contact 3",
    location.phone3 AS "Phone 3",
    location.contact4 AS "Contact 4",
    location.phone4 AS "Phone 4",
    location.contact5 AS "Contact 5",
    location.phone5 AS "Phone 5",
    location.contact6 AS "Contact 6",
    location.phone6 AS "Phone 6",
        CASE
            WHEN ((dispatch.complete IS NOT NULL) AND (dispatch.invoiced = 0) AND ((dispatchtype.billable IS NULL) OR (dispatchtype.billable = '-1'::integer))) THEN '-1'::integer
            ELSE 0
        END AS "UnInvoiced Dispatch",
    dispatch.quotesource AS "Quote"
   FROM (((exp_tables.dispatch
     JOIN exp_tables.customer ON (((dispatch.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((dispatch.custno)::text = (location.custno)::text) AND ((dispatch.locno)::text = (location.locno)::text))))
     LEFT JOIN exp_tables.dispatchtype ON (((dispatch.terms)::text = (dispatchtype.name)::text)));


ALTER TABLE exp_tables.viewlistdispatchesnodetail OWNER TO postgres;

--
-- Name: viewlistgeneraljournal; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistgeneraljournal AS
 SELECT finledger.trannumber AS "Transaction Number",
    finledger.trancount AS "Line Counter",
    coa.account AS "Account Number",
    coa."desc" AS "Account Description",
    finledger.amount,
    finledger.units,
        CASE
            WHEN (finledger.amount >= (0)::double precision) THEN finledger.amount
            ELSE (0)::double precision
        END AS "Debit Amount",
        CASE
            WHEN (finledger.amount < (0)::double precision) THEN abs(finledger.amount)
            ELSE (0)::double precision
        END AS "Credit Amount",
    finledger.transdate AS "Transaction Date And Time",
    finledger.transdesc AS "Transaction Description",
    finperiod.periodid AS "Financial Period",
    finledger.docnum AS "Document Number",
    finledger.transmemo AS "Transaction Memo",
    finledger.voided,
    finledger.voiddesc AS "Voided Description",
    finledger.modified AS "Modified Date And Time",
    finledger.modifiedby AS "Modified By",
    finledger.addeddate AS "Date Added And Time",
        CASE finledger.source
            WHEN 0 THEN 'Opening Balance'::text
            WHEN 50 THEN 'Budget'::text
            WHEN 100 THEN 'Estimate'::text
            WHEN 200 THEN 'Journal entry'::text
            WHEN 300 THEN 'Accounts payable'::text
            WHEN 400 THEN 'Sales'::text
            WHEN 500 THEN 'Receivables'::text
            WHEN 600 THEN 'Inventory'::text
            WHEN 700 THEN 'Payroll'::text
            WHEN 800 THEN 'Checking'::text
            WHEN 900 THEN 'Sales Tax'::text
            ELSE ''::text
        END AS "Source Name",
    acctcat."desc" AS "Account Category",
    finledger.active AS "Is Active",
    sldept.dept AS department,
    sldept."desc" AS "Department Name",
    sldept.division,
    jobs.name AS "Job Name",
    jobclass.name AS "Job Class Name",
        CASE finledger.costtype
            WHEN 100 THEN 'Material'::text
            WHEN 150 THEN 'Equipment'::text
            WHEN 200 THEN 'Labor'::text
            WHEN 300 THEN 'Subcontractor'::text
            WHEN 400 THEN 'Permits'::text
            WHEN 500 THEN 'Other'::text
            ELSE ''::text
        END AS "Cost Type",
        CASE finledger.transtype
            WHEN 0 THEN 'General'::text
            WHEN 300 THEN 'Payables Bill'::text
            WHEN 305 THEN 'Payables Credit'::text
            WHEN 400 THEN 'Sales Invoice'::text
            WHEN 405 THEN 'Sales Credit Memo'::text
            WHEN 410 THEN 'Estimate'::text
            WHEN 500 THEN 'Receivables Payment'::text
            WHEN 502 THEN 'Receivables Header Debit'::text
            WHEN 505 THEN 'Receivables Header Credit'::text
            WHEN 600 THEN 'Inventory Purchase'::text
            WHEN 605 THEN 'Inventory Adjustment'::text
            WHEN 610 THEN 'Inventory Transfer'::text
            WHEN 615 THEN 'Vendor Credit'::text
            WHEN 620 THEN 'Job Transfer'::text
            WHEN 800 THEN 'Check'::text
            WHEN 805 THEN 'Deposit'::text
            WHEN 810 THEN 'Interest Income'::text
            WHEN 815 THEN 'Bank Fee'::text
            WHEN 820 THEN 'Credit Card Fee'::text
            WHEN 825 THEN 'Interest Expense'::text
            WHEN 830 THEN 'Credit Card Charge'::text
            ELSE ''::text
        END AS "Type Of Transaction",
    finledger.reference,
    finledger.entryid AS "Internal ID EntryID",
    finledger.transid AS "Internal ID TransID",
    finledger.accountid AS "Internal ID AccountID",
    finperiod.fiscalid AS "Internal ID FiscalID"
   FROM (((((((exp_tables.finledger
     LEFT JOIN exp_tables.coa ON (((finledger.accountid)::text = (coa.accountid)::text)))
     JOIN exp_tables.acctcat ON (((coa.id)::text = (acctcat.id)::text)))
     LEFT JOIN exp_tables.jobs ON (((finledger.jobid)::text = (jobs.jobid)::text)))
     LEFT JOIN exp_tables.sldept ON (((finledger.deptid)::text = (sldept.deptid)::text)))
     LEFT JOIN exp_tables.jobclass ON (((finledger.jobclassid)::text = (jobclass.jobclassid)::text)))
     JOIN exp_tables.finperiod ON (((finledger.periodid)::text = (finperiod.periodid)::text)))
     JOIN exp_tables.finfiscal ON (((finperiod.fiscalid)::text = (finfiscal.fiscalid)::text)))
  WHERE (finledger.source > 100);


ALTER TABLE exp_tables.viewlistgeneraljournal OWNER TO postgres;

--
-- Name: viewlistinvoices; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistinvoices AS
 SELECT sales.invoice,
    sales.regid AS "register id",
    sales.clerk,
    clerkemp.empname AS "clerk name",
    sales.dispatch,
    sales.custno AS customer,
    sales.locno AS location,
    customer.fullname AS "customer full name",
    customer.lastname AS "customer last name",
    customer.firstname AS "customer first name",
    sales.billloc AS "billing location",
        CASE sales.billloc
            WHEN ''::text THEN location.locname
            ELSE billinglocation.locname
        END AS "billing location name",
    sales.pricecode AS "price code",
    (((sales.dept)::text || ' '::text) || (sldept."desc")::text) AS department,
    (sales.dept)::integer AS departmentid,
    sales.invdate AS "invoice date",
    sales.entdate AS "entry date",
    sales.modified AS "last modified date and time",
    sales.shipname AS "shipping name",
    sales.shipaddr1 AS "shipping address 1",
    sales.shipaddr2 AS "shipping address 2",
    sales.shipcsz AS "shipping city state zip",
    sales.invtype AS "invoice type",
    sales.agrmtno AS agreement,
        CASE sales.agrmtno
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "has agreement",
    sales.salesman AS "sales person",
    salespersonemp.empname AS "sales person name",
    sales.jobnumber AS job,
    sales.ponum AS "purchase order",
    sales.sort AS "sales sort",
    sales.hold AS "on hold",
    sales.taxcode AS "tax code",
    sales.printed,
    (sales.invamount)::numeric(12,2) AS "invoice amount",
    sales.slterms AS terms,
    receivab.paidoff AS "paid off date",
    ((((((sales.amtcharge + sales.amtcash) + sales.amtcheck) + sales.amtcreditc) - sales.amtchng) - sales.invamount))::numeric(12,2) AS tax,
        CASE sales.post
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "posted to external",
    sales.quoteorg AS "originating quote",
    (((((sales.amtcharge + sales.amtcash) + sales.amtcheck) + sales.amtcreditc) - sales.amtchng))::numeric(12,2) AS "invoice total"
   FROM ((((((((exp_tables.sales
     LEFT JOIN exp_tables.employee clerkemp ON (((sales.clerk)::text = (clerkemp.empno)::text)))
     JOIN exp_tables.customer ON (((sales.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((sales.custno)::text = (location.custno)::text) AND ((sales.locno)::text = (location.locno)::text))))
     LEFT JOIN exp_tables.location billinglocation ON ((((sales.custno)::text = (billinglocation.custno)::text) AND ((sales.billloc)::text = (billinglocation.locno)::text))))
     JOIN exp_tables.sldept ON (((sales.dept)::text = (sldept.dept)::text)))
     LEFT JOIN exp_tables.employee salespersonemp ON (((sales.salesman)::text = (salespersonemp.empno)::text)))
     LEFT JOIN exp_tables.reasonlostlist ON (((sales.reasonlostid)::text = (reasonlostlist.listid)::text)))
     LEFT JOIN exp_tables.receivab ON ((((sales.custno)::text = (receivab.custno)::text) AND ((sales.invoice)::text = (receivab.invoice)::text))))
  WHERE ((sales.invtype)::text <> 'Quote'::text);


ALTER TABLE exp_tables.viewlistinvoices OWNER TO postgres;

--
-- Name: viewlistitems; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistitems AS
 SELECT inven.part AS item,
    inven.shortdesc AS description,
        CASE inven.type
            WHEN 'I'::text THEN 'Inventory'::text
            WHEN 'P'::text THEN 'History Code'::text
            WHEN 'B'::text THEN 'Billing Code'::text
            ELSE ''::text
        END AS "item type",
    inven.cat AS category,
    inven.subcat AS subcategory,
    inven.averagec AS "average cost",
    inven.bprice AS "base cost",
    inven.lastprice AS "last price",
    inven.cunits AS "cost units",
    inven.buysellr AS "buy sell ratio",
    inven.runits AS "resale units",
    inven.markupcode,
    inven.pricea AS "price a",
    inven.priceb AS "price b",
    inven.pricec AS "price c",
    inven.pricebook AS "price book",
    inven.parttype AS "part type",
    inven.vendor AS "preferred vendor",
    vendor.company AS "vendor company",
    vendor.firstname AS "vendor first name",
        CASE inven.salestype
            WHEN 'M'::text THEN 'Material'::text
            WHEN 'L'::text THEN 'Labor'::text
            WHEN 'O'::text THEN 'Other'::text
            WHEN 'C'::text THEN 'Contract'::text
            WHEN 'D'::text THEN 'Discount'::text
            WHEN 'E'::text THEN 'Equipment'::text
            WHEN 'H'::text THEN 'Helper'::text
            WHEN 'A'::text THEN 'Agreement'::text
            ELSE ''::text
        END AS "sales type",
    inven.notes,
    inven.mfg AS manufacturer,
    inven.model,
    inven.eqtype AS "equipment type",
    inven.billrate AS "billing code rate",
    inven.inactive,
    ( SELECT sum((invenact.quan - invenact.quanout)) AS sum
           FROM exp_tables.invenact
          WHERE (((invenact.part)::text = (inven.part)::text) AND ((invenact.type)::text = 'I'::text))) AS "quantity in stock",
        CASE inven.spiffmethod
            WHEN 0 THEN 'None'::text
            WHEN 100 THEN 'Flat Dollar Value'::text
            WHEN 200 THEN 'Percent of Price'::text
            ELSE ''::text
        END AS "spiff method",
    inven.spiffvalue AS "spiff value",
    inven.itemid AS "internal id itemid"
   FROM (exp_tables.inven
     LEFT JOIN exp_tables.vendor ON (((inven.vendor)::text = (vendor.vendor)::text)));


ALTER TABLE exp_tables.viewlistitems OWNER TO postgres;

--
-- Name: viewlistpurchaseorders; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistpurchaseorders AS
 SELECT po.po,
    po.date,
    po.vendor,
    vendor.company AS "vendor company",
    vendor.firstname AS "vendor first name",
    po.custno AS customer,
    customer.fullname AS "customer full name",
    customer.lastname AS "customer last name",
    customer.firstname AS "customer first name",
    po.locno AS location,
    location.locname AS "location name",
    location.add1 AS "address 1",
    location.add2 AS "address 2",
    location.city,
    location.state,
    location.zip,
    po.shipname AS "shipping name",
    po.shipaddr1 AS "shipping address 1",
    po.shipaddr2 AS "shipping address 2",
    po.shipaddr3 AS "shipping address 3",
    (po.memo)::character varying(200) AS memo,
    po.datereq AS "date requested",
    po.buyer,
    buyeremp.empname AS "buyer name",
    po.terms,
    po.shipvia AS "ship via",
    po.confirmto AS "confirm to",
        CASE po.status
            WHEN 'O'::text THEN 'Open'::text
            WHEN 'C'::text THEN 'Complete'::text
            ELSE ''::text
        END AS "po status",
    po.billed,
        CASE po.transtype
            WHEN 0 THEN 'Purchase Order'::text
            WHEN 1 THEN 'Vendor Credit'::text
            ELSE ''::text
        END AS "transaction type",
    po.orderplaced AS "order placed",
    poled.part,
    poled."desc" AS "part description",
    poled.quan AS quantity,
    poled.received AS "quantity received",
    poled.price,
    poled.amount,
    jobs.name AS job,
    concat(concat(sldept.dept, ' '), sldept."desc") AS department,
    poled.cleared,
    poled.dispatchno AS dispatch
   FROM (((((((exp_tables.po
     JOIN exp_tables.vendor ON (((po.vendor)::text = (vendor.vendor)::text)))
     LEFT JOIN exp_tables.customer ON (((po.custno)::text = (customer.custno)::text)))
     LEFT JOIN exp_tables.location ON ((((po.custno)::text = (location.custno)::text) AND ((po.locno)::text = (location.locno)::text))))
     LEFT JOIN exp_tables.poled ON (((po.po)::text = (poled.po)::text)))
     LEFT JOIN exp_tables.employee buyeremp ON (((po.buyer)::text = (buyeremp.empno)::text)))
     LEFT JOIN exp_tables.jobs ON (((poled.jobid)::text = (jobs.jobid)::text)))
     LEFT JOIN exp_tables.sldept ON (((poled.deptid)::text = (sldept.deptid)::text)));


ALTER TABLE exp_tables.viewlistpurchaseorders OWNER TO postgres;

--
-- Name: viewlistquotes; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistquotes AS
 SELECT sales.invoice AS quote,
    sales.regid AS "register id",
    sales.clerk,
    clerkemp.empname AS "clerk name",
    sales.dispatch,
    sales.custno AS customer,
    sales.locno AS location,
    customer.fullname AS "customer full name",
    customer.lastname AS "customer last name",
    customer.firstname AS "customer first name",
    sales.billloc AS "billing location",
        CASE sales.billloc
            WHEN ''::text THEN location.locname
            ELSE billinglocation.locname
        END AS "billing location name",
    sales.pricecode AS "price code",
    concat(concat(sales.dept, ' '), sldept."desc") AS department,
    sales.invdate AS "quote date",
    sales.entdate AS "entry date",
    sales.modified AS "last modified date and time",
    sales.shipname AS "shipping name",
    sales.shipaddr1 AS "shipping address 1",
    sales.shipaddr2 AS "shipping address 2",
    sales.shipcsz AS "shipping city state zip",
    sales.agrmtno AS agreement,
        CASE sales.agrmtno
            WHEN ''::text THEN 0
            ELSE '-1'::integer
        END AS "has agreement",
    sales.salesman AS "sales person",
    salespersonemp.empname AS "sales person name",
    sales.jobnumber AS job,
    sales.ponum AS "purchase order",
    sales.sort AS "sales sort",
    sales.hold AS "on hold",
    sales.taxcode AS "tax code",
    sales.printed,
    (sales.invamount)::numeric(12,2) AS amount,
    sales.slterms AS terms,
        CASE sales.quotestatus
            WHEN 0 THEN 'Pending'::text
            WHEN 100 THEN 'Accepted'::text
            WHEN 200 THEN 'Rejected'::text
            ELSE ''::text
        END AS "quote status",
    reasonlostlist.value AS "reason rejected",
    ((((((sales.amtcharge + sales.amtcash) + sales.amtcheck) + sales.amtcreditc) - sales.amtchng) - sales.invamount))::numeric(12,2) AS tax,
    (((((sales.amtcharge + sales.amtcash) + sales.amtcheck) + sales.amtcreditc) - sales.amtchng))::numeric(12,2) AS "invoice total"
   FROM (((((((exp_tables.sales
     LEFT JOIN exp_tables.employee clerkemp ON (((sales.clerk)::text = (clerkemp.empno)::text)))
     JOIN exp_tables.customer ON (((sales.custno)::text = (customer.custno)::text)))
     JOIN exp_tables.location ON ((((sales.custno)::text = (location.custno)::text) AND ((sales.locno)::text = (location.locno)::text))))
     LEFT JOIN exp_tables.location billinglocation ON ((((sales.custno)::text = (billinglocation.custno)::text) AND ((sales.billloc)::text = (billinglocation.locno)::text))))
     JOIN exp_tables.sldept ON (((sales.dept)::text = (sldept.dept)::text)))
     LEFT JOIN exp_tables.employee salespersonemp ON (((sales.salesman)::text = (salespersonemp.empno)::text)))
     LEFT JOIN exp_tables.reasonlostlist ON (((sales.reasonlostid)::text = (reasonlostlist.listid)::text)))
  WHERE ((sales.invtype)::text = 'Quote'::text);


ALTER TABLE exp_tables.viewlistquotes OWNER TO postgres;

--
-- Name: viewlistvendorlocations; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewlistvendorlocations AS
 SELECT vendor.vendor,
    vendor.company AS "company name",
    vendor.firstname AS "first name",
    vendor.add1 AS "address 1",
    vendor.add2 AS "address 2",
    vendor.city,
    vendor.state,
    vendor.zip,
    vendor.phone1 AS "phone 1",
    vendor.phone2 AS "phone 2",
    vendor.fax,
    vendor.terms,
    vendor.account,
    vendor.discount,
    vendor.email AS "email address",
    vendor.weburl AS "web address",
    vendor.vendornotes AS "vendor notes",
    vendor.print1099 AS "print 1099",
    vendor.taxid AS "tax id",
    vendor.vendorinactive AS "inactive vendor",
    vendorlocations.locname AS "location name",
    vendorlocations.locadd1 AS "location address 1",
    vendorlocations.locadd2 AS "location address 2",
    vendorlocations.loccity AS "location city",
    vendorlocations.locstate AS "location state",
    vendorlocations.loczip AS "location zip",
    vendorlocations.contactname1 AS "contact 1",
    vendorlocations.contactemail1 AS "email 1",
    vendorlocations.phone1 AS "loc phone 1",
    vendorlocations.extension1 AS "loc ext 1",
    vendorlocations.contactname2 AS "contact 2",
    vendorlocations.contactemail2 AS "email 2",
    vendorlocations.phone2 AS "loc phone 2",
    vendorlocations.extension2 AS "loc ext 2",
    vendorlocations.contactname3 AS "contact 3",
    vendorlocations.contactemail3 AS "email 3",
    vendorlocations.phone3 AS "loc phone 3",
    vendorlocations.extension3 AS "loc ext 3",
    vendorlocations.contactname4 AS "contact 4",
    vendorlocations.contactemail4 AS "email 4",
    vendorlocations.phone4 AS "loc phone 4",
    vendorlocations.extension4 AS "loc ext 4",
    vendorlocations.contactname5 AS "contact 5",
    vendorlocations.contactemail5 AS "email 5",
    vendorlocations.phone5 AS "loc phone 5",
    vendorlocations.extension5 AS "loc ext 5",
    vendorlocations.contactname6 AS "contact 6",
    vendorlocations.contactemail6 AS "email 6",
    vendorlocations.phone6 AS "loc phone 6",
    vendorlocations.extension6 AS "loc ext 6",
    vendorlocations.locinactive AS "inactive location",
    vendorlocations.listid AS "internal id locationid"
   FROM (exp_tables.vendor
     JOIN exp_tables.vendorlocations ON (((vendor.vendor)::text = (vendorlocations.vendor)::text)));


ALTER TABLE exp_tables.viewlistvendorlocations OWNER TO postgres;

--
-- Name: viewpayablesledger; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewpayablesledger AS
 SELECT viewgeneraljournal.transid,
    viewgeneraljournal.entryid,
    viewgeneraljournal.periodid,
    viewgeneraljournal.accrualvendor,
    viewgeneraljournal.vendorcompany,
    viewgeneraljournal.vendorfirstname,
    viewgeneraljournal.vendorphone,
    viewgeneraljournal.transdate,
    viewgeneraljournal.transdesc,
    viewgeneraljournal.duedate,
    viewgeneraljournal.amount,
    viewgeneraljournal.docnum,
    viewgeneraljournal.discountdate,
    viewgeneraljournal.discountamount,
    viewgeneraljournal.discounttaken,
    viewgeneraljournal.reference,
    viewgeneraljournal.accountid,
    viewgeneraljournal.account,
    viewgeneraljournal.transtypename,
    viewgeneraljournal.accrualtype,
    viewgeneraljournal.billreceived,
    viewgeneraljournal.addeddate,
    viewgeneraljournal.accrualpaidoff,
    viewgeneraljournal.source,
    viewgeneraljournal.transtype,
    viewgeneraljournal.modified
   FROM exp_tables.viewgeneraljournal
  WHERE ((viewgeneraljournal.voided = 0) AND (viewgeneraljournal.active = '-1'::integer) AND ((viewgeneraljournal.source = 0) OR (viewgeneraljournal.source > 100)));


ALTER TABLE exp_tables.viewpayablesledger OWNER TO postgres;

--
-- Name: viewregister; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewregister AS
 SELECT viewgeneraljournal.accountid,
    viewgeneraljournal.account,
    viewgeneraljournal.accountdesc,
    viewgeneraljournal.entryid,
    viewgeneraljournal.transid,
    viewgeneraljournal.fiscalid,
    viewgeneraljournal.voided,
    viewgeneraljournal.transdate,
    viewgeneraljournal.transdesc,
    viewgeneraljournal.transmemo,
    viewgeneraljournal.docnum,
    viewgeneraljournal.cleared,
    viewgeneraljournal.amount,
    viewgeneraljournal.jobid,
    viewgeneraljournal.cleareddate,
    viewgeneraljournal.acctcatid,
    viewgeneraljournal.debit,
    viewgeneraljournal.credit,
    viewgeneraljournal.recondate,
    viewgeneraljournal.reconbeginbal,
    viewgeneraljournal.reconendbal,
    viewgeneraljournal.periodid,
    viewgeneraljournal.source,
    viewgeneraljournal.checktiecustno,
    viewgeneraljournal.checktievendorno,
    viewgeneraljournal.checktieempno
   FROM exp_tables.viewgeneraljournal
  WHERE ((viewgeneraljournal.voided = 0) AND (viewgeneraljournal.active = '-1'::integer) AND ((viewgeneraljournal.source = 0) OR (viewgeneraljournal.source > 100)));


ALTER TABLE exp_tables.viewregister OWNER TO postgres;

--
-- Name: viewvendorpayments; Type: VIEW; Schema: exp_tables; Owner: postgres
--

CREATE VIEW exp_tables.viewvendorpayments AS
 SELECT v.vendorfirstname,
    v.vendorcompany,
    v.accrualvendor,
    v.periodid,
    v.transid,
    v.transdate,
    v.amount,
    v.transtypename,
    v.docnum,
    v.discounttaken,
    v.account,
    v.trancount,
    v.voided,
    v.active,
    v.source,
    v.transtype,
    f_org."DocNum" AS orgdocnum,
    f_org."TransDate" AS orgdate
   FROM (exp_tables.viewgeneraljournal v
     LEFT JOIN LATERAL ( SELECT f.docnum AS "DocNum",
            f.transdate AS "TransDate"
           FROM exp_tables.finledger f
          WHERE (((f.entryid)::text = (v.accruallinkentryid)::text) AND (f.voided = 0))
          ORDER BY f.transdate DESC NULLS LAST
         LIMIT 1) f_org ON (true));


ALTER TABLE exp_tables.viewvendorpayments OWNER TO postgres;

--
-- Name: warehous; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.warehous (
    wh character varying(4),
    "desc" character varying(20),
    inactive smallint NOT NULL
);


ALTER TABLE exp_tables.warehous OWNER TO postgres;

--
-- Name: weblog; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.weblog (
    custno character varying(7),
    locno character varying(5),
    logdatetime timestamp without time zone,
    action character varying(1),
    notes text
);


ALTER TABLE exp_tables.weblog OWNER TO postgres;

--
-- Name: xlogrec; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.xlogrec (
    id character varying(36),
    transdate timestamp without time zone,
    entryid character varying(36),
    invoice character varying(10),
    amount double precision NOT NULL,
    transid character varying(36),
    memo text,
    counter integer NOT NULL,
    custno character varying(7)
);


ALTER TABLE exp_tables.xlogrec OWNER TO postgres;

--
-- Name: zipcodes; Type: TABLE; Schema: exp_tables; Owner: postgres
--

CREATE TABLE exp_tables.zipcodes (
    zip character varying(10),
    city character varying(25),
    state character varying(2)
);


ALTER TABLE exp_tables.zipcodes OWNER TO postgres;

--
-- Name: finledger_voided_transtype_addeddate_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX finledger_voided_transtype_addeddate_idx ON exp_tables.finledger USING btree (addeddate DESC) WHERE ((voided = 0) AND (transtype = 805));


--
-- Name: idx_acctcat_group_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_acctcat_group_id_idx ON exp_tables.acctcat USING btree ("group", id);


--
-- Name: idx_acctcat_id; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_acctcat_id ON exp_tables.acctcat USING btree (id);


--
-- Name: idx_activity_custno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_activity_custno_idx ON exp_tables.activity USING btree (custno);


--
-- Name: idx_activity_date_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_activity_date_idx ON exp_tables.activity USING btree (date);


--
-- Name: idx_ahsstatus_created_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_ahsstatus_created_idx ON exp_tables.ahsstatus USING btree (created);


--
-- Name: idx_ahsstatus_handled_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_ahsstatus_handled_idx ON exp_tables.ahsstatus USING btree (handled);


--
-- Name: idx_billinglocation_custno_locno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_billinglocation_custno_locno ON exp_tables.location USING btree (custno, locno);


--
-- Name: idx_calleridalt_phone_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_calleridalt_phone_idx ON exp_tables.calleridalt USING btree (phone);


--
-- Name: idx_coa_accountid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_coa_accountid ON exp_tables.coa USING btree (accountid);


--
-- Name: idx_coa_accountlookup_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_coa_accountlookup_idx ON exp_tables.coa USING btree (accountid, account, id, "desc", parentid, accountsort, type, recondate, reconbeginbal, reconendbal);


--
-- Name: idx_customer_acctkey_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_acctkey_idx ON exp_tables.customer USING btree (acctkey);


--
-- Name: idx_customer_custno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_custno ON exp_tables.customer USING btree (custno);


--
-- Name: idx_customer_custno_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_custno_text ON exp_tables.customer USING btree (((custno)::text));


--
-- Name: idx_customer_fullname_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_fullname_idx ON exp_tables.customer USING btree (fullname);


--
-- Name: idx_customer_listid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_listid_idx ON exp_tables.customer USING btree (listid);


--
-- Name: idx_customer_name_lastname_firstname_custno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_name_lastname_firstname_custno_idx ON exp_tables.customer USING btree (lastname, firstname, custno);


--
-- Name: idx_customer_optcity_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_optcity_idx ON exp_tables.customer USING btree (city);


--
-- Name: idx_customer_optcustname_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_optcustname_idx ON exp_tables.customer USING btree (custno, lastname, firstname);


--
-- Name: idx_customer_optkey_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_optkey_idx ON exp_tables.customer USING btree (acctkey);


--
-- Name: idx_customer_optpost_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_optpost_idx ON exp_tables.customer USING btree (post);


--
-- Name: idx_customer_optstate_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_customer_optstate_idx ON exp_tables.customer USING btree (state);


--
-- Name: idx_dispatch_active_recent; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_active_recent ON exp_tables.dispatch USING btree (recdate DESC) WHERE (complete IS NULL);


--
-- Name: idx_dispatch_covering; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_covering ON exp_tables.dispatch USING btree (recdate DESC, ((custno)::text)) INCLUDE (locno, invoice);


--
-- Name: idx_dispatch_custno_cast_recdate_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_custno_cast_recdate_desc ON exp_tables.dispatch USING btree (COALESCE(
CASE
    WHEN ((custno)::text ~ '^[0-9]+$'::text) THEN (custno)::integer
    ELSE NULL::integer
END, 0), recdate DESC NULLS LAST);


--
-- Name: idx_dispatch_custno_text_locno_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_custno_text_locno_text ON exp_tables.dispatch USING btree (((custno)::text), ((locno)::text));


--
-- Name: idx_dispatch_custorder_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_custorder_idx ON exp_tables.dispatch USING btree (custno);


--
-- Name: idx_dispatch_dispatch; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_dispatch ON exp_tables.dispatch USING btree (dispatch);


--
-- Name: idx_dispatch_dispatch_complete; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_dispatch_complete ON exp_tables.dispatch USING btree (dispatch) WHERE (complete IS NOT NULL);


--
-- Name: idx_dispatch_invoice_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_invoice_idx ON exp_tables.dispatch USING btree (invoice);


--
-- Name: idx_dispatch_optcomplet_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_optcomplet_idx ON exp_tables.dispatch USING btree (complete);


--
-- Name: idx_dispatch_optinv_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_optinv_idx ON exp_tables.dispatch USING btree (invoiced);


--
-- Name: idx_dispatch_recdate_covering; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_recdate_covering ON exp_tables.dispatch USING btree (recdate DESC NULLS LAST, dispatch) INCLUDE (custno, locno, zone, calledinby, ponum, rectime, recby, priority, complete, invoice, invoiced);


--
-- Name: idx_dispatch_recdate_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_recdate_desc ON exp_tables.dispatch USING btree (recdate DESC);


--
-- Name: idx_dispatch_recdate_desc_pagination; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_recdate_desc_pagination ON exp_tables.dispatch USING btree (recdate DESC NULLS LAST, dispatch);


--
-- Name: idx_dispatch_servagr_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatch_servagr_idx ON exp_tables.dispatch USING btree (servagrnum);


--
-- Name: idx_dispatchtype_name_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispatchtype_name_text ON exp_tables.dispatchtype USING btree (((name)::text));


--
-- Name: idx_dispcomp_count_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispcomp_count_idx ON exp_tables.dispcomp USING btree (count);


--
-- Name: idx_dispparts_prod_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispparts_prod_idx ON exp_tables.dispparts USING btree (prod);


--
-- Name: idx_dispparts_wh_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_dispparts_wh_idx ON exp_tables.dispparts USING btree (wh);


--
-- Name: idx_disptech_dispatch; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_dispatch ON exp_tables.disptech USING btree (dispatch);


--
-- Name: idx_disptech_dispatch_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_dispatch_text ON exp_tables.disptech USING btree (((dispatch)::text));


--
-- Name: idx_disptech_dispatch_timeoff; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_dispatch_timeoff ON exp_tables.disptech USING btree (dispatch) WHERE (timeoff IS NOT NULL);


--
-- Name: idx_disptech_edb_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_edb_idx ON exp_tables.disptech USING btree (serviceman, tpromdate, tpromtime, priority);


--
-- Name: idx_disptech_optdate_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_optdate_idx ON exp_tables.disptech USING btree (dispdate);


--
-- Name: idx_disptech_optstatus_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_optstatus_idx ON exp_tables.disptech USING btree (status);


--
-- Name: idx_disptech_serviceman_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_serviceman_text ON exp_tables.disptech USING btree (((serviceman)::text));


--
-- Name: idx_disptech_sortdate_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_sortdate_idx ON exp_tables.disptech USING btree (sortdate);


--
-- Name: idx_disptech_timeentrycreated_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_disptech_timeentrycreated_idx ON exp_tables.disptech USING btree (timeentrycreated);


--
-- Name: idx_docattachidx_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_docattachidx_id_idx ON exp_tables.docattachidx USING btree (id);


--
-- Name: idx_docwptemplate_docname_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_docwptemplate_docname_idx ON exp_tables.docwptemplate USING btree (name);


--
-- Name: idx_docwptemplate_source_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_docwptemplate_source_idx ON exp_tables.docwptemplate USING btree (source);


--
-- Name: idx_emailtpl_user_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_emailtpl_user_idx ON exp_tables.emailtpl USING btree ("user");


--
-- Name: idx_employee_acctkey_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_acctkey_idx ON exp_tables.employee USING btree (acctkey);


--
-- Name: idx_employee_crew_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_crew_idx ON exp_tables.employee USING btree (crew);


--
-- Name: idx_employee_empno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_empno ON exp_tables.employee USING btree (empno);


--
-- Name: idx_employee_empno_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_empno_text ON exp_tables.employee USING btree (((empno)::text));


--
-- Name: idx_employee_gpstechlink_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_gpstechlink_idx ON exp_tables.employee USING btree (gpstechlink);


--
-- Name: idx_employee_listid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_listid_idx ON exp_tables.employee USING btree (listid);


--
-- Name: idx_employee_optempmarital_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_optempmarital_idx ON exp_tables.employee USING btree (empno, maritalstatus);


--
-- Name: idx_employee_search_empno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employee_search_empno_idx ON exp_tables.employee USING btree (search, empno);


--
-- Name: idx_employeepay_payitemid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_employeepay_payitemid_idx ON exp_tables.employeepay USING btree (payitemid);


--
-- Name: idx_finfiscal_fiscalid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finfiscal_fiscalid ON exp_tables.finfiscal USING btree (fiscalid);


--
-- Name: idx_finledger_accountid_periodid_active_voided; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accountid_periodid_active_voided ON exp_tables.finledger USING btree (accountid, periodid, active, voided);


--
-- Name: idx_finledger_accountid_transdate_trannumber; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accountid_transdate_trannumber ON exp_tables.finledger USING btree (accountid, transdate, trannumber);


--
-- Name: idx_finledger_accruallink_partial_covering; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accruallink_partial_covering ON exp_tables.finledger USING btree (accruallinkentryid, amount) WHERE (voided = 0);


--
-- Name: idx_finledger_accruallinkentryid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accruallinkentryid ON exp_tables.finledger USING btree (accruallinkentryid);


--
-- Name: idx_finledger_accruallinkentryid_voided; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accruallinkentryid_voided ON exp_tables.finledger USING btree (accruallinkentryid, voided);


--
-- Name: idx_finledger_accrualtype_voided_accrualvendor; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accrualtype_voided_accrualvendor ON exp_tables.finledger USING btree (accrualtype, voided, accrualvendor);


--
-- Name: idx_finledger_accrualtype_voided_paidoff; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accrualtype_voided_paidoff ON exp_tables.finledger USING btree (accrualtype, voided, accrualpaidoff);


--
-- Name: idx_finledger_accrualvendor; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_accrualvendor ON exp_tables.finledger USING btree (accrualvendor);


--
-- Name: idx_finledger_active_docnum_source_voided; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_active_docnum_source_voided ON exp_tables.finledger USING btree (active, docnum, source, voided);


--
-- Name: idx_finledger_entryid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_entryid ON exp_tables.finledger USING btree (entryid);


--
-- Name: idx_finledger_fetch_entries; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_fetch_entries ON exp_tables.finledger USING btree (transid, voided, transdate DESC, trannumber DESC, trancount) WHERE (voided = 0);


--
-- Name: idx_finledger_jobclassid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_jobclassid ON exp_tables.finledger USING btree (jobclassid);


--
-- Name: idx_finledger_main_filter; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_main_filter ON exp_tables.finledger USING btree (voided, active, source, accountid, periodid, jobid, deptid, itemid);


--
-- Name: idx_finledger_payitemid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_payitemid ON exp_tables.finledger USING btree (payitemid);


--
-- Name: idx_finledger_periodid_voided_active_accountid_source; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_periodid_voided_active_accountid_source ON exp_tables.finledger USING btree (periodid, voided, active, accountid, source);


--
-- Name: idx_finledger_relatedtransid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_relatedtransid ON exp_tables.finledger USING btree (relatedtransid);


--
-- Name: idx_finledger_trannumber; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_trannumber ON exp_tables.finledger USING btree (trannumber);


--
-- Name: idx_finledger_trannumber_covering; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_trannumber_covering ON exp_tables.finledger USING btree (trannumber DESC, transid) INCLUDE (transdate) WHERE (voided = 0);


--
-- Name: idx_finledger_trannumber_scan_fast; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_trannumber_scan_fast ON exp_tables.finledger USING btree (trannumber DESC, transid) WHERE (voided = 0);


--
-- Name: idx_finledger_transid_trannumber; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finledger_transid_trannumber ON exp_tables.finledger USING btree (transid, trannumber DESC);


--
-- Name: idx_finperiod_periodid_fiscalid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_finperiod_periodid_fiscalid ON exp_tables.finperiod USING btree (periodid, fiscalid);


--
-- Name: idx_inven_itemid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_inven_itemid ON exp_tables.inven USING btree (itemid);


--
-- Name: idx_invenact_new_part_wh_type_i; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_new_part_wh_type_i ON exp_tables.invenact USING btree (part, wh) INCLUDE (quan, quanout) WHERE (((type)::text = 'I'::text) AND (wh IS NOT NULL));


--
-- Name: idx_invenact_part_period_wh_count_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_period_wh_count_desc ON exp_tables.invenact USING btree (part, period, wh, count DESC);


--
-- Name: idx_invenact_part_wh_date; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_wh_date ON exp_tables.invenact USING btree (part, wh, date);


--
-- Name: idx_invenact_part_wh_date_base; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_wh_date_base ON exp_tables.invenact USING btree (part, wh, date DESC) WHERE ((type)::text = 'X'::text);


--
-- Name: idx_invenact_part_wh_date_inc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_wh_date_inc ON exp_tables.invenact USING btree (part, wh, date) INCLUDE (quan, type);


--
-- Name: idx_invenact_part_wh_date_quan; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_wh_date_quan ON exp_tables.invenact USING btree (part, wh, date) INCLUDE (quan) WHERE (wh IS NOT NULL);


--
-- Name: idx_invenact_part_wh_date_x; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_part_wh_date_x ON exp_tables.invenact USING btree (part, wh, date DESC) WHERE (((type)::text = 'X'::text) AND (wh IS NOT NULL) AND (date IS NOT NULL));


--
-- Name: idx_invenact_x_exists_part_wh; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_invenact_x_exists_part_wh ON exp_tables.invenact USING btree (part, wh) WHERE (((type)::text = 'X'::text) AND (date IS NOT NULL) AND (wh IS NOT NULL));


--
-- Name: idx_jobclass_jobclassid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_jobclass_jobclassid ON exp_tables.jobclass USING btree (jobclassid);


--
-- Name: idx_jobs_jobid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_jobs_jobid ON exp_tables.jobs USING btree (jobid);


--
-- Name: idx_location_custno_locno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_location_custno_locno ON exp_tables.location USING btree (custno, locno);


--
-- Name: idx_location_custno_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_location_custno_text ON exp_tables.location USING btree (((custno)::text));


--
-- Name: idx_location_locno_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_location_locno_text ON exp_tables.location USING btree (((locno)::text));


--
-- Name: idx_po_date_desc_nullslast; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_po_date_desc_nullslast ON exp_tables.po USING btree (date DESC NULLS LAST);


--
-- Name: idx_prpayitem_itemid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_prpayitem_itemid ON exp_tables.prpayitem USING btree (itemid);


--
-- Name: idx_reasonlostlist_listid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_reasonlostlist_listid ON exp_tables.reasonlostlist USING btree (listid);


--
-- Name: idx_receivab_custno_invoice; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_receivab_custno_invoice ON exp_tables.receivab USING btree (custno, invoice);


--
-- Name: idx_sales_billloc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_billloc ON exp_tables.sales USING btree (billloc);


--
-- Name: idx_sales_clerk; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_clerk ON exp_tables.sales USING btree (clerk);


--
-- Name: idx_sales_covering_list; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_covering_list ON exp_tables.sales USING btree (invdate DESC, invtype) INCLUDE (invoice, custno, locno, invamount, amtcharge, dept, transid);


--
-- Name: idx_sales_custno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_custno ON exp_tables.sales USING btree (custno);


--
-- Name: idx_sales_custno_cast_invdate_desc_not_quote; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_custno_cast_invdate_desc_not_quote ON exp_tables.sales USING btree (COALESCE(
CASE
    WHEN ((custno)::text ~ '^[0-9]+$'::text) THEN (custno)::integer
    ELSE NULL::integer
END, 0), invdate DESC NULLS LAST) WHERE (NOT (upper((invtype)::text) = upper('quote'::text)));


--
-- Name: idx_sales_custno_invdate; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_custno_invdate ON exp_tables.sales USING btree (custno, invdate DESC);


--
-- Name: idx_sales_dept; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_dept ON exp_tables.sales USING btree (dept);


--
-- Name: idx_sales_dept_locno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_dept_locno ON exp_tables.sales USING btree (dept, locno);


--
-- Name: idx_sales_invdate_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_invdate_desc ON exp_tables.sales USING btree (invdate DESC NULLS LAST);


--
-- Name: idx_sales_invoice_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_invoice_text ON exp_tables.sales USING btree (((invoice)::text));


--
-- Name: idx_sales_invtype; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_invtype ON exp_tables.sales USING btree (invtype);


--
-- Name: idx_sales_invtype_invdate; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_invtype_invdate ON exp_tables.sales USING btree (invtype, invdate DESC);


--
-- Name: idx_sales_locno; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_locno ON exp_tables.sales USING btree (locno);


--
-- Name: idx_sales_modified_asc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_modified_asc ON exp_tables.sales USING btree (modified);


--
-- Name: idx_sales_modified_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_modified_desc ON exp_tables.sales USING btree (modified DESC NULLS LAST);


--
-- Name: idx_sales_month_trunc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_month_trunc ON exp_tables.sales USING btree (date_trunc('month'::text, invdate));


--
-- Name: idx_sales_period_invdate; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_period_invdate ON exp_tables.sales USING btree (period, invdate DESC);


--
-- Name: idx_sales_salesman; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_salesman ON exp_tables.sales USING btree (salesman);


--
-- Name: idx_sales_transid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sales_transid ON exp_tables.sales USING btree (transid);


--
-- Name: idx_salesled_covering_details; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_covering_details ON exp_tables.salesled USING btree (invoice, count) INCLUDE (prod, quan, price, amount, cost, wh, entryid);


--
-- Name: idx_salesled_entryid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_entryid ON exp_tables.salesled USING btree (entryid);


--
-- Name: idx_salesled_invoice_count; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_invoice_count ON exp_tables.salesled USING btree (invoice, count);


--
-- Name: idx_salesled_invoice_text; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_invoice_text ON exp_tables.salesled USING btree (((invoice)::text));


--
-- Name: idx_salesled_prod_invoice; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_prod_invoice ON exp_tables.salesled USING btree (prod, invoice);


--
-- Name: idx_salesled_wh_invoice; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_salesled_wh_invoice ON exp_tables.salesled USING btree (wh, invoice);


--
-- Name: idx_sldept_dept; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sldept_dept ON exp_tables.sldept USING btree (dept);


--
-- Name: idx_sldept_deptid; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_sldept_deptid ON exp_tables.sldept USING btree (deptid);


--
-- Name: idx_vendor_vendor; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_vendor_vendor ON exp_tables.vendor USING btree (vendor);


--
-- Name: idx_warehous_desc; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_warehous_desc ON exp_tables.warehous USING btree ("desc");


--
-- Name: idx_warehous_desc_wh_int; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_warehous_desc_wh_int ON exp_tables.warehous USING btree ("desc", ((wh)::integer));


--
-- Name: idx_warehous_wh_int; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE INDEX idx_warehous_wh_int ON exp_tables.warehous USING btree (((wh)::integer));


--
-- Name: uidx_acctcat_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_acctcat_id_idx ON exp_tables.acctcat USING btree (id);


--
-- Name: uidx_acctsort_account_dept_key_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_acctsort_account_dept_key_idx ON exp_tables.acctsort USING btree (account, dept, key);


--
-- Name: uidx_actionlist_listid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_actionlist_listid_idx ON exp_tables.actionlist USING btree (listid);


--
-- Name: uidx_actionlist_value_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_actionlist_value_idx ON exp_tables.actionlist USING btree (value);


--
-- Name: uidx_activity_activityid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_activity_activityid_idx ON exp_tables.activity USING btree (activityid);


--
-- Name: uidx_actsetup_key_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_actsetup_key_idx ON exp_tables.actsetup USING btree (key);


--
-- Name: uidx_ahsstatus_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_ahsstatus_id_idx ON exp_tables.ahsstatus USING btree (id);


--
-- Name: uidx_appstats_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_appstats_id_idx ON exp_tables.appstats USING btree (id);


--
-- Name: uidx_calleridalt_custno_locno_phone_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_calleridalt_custno_locno_phone_idx ON exp_tables.calleridalt USING btree (custno, locno, phone);


--
-- Name: uidx_coa_account_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_coa_account_idx ON exp_tables.coa USING btree (account);


--
-- Name: uidx_coa_accountid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_coa_accountid_idx ON exp_tables.coa USING btree (accountid);


--
-- Name: uidx_collactn_code_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_collactn_code_idx ON exp_tables.collactn USING btree (code);


--
-- Name: uidx_collectn_custno_date_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_collectn_custno_date_idx ON exp_tables.collectn USING btree (custno, date);


--
-- Name: uidx_colltemp_custno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_colltemp_custno_idx ON exp_tables.colltemp USING btree (custno);


--
-- Name: uidx_company_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_company_name_idx ON exp_tables.company USING btree (name);


--
-- Name: uidx_counter_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_counter_name_idx ON exp_tables.counter USING btree (name);


--
-- Name: uidx_credcard_custno_serial_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_credcard_custno_serial_idx ON exp_tables.credcard USING btree (custno, serial);


--
-- Name: uidx_creditratings_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_creditratings_name_idx ON exp_tables.creditratings USING btree (name);


--
-- Name: uidx_custflds_tblname_fldnum_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_custflds_tblname_fldnum_idx ON exp_tables.custflds USING btree (tblname, fldnum);


--
-- Name: uidx_custlaborrate_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_custlaborrate_id_idx ON exp_tables.custlaborrate USING btree (id);


--
-- Name: uidx_custlaborrate_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_custlaborrate_name_idx ON exp_tables.custlaborrate USING btree (name);


--
-- Name: uidx_customer_custno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_customer_custno_idx ON exp_tables.customer USING btree (custno);


--
-- Name: uidx_customview_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_customview_name_idx ON exp_tables.customview USING btree (name);


--
-- Name: uidx_customview_viewid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_customview_viewid_idx ON exp_tables.customview USING btree (viewid);


--
-- Name: uidx_custsort_custno_locno_counter_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_custsort_custno_locno_counter_idx ON exp_tables.custsort USING btree (custno, locno, counter);


--
-- Name: uidx_depinfo_key_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_depinfo_key_idx ON exp_tables.depinfo USING btree (key);


--
-- Name: uidx_deprecn_assetnum_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_deprecn_assetnum_idx ON exp_tables.deprecn USING btree (assetnum);


--
-- Name: uidx_dispatch_dispatch_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispatch_dispatch_idx ON exp_tables.dispatch USING btree (dispatch);


--
-- Name: uidx_dispatch_trigger_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispatch_trigger_id_idx ON exp_tables.dispatch_trigger USING btree (id);


--
-- Name: uidx_dispatchpriority_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispatchpriority_name_idx ON exp_tables.dispatchpriority USING btree (name);


--
-- Name: uidx_dispatchtype_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispatchtype_name_idx ON exp_tables.dispatchtype USING btree (name);


--
-- Name: uidx_dispcomp_dispatch_count_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispcomp_dispatch_count_idx ON exp_tables.dispcomp USING btree (dispatch, count);


--
-- Name: uidx_displock_dispatch_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_displock_dispatch_idx ON exp_tables.displock USING btree (dispatch);


--
-- Name: uidx_dispparts_dispatch_counter_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispparts_dispatch_counter_idx ON exp_tables.dispparts USING btree (dispatch, counter);


--
-- Name: uidx_dispscrn_screen_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispscrn_screen_idx ON exp_tables.dispscrn USING btree (screen);


--
-- Name: uidx_disptech_dispatch_counter_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_disptech_dispatch_counter_idx ON exp_tables.disptech USING btree (dispatch, counter);


--
-- Name: uidx_dispuser_user_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_dispuser_user_idx ON exp_tables.dispuser USING btree ("user");


--
-- Name: uidx_docwptemplate_id_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_docwptemplate_id_idx ON exp_tables.docwptemplate USING btree (id);


--
-- Name: uidx_edbupdate_user_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_edbupdate_user_idx ON exp_tables.edbupdate USING btree ("user");


--
-- Name: uidx_emailinv_counter_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_emailinv_counter_idx ON exp_tables.emailinv USING btree (counter);


--
-- Name: uidx_emailpo_counter_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_emailpo_counter_idx ON exp_tables.emailpo USING btree (counter);


--
-- Name: uidx_emailtpl_name_source_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_emailtpl_name_source_idx ON exp_tables.emailtpl USING btree (name, source);


--
-- Name: uidx_emailusr_user_source_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_emailusr_user_source_idx ON exp_tables.emailusr USING btree ("user", source);


--
-- Name: uidx_empcommcodes_itemid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_empcommcodes_itemid_idx ON exp_tables.empcommcodes USING btree (itemid);


--
-- Name: uidx_empcommcodes_name_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_empcommcodes_name_idx ON exp_tables.empcommcodes USING btree (name);


--
-- Name: uidx_employee_empno_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_employee_empno_idx ON exp_tables.employee USING btree (empno);


--
-- Name: uidx_employeepay_empno_payitemid_idx; Type: INDEX; Schema: exp_tables; Owner: postgres
--

CREATE UNIQUE INDEX uidx_employeepay_empno_payitemid_idx ON exp_tables.employeepay USING btree (empno, payitemid);


--
-- PostgreSQL database dump complete
--

