// large_form.h
#pragma once

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

    public ref class large_form : public System::Windows::Forms::Form
    {
    public:
        large_form(void)
        {
            InitializeComponent();
        }

    protected:
        ~large_form()
        {
            if (components)
            {
                delete components;
            }
        }

    private:
        System::Windows::Forms::TextBox^ expressionTextBox;
        System::Windows::Forms::Button^ calculateButton;
        System::Windows::Forms::Label^ resultLabel;
        System::Windows::Forms::Button^ backButton;
        System::ComponentModel::Container^ components;

        void InitializeComponent(void)
        {
            this->expressionTextBox = gcnew System::Windows::Forms::TextBox();
            this->calculateButton = gcnew System::Windows::Forms::Button();
            this->resultLabel = gcnew System::Windows::Forms::Label();
            this->backButton = gcnew System::Windows::Forms::Button();
            this->SuspendLayout();
            
            // expressionTextBox
            this->expressionTextBox->Font = gcnew System::Drawing::Font("Microsoft Sans Serif", 14.0F);
            this->expressionTextBox->Location = System::Drawing::Point(20, 20);
            this->expressionTextBox->Size = System::Drawing::Size(400, 30);
            this->expressionTextBox->Name = L"expressionTextBox";
            
            // calculateButton
            this->calculateButton->Location = System::Drawing::Point(20, 70);
            this->calculateButton->Size = System::Drawing::Size(100, 30);
            this->calculateButton->Text = L"Calculate";
            this->calculateButton->Click += gcnew System::EventHandler(this, &large_form::calculateButton_Click);
            
            // resultLabel
            this->resultLabel->Font = gcnew System::Drawing::Font("Microsoft Sans Serif", 14.0F);
            this->resultLabel->Location = System::Drawing::Point(20, 120);
            this->resultLabel->Size = System::Drawing::Size(400, 30);
            this->resultLabel->Name = L"resultLabel";
            this->resultLabel->Text = L"Result: ";
            
            // backButton
            this->backButton->Location = System::Drawing::Point(150, 70);
            this->backButton->Size = System::Drawing::Size(100, 30);
            this->backButton->Text = L"Back";
            this->backButton->Click += gcnew System::EventHandler(this, &large_form::backButton_Click);
            
            // large_form
            this->ClientSize = System::Drawing::Size(440, 180);
            this->Controls->Add(this->backButton);
            this->Controls->Add(this->resultLabel);
            this->Controls->Add(this->calculateButton);
            this->Controls->Add(this->expressionTextBox);
            this->Text = L"Advanced Calculator";
            this->ResumeLayout(false);
            this->PerformLayout();
        }

    private:
        System::Void calculateButton_Click(System::Object^ sender, System::EventArgs^ e)
        {
            String^ expression = expressionTextBox->Text;
            std::string stdExpression = msclr::interop::marshal_as<std::string>(expression);
            
            try {
                double result = EvaluateExpression(stdExpression);
                resultLabel->Text = "Result: " + result.ToString();
            }
            catch (Exception^ ex) {
                resultLabel->Text = "Error: " + ex->Message;
            }
        }

        System::Void backButton_Click(System::Object^ sender, System::EventArgs^ e)
        {
            this->Close();
        }

        double EvaluateExpression(const std::string& expression)
        {
            std::stack<double> numbers;
            std::stack<char> ops;
            
            for (size_t i = 0; i < expression.length(); i++) {
                if (expression[i] == ' ') continue;
                
                if (expression[i] == '(') {
                    ops.push(expression[i]);
                }
                else if (isdigit(expression[i]) {
                    double num = 0;
                    while (i < expression.length() && isdigit(expression[i])) {
                        num = num * 10 + (expression[i] - '0');
                        i++;
                    }
                    
                    if (i < expression.length() && expression[i] == '.') {
                        i++;
                        double fraction = 0.1;
                        while (i < expression.length() && isdigit(expression[i])) {
                            num += (expression[i] - '0') * fraction;
                            fraction *= 0.1;
                            i++;
                        }
                    }
                    
                    numbers.push(num);
                    i--;
                }
                else if (expression[i] == '-' && (i == 0 || expression[i-1] == '(' || 
                         expression[i-1] == '+' || expression[i-1] == '-' || 
                         expression[i-1] == '*' || expression[i-1] == '/')) {
                    // Handle negative numbers
                    i++;
                    double num = 0;
                    bool hasFraction = false;
                    double fraction = 0.1;
                    
                    while (i < expression.length() && (isdigit(expression[i]) || expression[i] == '.')) {
                        if (expression[i] == '.') {
                            hasFraction = true;
                            i++;
                            continue;
                        }
                        
                        if (!hasFraction) {
                            num = num * 10 + (expression[i] - '0');
                        } else {
                            num += (expression[i] - '0') * fraction;
                            fraction *= 0.1;
                        }
                        i++;
                    }
                    
                    numbers.push(-num);
                    i--;
                }
                else if (expression[i] == ')') {
                    while (!ops.empty() && ops.top() != '(') {
                        double val2 = numbers.top();
                        numbers.pop();
                        
                        double val1 = numbers.top();
                        numbers.pop();
                        
                        char op = ops.top();
                        ops.pop();
                        
                        numbers.push(ApplyOp(val1, val2, op));
                    }
                    
                    if (!ops.empty())
                        ops.pop();
                }
                else {
                    while (!ops.empty() && Precedence(ops.top()) >= Precedence(expression[i])) {
                        double val2 = numbers.top();
                        numbers.pop();
                        
                        double val1 = numbers.top();
                        numbers.pop();
                        
                        char op = ops.top();
                        ops.pop();
                        
                        numbers.push(ApplyOp(val1, val2, op));
                    }
                    
                    ops.push(expression[i]);
                }
            }
            
            while (!ops.empty()) {
                double val2 = numbers.top();
                numbers.pop();
                
                double val1 = numbers.top();
                numbers.pop();
                
                char op = ops.top();
                ops.pop();
                
                numbers.push(ApplyOp(val1, val2, op));
            }
            
            return numbers.top();
        }

        int Precedence(char op)
        {
            if (op == '+' || op == '-')
                return 1;
            if (op == '*' || op == '/')
                return 2;
            return 0;
        }

        double ApplyOp(double a, double b, char op)
        {
            switch (op) {
                case '+': return a + b;
                case '-': return a - b;
                case '*': return a * b;
                case '/': 
                    if (b == 0) throw gcnew System::DivideByZeroException("Division by zero");
                    return a / b;
            }
            return 0;
        }
    };
}// large_form.h
#pragma once

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

    public ref class large_form : public System::Windows::Forms::Form
    {
    public:
        large_form(void)
        {
            InitializeComponent();
        }

    protected:
        ~large_form()
        {
            if (components)
            {
                delete components;
            }
        }

    private:
        System::Windows::Forms::TextBox^ expressionTextBox;
        System::Windows::Forms::Button^ calculateButton;
        System::Windows::Forms::Label^ resultLabel;
        System::Windows::Forms::Button^ backButton;
        System::ComponentModel::Container^ components;

        void InitializeComponent(void)
        {
            this->expressionTextBox = gcnew System::Windows::Forms::TextBox();
            this->calculateButton = gcnew System::Windows::Forms::Button();
            this->resultLabel = gcnew System::Windows::Forms::Label();
            this->backButton = gcnew System::Windows::Forms::Button();
            this->SuspendLayout();
            
            // expressionTextBox
            this->expressionTextBox->Font = gcnew System::Drawing::Font("Microsoft Sans Serif", 14.0F);
            this->expressionTextBox->Location = System::Drawing::Point(20, 20);
            this->expressionTextBox->Size = System::Drawing::Size(400, 30);
            this->expressionTextBox->Name = L"expressionTextBox";
            
            // calculateButton
            this->calculateButton->Location = System::Drawing::Point(20, 70);
            this->calculateButton->Size = System::Drawing::Size(100, 30);
            this->calculateButton->Text = L"Calculate";
            this->calculateButton->Click += gcnew System::EventHandler(this, &large_form::calculateButton_Click);
            
            // resultLabel
            this->resultLabel->Font = gcnew System::Drawing::Font("Microsoft Sans Serif", 14.0F);
            this->resultLabel->Location = System::Drawing::Point(20, 120);
            this->resultLabel->Size = System::Drawing::Size(400, 30);
            this->resultLabel->Name = L"resultLabel";
            this->resultLabel->Text = L"Result: ";
            
            // backButton
            this->backButton->Location = System::Drawing::Point(150, 70);
            this->backButton->Size = System::Drawing::Size(100, 30);
            this->backButton->Text = L"Back";
            this->backButton->Click += gcnew System::EventHandler(this, &large_form::backButton_Click);
            
            // large_form
            this->ClientSize = System::Drawing::Size(440, 180);
            this->Controls->Add(this->backButton);
            this->Controls->Add(this->resultLabel);
            this->Controls->Add(this->calculateButton);
            this->Controls->Add(this->expressionTextBox);
            this->Text = L"Advanced Calculator";
            this->ResumeLayout(false);
            this->PerformLayout();
        }

    private:
        System::Void calculateButton_Click(System::Object^ sender, System::EventArgs^ e)
        {
            String^ expression = expressionTextBox->Text;
            std::string stdExpression = msclr::interop::marshal_as<std::string>(expression);
            
            try {
                double result = EvaluateExpression(stdExpression);
                resultLabel->Text = "Result: " + result.ToString();
            }
            catch (Exception^ ex) {
                resultLabel->Text = "Error: " + ex->Message;
            }
        }

        System::Void backButton_Click(System::Object^ sender, System::EventArgs^ e)
        {
            this->Close();
        }

        double EvaluateExpression(const std::string& expression)
        {
            std::stack<double> numbers;
            std::stack<char> ops;
            
            for (size_t i = 0; i < expression.length(); i++) {
                if (expression[i] == ' ') continue;
                
                if (expression[i] == '(') {
                    ops.push(expression[i]);
                }
                else if (isdigit(expression[i]) {
                    double num = 0;
                    while (i < expression.length() && isdigit(expression[i])) {
                        num = num * 10 + (expression[i] - '0');
                        i++;
                    }
                    
                    if (i < expression.length() && expression[i] == '.') {
                        i++;
                        double fraction = 0.1;
                        while (i < expression.length() && isdigit(expression[i])) {
                            num += (expression[i] - '0') * fraction;
                            fraction *= 0.1;
                            i++;
                        }
                    }
                    
                    numbers.push(num);
                    i--;
                }
                else if (expression[i] == '-' && (i == 0 || expression[i-1] == '(' || 
                         expression[i-1] == '+' || expression[i-1] == '-' || 
                         expression[i-1] == '*' || expression[i-1] == '/')) {
                    // Handle negative numbers
                    i++;
                    double num = 0;
                    bool hasFraction = false;
                    double fraction = 0.1;
                    
                    while (i < expression.length() && (isdigit(expression[i]) || expression[i] == '.')) {
                        if (expression[i] == '.') {
                            hasFraction = true;
                            i++;
                            continue;
                        }
                        
                        if (!hasFraction) {
                            num = num * 10 + (expression[i] - '0');
                        } else {
                            num += (expression[i] - '0') * fraction;
                            fraction *= 0.1;
                        }
                        i++;
                    }
                    
                    numbers.push(-num);
                    i--;
                }
                else if (expression[i] == ')') {
                    while (!ops.empty() && ops.top() != '(') {
                        double val2 = numbers.top();
                        numbers.pop();
                        
                        double val1 = numbers.top();
                        numbers.pop();
                        
                        char op = ops.top();
                        ops.pop();
                        
                        numbers.push(ApplyOp(val1, val2, op));
                    }
                    
                    if (!ops.empty())
                        ops.pop();
                }
                else {
                    while (!ops.empty() && Precedence(ops.top()) >= Precedence(expression[i])) {
                        double val2 = numbers.top();
                        numbers.pop();
                        
                        double val1 = numbers.top();
                        numbers.pop();
                        
                        char op = ops.top();
                        ops.pop();
                        
                        numbers.push(ApplyOp(val1, val2, op));
                    }
                    
                    ops.push(expression[i]);
                }
            }
            
            while (!ops.empty()) {
                double val2 = numbers.top();
                numbers.pop();
                
                double val1 = numbers.top();
                numbers.pop();
                
                char op = ops.top();
                ops.pop();
                
                numbers.push(ApplyOp(val1, val2, op));
            }
            
            return numbers.top();
        }

        int Precedence(char op)
        {
            if (op == '+' || op == '-')
                return 1;
            if (op == '*' || op == '/')
                return 2;
            return 0;
        }

        double ApplyOp(double a, double b, char op)
        {
            switch (op) {
                case '+': return a + b;
                case '-': return a - b;
                case '*': return a * b;
                case '/': 
                    if (b == 0) throw gcnew System::DivideByZeroException("Division by zero");
                    return a / b;
            }
            return 0;
        }
    };
}
