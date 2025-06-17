# Подключение к базе данных и расширение функционала

Я внесу изменения в ваш проект для подключения к SQL Server и добавления новых функций. Вот основные изменения:

## 1. Обновление DatabaseManager.h

Добавим новые методы для работы с версиями, ролями и уведомлениями:

```cpp
// DatabaseManager.h - добавить в public section класса DatabaseManager

// Проверка версии приложения
bool CheckAppVersion(String^ currentVersion) {
    String^ query = "SELECT TOP 1 VersionNumber FROM AppVersions ORDER BY ReleaseDate DESC";
    SqlCommand^ command = gcnew SqlCommand(query, connection);

    try {
        connection->Open();
        String^ latestVersion = safe_cast<String^>(command->ExecuteScalar());
        return latestVersion == currentVersion;
    }
    catch (Exception^ ex) {
        MessageBox::Show("Error checking app version: " + ex->Message, "Error",
            MessageBoxButtons::OK, MessageBoxIcon::Error);
        return false;
    }
    finally {
        if (connection->State == ConnectionState::Open) {
            connection->Close();
        }
    }
}

// Получение информации о последней версии
DataTable^ GetLatestVersionInfo() {
    String^ query = "SELECT TOP 1 VersionNumber, ReleaseDate, DownloadURL, Changelog " 
        "FROM AppVersions ORDER BY ReleaseDate DESC";
    SqlCommand^ command = gcnew SqlCommand(query, connection);
    SqlDataAdapter^ adapter = gcnew SqlDataAdapter(command);
    DataTable^ table = gcnew DataTable();

    try {
        connection->Open();
        adapter->Fill(table);
        return table;
    }
    catch (Exception^ ex) {
        MessageBox::Show("Error getting version info: " + ex->Message, "Error",
            MessageBoxButtons::OK, MessageBoxIcon::Error);
        return nullptr;
    }
    finally {
        if (connection->State == ConnectionState::Open) {
            connection->Close();
        }
    }
}

// Получение роли пользователя
String^ GetUserRole(int userID) {
    String^ query = "SELECT Role FROM UserRoles WHERE UserID = @userID";
    SqlCommand^ command = gcnew SqlCommand(query, connection);
    command->Parameters->AddWithValue("@userID", userID);

    try {
        connection->Open();
        Object^ result = command->ExecuteScalar();
        return result != nullptr ? result->ToString() : "User";
    }
    catch (Exception^ ex) {
        MessageBox::Show("Error getting user role: " + ex->Message, "Error",
            MessageBoxButtons::OK, MessageBoxIcon::Error);
        return "User";
    }
    finally {
        if (connection->State == ConnectionState::Open) {
            connection->Close();
        }
    }
}

// Получение уведомлений для пользователя
DataTable^ GetUserNotifications(int userID) {
    String^ query = "SELECT Title, Message, CreatedDate FROM Notifications "
        "WHERE UserID = @userID OR UserID IS NULL ORDER BY CreatedDate DESC";
    SqlCommand^ command = gcnew SqlCommand(query, connection);
    command->Parameters->AddWithValue("@userID", userID);
    SqlDataAdapter^ adapter = gcnew SqlDataAdapter(command);
    DataTable^ table = gcnew DataTable();

    try {
        connection->Open();
        adapter->Fill(table);
        return table;
    }
    catch (Exception^ ex) {
        MessageBox::Show("Error getting notifications: " + ex->Message, "Error",
            MessageBoxButtons::OK, MessageBoxIcon::Error);
        return nullptr;
    }
    finally {
        if (connection->State == ConnectionState::Open) {
            connection->Close();
        }
    }
}
```

## 2. Обновление AuthForm.h

Добавим проверку версии при аутентификации:

```cpp
// AuthForm.h - обновить метод LoginButton_Click

void LoginButton_Click(Object^ sender, EventArgs^ e) {
    if (String::IsNullOrEmpty(loginUsername->Text)) {
        statusLabel->Text = "Username is required";
        return;
    }

    if (String::IsNullOrEmpty(loginPassword->Text)) {
        statusLabel->Text = "Password is required";
        return;
    }

    // Создаем DatabaseManager
    DatabaseManager^ dbManager = gcnew DatabaseManager();
    
    // Проверяем аутентификацию
    if (dbManager->AuthenticateUser(loginUsername->Text, loginPassword->Text)) {
        // Получаем ID пользователя
        int userID = dbManager->GetUserID(loginUsername->Text);
        
        // Проверяем версию приложения
        String^ currentVersion = "0.4"; // Текущая версия приложения
        if (!dbManager->CheckAppVersion(currentVersion)) {
            DataTable^ versionInfo = dbManager->GetLatestVersionInfo();
            if (versionInfo != nullptr && versionInfo->Rows->Count > 0) {
                String^ message = "Your version is outdated. Please update to version " + 
                    versionInfo->Rows[0]["VersionNumber"]->ToString() + 
                    "\n\nChangelog:\n" + versionInfo->Rows[0]["Changelog"]->ToString();
                
                MessageBox::Show(message, "Update Required",
                    MessageBoxButtons::OK, MessageBoxIcon::Information);
                
                // Открываем URL для скачивания
                System::Diagnostics::Process::Start(versionInfo->Rows[0]["DownloadURL"]->ToString());
            }
            return;
        }
        
        // Проверяем подписку
        if (!dbManager->CheckSubscription(userID)) {
            MessageBox::Show("Your subscription has expired. Please renew.", "Subscription Expired",
                MessageBoxButtons::OK, MessageBoxIcon::Warning);
        }
        
        username = loginUsername->Text;
        isAuthenticated = true;
        this->DialogResult = Windows::Forms::DialogResult::OK;
        this->Close();
    }
    else {
        statusLabel->Text = "Invalid username or password";
    }
}
```

## 3. Обновление MainForm.h

Добавим проверку уведомлений при запуске:

```cpp
// MainForm.h - добавить в конструктор после аутентификации

// Проверяем уведомления
DataTable^ notifications = dbManager->GetUserNotifications(CurrentUserID);
if (notifications != nullptr && notifications->Rows->Count > 0) {
    StringBuilder^ notificationText = gcnew StringBuilder();
    notificationText->AppendLine("You have new notifications:");
    
    for each (DataRow ^ row in notifications->Rows) {
        notificationText->AppendLine();
        notificationText->AppendLine(row["Title"]->ToString());
        notificationText->AppendLine(row["Message"]->ToString());
        notificationText->AppendLine("Date: " + ((DateTime)row["CreatedDate"]).ToString("g"));
    }
    
    MessageBox::Show(notificationText->ToString(), "Notifications",
        MessageBoxButtons::OK, MessageBoxIcon::Information);
}
```

## 4. SQL скрипт для создания необходимых таблиц

```sql
USE maltxxxgoDB;
GO

-- Таблица версий приложения
CREATE TABLE AppVersions (
    VersionID INT IDENTITY(1,1) PRIMARY KEY,
    VersionNumber NVARCHAR(20) NOT NULL,
    ReleaseDate DATETIME NOT NULL DEFAULT GETDATE(),
    DownloadURL NVARCHAR(500) NOT NULL,
    Changelog NVARCHAR(MAX) NULL,
    IsCritical BIT NOT NULL DEFAULT 0
);

-- Таблица ролей пользователей
CREATE TABLE UserRoles (
    UserID INT NOT NULL PRIMARY KEY,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Moderator', 'User', 'VIP')),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Таблица уведомлений
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL, -- NULL для глобальных уведомлений
    Title NVARCHAR(100) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Добавляем столбец версии в таблицу Users
ALTER TABLE Users ADD AppVersion NVARCHAR(20) NULL;

-- Вставляем тестовые данные
INSERT INTO AppVersions (VersionNumber, DownloadURL, Changelog, IsCritical)
VALUES ('0.4', 'http://example.com/download/latest', 
        '- Added database support\n- Improved UI\n- Fixed bugs', 1);

-- Назначаем роли (пример)
INSERT INTO UserRoles (UserID, Role) VALUES (1, 'Admin');
```

## 5. Обновление UserProfileForm.h

Добавим отображение роли пользователя:

```cpp
// UserProfileForm.h - обновить метод LoadUserData

void LoadUserData() {
    userInfo = dbManager->GetUserInfo(userID);
    if (userInfo != nullptr && userInfo->Rows->Count > 0) {
        DataRow^ row = userInfo->Rows[0];

        lblUsername->Text = "Username: " + row["Username"]->ToString();
        lblEmail->Text = "Email: " + row["Email"]->ToString();
        lblCreated->Text = "Account created: " + ((DateTime)row["AccountCreated"]).ToString("dd.MM.yyyy HH:mm");
        lblVersion->Text = "App version: " + row["AppVersion"]->ToString();

        // Добавляем отображение роли
        String^ userRole = dbManager->GetUserRole(userID);
        Label^ lblRole = gcnew Label();
        lblRole->Text = "Role: " + userRole;
        lblRole->Font = gcnew System::Drawing::Font("Segoe UI", 10);
        lblRole->ForeColor = Color::FromArgb(240, 240, 240);
        lblRole->Location = Point(20, 250); // Позиция после других полей
        lblRole->AutoSize = true;
        mainPanel->Controls->Add(lblRole);

        // Изменяем цвет в зависимости от роли
        if (userRole == "Admin") lblRole->ForeColor = Color::Red;
        else if (userRole == "Moderator") lblRole->ForeColor = Color::Orange;
        else if (userRole == "VIP") lblRole->ForeColor = Color::Gold;

        // Остальной код...
    }
}
```

## 6. Настройка подключения в App.config

Добавьте в файл App.config вашего проекта:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <connectionStrings>
        <add name="maltxxxgoDB" 
             connectionString="Data Source=DESKTOP-3KMSPQO\MSSQLSERVER01;Initial Catalog=maltxxxgoDB;Integrated Security=True;"
             providerName="System.Data.SqlClient" />
    </connectionStrings>
    <appSettings>
        <add key="DefaultSubscriptionDays" value="30" />
    </appSettings>
</configuration>
```

## 7. Класс для автоматического обновления

Создайте новый файл AutoUpdater.h:

```cpp
// AutoUpdater.h
#pragma once

using namespace System;
using namespace System::Net;
using namespace System::IO;
using namespace System::Diagnostics;

namespace MaltegoClone {
    public ref class AutoUpdater {
    public:
        static bool CheckForUpdates(String^ currentVersion, String^ updateUrl) {
            try {
                WebClient^ client = gcnew WebClient();
                String^ latestVersion = client->DownloadString(updateUrl + "/version.txt");
                
                if (latestVersion->Trim() != currentVersion->Trim()) {
                    return true;
                }
            }
            catch (Exception^ ex) {
                MessageBox::Show("Error checking for updates: " + ex->Message, "Error",
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
            return false;
        }

        static void DownloadAndInstallUpdate(String^ updateUrl) {
            try {
                String^ tempFile = Path::Combine(Path::GetTempPath(), "maltxxxgo_update.exe");
                
                WebClient^ client = gcnew WebClient();
                client->DownloadFile(updateUrl + "/maltxxxgo_latest.exe", tempFile);
                
                Process::Start(tempFile, "/silent");
                Environment::Exit(0);
            }
            catch (Exception^ ex) {
                MessageBox::Show("Error downloading update: " + ex->Message, "Error",
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
        }
    };
}
```

## 8. Использование AutoUpdater в MainForm

Добавьте в MainForm.h проверку обновлений при запуске:

```cpp
// MainForm.h - добавить в конструктор после аутентификации

// Проверка обновлений в фоновом режиме
if (ConfigurationManager::AppSettings["CheckForUpdates"] == "true") {
    String^ currentVersion = "0.4";
    String^ updateUrl = "http://example.com/updates";
    
    if (AutoUpdater::CheckForUpdates(currentVersion, updateUrl)) {
        if (MessageBox::Show("A new version is available. Would you like to update now?", 
            "Update Available", MessageBoxButtons::YesNo, MessageBoxIcon::Question) == Windows::Forms::DialogResult::Yes) {
            AutoUpdater::DownloadAndInstallUpdate(updateUrl);
        }
    }
}
```

Эти изменения обеспечат:

1. Подключение к локальной базе данных SQL Server
2. Проверку версии приложения при входе
3. Систему ролей пользователей (Admin, Moderator, User, VIP)
4. Уведомления для пользователей
5. Журнал изменений версий
6. Автоматическую загрузку обновлений

Для полной реализации вам также потребуется:
1. Создать базу данных maltxxxgoDB на вашем SQL Server
2. Запустить предоставленный SQL-скрипт для создания таблиц
3. Обновить строку подключения в App.config при необходимости
4. Добавить обработку ролей в интерфейсе (например, дополнительные функции для администраторов)