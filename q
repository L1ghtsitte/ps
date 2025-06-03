#pragma once
#include "GraphElement.h"

namespace MaltegoClone {
    public ref class GraphNode : public GraphElement
    {
    public:
        GraphNode()
        {
            Size = System::Drawing::Size(100, 40);
            Color = Color::White;
        }
        
        virtual void Draw(Graphics^ g) override
        {
            // Draw background
            g->FillRectangle(gcnew SolidBrush(Color), Bounds);
            
            // Draw border
            g->DrawRectangle(Pens::Black, Bounds);
            
            // Draw text
            StringFormat^ format = gcnew StringFormat();
            format->Alignment = StringAlignment::Center;
            format->LineAlignment = StringAlignment::Center;
            
            g->DrawString(Text, gcnew Font("Arial", 8), Brushes::Black, 
                          RectangleF(Bounds), format);
        }
    };
}