# ps

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <dirent.h>
#include <sys/stat.h>

using namespace std;

// Проверка, является ли объект файлом
bool isFile(const string& path) {
    struct stat pathStat;
    stat(path.c_str(), &pathStat);
    return S_ISREG(pathStat.st_mode);
}

// Получение списка файлов в директории
vector<string> getFiles(const string& directory) {
    vector<string> files;
    DIR* dir = opendir(directory.c_str());
    
    if (dir) {
        dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            string filename = entry->d_name;
            if (filename != "." && filename != "..") {
                string fullPath = directory + "/" + filename;
                if (isFile(fullPath)) {
                    files.push_back(fullPath);
                }
            }
        }
        closedir(dir);
    }
    return files;
}

// Поиск текста в файле
vector<string> searchInFile(const string& filename, const string& searchText) {
    vector<string> results;
    ifstream file(filename);
    string line;
    int lineNum = 1;
    
    while (getline(file, line)) {
        if (line.find(searchText) != string::npos) {
            results.push_back("Файл: " + filename + ", строка " + to_string(lineNum) + ": " + line);
        }
        lineNum++;
    }
    
    return results;
}

int main() {
    string searchText, directory;
    
    cout << "Введите текст для поиска (номер телефона или email): ";
    getline(cin, searchText);
    
    cout << "Введите путь к директории для поиска: ";
    getline(cin, directory);

    vector<string> files = getFiles(directory);
    vector<string> allResults;
    
    for (const string& file : files) {
        vector<string> fileResults = searchInFile(file, searchText);
        allResults.insert(allResults.end(), fileResults.begin(), fileResults.end());
    }

    // Сохранение результатов
    ofstream out("results.txt");
    out << "Результаты поиска для: " << searchText << "\n\n";
    
    if (allResults.empty()) {
        out << "Совпадений не найдено.\n";
    } else {
        for (const string& result : allResults) {
            out << result << "\n";
        }
        out << "\nВсего найдено: " << allResults.size() << " совпадений\n";
    }
    
    cout << "Поиск завершен. Результаты сохранены в results.txt\n";
    return 0;
}