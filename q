#pragma once

#include <map>
#include <string>

using namespace System;
using namespace System::Drawing;
using namespace System::Collections::Generic;

namespace MaltegoClone {

    public ref class GraphElement
    {
    public:
        int id;
        String^ type;
        String^ text;
        Point location;
        Size size;
        Color color;
        Dictionary<String^, String^>^ properties;
        bool is_expanded;
        String^ url;

        GraphElement()
        {
            properties = gcnew Dictionary<String^, String^>();
            is_expanded = false;
            color = Color::FromArgb(50, 50, 50);
            url = String::Empty;
        }

        property Rectangle bounds {
            Rectangle get() { return Rectangle(location, size); }
        }

        virtual void Draw(Graphics^ g) = 0;
        
        virtual void ToggleExpand() {
            is_expanded = !is_expanded;
            if (is_expanded) {
                size = Size(250, CalculateExpandedHeight());
            } else {
                size = Size(120, 50);
            }
        }

        virtual int CalculateExpandedHeight() {
            int height = 60; // Минимальная высота
            for each (KeyValuePair<String^, String^> pair in properties) {
                if (!String::IsNullOrEmpty(pair.Value)) {
                    height += 25;
                }
            }
            return Math::Min(height, 400); // Ограничиваем максимальную высоту
        }

        virtual void UpdateProperties(Dictionary<String^, String^>^ new_properties) {
            properties->Clear();
            for each (KeyValuePair<String^, String^> pair in new_properties) {
                properties->Add(pair.Key, pair.Value);
            }
        }
    };

    public ref class PersonNode : public GraphElement
    {
    public:
        PersonNode() {
            type = "Person";
            color = Color::FromArgb(70, 130, 180);
            text = "Person";
            properties->Add("first_name", "");
            properties->Add("last_name", "");
            properties->Add("age", "");
            properties->Add("gender", "");
            properties->Add("email", "");
            properties->Add("phone", "");
            properties->Add("address", "");
            properties->Add("social_networks", "");
            properties->Add("workplace", "");
            properties->Add("notes", "");
        }

        virtual void Draw(Graphics^ g) override {
            SolidBrush^ brush = gcnew SolidBrush(color);
            Pen^ pen = gcnew Pen(Color::FromArgb(100, 100, 100), 1.5f);

            g->FillRectangle(brush, bounds);
            g->DrawRectangle(pen, bounds);

            System::Drawing::Font^ font = gcnew System::Drawing::Font("Arial", 9, FontStyle::Bold);
            SolidBrush^ text_brush = gcnew SolidBrush(Color::White);

            // Рисуем основной текст
            g->DrawString(text, font, text_brush, 
                RectangleF(location.X, location.Y, size.Width, 25), 
                GetCenterAlignment());

            if (is_expanded) {
                // Рисуем расширенную информацию
                System::Drawing::Font^ prop_font = gcnew System::Drawing::Font("Arial", 8);
                float y = location.Y + 30;
                
                for each (KeyValuePair<String^, String^> pair in properties) {
                    if (!String::IsNullOrEmpty(pair.Value)) {
                        String^ display_text = pair.Key + ": " + pair.Value;
                        g->DrawString(display_text, prop_font, text_brush, 
                                    location.X + 10, y);
                        y += 20;
                    }
                }
                
                delete prop_font;
            }

            // Рисуем иконку ссылки если есть URL
            if (!String::IsNullOrEmpty(url)) {
                Image^ link_icon = Image::FromFile("link_icon.png");
                g->DrawImage(link_icon, Rectangle(location.X + size.Width - 20, 
                                                location.Y + size.Height - 20, 
                                                16, 16));
            }

            delete brush;
            delete pen;
            delete font;
            delete text_brush;
        }

    private:
        StringFormat^ GetCenterAlignment() {
            StringFormat^ format = gcnew StringFormat();
            format->Alignment = StringAlignment::Center;
            format->LineAlignment = StringAlignment::Center;
            return format;
        }
    };

    public ref class IpAddressNode : public GraphElement
    {
    public:
        IpAddressNode() {
            type = "IP Address";
            color = Color::FromArgb(220, 80, 60);
            text = "IP Address";
            properties->Add("ip", "");
            properties->Add("location", "");
            properties->Add("isp", "");
            properties->Add("asn", "");
            properties->Add("services", "");
            properties->Add("notes", "");
        }

        virtual void Draw(Graphics^ g) override {
            // Аналогичная реализация как у PersonNode с особенностями для IP
        }
    };

    public ref class GraphElementFactory
    {
    public:
        static GraphElement^ CreateElement(String^ type) {
            if (type == "Person") return gcnew PersonNode();
            if (type == "IP Address") return gcnew IpAddressNode();
            // Добавьте другие типы по аналогии
            
            // По умолчанию создаем базовый узел
            GraphElement^ element = gcnew GraphElement();
            element->type = type;
            element->text = type;
            return element;
        }
    };
}