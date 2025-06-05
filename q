#pragma once
#include "GraphElement.h"

namespace MaltegoClone {

    public ref class GraphNode : public GraphElement
    {
    public:
        virtual void Draw(Graphics^ g) override {
            SolidBrush^ brush = gcnew SolidBrush(color);
            Pen^ pen = gcnew Pen(Color::FromArgb(100, 100, 100), 1.5f);

            g->FillRectangle(brush, bounds);
            g->DrawRectangle(pen, bounds);

            System::Drawing::Font^ font = gcnew System::Drawing::Font("Arial", 9);
            SolidBrush^ text_brush = gcnew SolidBrush(Color::White);

            StringFormat^ format = gcnew StringFormat();
            format->Alignment = StringAlignment::Center;
            format->LineAlignment = StringAlignment::Center;

            g->DrawString(text, font, text_brush, 
                RectangleF(location.X, location.Y, size.Width, size.Height), format);

            delete brush;
            delete pen;
            delete font;
            delete text_brush;
            delete format;
        }
    };
}