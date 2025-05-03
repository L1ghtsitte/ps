#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <windows.h> // Только для Windows

using namespace std;

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

vector<string> getFilesInDirectory(const string& directory) {
    vector<string> files;
    WIN32_FIND_DATA findFileData;
    HANDLE hFind = FindFirstFile((directory + "\\*").c_str(), &findFileData);
    
    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            if (!(findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                files.push_back(directory + "\\" + findFileData.cFileName);
            }
        } while (FindNextFile(hFind, &findFileData) != 0);
        FindClose(hFind);
    }
    
    return files;
}

int main() {
    cout << "Программа поиска в файлах (Windows)\n";
    
    string searchText, directory;
    cout << "Введите текст для поиска: ";
    getline(cin, searchText);
    cout << "Введите путь к директории (например: C:\\Users\\Name\\Documents): ";
    getline(cin, directory);

    vector<string> files = getFilesInDirectory(directory);
    vector<string> allResults;
    
    for (const string& file : files) {
        auto results = searchInFile(file, searchText);
        allResults.insert(allResults.end(), results.begin(), results.end());
        cout << "Обработан файл: " << file << "\n";
    }

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
    
    cout << "\nПоиск завершен. Результаты сохранены в results.txt\n";
    return 0;
}
