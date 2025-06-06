// GraphNode.h
#pragma once
#include "GraphElement.h"
#include "NodePropertiesEditor.h"
#include <windows.h> // Добавляем для GDI+
#include <gdiplus.h> // Добавляем для LinearGradientBrush

using namespace System;
using namespace System::Drawing;
using namespace System::Windows::Forms;
using namespace Gdiplus; // Добавляем пространство имен GDI+

namespace MaltegoClone {
    public ref class GraphNode : public GraphElement {
    public:
        event EventHandler^ NodeChanged;
        event EventHandler^ NodeDeleted;

        GraphNode() {
            this->Editable = true;
            this->size = Size(150, 50);
            this->is_expanded = false;
        }

        virtual void Draw(Graphics^ g) override {
            // Draw shadow
            System::Drawing::Rectangle shadowRect = System::Drawing::Rectangle(
                location.X + 3, location.Y + 3, size.Width, size.Height);
            SolidBrush^ shadowBrush = gcnew SolidBrush(Color::FromArgb(30, 0, 0, 0));
            g->FillRectangle(shadowBrush, shadowRect);
            delete shadowBrush;

            // Draw main rectangle with gradient
            System::Drawing::Rectangle bounds = this->Bounds;
            Gdiplus::LinearGradientBrush* brush = new Gdiplus::LinearGradientBrush(
                Gdiplus::Rect(bounds.X, bounds.Y, bounds.Width, bounds.Height),
                Gdiplus::Color(color.R, color.G, color.B),
                Gdiplus::Color(color.R - 20, color.G - 20, color.B - 20),
                Gdiplus::LinearGradientModeForwardDiagonal);

            Pen^ pen = gcnew Pen(Color::FromArgb(100, 100, 100), 1.5f);
            g->FillRectangle(gcnew SolidBrush(brush), bounds);
            g->DrawRectangle(pen, bounds);
            delete brush;
            delete pen;

            // Draw resize handle if selected
            if (is_resizing) {
                SolidBrush^ handleBrush = gcnew SolidBrush(Color::FromArgb(200, 200, 200));
                g->FillEllipse(handleBrush, ResizeHandle);
                delete handleBrush;
            }

            // Draw title with text shadow
            System::Drawing::Font^ font = gcnew System::Drawing::Font("Segoe UI", 9, FontStyle::Bold);
            RectangleF textRect = RectangleF(location.X, location.Y, size.Width, size.Height);
            StringFormat^ format = gcnew StringFormat();
            format->Alignment = StringAlignment::Center;
            format->LineAlignment = StringAlignment::Center;

            // Text shadow
            textRect.Offset(1, 1);
            g->DrawString(text, font, Brushes::Black, textRect, format);

            // Main text
            textRect.Offset(-1, -1);
            g->DrawString(text, font, Brushes::White, textRect, format);
            delete font;
            delete format;
        }

        // ... остальные методы класса ...
    };
}