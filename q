// GraphElement.h
#pragma once
#include <map>
#include <string>
#include <msclr/marshal_cppstd.h>

using namespace System;
using namespace System::Drawing;
using namespace System::IO; // Добавляем для Path, Directory, File
using namespace System::Windows::Forms; // Добавляем для Application
using namespace System::Collections::Generic;
using namespace msclr::interop;

namespace MaltegoClone {
    public enum class ElementType {
        Person, Organization, Website, IPAddress, Email,
        Document, SocialNetwork, School, Address, PhoneNumber,
        Telegram, VK, Facebook, Twitter, Instagram, Custom
    };

    public ref class GraphElement {
    public:
        // ... остальные члены класса остаются без изменений ...

        void SaveToFile() {
            String^ directory = Path::Combine(Application::StartupPath, text);
            Directory::CreateDirectory(directory);

            String^ filename = Path::Combine(directory, type.ToString() + ".txt");

            StreamWriter^ writer = gcnew StreamWriter(filename);
            writer->WriteLine("ID: " + id);
            writer->WriteLine("Type: " + type.ToString());
            writer->WriteLine("Text: " + text);
            writer->WriteLine("Location: " + location.X + "," + location.Y);
            writer->WriteLine("Size: " + size.Width + "," + size.Height);
            writer->WriteLine("Color: " + color.ToArgb());

            writer->WriteLine("Properties:");
            for each(KeyValuePair<String^, String^> pair in properties) {
                writer->WriteLine(pair.Key + ": " + pair.Value);
            }

            writer->WriteLine("Notes:");
            writer->WriteLine(notes);

            writer->Close();
        }

        void LoadFromFile() {
            String^ directory = Path::Combine(Application::StartupPath, text);
            String^ filename = Path::Combine(directory, type.ToString() + ".txt");

            if (!File::Exists(filename)) return;

            StreamReader^ reader = gcnew StreamReader(filename);
            String^ line;

            while ((line = reader->ReadLine()) != nullptr) {
                // ... остальная часть метода без изменений ...
            }

            reader->Close();
        }
    };
}