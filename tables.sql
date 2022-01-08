CREATE DATABASE btpw;

USE btpw;

DROP TABLE IF EXISTS Entries;
DROP TABLE IF EXISTS Users;
DROP TRIGGER IF EXISTS entryTimeStampInsert;
DROP TRIGGER IF EXISTS entryTimeStampUpdate;
DROP PROCEDURE IF EXISTS updateEntry;

CREATE TABLE Users (
    uid INTEGER AUTO_INCREMENT,
    username VARCHAR(320) NOT NULL,
    phash BLOB(192) NOT NULL,
    psalt BLOB(32) NOT NULL,
    allowance INTEGER NOT NULL DEFAULT 4096,
    PRIMARY KEY (uid),
    UNIQUE (username)
) ENGINE=InnoDB;

/* Name and content are encrypted */
CREATE TABLE Entries (
    owner_uid INTEGER NOT NULL,
    id INTEGER AUTO_INCREMENT,
    salt BLOB(32) NOT NULL,
    name BLOB(128) NOT NULL,
    content BLOB(1024),
    lastchange TIMESTAMP NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (owner_uid) REFERENCES Users(uid) ON DELETE CASCADE
) ENGINE=InnoDB;

DELIMITER //
CREATE PROCEDURE updateEntry(IN ownerID INTEGER, IN entryID INTEGER, IN newcontent BLOB(1024), IN changetime TIMESTAMP)
BEGIN
    UPDATE Entries
    SET
        lastchange=changetime,
        content=newcontent
    WHERE
          owner_uid=ownerID AND
          id=entryID AND
          lastchange<changetime;
END //

CREATE TRIGGER entryTimeStampInsert
    BEFORE INSERT ON Entries FOR EACH ROW
BEGIN
    SET NEW.lastchange := CURRENT_TIMESTAMP;
END //

CREATE TRIGGER entryTimeStampUpdate
    BEFORE UPDATE ON Entries FOR EACH ROW
BEGIN
    SET NEW.lastchange := CURRENT_TIMESTAMP;
END //
DELIMITER ;