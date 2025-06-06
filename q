// PropertyEditor.h
#pragma once

using namespace System;
using namespace System::Windows::Forms;
using namespace System::Drawing;

namespace MaltegoClone {
    public ref class PropertyEditor : public Form {
    public:
        property String^ PropertyName {
            String^ get() { return nameBox->Text; }
            void set(String^ value) { nameBox->Text = value; }
        }

        property String^ PropertyValue {
            String^ get() { return valueBox->Text; }
            void set(String^ value) { valueBox->Text = value; }
        }

        PropertyEditor() {
            InitializeComponent();
            InitializeDarkTheme();
        }

    private:
        TextBox^ nameBox;
        TextBox^ valueBox;
        Button^ okButton;
        Button^ cancelButton;

        void InitializeComponent() {
            this->Text = "Edit Property";
            this->Size = System::Drawing::Size(350, 200);
            this->FormBorderStyle = Windows::Forms::FormBorderStyle::FixedDialog;
            this->StartPosition = FormStartPosition::CenterParent;
            this->Padding = System::Windows::Forms::Padding(10);

            // Name label and textbox
            Label^ nameLabel = gcnew Label();
            nameLabel->Text = "Property Name:";
            nameLabel->Location = System::Drawing::Point(10, 15);
            nameLabel->Size = System::Drawing::Size(120, 20);
            this->Controls->Add(nameLabel);

            nameBox = gcnew TextBox();
            nameBox->Location = System::Drawing::Point(140, 15);
            nameBox->Size = System::Drawing::Size(180, 20);
            this->Controls->Add(nameBox);

            // Value label and textbox
            Label^ valueLabel = gcnew Label();
            valueLabel->Text = "Property Value:";
            valueLabel->Location = System::Drawing::Point(10, 50);
            valueLabel->Size = System::Drawing::Size(120, 20);
            this->Controls->Add(valueLabel);

            valueBox = gcnew TextBox();
            valueBox->Location = System::Drawing::Point(140, 50);
            valueBox->Size = System::Drawing::Size(180, 20);
            this->Controls->Add(valueBox);

            // OK and Cancel buttons
            okButton = gcnew Button();
            okButton->Text = "OK";
            okButton->Location = System::Drawing::Point(70, 100);
            okButton->Size = System::Drawing::Size(80, 30);
            okButton->DialogResult = Windows::Forms::DialogResult::OK;
            this->Controls->Add(okButton);

            cancelButton = gcnew Button();
            cancelButton->Text = "Cancel";
            cancelButton->Location = System::Drawing::Point(170, 100);
            cancelButton->Size = System::Drawing::Size(80, 30);
            cancelButton->DialogResult = Windows::Forms::DialogResult::Cancel;
            this->Controls->Add(cancelButton);

            this->AcceptButton = okButton;
            this->CancelButton = cancelButton;
        }

        void InitializeDarkTheme() {
            this->BackColor = Color::FromArgb(45, 45, 48);
            this->ForeColor = Color::FromArgb(240, 240, 240);

            nameBox->BackColor = Color::FromArgb(60, 60, 65);
            nameBox->ForeColor = Color::FromArgb(240, 240, 240);
            nameBox->BorderStyle = BorderStyle::FixedSingle;

            valueBox->BackColor = Color::FromArgb(60, 60, 65);
            valueBox->ForeColor = Color::FromArgb(240, 240, 240);
            valueBox->BorderStyle = BorderStyle::FixedSingle;

            okButton->BackColor = Color::FromArgb(70, 70, 75);
            okButton->ForeColor = Color::FromArgb(240, 240, 240);
            okButton->FlatStyle = FlatStyle::Flat;
            okButton->FlatAppearance->BorderColor = Color::FromArgb(90, 90, 100);
            okButton->FlatAppearance->MouseOverBackColor = Color::FromArgb(80, 80, 85);

            cancelButton->BackColor = Color::FromArgb(70, 70, 75);
            cancelButton->ForeColor = Color::FromArgb(240, 240, 240);
            cancelButton->FlatStyle = FlatStyle::Flat;
            cancelButton->FlatAppearance->BorderColor = Color::FromArgb(90, 90, 100);
            cancelButton->FlatAppearance->MouseOverBackColor = Color::FromArgb(80, 80, 85);
        }
    };
}