#pragma once
#include "GraphElement.h"

namespace MaltegoClone {

    public ref class GraphNode : public GraphElement
    {
    public:
        virtual void Draw(Graphics^ g) override
        {
            SolidBrush^ brush = gcnew SolidBrush(Color);
            Pen^ pen = gcnew Pen(Color::Black, 2);
            
            g->FillRectangle(brush, Bounds);
            g->DrawRectangle(pen, Bounds);
            
            System::Drawing::Font^ font = gcnew System::Drawing::Font("Arial", 8);
            StringFormat^ format = gcnew StringFormat();
            format->Alignment = StringAlignment::Center;
            format->LineAlignment = StringAlignment::Center;
            
            g->DrawString(Text, font, Brushes::Black, 
                RectangleF(Location.X, Location.Y, Size.Width, Size.Height), format);
            
            delete brush;
            delete pen;
            delete font;
        }
    };
}