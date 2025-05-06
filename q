#pragma once

#include "main.h"

namespace maltxxxxgo {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;

	/// <summary>
	/// Сводка для entry
	/// </summary>
	public ref class entry : public System::Windows::Forms::Form
	{
	public:
		entry(void)
		{
			InitializeComponent();
			//
			//TODO: добавьте код конструктора
			//
		}

	protected:
		/// <summary>
		/// Освободить все используемые ресурсы.
		/// </summary>
		~entry()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::Label^ username_label_1;
	private: System::Windows::Forms::TextBox^ enter_username_1;
	private: System::Windows::Forms::TextBox^ enter_password_1;
	protected:



	private: System::Windows::Forms::Label^ paeeword_label_1;
	private: System::Windows::Forms::Button^ entry_button_1;
	private: System::Windows::Forms::Label^ label_maltxxxxgo_entry;
	private: System::Windows::Forms::Label^ version_label;

		   String^	username = "admin";
		   String^	password = "123";
		   String^	username1;
		   String^	password1;



	protected:

	protected:

	private:
		/// <summary>
		/// Обязательная переменная конструктора.
		/// </summary>
		System::ComponentModel::Container^ components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Требуемый метод для поддержки конструктора — не изменяйте 
		/// содержимое этого метода с помощью редактора кода.
		/// </summary>
		void InitializeComponent(void)
		{
			System::ComponentModel::ComponentResourceManager^ resources = (gcnew System::ComponentModel::ComponentResourceManager(entry::typeid));
			this->username_label_1 = (gcnew System::Windows::Forms::Label());
			this->enter_username_1 = (gcnew System::Windows::Forms::TextBox());
			this->enter_password_1 = (gcnew System::Windows::Forms::TextBox());
			this->paeeword_label_1 = (gcnew System::Windows::Forms::Label());
			this->entry_button_1 = (gcnew System::Windows::Forms::Button());
			this->label_maltxxxxgo_entry = (gcnew System::Windows::Forms::Label());
			this->version_label = (gcnew System::Windows::Forms::Label());
			this->SuspendLayout();
			// 
			// username_label_1
			// 
			this->username_label_1->AutoSize = true;
			this->username_label_1->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 9.75F, System::Drawing::FontStyle::Regular,
				System::Drawing::GraphicsUnit::Point, static_cast<System::Byte>(204)));
			this->username_label_1->Location = System::Drawing::Point(51, 101);
			this->username_label_1->Name = L"username_label_1";
			this->username_label_1->Size = System::Drawing::Size(76, 16);
			this->username_label_1->TabIndex = 0;
			this->username_label_1->Text = L"Username: ";
			// 
			// enter_username_1
			// 
			this->enter_username_1->Location = System::Drawing::Point(133, 101);
			this->enter_username_1->Name = L"enter_username_1";
			this->enter_username_1->Size = System::Drawing::Size(100, 20);
			this->enter_username_1->TabIndex = 1;
			// 
			// enter_password_1
			// 
			this->enter_password_1->Location = System::Drawing::Point(133, 127);
			this->enter_password_1->Name = L"enter_password_1";
			this->enter_password_1->Size = System::Drawing::Size(100, 20);
			this->enter_password_1->TabIndex = 3;
			// 
			// paeeword_label_1
			// 
			this->paeeword_label_1->AutoSize = true;
			this->paeeword_label_1->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 9.75F, System::Drawing::FontStyle::Regular,
				System::Drawing::GraphicsUnit::Point, static_cast<System::Byte>(204)));
			this->paeeword_label_1->Location = System::Drawing::Point(51, 127);
			this->paeeword_label_1->Name = L"paeeword_label_1";
			this->paeeword_label_1->Size = System::Drawing::Size(70, 16);
			this->paeeword_label_1->TabIndex = 2;
			this->paeeword_label_1->Text = L"Password:";
			// 
			// entry_button_1
			// 
			this->entry_button_1->Location = System::Drawing::Point(54, 179);
			this->entry_button_1->Name = L"entry_button_1";
			this->entry_button_1->Size = System::Drawing::Size(179, 23);
			this->entry_button_1->TabIndex = 4;
			this->entry_button_1->Text = L"Войти";
			this->entry_button_1->UseVisualStyleBackColor = true;
			this->entry_button_1->Click += gcnew System::EventHandler(this, &entry::button1_Click);
			// 
			// label_maltxxxxgo_entry
			// 
			this->label_maltxxxxgo_entry->Font = (gcnew System::Drawing::Font(L"Comic Sans MS", 20.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->label_maltxxxxgo_entry->Location = System::Drawing::Point(47, 38);
			this->label_maltxxxxgo_entry->Name = L"label_maltxxxxgo_entry";
			this->label_maltxxxxgo_entry->Size = System::Drawing::Size(186, 48);
			this->label_maltxxxxgo_entry->TabIndex = 5;
			this->label_maltxxxxgo_entry->Text = L" maltxxxxgo";
			this->label_maltxxxxgo_entry->Click += gcnew System::EventHandler(this, &entry::label_maltxxxxgo_entry_Click);
			// 
			// version_label
			// 
			this->version_label->AutoSize = true;
			this->version_label->Location = System::Drawing::Point(237, 239);
			this->version_label->Name = L"version_label";
			this->version_label->Size = System::Drawing::Size(40, 13);
			this->version_label->TabIndex = 6;
			this->version_label->Text = L"ver 0.1";
			// 
			// entry
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(284, 261);
			this->Controls->Add(this->version_label);
			this->Controls->Add(this->label_maltxxxxgo_entry);
			this->Controls->Add(this->entry_button_1);
			this->Controls->Add(this->enter_password_1);
			this->Controls->Add(this->paeeword_label_1);
			this->Controls->Add(this->enter_username_1);
			this->Controls->Add(this->username_label_1);
			this->Icon = (cli::safe_cast<System::Drawing::Icon^>(resources->GetObject(L"$this.Icon")));
			this->Name = L"entry";
			this->StartPosition = System::Windows::Forms::FormStartPosition::CenterScreen;
			this->Text = L"maltxxxxgo";
			this->ResumeLayout(false);
			this->PerformLayout();

		}
#pragma endregion
	private: System::Void button1_Click(System::Object^ sender, System::EventArgs^ e)
	{

		username1 = this->enter_username_1->Text;
		password1 = this->enter_password_1->Text;

		if (username == username1 && password == password1)
		{
			main^ main_form = gcnew main();
			main_form->Show();
			this->Hide();
		}
	}
	private: System::Void label_maltxxxxgo_entry_Click(System::Object^ sender, System::EventArgs^ e)
	{
		System::Diagnostics::Process::Start("https://github.com/L1ghtsitte/maltxxxxgo");
	}
};
}
