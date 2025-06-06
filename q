// NodePropertiesEditor.h
#pragma once
#include "GraphElement.h"
#include "PropertyEditor.h"

using namespace System;
using namespace System::Windows::Forms;
using namespace System::Drawing;
using namespace System::Collections::Generic;

namespace MaltegoClone {
    public ref class NodePropertiesEditor : public Form {
    public:
        property String^ NodeText {
            String^ get() { return element_ref->text; }
            void set(String^ value) { element_ref->text = value; }
        }

        NodePropertiesEditor(GraphElement^ element) {
            element_ref = element;
            InitializeComponent();
            InitializeProperties();
        }

        property bool ChangesMade {
            bool get() { return changesMade; }
        }

    private:
        GraphElement^ element_ref;
        PropertyGrid^ property_grid;
        TextBox^ notes_box;
        Button^ save_button;
        Button^ cancel_button;
        Button^ delete_button;
        bool changesMade;

        void InitializeComponent() {
            changesMade = false;
            this->Text = "Edit Node Properties - " + element_ref->text;
            this->Size = System::Drawing::Size(500, 600);
            this->FormBorderStyle = Windows::Forms::FormBorderStyle::FixedDialog;
            this->StartPosition = FormStartPosition::CenterParent;
            this->BackColor = Color::FromArgb(45, 45, 48);
            this->ForeColor = Color::FromArgb(240, 240, 240);

            // Property Grid
            property_grid = gcnew PropertyGrid();
            property_grid->Location = Point(10, 10);
            property_grid->Size = System::Drawing::Size(460, 250);
            property_grid->ToolbarVisible = false;
            property_grid->HelpVisible = false;
            property_grid->BackColor = Color::FromArgb(60, 60, 65);
            property_grid->ForeColor = Color::FromArgb(240, 240, 240);
            property_grid->ViewBackColor = Color::FromArgb(60, 60, 65);
            property_grid->ViewForeColor = Color::FromArgb(240, 240, 240);
            property_grid->PropertyValueChanged += gcnew PropertyValueChangedEventHandler(this, &NodePropertiesEditor::PropertyGrid_PropertyValueChanged);
            this->Controls->Add(property_grid);

            // Notes
            Label^ notesLabel = gcnew Label();
            notesLabel->Text = "Notes:";
            notesLabel->Location = Point(10, 270);
            notesLabel->ForeColor = Color::FromArgb(240, 240, 240);
            this->Controls->Add(notesLabel);

            notes_box = gcnew TextBox();
            notes_box->Multiline = true;
            notes_box->Location = Point(10, 290);
            notes_box->Size = System::Drawing::Size(460, 150);
            notes_box->Text = element_ref->notes;
            notes_box->BackColor = Color::FromArgb(60, 60, 65);
            notes_box->ForeColor = Color::FromArgb(240, 240, 240);
            notes_box->BorderStyle = BorderStyle::FixedSingle;
            this->Controls->Add(notes_box);

            // Delete Button
            delete_button = gcnew Button();
            delete_button->Text = "Delete Node";
            delete_button->Location = Point(10, 450);
            delete_button->Size = System::Drawing::Size(120, 30);
            delete_button->BackColor = Color::FromArgb(90, 50, 50);
            delete_button->ForeColor = Color::FromArgb(240, 240, 240);
            delete_button->FlatStyle = FlatStyle::Flat;
            delete_button->FlatAppearance->BorderColor = Color::FromArgb(120, 70, 70);
            delete_button->FlatAppearance->MouseOverBackColor = Color::FromArgb(110, 60, 60);
            delete_button->Click += gcnew EventHandler(this, &NodePropertiesEditor::DeleteNode);
            this->Controls->Add(delete_button);

            // Cancel Button
            cancel_button = gcnew Button();
            cancel_button->Text = "Cancel";
            cancel_button->Location = Point(250, 450);
            cancel_button->Size = System::Drawing::Size(100, 30);
            cancel_button->BackColor = Color::FromArgb(70, 70, 75);
            cancel_button->ForeColor = Color::FromArgb(240, 240, 240);
            cancel_button->FlatStyle = FlatStyle::Flat;
            cancel_button->FlatAppearance->BorderColor = Color::FromArgb(90, 90, 100);
            cancel_button->FlatAppearance->MouseOverBackColor = Color::FromArgb(80, 80, 85);
            cancel_button->Click += gcnew EventHandler(this, &NodePropertiesEditor::CancelChanges);
            this->Controls->Add(cancel_button);

            // Save Button
            save_button = gcnew Button();
            save_button->Text = "Save";
            save_button->Location = Point(360, 450);
            save_button->Size = System::Drawing::Size(100, 30);
            save_button->BackColor = Color::FromArgb(70, 70, 75);
            save_button->ForeColor = Color::FromArgb(240, 240, 240);
            save_button->FlatStyle = FlatStyle::Flat;
            save_button->FlatAppearance->BorderColor = Color::FromArgb(90, 90, 100);
            save_button->FlatAppearance->MouseOverBackColor = Color::FromArgb(80, 80, 85);
            save_button->Click += gcnew EventHandler(this, &NodePropertiesEditor::SaveChanges);
            this->Controls->Add(save_button);
        }

        void InitializeProperties() {
            // Create a wrapper object for property grid
            Object^ propsObj = gcnew DynamicProperties(element_ref);
            property_grid->SelectedObject = propsObj;
        }

        void PropertyGrid_PropertyValueChanged(Object^ sender, PropertyValueChangedEventArgs^ e) {
            changesMade = true;
        }

        void SaveChanges(Object^ sender, EventArgs^ e) {
            element_ref->notes = notes_box->Text;
            changesMade = true;
            this->DialogResult = Windows::Forms::DialogResult::OK;
            this->Close();
        }

        void CancelChanges(Object^ sender, EventArgs^ e) {
            this->DialogResult = Windows::Forms::DialogResult::Cancel;
            this->Close();
        }

        void DeleteNode(Object^ sender, EventArgs^ e) {
            if (MessageBox::Show("Are you sure you want to delete this node and all its connections?",
                "Confirm Delete",
                MessageBoxButtons::YesNo,
                MessageBoxIcon::Warning) == Windows::Forms::DialogResult::Yes) {
                changesMade = true;
                this->DialogResult = Windows::Forms::DialogResult::Abort;
                this->Close();
            }
        }

        // Wrapper class for property grid
        ref class DynamicProperties {
        private:
            GraphElement^ element;

        public:
            DynamicProperties(GraphElement^ element) : element(element) {}

            property String^ Text {
                String^ get() { return element->text; }
                void set(String^ value) { element->text = value; }
            }

            property Color NodeColor {
                Color get() { return element->color; }
                void set(Color value) { element->color = value; }
            }

            property bool IsExpanded {
                bool get() { return element->is_expanded; }
                void set(bool value) { element->is_expanded = value; }
            }

            property String^ FirstName {
                String^ get() {
                    if (element->properties->ContainsKey("First Name"))
                        return element->properties["First Name"];
                    return String::Empty;
                }
                void set(String^ value) {
                    element->properties["First Name"] = value;
                }
            }

            property String^ LastName {
                String^ get() {
                    if (element->properties->ContainsKey("Last Name"))
                        return element->properties["Last Name"];
                    return String::Empty;
                }
                void set(String^ value) {
                    element->properties["Last Name"] = value;
                }
            }
        };
    };
}