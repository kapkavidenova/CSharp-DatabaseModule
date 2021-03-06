CREATE DATABASE Bitbucket
USE Bitbucket

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY ,
Username VARCHAR(30)  NOT NULL ,
Password VARCHAR(30)  NOT NULL ,
Email    VARCHAR(50)  NOT NULL
)

CREATE TABLE Repositories
(
Id   INT PRIMARY KEY IDENTITY ,
Name VARCHAR(50)  NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId  INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
Id           INT PRIMARY KEY IDENTITY ,
Title        VARCHAR(MAX) NOT NULL ,
IssueStatus  CHAR(6) NOT NULL,
RepositoryId INT  NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
AssigneeId   INT  NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY ,
Message VARCHAR(MAX) NOT NULL ,
IssueId INT FOREIGN KEY REFERENCES Issues(Id),
RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
ContributorId  INT NOT NULL FOREIGN KEY REFERENCES Users(Id)

)

CREATE TABLE Files
(
Id   INT PRIMARY KEY IDENTITY ,
Name VARCHAR(100)  NOT NULL ,
Size DECIMAL(18,2) NOT NULL ,
ParentId INT FOREIGN KEY REFERENCES Files(Id),
CommitId INT       NOT NULL FOREIGN KEY REFERENCES Commits(Id)
)


--Section 2. DML (10 pts)
--2.	Insert
INSERT INTO Files([Name],Size,ParentId,CommitId)
	VALUES
		('Trade.idk',2598.0,1,1),
		('menu.net',9238.31,2,2),
		('Administrate.soshy',1246.93,3,3),
		('Controller.php',7353.15,4,4),
		('Find.java',9957.86,5,5),
		('Controller.json',14034.87,3,6),
		('Operate.xix',7662.92,7,7)

--SELECT * FROM Files

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId)
	VALUES 
	('Critical Problem with HomeController.cs file',	'open',	1,	4),
	('Typo fix in Judge.html',	'open',	4,	3),
	('Implement documentation for UsersService.cs',	'closed',	8,	2),
	('Unreachable code in Index.cs',	'open',	9,	8)

		
--3.	Update
  UPDATE Issues
  SET IssueStatus = 'closed'
  WHERE AssigneeId = 6
  --SELECT * FROM Issues


--4.	Delete
--SELECT * FROM Repositories
--ORDER BY Name
DELETE FROM RepositoriesContributors
WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE [Name]= 'Softuni-Teamwork')
DELETE FROM Issues WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE Name = 'Softuni-Teamwork')

--Section 3. Querying (40 pts)
--5.	Commits
SELECT Id,
		Message,
		RepositoryId,
		ContributorId
		FROM Commits
ORDER BY Id ASC,Message ASC, RepositoryId ASC,ContributorId ASC

--6.	Front-end
SELECT Id,[Name],Size
FROM Files
WHERE Size>1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id ASC, [Name] ASC

--7.	Issue Assignment
SELECT i.Id,
		CONCAT(u.Username,' : ',i.Title) AS [IssueAssignee]
FROM Issues AS i
JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId ASC

--8.	Single Files
SELECT f2.Id,
		f2.[Name],
		CONCAT(f2.Size,'KB') AS Size
FROM Files AS f
RIGHT JOIN Files AS f2 ON f.ParentId = f2.Id
WHERE f.ParentId IS NULL
ORDER BY f2.Id ASC,f2.[Name] ASC,f2.Size DESC


--9.	Commits in Repositories
SELECT TOP(5) r.Id,
		r.[Name],
		COUNT(c.Id) AS Commits
FROM Repositories AS r
JOIN Commits AS c ON r.Id = c.RepositoryId
JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
GROUP BY r.Id,r.Name
ORDER BY Commits DESC,r.Id ASC,r.[Name] ASC

--10.	Average Size
SELECT 
--*
	u.Username,
	AVG(f.Size)
FROM Users AS u
RIGHT JOIN Commits AS c ON u.Id = c.ContributorId
JOIN Files AS f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY AVG(f.Size) DESC,u.Username ASC

--11.	All User Commits
GO
CREATE OR ALTER FUNCTION udf_AllUserCommits(@username VARCHAR(30)) 
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(C.ContributorId) 
	FROM Users AS u
	JOIN Commits AS c ON u.Id = c.ContributorId
	WHERE u.Username = @username)
	
	
END
GO
SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--12.	 Search for Files
GO
CREATE OR ALTER PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
SELECT Id,
		[Name],
		CONCAT(Size,'KB') AS Size
FROM Files
WHERE [Name] LIKE '%'+@fileExtension+'%'
ORDER BY Id ASC,[Name] ASC,Size DESC

GO

EXEC usp_SearchForFiles 'txt'