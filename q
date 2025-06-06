// GraphNode.h
#pragma once
#include "GraphElement.h"
#include "NodePropertiesEditor.h"

using namespace System;
using namespace System::Drawing;
using namespace System::Windows::Forms;

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

    public:
        bool HandleClick(Point clickPoint) {
            return false;
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
            System::Drawing::Drawing2D::LinearGradientBrush^ brush = gcnew 
                System::Drawing::Drawing2D::LinearGradientBrush(
                    bounds,
                    Color::FromArgb(color.R, color.G, color.B),
                    Color::FromArgb(color.R - 20, color.G - 20, color.B - 20),
                    45.0f);

            Pen^ pen = gcnew Pen(Color::FromArgb(100, 100, 100), 1.5f);
            g->FillRectangle(brush, bounds);
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

        void BeginEditTitle(Control^ parent) {
            if (!Editable) return;

            TextBox^ editBox = gcnew TextBox();
            editBox->Text = this->text;
            editBox->Bounds = System::Drawing::Rectangle(location.X, location.Y, size.Width, size.Height);
            editBox->Font = gcnew System::Drawing::Font("Segoe UI", 9, FontStyle::Bold);
            editBox->TextAlign = HorizontalAlignment::Center;
            editBox->Tag = this;

            editBox->KeyDown += gcnew KeyEventHandler(this, &GraphNode::EditBox_KeyDown);
            editBox->LostFocus += gcnew EventHandler(this, &GraphNode::EditBox_LostFocus);

            parent->Controls->Add(editBox);
            editBox->Focus();
        }

        void OpenEditor(Form^ parentForm) {
            NodePropertiesEditor^ editor = gcnew NodePropertiesEditor(this);
            if (editor->ShowDialog(parentForm) == Windows::Forms::DialogResult::OK) {
                NodeChanged(this, EventArgs::Empty);
            }
        }

        property bool Editable;

    private:
        void EditBox_KeyDown(Object^ sender, KeyEventArgs^ e) {
            if (e->KeyCode == Keys::Enter)
                CompleteEditing((TextBox^)sender);
        }

        void EditBox_LostFocus(Object^ sender, EventArgs^ e) {
            CompleteEditing((TextBox^)sender);
        }

        void CompleteEditing(TextBox^ editBox) {
            this->text = editBox->Text;
            editBox->Parent->Controls->Remove(editBox);
            NodeChanged(this, EventArgs::Empty);
        }
    };
}