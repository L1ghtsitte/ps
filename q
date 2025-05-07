#pragma once

#include <Windows.h>
#include "large_form.h"
#include <string>
#include <stack>
#include <cmath>
#include <algorithm>

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

    private: 
        // ... (keep all your existing button declarations the same)

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
            // ... (keep all your existing InitializeComponent code the same)
        }
#pragma endregion

    private: 
        System::Void exit_button_main_Click(System::Object^ sender, System::EventArgs^ e)
        {
            this->Close();
        }

        System::Void button_number_choise(System::Object^ sender, System::EventArgs^ e)
        {
            Button^ button = safe_cast<Button^>(sender);

            if (this->result_lable->Text == "0")
                this->result_lable->Text = button->Text;
            else
                this->result_lable->Text += button->Text;
        }

        System::Void plus_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            math_action('+');
        }

        System::Void minus_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            math_action('-');
        }

        System::Void multiplication_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            math_action('*');
        }

        System::Void division_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            math_action('/');
        }

        System::Void math_action(char action)
        {
            this->first_num = System::Convert::ToDouble(this->result_lable->Text);
            this->user_action = action;
            this->result_lable->Text = "0";
        }

        System::Void equals_button_Click(System::Object^ sender, System::EventArgs^ e)
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

        System::Void large_form_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            large_form^ large_form1 = gcnew large_form();
            large_form1->Show();
            this->Hide();
        }

        System::Void button1_Click(System::Object^ sender, System::EventArgs^ e) 
        {
            System::Diagnostics::Process::Start("https://github.com/L1ghtsitte/calculator");
        }

        System::Void clear_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            this->result_lable->Text = "0";
            this->first_num = 0;
            this->user_action = '\0';
        }

        System::Void negative_pozitive_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            if (this->result_lable->Text->StartsWith("-"))
            {
                this->result_lable->Text = this->result_lable->Text->Substring(1);
            }
            else
            {
                this->result_lable->Text = "-" + this->result_lable->Text;
            }
        }

        System::Void dot_button_Click(System::Object^ sender, System::EventArgs^ e)
        {
            if (!this->result_lable->Text->Contains("."))
            {
                this->result_lable->Text += ".";
            }
        }
    };
}
