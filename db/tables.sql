-- All tables, keys, indexes, and constraints for authz_umichlib in MariaDB.
CREATE TABLE aa_user(
	userid		 		VARCHAR(64)	NOT NULL,
	personalTitle			VARCHAR(32),
	givenName			VARCHAR(32)	NOT NULL,
	initials			VARCHAR(32),
	surname				VARCHAR(32)	NOT NULL,
	rfc822Mailbox			VARCHAR(64),
	organizationalUnitName		VARCHAR(128),
	postalAddress                   VARCHAR(128),
	localityName			VARCHAR(32),
	stateOrProvinceName             VARCHAR(32),
	postalCode			VARCHAR(9),
	countryName			VARCHAR(32),
	telephoneNumber			VARCHAR(32),
	organizationalStatus		VARCHAR(8),
	dlpsCourse			VARCHAR(8),
	dlpsKey				VARCHAR(32)	NOT NULL,
	userPassword			VARCHAR(32)	NOT NULL,
	manager				INT,
	description			VARCHAR(2048),
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
	dlpsExpiryTime  		DATETIME,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (userid)
);

CREATE TABLE aa_user_grp(
	uniqueIdentifier		INT	NOT NULL,
	commonName			VARCHAR(128)	NOT NULL,
	manager				INT,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (uniqueIdentifier)
);

CREATE TABLE aa_inst(
	uniqueIdentifier		INT	NOT NULL AUTO_INCREMENT,
	organizationName		VARCHAR(128)	NOT NULL,
	manager				INT,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (uniqueIdentifier)
);

CREATE TABLE aa_is_member_of_inst(
	userid				VARCHAR(64)	NOT NULL,
	inst				INT	NOT NULL,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (userid, inst)
);

CREATE TABLE aa_is_member_of_grp(
	userid				VARCHAR(64),
	user_grp			INT	NOT NULL,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (userid, user_grp)
);

CREATE TABLE aa_coll(
	uniqueIdentifier		VARCHAR(32)	NOT NULL,
	commonName			VARCHAR(128)	NOT NULL,
	description			VARCHAR(128)	NOT NULL,
	dlpsClass			VARCHAR(10),
	dlpsSource			VARCHAR(128)  	NOT NULL,
	dlpsAuthenMethod		VARCHAR(3)	NOT NULL,
	dlpsAuthzType			CHAR(1)    	NOT NULL,
        dlpsPartlyPublic		CHAR(1)         NOT NULL,
	manager				INT,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (uniqueIdentifier)
);

CREATE TABLE aa_coll_obj(
	dlpsServer			VARCHAR(128)	NOT NULL,
	dlpsPath			VARCHAR(128)	NOT NULL,
	coll				VARCHAR(32)	NOT NULL,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (dlpsServer, dlpsPath, coll)
);

CREATE TABLE aa_network(
	uniqueIdentifier		INT	NOT NULL AUTO_INCREMENT,
	dlpsDNSName			VARCHAR(128),
	dlpsCIDRAddress			VARCHAR(18),
	dlpsAddressStart		INT UNSIGNED,
	dlpsAddressEnd  		INT UNSIGNED,
	dlpsAccessSwitch		VARCHAR(5)	NOT NULL,
	coll				VARCHAR(32),
	inst				INT,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (uniqueIdentifier)
);

CREATE TABLE aa_may_access(
	uniqueIdentifier		INT	NOT NULL AUTO_INCREMENT,
	userid				VARCHAR(64),
	user_grp			INT,
	inst				INT,
	coll				VARCHAR(32)	NOT NULL,
	lastModifiedTime		TIMESTAMP	NOT NULL,
	lastModifiedBy			VARCHAR(64)	NOT NULL,
	dlpsExpiryTime  		TIMESTAMP,
        dlpsDeleted                     CHAR(1)         NOT NULL,
	PRIMARY KEY (uniqueIdentifier)
);

-- additional indexes:

ALTER TABLE aa_network ADD INDEX (dlpsAddressStart);
ALTER TABLE aa_network ADD INDEX (dlpsAddressEnd);
ALTER TABLE aa_coll_obj ADD INDEX (dlpsPath);

-- additional constraints
ALTER TABLE aa_user ADD CONSTRAINT user_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_user_grp ADD CONSTRAINT user_grp_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_inst ADD CONSTRAINT inst_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_is_member_of_inst ADD CONSTRAINT is_member_of_inst_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_is_member_of_grp ADD CONSTRAINT is_member_of_grp_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_coll ADD CONSTRAINT coll_dlpsAuthenMethod
  CHECK (dlpsAuthenMethod IN ('any', 'ip', 'pw'));

ALTER TABLE aa_coll ADD CONSTRAINT coll_dlpsAuthzType
  CHECK (dlpsAuthzType IN ('n', 'd', 'm'));

ALTER TABLE aa_coll ADD CONSTRAINT coll_dlpsPartlyPublic
  CHECK (dlpsPartlyPublic IN ('t', 'f'));

ALTER TABLE aa_coll ADD CONSTRAINT coll_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_coll_obj ADD CONSTRAINT coll_obj_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_network ADD CONSTRAINT network_dlpsAccessSwitch
  CHECK (dlpsAccessSwitch IN ('allow', 'deny'));

ALTER TABLE aa_network ADD CONSTRAINT network_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

ALTER TABLE aa_may_access ADD CONSTRAINT may_access_dlpsDeleted
  CHECK (dlpsDeleted IN ('t', 'f'));

