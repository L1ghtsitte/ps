#pragma once

#include <Windows.h>
#include "large_form.h"

namespace crl2stud {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;

	/// <summary>
	/// Сводка для main_form
	/// </summary>
	public ref class main_form : public System::Windows::Forms::Form
	{
	public:
		main_form(void)
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
		~main_form()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::Button^ exit_button_main;
	private: System::Windows::Forms::Label^ result_lable;
	private: System::Windows::Forms::Button^ negative_pozitive_button;


	private: System::Windows::Forms::Button^ ttr_button;

	private: System::Windows::Forms::Button^ division_button;



	private: System::Windows::Forms::Button^ clear_button;
	private: System::Windows::Forms::Button^ nine_button;
	private: System::Windows::Forms::Button^ eight_button;





	private: System::Windows::Forms::Button^ plus_button;
	private: System::Windows::Forms::Button^ seven_button;
	private: System::Windows::Forms::Button^ four_button;
	private: System::Windows::Forms::Button^ one_button;





	private: System::Windows::Forms::Button^ six_button;
	private: System::Windows::Forms::Button^ five_button;


	private: System::Windows::Forms::Button^ multiplication_button;
	private: System::Windows::Forms::Button^ three_button;
	private: System::Windows::Forms::Button^ two_button;



	private: System::Windows::Forms::Button^ minus_button;
	private: System::Windows::Forms::Button^ zero_button;
	private: System::Windows::Forms::Button^ dot_button;



	private: System::Windows::Forms::Button^ equals_button;
	private: double first_num;
	private: char user_action;
	private: System::Windows::Forms::Button^ large_form_button;
	private: System::Windows::Forms::Button^ button1;


	protected:

	protected:



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
			System::ComponentModel::ComponentResourceManager^ resources = (gcnew System::ComponentModel::ComponentResourceManager(main_form::typeid));
			this->exit_button_main = (gcnew System::Windows::Forms::Button());
			this->result_lable = (gcnew System::Windows::Forms::Label());
			this->negative_pozitive_button = (gcnew System::Windows::Forms::Button());
			this->ttr_button = (gcnew System::Windows::Forms::Button());
			this->division_button = (gcnew System::Windows::Forms::Button());
			this->clear_button = (gcnew System::Windows::Forms::Button());
			this->nine_button = (gcnew System::Windows::Forms::Button());
			this->eight_button = (gcnew System::Windows::Forms::Button());
			this->plus_button = (gcnew System::Windows::Forms::Button());
			this->seven_button = (gcnew System::Windows::Forms::Button());
			this->four_button = (gcnew System::Windows::Forms::Button());
			this->one_button = (gcnew System::Windows::Forms::Button());
			this->six_button = (gcnew System::Windows::Forms::Button());
			this->five_button = (gcnew System::Windows::Forms::Button());
			this->multiplication_button = (gcnew System::Windows::Forms::Button());
			this->three_button = (gcnew System::Windows::Forms::Button());
			this->two_button = (gcnew System::Windows::Forms::Button());
			this->minus_button = (gcnew System::Windows::Forms::Button());
			this->zero_button = (gcnew System::Windows::Forms::Button());
			this->dot_button = (gcnew System::Windows::Forms::Button());
			this->equals_button = (gcnew System::Windows::Forms::Button());
			this->large_form_button = (gcnew System::Windows::Forms::Button());
			this->button1 = (gcnew System::Windows::Forms::Button());
			this->SuspendLayout();
			// 
			// exit_button_main
			// 
			this->exit_button_main->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(64)), static_cast<System::Int32>(static_cast<System::Byte>(62)),
				static_cast<System::Int32>(static_cast<System::Byte>(62)));
			this->exit_button_main->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"exit_button_main.BackgroundImage")));
			this->exit_button_main->Cursor = System::Windows::Forms::Cursors::No;
			this->exit_button_main->FlatStyle = System::Windows::Forms::FlatStyle::Flat;
			this->exit_button_main->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 8.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->exit_button_main->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(64)), static_cast<System::Int32>(static_cast<System::Byte>(62)),
				static_cast<System::Int32>(static_cast<System::Byte>(62)));
			this->exit_button_main->Location = System::Drawing::Point(3, 3);
			this->exit_button_main->Name = L"exit_button_main";
			this->exit_button_main->Size = System::Drawing::Size(30, 30);
			this->exit_button_main->TabIndex = 0;
			this->exit_button_main->UseVisualStyleBackColor = false;
			this->exit_button_main->Click += gcnew System::EventHandler(this, &main_form::exit_button_main_Click);
			// 
			// result_lable
			// 
			this->result_lable->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 27.75F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->result_lable->ForeColor = System::Drawing::SystemColors::ButtonHighlight;
			this->result_lable->Location = System::Drawing::Point(12, 49);
			this->result_lable->Name = L"result_lable";
			this->result_lable->Size = System::Drawing::Size(278, 54);
			this->result_lable->TabIndex = 1;
			this->result_lable->Text = L"0";
			this->result_lable->TextAlign = System::Drawing::ContentAlignment::TopRight;
			// 
			// negative_pozitive_button
			// 
			this->negative_pozitive_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)), static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->negative_pozitive_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"negative_pozitive_button.BackgroundImage")));
			this->negative_pozitive_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->negative_pozitive_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->negative_pozitive_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->negative_pozitive_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)), static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->negative_pozitive_button->Location = System::Drawing::Point(9, 356);
			this->negative_pozitive_button->Name = L"negative_pozitive_button";
			this->negative_pozitive_button->Size = System::Drawing::Size(65, 50);
			this->negative_pozitive_button->TabIndex = 2;
			this->negative_pozitive_button->Text = L"+/-";
			this->negative_pozitive_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->negative_pozitive_button->UseVisualStyleBackColor = false;
			// 
			// ttr_button
			// 
			this->ttr_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->ttr_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"ttr_button.BackgroundImage")));
			this->ttr_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->ttr_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->ttr_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->ttr_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->ttr_button->Location = System::Drawing::Point(80, 132);
			this->ttr_button->Name = L"ttr_button";
			this->ttr_button->Size = System::Drawing::Size(65, 50);
			this->ttr_button->TabIndex = 3;
			this->ttr_button->Text = L"%";
			this->ttr_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->ttr_button->UseVisualStyleBackColor = false;
			// 
			// division_button
			// 
			this->division_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->division_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"division_button.BackgroundImage")));
			this->division_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->division_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->division_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->division_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->division_button->Location = System::Drawing::Point(151, 132);
			this->division_button->Name = L"division_button";
			this->division_button->Size = System::Drawing::Size(65, 50);
			this->division_button->TabIndex = 5;
			this->division_button->Text = L"/";
			this->division_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->division_button->UseVisualStyleBackColor = false;
			this->division_button->Click += gcnew System::EventHandler(this, &main_form::division_button_Click);
			// 
			// clear_button
			// 
			this->clear_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->clear_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"clear_button.BackgroundImage")));
			this->clear_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->clear_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->clear_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->clear_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->clear_button->Location = System::Drawing::Point(9, 132);
			this->clear_button->Name = L"clear_button";
			this->clear_button->Size = System::Drawing::Size(65, 50);
			this->clear_button->TabIndex = 6;
			this->clear_button->Text = L"AC";
			this->clear_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->clear_button->UseVisualStyleBackColor = false;
			// 
			// nine_button
			// 
			this->nine_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->nine_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"nine_button.BackgroundImage")));
			this->nine_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->nine_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->nine_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->nine_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->nine_button->Location = System::Drawing::Point(9, 188);
			this->nine_button->Name = L"nine_button";
			this->nine_button->Size = System::Drawing::Size(65, 50);
			this->nine_button->TabIndex = 7;
			this->nine_button->Text = L"9";
			this->nine_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->nine_button->UseVisualStyleBackColor = false;
			this->nine_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// eight_button
			// 
			this->eight_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->eight_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"eight_button.BackgroundImage")));
			this->eight_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->eight_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->eight_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->eight_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->eight_button->Location = System::Drawing::Point(80, 188);
			this->eight_button->Name = L"eight_button";
			this->eight_button->Size = System::Drawing::Size(65, 50);
			this->eight_button->TabIndex = 8;
			this->eight_button->Text = L"8";
			this->eight_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->eight_button->UseVisualStyleBackColor = false;
			this->eight_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// plus_button
			// 
			this->plus_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->plus_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"plus_button.BackgroundImage")));
			this->plus_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->plus_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->plus_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->plus_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->plus_button->Location = System::Drawing::Point(222, 188);
			this->plus_button->Name = L"plus_button";
			this->plus_button->Size = System::Drawing::Size(65, 50);
			this->plus_button->TabIndex = 9;
			this->plus_button->Text = L"+";
			this->plus_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->plus_button->UseVisualStyleBackColor = false;
			this->plus_button->Click += gcnew System::EventHandler(this, &main_form::plus_button_Click);
			// 
			// seven_button
			// 
			this->seven_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->seven_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"seven_button.BackgroundImage")));
			this->seven_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->seven_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->seven_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->seven_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->seven_button->Location = System::Drawing::Point(151, 188);
			this->seven_button->Name = L"seven_button";
			this->seven_button->Size = System::Drawing::Size(65, 50);
			this->seven_button->TabIndex = 11;
			this->seven_button->Text = L"7";
			this->seven_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->seven_button->UseVisualStyleBackColor = false;
			this->seven_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// four_button
			// 
			this->four_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->four_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"four_button.BackgroundImage")));
			this->four_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->four_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->four_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->four_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->four_button->Location = System::Drawing::Point(151, 244);
			this->four_button->Name = L"four_button";
			this->four_button->Size = System::Drawing::Size(65, 50);
			this->four_button->TabIndex = 12;
			this->four_button->Text = L"4";
			this->four_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->four_button->UseVisualStyleBackColor = false;
			this->four_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// one_button
			// 
			this->one_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->one_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"one_button.BackgroundImage")));
			this->one_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->one_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->one_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->one_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->one_button->Location = System::Drawing::Point(151, 300);
			this->one_button->Name = L"one_button";
			this->one_button->Size = System::Drawing::Size(65, 50);
			this->one_button->TabIndex = 13;
			this->one_button->Text = L"1";
			this->one_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->one_button->UseVisualStyleBackColor = false;
			this->one_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// six_button
			// 
			this->six_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->six_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"six_button.BackgroundImage")));
			this->six_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->six_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->six_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->six_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->six_button->Location = System::Drawing::Point(9, 244);
			this->six_button->Name = L"six_button";
			this->six_button->Size = System::Drawing::Size(65, 50);
			this->six_button->TabIndex = 14;
			this->six_button->Text = L"6";
			this->six_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->six_button->UseVisualStyleBackColor = false;
			this->six_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// five_button
			// 
			this->five_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->five_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"five_button.BackgroundImage")));
			this->five_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->five_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->five_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->five_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->five_button->Location = System::Drawing::Point(80, 244);
			this->five_button->Name = L"five_button";
			this->five_button->Size = System::Drawing::Size(65, 50);
			this->five_button->TabIndex = 15;
			this->five_button->Text = L"5";
			this->five_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->five_button->UseVisualStyleBackColor = false;
			this->five_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// multiplication_button
			// 
			this->multiplication_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)), static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->multiplication_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"multiplication_button.BackgroundImage")));
			this->multiplication_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->multiplication_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->multiplication_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->multiplication_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)), static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->multiplication_button->Location = System::Drawing::Point(222, 132);
			this->multiplication_button->Name = L"multiplication_button";
			this->multiplication_button->Size = System::Drawing::Size(65, 50);
			this->multiplication_button->TabIndex = 16;
			this->multiplication_button->Text = L"*";
			this->multiplication_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->multiplication_button->UseVisualStyleBackColor = false;
			this->multiplication_button->Click += gcnew System::EventHandler(this, &main_form::multiplication_button_Click);
			// 
			// three_button
			// 
			this->three_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->three_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"three_button.BackgroundImage")));
			this->three_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->three_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->three_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->three_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->three_button->Location = System::Drawing::Point(9, 300);
			this->three_button->Name = L"three_button";
			this->three_button->Size = System::Drawing::Size(65, 50);
			this->three_button->TabIndex = 17;
			this->three_button->Text = L"3";
			this->three_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->three_button->UseVisualStyleBackColor = false;
			this->three_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// two_button
			// 
			this->two_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->two_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"two_button.BackgroundImage")));
			this->two_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->two_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->two_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->two_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->two_button->Location = System::Drawing::Point(80, 300);
			this->two_button->Name = L"two_button";
			this->two_button->Size = System::Drawing::Size(65, 50);
			this->two_button->TabIndex = 18;
			this->two_button->Text = L"2";
			this->two_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->two_button->UseVisualStyleBackColor = false;
			this->two_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// minus_button
			// 
			this->minus_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->minus_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"minus_button.BackgroundImage")));
			this->minus_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->minus_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->minus_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->minus_button->Location = System::Drawing::Point(222, 244);
			this->minus_button->Name = L"minus_button";
			this->minus_button->Size = System::Drawing::Size(65, 50);
			this->minus_button->TabIndex = 19;
			this->minus_button->Text = L"-";
			this->minus_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->minus_button->UseVisualStyleBackColor = false;
			this->minus_button->Click += gcnew System::EventHandler(this, &main_form::minus_button_Click);
			// 
			// zero_button
			// 
			this->zero_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->zero_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"zero_button.BackgroundImage")));
			this->zero_button->Cursor = System::Windows::Forms::Cursors::Cross;
			this->zero_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->zero_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->zero_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->zero_button->Location = System::Drawing::Point(80, 356);
			this->zero_button->Name = L"zero_button";
			this->zero_button->Size = System::Drawing::Size(65, 50);
			this->zero_button->TabIndex = 20;
			this->zero_button->Text = L"0";
			this->zero_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->zero_button->UseVisualStyleBackColor = false;
			this->zero_button->Click += gcnew System::EventHandler(this, &main_form::button_number_choise);
			// 
			// dot_button
			// 
			this->dot_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->dot_button->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"dot_button.BackgroundImage")));
			this->dot_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->dot_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->dot_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 1.5F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->dot_button->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->dot_button->Location = System::Drawing::Point(151, 356);
			this->dot_button->Name = L"dot_button";
			this->dot_button->Size = System::Drawing::Size(65, 50);
			this->dot_button->TabIndex = 21;
			this->dot_button->Text = L".";
			this->dot_button->TextAlign = System::Drawing::ContentAlignment::TopLeft;
			this->dot_button->UseVisualStyleBackColor = false;
			// 
			// equals_button
			// 
			this->equals_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)), static_cast<System::Int32>(static_cast<System::Byte>(125)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->equals_button->Cursor = System::Windows::Forms::Cursors::Hand;
			this->equals_button->FlatStyle = System::Windows::Forms::FlatStyle::Popup;
			this->equals_button->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 14.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->equals_button->Location = System::Drawing::Point(222, 300);
			this->equals_button->Name = L"equals_button";
			this->equals_button->Size = System::Drawing::Size(65, 106);
			this->equals_button->TabIndex = 22;
			this->equals_button->Text = L"=";
			this->equals_button->UseVisualStyleBackColor = false;
			this->equals_button->Click += gcnew System::EventHandler(this, &main_form::equals_button_Click);
			// 
			// large_form_button
			// 
			this->large_form_button->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(130)),
				static_cast<System::Int32>(static_cast<System::Byte>(125)), static_cast<System::Int32>(static_cast<System::Byte>(125)));
			this->large_form_button->Location = System::Drawing::Point(39, 3);
			this->large_form_button->Name = L"large_form_button";
			this->large_form_button->Size = System::Drawing::Size(52, 30);
			this->large_form_button->TabIndex = 23;
			this->large_form_button->Text = L"large";
			this->large_form_button->UseVisualStyleBackColor = false;
			this->large_form_button->Click += gcnew System::EventHandler(this, &main_form::large_form_button_Click);
			// 
			// button1
			// 
			this->button1->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"button1.BackgroundImage")));
			this->button1->BackgroundImageLayout = System::Windows::Forms::ImageLayout::Center;
			this->button1->FlatStyle = System::Windows::Forms::FlatStyle::Flat;
			this->button1->ForeColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(64)), static_cast<System::Int32>(static_cast<System::Byte>(62)),
				static_cast<System::Int32>(static_cast<System::Byte>(62)));
			this->button1->Location = System::Drawing::Point(260, 3);
			this->button1->Name = L"button1";
			this->button1->Size = System::Drawing::Size(30, 30);
			this->button1->TabIndex = 24;
			this->button1->UseVisualStyleBackColor = true;
			this->button1->Click += gcnew System::EventHandler(this, &main_form::button1_Click);
			// 
			// main_form
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(7, 16);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->BackColor = System::Drawing::Color::FromArgb(static_cast<System::Int32>(static_cast<System::Byte>(64)), static_cast<System::Int32>(static_cast<System::Byte>(62)),
				static_cast<System::Int32>(static_cast<System::Byte>(62)));
			this->ClientSize = System::Drawing::Size(300, 420);
			this->Controls->Add(this->button1);
			this->Controls->Add(this->large_form_button);
			this->Controls->Add(this->result_lable);
			this->Controls->Add(this->equals_button);
			this->Controls->Add(this->dot_button);
			this->Controls->Add(this->zero_button);
			this->Controls->Add(this->minus_button);
			this->Controls->Add(this->two_button);
			this->Controls->Add(this->three_button);
			this->Controls->Add(this->multiplication_button);
			this->Controls->Add(this->five_button);
			this->Controls->Add(this->six_button);
			this->Controls->Add(this->one_button);
			this->Controls->Add(this->four_button);
			this->Controls->Add(this->seven_button);
			this->Controls->Add(this->plus_button);
			this->Controls->Add(this->eight_button);
			this->Controls->Add(this->nine_button);
			this->Controls->Add(this->clear_button);
			this->Controls->Add(this->division_button);
			this->Controls->Add(this->ttr_button);
			this->Controls->Add(this->negative_pozitive_button);
			this->Controls->Add(this->exit_button_main);
			this->Cursor = System::Windows::Forms::Cursors::Hand;
			this->Font = (gcnew System::Drawing::Font(L"Microsoft YaHei", 8.25F, System::Drawing::FontStyle::Bold, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(204)));
			this->ForeColor = System::Drawing::Color::White;
			this->FormBorderStyle = System::Windows::Forms::FormBorderStyle::None;
			this->Icon = (cli::safe_cast<System::Drawing::Icon^>(resources->GetObject(L"$this.Icon")));
			this->Margin = System::Windows::Forms::Padding(4);
			this->Name = L"main_form";
			this->StartPosition = System::Windows::Forms::FormStartPosition::CenterScreen;
			this->Text = L"Calculaor";
			this->ResumeLayout(false);

		}
#pragma endregion

	private: System::Void exit_button_main_Click(System::Object^ sender, System::EventArgs^ e)
	{
		this->Close();
	}

	private: System::Void button_number_choise(System::Object^ sender, System::EventArgs^ e)
	{
		Button^ button = safe_cast<Button^>(sender);

		if (this->result_lable->Text == "0")
			this->result_lable->Text = button->Text;
		else
			this->result_lable->Text += button->Text;
	}
	private: System::Void plus_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		math_action('+');
	}
	private: System::Void minus_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		math_action('-');
	}
	private: System::Void multiplication_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		math_action('*');
	}
	private: System::Void division_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		math_action('/');
	}
	private: System::Void math_action(char action)
	{
		this->first_num = System::Convert::ToDouble(this->result_lable->Text);
		this->user_action = action;
		this->result_lable->Text = "0";
	}
	private: System::Void equals_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		double second_num;
		double result;

		second_num = System::Convert::ToDouble(this->result_lable->Text);
		result = 1;

		switch (this->user_action)
		{
		case '+':
		{
			result = this->first_num + second_num;
			break;
		}
		case '-':
		{
			result = this->first_num - second_num;
			break;
		}
		case '*':
		{
			result = this->first_num * second_num;
			break;
		}
		case '/':
		{
			result = this->first_num / second_num;
			break;
		}
		}

		this->result_lable->Text = System::Convert::ToString(result);
	}
	private: System::Void large_form_button_Click(System::Object^ sender, System::EventArgs^ e)
	{
		large_form^ large_form1 = gcnew large_form();
		large_form1->Show();
		this->Hide();
	}
	private: System::Void button1_Click(System::Object^ sender, System::EventArgs^ e) 
	{
		System::Diagnostics::Process::Start("https://github.com/L1ghtsitte/calculator");
	}
};
}
