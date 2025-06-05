#pragma once

#include <vector>
#include <map>
#include <string>
#include <fstream>
#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "IMaltegoModule.h"

namespace MaltegoClone {

    public ref class NodePropertiesWrapper
    {
    public:
        property String^ Text;
        property String^ Type;
        property int Id;
        property Dictionary<String^, String^>^ Properties;
        
        NodePropertiesWrapper(GraphElement^ element)
        {
            Text = element->Text;
            Type = element->Type;
            Id = element->Id;
            Properties = element->Properties;
        }
    };

    public ref class MainForm : public Form
    {
    public:
        MainForm(void)
        {
            InitializeComponent();
            InitializeToolbox();
            this->DoubleBuffered = true;
            graphElements = gcnew List<GraphElement^>();
            edges = gcnew List<GraphEdge^>();
            selectedElement = nullptr;
            isDragging = false;
            isDrawingEdge = false;
            tempEdge = nullptr;
            nodeIdCounter = 1;
            
            // Set up drag and drop
            this->toolbox->MouseDown += gcnew MouseEventHandler(this, &MainForm::toolbox_MouseDown);
            this->graphPanel->DragEnter += gcnew DragEventHandler(this, &MainForm::graphPanel_DragEnter);
            this->graphPanel->DragDrop += gcnew DragEventHandler(this, &MainForm::graphPanel_DragDrop);
            this->graphPanel->MouseDown += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseDown);
            this->graphPanel->MouseMove += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseMove);
            this->graphPanel->MouseUp += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseUp);
            this->graphPanel->Paint += gcnew PaintEventHandler(this, &MainForm::graphPanel_Paint);
            
            // Load modules
            LoadModules();
        }

    protected:
        ~MainForm()
        {
            if (components)
            {
                delete components;
            }
        }

    private:
        System::ComponentModel::Container ^components;
        System::Windows::Forms::Panel^ graphPanel;
        System::Windows::Forms::MenuStrip^ menuStrip;
        System::Windows::Forms::ToolStripMenuItem^ fileToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ saveToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ loadToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ modulesToolStripMenuItem;
        System::Windows::Forms::StatusStrip^ statusStrip;
        System::Windows::Forms::ToolStripStatusLabel^ statusLabel;
        System::Windows::Forms::ListBox^ toolbox;
        System::Windows::Forms::Button^ addCustomElementButton;
        System::Windows::Forms::TextBox^ customElementName;
        System::Windows::Forms::Button^ edgeModeButton;
        System::Windows::Forms::ContextMenuStrip^ nodeContextMenu;
        System::Windows::Forms::ToolStripMenuItem^ editNodeToolStripMenuItem;
        PropertyGrid^ propertyGrid;

        List<GraphElement^>^ graphElements;
        List<GraphEdge^>^ edges;
        GraphElement^ selectedElement;
        bool isDragging;
        Point dragOffset;
        bool isDrawingEdge;
        GraphEdge^ tempEdge;
        int nodeIdCounter;
        List<IMaltegoModule^>^ modules;

        void InitializeComponent(void)
        {
            // ... (инициализация компонентов остается без изменений)
        }

        void InitializeToolbox()
        {
            // ... (инициализация toolbox остается без изменений)
        }

        void LoadModules()
        {
            // ... (загрузка модулей остается без изменений)
        }

        // ... (остальные методы остаются без изменений до editNodeToolStripMenuItem_Click)

        void editNodeToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            if (selectedElement != nullptr)
            {
                Form^ editForm = gcnew Form();
                editForm->Text = "Edit " + selectedElement->Type;
                editForm->Width = 400;
                editForm->Height = 500;
                
                propertyGrid = gcnew PropertyGrid();
                propertyGrid->Dock = DockStyle::Fill;
                
                NodePropertiesWrapper^ wrapper = gcnew NodePropertiesWrapper(selectedElement);
                propertyGrid->SelectedObject = wrapper;
                editForm->Controls->Add(propertyGrid);
                
                Button^ saveButton = gcnew Button();
                saveButton->Text = "Save";
                saveButton->Dock = DockStyle::Bottom;
                saveButton->Click += gcnew EventHandler(this, &MainForm::saveProperties_Click);
                editForm->Controls->Add(saveButton);
                
                editForm->ShowDialog();
            }
        }

        void saveProperties_Click(Object^ sender, EventArgs^ e)
        {
            if (propertyGrid != nullptr && selectedElement != nullptr)
            {
                NodePropertiesWrapper^ wrapper = dynamic_cast<NodePropertiesWrapper^>(propertyGrid->SelectedObject);
                if (wrapper != nullptr)
                {
                    selectedElement->Text = wrapper->Text;
                    // Обновляем свойства
                    selectedElement->Properties->Clear();
                    for each (KeyValuePair<String^, String^>^ pair in wrapper->Properties)
                    {
                        selectedElement->Properties->Add(pair->Key, pair->Value);
                    }
                    graphPanel->Invalidate();
                    MessageBox::Show("Properties saved!", "Success");
                }
            }
        }

        // ... (остальные методы остаются без изменений)
    };
}