// GraphElement.h
#pragma once
#include <map>
#include <string>
#include <msclr/marshal_cppstd.h>

using namespace System;
using namespace System::Drawing;
using namespace System::IO; // Добавлено для работы с файлами
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
        int id;
        ElementType type;
        String^ text;
        Point location;
        Size size;
        Color color;
        Dictionary<String^, String^>^ properties;
        bool is_expanded;
        String^ notes;
        bool is_resizing;
        bool is_dragging;
        Point resize_start;
        Size original_size;

        GraphElement() {
            properties = gcnew Dictionary<String^, String^>();
            is_expanded = false;
            notes = String::Empty;
            color = Color::FromArgb(60, 60, 65);
            size = Size(150, 50);
            is_resizing = false;
            is_dragging = false;
        }

        property System::Drawing::Rectangle Bounds { // Изменено имя и добавлено полное квалифицированное имя
            System::Drawing::Rectangle get() { return System::Drawing::Rectangle(location, size); }
        }

        property System::Drawing::Rectangle ResizeHandle {
            System::Drawing::Rectangle get() {
                return System::Drawing::Rectangle(location.X + size.Width - 10,
                                   location.Y + size.Height - 10,
                                   10, 10);
            }
        }

        virtual void Draw(Graphics^ g) = 0;

        bool HitTestResizeHandle(Point point) {
            return ResizeHandle.Contains(point);
        }

        void StartResizing(Point point) {
            is_resizing = true;
            resize_start = point;
            original_size = size;
        }

        void Resize(Point point) {
            if (!is_resizing) return;

            int deltaX = point.X - resize_start.X;
            int deltaY = point.Y - resize_start.Y;

            size = Size(
                Math::Max(100, original_size.Width + deltaX),
                Math::Max(40, original_size.Height + deltaY)
            );
        }

        void EndResizing() {
            is_resizing = false;
        }

        void SaveToFile() {
            String^ directory = System::IO::Path::Combine(Application::StartupPath, text);
            System::IO::Directory::CreateDirectory(directory);

            String^ filename = System::IO::Path::Combine(directory, type.ToString() + ".txt");

            System::IO::StreamWriter^ writer = gcnew System::IO::StreamWriter(filename);
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
            String^ directory = System::IO::Path::Combine(Application::StartupPath, text);
            String^ filename = System::IO::Path::Combine(directory, type.ToString() + ".txt");

            if (!System::IO::File::Exists(filename)) return;

            System::IO::StreamReader^ reader = gcnew System::IO::StreamReader(filename);
            String^ line;

            while ((line = reader->ReadLine()) != nullptr) {
                if (line->StartsWith("ID: ")) {
                    id = Int32::Parse(line->Substring(4));
                }
                else if (line->StartsWith("Location: ")) {
                    array<String^>^ parts = line->Substring(10)->Split(',');
                    location = Point(Int32::Parse(parts[0]), Int32::Parse(parts[1]));
                }
                else if (line->StartsWith("Size: ")) {
                    array<String^>^ parts = line->Substring(6)->Split(',');
                    size = Size(Int32::Parse(parts[0]), Int32::Parse(parts[1]));
                }
                else if (line->StartsWith("Color: ")) {
                    color = Color::FromArgb(Int32::Parse(line->Substring(7)));
                }
                else if (line == "Properties:") {
                    while ((line = reader->ReadLine()) != nullptr && line != "Notes:") {
                        int colonPos = line->IndexOf(": ");
                        if (colonPos > 0) {
                            String^ key = line->Substring(0, colonPos);
                            String^ value = line->Substring(colonPos + 2);
                            properties[key] = value;
                        }
                    }
                }
                else if (line == "Notes:") {
                    notes = reader->ReadToEnd();
                }
            }

            reader->Close();
        }
    };
}