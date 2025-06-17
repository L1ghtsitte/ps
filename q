USE master;
GO

-- Создаем базу данных, если она не существует
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'maltxxxgoDB')
BEGIN
    CREATE DATABASE maltxxxgoDB;
    PRINT 'Database maltxxxgoDB created.';
END
ELSE
BEGIN
    PRINT 'Database maltxxxgoDB already exists.';
END
GO

USE maltxxxgoDB;
GO

-- Создаем таблицу Users, если она не существует
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL UNIQUE,
        Password NVARCHAR(255) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Salt NVARCHAR(255) NOT NULL,
        AccountCreated DATETIME NOT NULL DEFAULT GETDATE(),
        AppVersion NVARCHAR(20) NULL,
        SubscriptionEndDate DATETIME NULL,
        IsOnline BIT NOT NULL DEFAULT 0,
        LastLogin DATETIME NULL,
        TotalHours FLOAT NOT NULL DEFAULT 0
    );
    PRINT 'Table Users created.';
END
ELSE
BEGIN
    PRINT 'Table Users already exists.';
END
GO

-- Создаем таблицу версий приложения
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppVersions')
BEGIN
    CREATE TABLE AppVersions (
        VersionID INT IDENTITY(1,1) PRIMARY KEY,
        VersionNumber NVARCHAR(20) NOT NULL,
        ReleaseDate DATETIME NOT NULL DEFAULT GETDATE(),
        DownloadURL NVARCHAR(500) NOT NULL,
        Changelog NVARCHAR(MAX) NULL,
        IsCritical BIT NOT NULL DEFAULT 0
    );
    PRINT 'Table AppVersions created.';
END
ELSE
BEGIN
    PRINT 'Table AppVersions already exists.';
END
GO

-- Создаем таблицу ролей пользователей
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRoles')
BEGIN
    CREATE TABLE UserRoles (
        UserID INT NOT NULL PRIMARY KEY,
        Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Moderator', 'User', 'VIP')),
        CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserID) 
            REFERENCES Users(UserID) ON DELETE CASCADE
    );
    PRINT 'Table UserRoles created.';
END
ELSE
BEGIN
    PRINT 'Table UserRoles already exists.';
END
GO

-- Создаем таблицу уведомлений
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications')
BEGIN
    CREATE TABLE Notifications (
        NotificationID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NULL, -- NULL для глобальных уведомлений
        Title NVARCHAR(100) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        IsRead BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_Notifications_Users FOREIGN KEY (UserID) 
            REFERENCES Users(UserID) ON DELETE CASCADE
    );
    PRINT 'Table Notifications created.';
END
ELSE
BEGIN
    PRINT 'Table Notifications already exists.';
END
GO

-- Создаем таблицы для проектов
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Projects')
BEGIN
    CREATE TABLE Projects (
        ProjectID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        ProjectName NVARCHAR(100) NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        LastModified DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Projects_Users FOREIGN KEY (UserID) 
            REFERENCES Users(UserID) ON DELETE CASCADE
    );
    PRINT 'Table Projects created.';
END
ELSE
BEGIN
    PRINT 'Table Projects already exists.';
END
GO

-- Создаем таблицу узлов
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Nodes')
BEGIN
    CREATE TABLE Nodes (
        NodeID INT IDENTITY(1,1) PRIMARY KEY,
        ProjectID INT NOT NULL,
        Type NVARCHAR(50) NOT NULL,
        Text NVARCHAR(255) NOT NULL,
        X INT NOT NULL,
        Y INT NOT NULL,
        Width INT NOT NULL,
        Height INT NOT NULL,
        Color INT NOT NULL,
        Notes NVARCHAR(MAX) NULL,
        CONSTRAINT FK_Nodes_Projects FOREIGN KEY (ProjectID) 
            REFERENCES Projects(ProjectID) ON DELETE CASCADE
    );
    PRINT 'Table Nodes created.';
END
ELSE
BEGIN
    PRINT 'Table Nodes already exists.';
END
GO

-- Создаем таблицу свойств узлов
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NodeProperties')
BEGIN
    CREATE TABLE NodeProperties (
        PropertyID INT IDENTITY(1,1) PRIMARY KEY,
        NodeID INT NOT NULL,
        ProjectID INT NOT NULL,
        PropertyKey NVARCHAR(100) NOT NULL,
        PropertyValue NVARCHAR(MAX) NULL,
        CONSTRAINT FK_NodeProperties_Nodes FOREIGN KEY (NodeID) 
            REFERENCES Nodes(NodeID) ON DELETE CASCADE,
        CONSTRAINT FK_NodeProperties_Projects FOREIGN KEY (ProjectID) 
            REFERENCES Projects(ProjectID) ON DELETE CASCADE
    );
    PRINT 'Table NodeProperties created.';
END
ELSE
BEGIN
    PRINT 'Table NodeProperties already exists.';
END
GO

-- Создаем таблицу связей
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Edges')
BEGIN
    CREATE TABLE Edges (
        EdgeID INT IDENTITY(1,1) PRIMARY KEY,
        ProjectID INT NOT NULL,
        SourceNodeID INT NOT NULL,
        TargetNodeID INT NOT NULL,
        Color INT NOT NULL,
        CONSTRAINT FK_Edges_Projects FOREIGN KEY (ProjectID) 
            REFERENCES Projects(ProjectID) ON DELETE CASCADE,
        CONSTRAINT FK_Edges_SourceNodes FOREIGN KEY (SourceNodeID) 
            REFERENCES Nodes(NodeID),
        CONSTRAINT FK_Edges_TargetNodes FOREIGN KEY (TargetNodeID) 
            REFERENCES Nodes(NodeID)
    );
    PRINT 'Table Edges created.';
END
ELSE
BEGIN
    PRINT 'Table Edges already exists.';
END
GO

-- Вставляем тестовые данные (если нужно)
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'admin')
BEGIN
    -- Вставляем тестового пользователя
    DECLARE @salt NVARCHAR(255) = NEWID();
    DECLARE @password NVARCHAR(255) = HASHBYTES('SHA2_256', 'admin123' + @salt);
    
    INSERT INTO Users (Username, Password, Email, Salt, AppVersion, SubscriptionEndDate)
    VALUES ('admin', @password, 'admin@example.com', @salt, '0.4', DATEADD(YEAR, 1, GETDATE()));
    
    -- Назначаем роль администратора
    DECLARE @adminId INT = SCOPE_IDENTITY();
    INSERT INTO UserRoles (UserID, Role) VALUES (@adminId, 'Admin');
    
    PRINT 'Test admin user created.';
END
ELSE
BEGIN
    PRINT 'Test admin user already exists.';
END
GO

-- Вставляем информацию о версии
IF NOT EXISTS (SELECT * FROM AppVersions WHERE VersionNumber = '0.4')
BEGIN
    INSERT INTO AppVersions (VersionNumber, DownloadURL, Changelog, IsCritical)
    VALUES ('0.4', 'http://example.com/download/latest', 
            '- Added database support\n- Improved UI\n- Fixed bugs', 1);
    PRINT 'Version info added.';
END
ELSE
BEGIN
    PRINT 'Version info already exists.';
END
GO

PRINT 'Database setup completed successfully.';
GO