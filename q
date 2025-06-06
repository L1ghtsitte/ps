// GraphNode.h
#pragma once
#include "GraphElement.h"
#include "NodePropertiesEditor.h"

using namespace System;
using namespace System::Drawing;
using namespace System::Drawing::Drawing2D; // Добавлено для LinearGradientBrush
using namespace System::Windows::Forms;

namespace MaltegoClone {
    public ref class GraphNode : public GraphElement {
    public:
        // ... остальной код класса ...

        virtual void Draw(Graphics^ g) override {
            // Draw shadow
            System::Drawing::Rectangle shadowRect = System::Drawing::Rectangle(
                location.X + 3, location.Y + 3, size.Width, size.Height);
            SolidBrush^ shadowBrush = gcnew SolidBrush(Color::FromArgb(30, 0, 0, 0));
            g->FillRectangle(shadowBrush, shadowRect);
            delete shadowBrush;

            // Draw main rectangle with gradient
            System::Drawing::Rectangle bounds = this->Bounds;
            LinearGradientBrush^ brush = gcnew LinearGradientBrush(
                bounds,
                Color::FromArgb(color.R, color.G, color.B),
                Color::FromArgb(color.R - 20, color.G - 20, color.B - 20),
                LinearGradientMode::ForwardDiagonal); // Изменено на ForwardDiagonal

            Pen^ pen = gcnew Pen(Color::FromArgb(100, 100, 100), 1.5f);
            g->FillRectangle(brush, bounds);
            g->DrawRectangle(pen, bounds);
            delete brush;
            delete pen;

            // ... остальной код метода Draw ...
        }

        // ... остальной код класса ...
    };
}