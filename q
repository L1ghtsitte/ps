#pragma once

#include <vector>
#include <map>
#include <string>
#include <fstream>
#include "nlohmann/json.hpp"
#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "IMaltegoModule.h"

using json = nlohmann::json;

namespace MaltegoClone {

    using namespace System;
    using namespace System::ComponentModel;
    using namespace System::Collections;
    using namespace System::Windows::Forms;
    using namespace System::Data;
    using namespace System::Drawing;
    using namespace System::IO;

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
            this->toolbox->ItemDrag += gcnew ItemDragEventHandler(this, &MainForm::toolbox_ItemDrag);
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
            this->graphPanel = gcnew System::Windows::Forms::Panel();
            this->menuStrip = gcnew System::Windows::Forms::MenuStrip();
            this->fileToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->saveToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->loadToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->modulesToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->statusStrip = gcnew System::Windows::Forms::StatusStrip();
            this->statusLabel = gcnew System::Windows::Forms::ToolStripStatusLabel();
            this->toolbox = gcnew System::Windows::Forms::ListBox();
            this->addCustomElementButton = gcnew System::Windows::Forms::Button();
            this->customElementName = gcnew System::Windows::Forms::TextBox();
            this->edgeModeButton = gcnew System::Windows::Forms::Button();
            this->menuStrip->SuspendLayout();
            this->SuspendLayout();
            
            // graphPanel
            this->graphPanel->BackColor = System::Drawing::SystemColors::Window;
            this->graphPanel->Location = System::Drawing::Point(150, 27);
            this->graphPanel->Name = L"graphPanel";
            this->graphPanel->Size = System::Drawing::Size(650, 423);
            this->graphPanel->TabIndex = 0;
            this->graphPanel->AllowDrop = true;
            
            // menuStrip
            this->menuStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(2) {
                this->fileToolStripMenuItem,
                this->modulesToolStripMenuItem
            });
            this->menuStrip->Location = System::Drawing::Point(0, 0);
            this->menuStrip->Name = L"menuStrip";
            this->menuStrip->Size = System::Drawing::Size(800, 24);
            this->menuStrip->TabIndex = 1;
            this->menuStrip->Text = L"menuStrip1";
            
            // fileToolStripMenuItem
            this->fileToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(2) {
                this->saveToolStripMenuItem,
                this->loadToolStripMenuItem
            });
            this->fileToolStripMenuItem->Name = L"fileToolStripMenuItem";
            this->fileToolStripMenuItem->Size = System::Drawing::Size(37, 20);
            this->fileToolStripMenuItem->Text = L"File";
            
            // saveToolStripMenuItem
            this->saveToolStripMenuItem->Name = L"saveToolStripMenuItem";
            this->saveToolStripMenuItem->Size = System::Drawing::Size(180, 22);
            this->saveToolStripMenuItem->Text = L"Save Graph";
            this->saveToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainForm::saveToolStripMenuItem_Click);
            
            // loadToolStripMenuItem
            this->loadToolStripMenuItem->Name = L"loadToolStripMenuItem";
            this->loadToolStripMenuItem->Size = System::Drawing::Size(180, 22);
            this->loadToolStripMenuItem->Text = L"Load Graph";
            this->loadToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainForm::loadToolStripMenuItem_Click);
            
            // modulesToolStripMenuItem
            this->modulesToolStripMenuItem->Name = L"modulesToolStripMenuItem";
            this->modulesToolStripMenuItem->Size = System::Drawing::Size(65, 20);
            this->modulesToolStripMenuItem->Text = L"Modules";
            
            // statusStrip
            this->statusStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(1) {this->statusLabel});
            this->statusStrip->Location = System::Drawing::Point(0, 450);
            this->statusStrip->Name = L"statusStrip";
            this->statusStrip->Size = System::Drawing::Size(800, 22);
            this->statusStrip->TabIndex = 2;
            this->statusStrip->Text = L"statusStrip1";
            
            // statusLabel
            this->statusLabel->Name = L"statusLabel";
            this->statusLabel->Size = System::Drawing::Size(39, 17);
            this->statusLabel->Text = L"Ready";
            
            // toolbox
            this->toolbox->FormattingEnabled = true;
            this->toolbox->Location = System::Drawing::Point(0, 27);
            this->toolbox->Name = L"toolbox";
            this->toolbox->Size = System::Drawing::Size(150, 355);
            this->toolbox->TabIndex = 3;
            this->toolbox->AllowDrop = true;
            
            // addCustomElementButton
            this->addCustomElementButton->Location = System::Drawing::Point(0, 388);
            this->addCustomElementButton->Name = L"addCustomElementButton";
            this->addCustomElementButton->Size = System::Drawing::Size(150, 23);
            this->addCustomElementButton->TabIndex = 4;
            this->addCustomElementButton->Text = L"Add Custom Element";
            this->addCustomElementButton->Click += gcnew System::EventHandler(this, &MainForm::addCustomElementButton_Click);
            
            // customElementName
            this->customElementName->Location = System::Drawing::Point(0, 415);
            this->customElementName->Name = L"customElementName";
            this->customElementName->Size = System::Drawing::Size(150, 20);
            this->customElementName->TabIndex = 5;
            
            // edgeModeButton
            this->edgeModeButton->Location = System::Drawing::Point(0, 440);
            this->edgeModeButton->Name = L"edgeModeButton";
            this->edgeModeButton->Size = System::Drawing::Size(150, 23);
            this->edgeModeButton->TabIndex = 6;
            this->edgeModeButton->Text = L"Edge Mode (Off)";
            this->edgeModeButton->Click += gcnew System::EventHandler(this, &MainForm::edgeModeButton_Click);
            
            // MainForm
            this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
            this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
            this->ClientSize = System::Drawing::Size(800, 472);
            this->Controls->Add(this->edgeModeButton);
            this->Controls->Add(this->customElementName);
            this->Controls->Add(this->addCustomElementButton);
            this->Controls->Add(this->toolbox);
            this->Controls->Add(this->statusStrip);
            this->Controls->Add(this->graphPanel);
            this->Controls->Add(this->menuStrip);
            this->MainMenuStrip = this->menuStrip;
            this->Name = L"MainForm";
            this->Text = L"Maltego-like Graph Editor";
            this->menuStrip->ResumeLayout(false);
            this->menuStrip->PerformLayout();
            this->ResumeLayout(false);
            this->PerformLayout();
        }

        void InitializeToolbox()
        {
            // Add default element types
            toolbox->Items->Add("Person");
            toolbox->Items->Add("Organization");
            toolbox->Items->Add("Website");
            toolbox->Items->Add("IP Address");
            toolbox->Items->Add("Email");
            toolbox->Items->Add("Document");
        }

        void LoadModules()
        {
            modules = gcnew List<IMaltegoModule^>();
            // In a real implementation, this would load DLLs
            // For now we'll just add a sample module
            // modules->Add(gcnew SampleModule());
            
            // Add module menu items
            for each (IMaltegoModule^ module in modules)
            {
                ToolStripMenuItem^ item = gcnew ToolStripMenuItem(module->GetModuleName());
                item->Click += gcnew EventHandler(this, &MainForm::ModuleMenuItem_Click);
                modulesToolStripMenuItem->DropDownItems->Add(item);
            }
            
            statusLabel->Text = "Loaded " + modules->Count + " modules";
        }

        void ModuleMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            ToolStripMenuItem^ item = (ToolStripMenuItem^)sender;
            String^ moduleName = item->Text;
            
            for each (IMaltegoModule^ module in modules)
            {
                if (module->GetModuleName() == moduleName)
                {
                    module->Execute(this->graphPanel);
                    break;
                }
            }
        }

        void toolbox_ItemDrag(Object^ sender, ItemDragEventArgs^ e)
        {
            if (e->Item != nullptr)
            {
                DoDragDrop(e->Item, DragDropEffects::Copy);
            }
        }

        void graphPanel_DragEnter(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent("System.String"))
            {
                e->Effect = DragDropEffects::Copy;
            }
        }

        void graphPanel_DragDrop(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent("System.String"))
            {
                String^ elementType = (String^)e->Data->GetData("System.String");
                Point dropLocation = graphPanel->PointToClient(Point(e->X, e->Y));
                
                GraphNode^ newNode = gcnew GraphNode();
                newNode->Id = nodeIdCounter++;
                newNode->Type = elementType;
                newNode->Text = elementType + " " + newNode->Id;
                newNode->Location = dropLocation;
                newNode->Size = System::Drawing::Size(100, 40);
                newNode->Color = GetColorForType(elementType);
                
                graphElements->Add(newNode);
                graphPanel->Invalidate();
            }
        }

        Color GetColorForType(String^ type)
        {
            if (type == "Person") return Color::LightBlue;
            if (type == "Organization") return Color::LightGreen;
            if (type == "Website") return Color::LightPink;
            if (type == "IP Address") return Color::LightSalmon;
            if (type == "Email") return Color::LightGoldenrodYellow;
            if (type == "Document") return Color::LightGray;
            return Color::White;
        }

        void graphPanel_MouseDown(Object^ sender, MouseEventArgs^ e)
        {
            if (isDrawingEdge)
            {
                // Start drawing an edge
                selectedElement = FindElementAtPoint(e->Location);
                if (selectedElement != nullptr)
                {
                    tempEdge = gcnew GraphEdge();
                    tempEdge->Source = selectedElement;
                    tempEdge->StartPoint = GetElementConnectionPoint(selectedElement, e->Location);
                    tempEdge->EndPoint = e->Location;
                }
            }
            else
            {
                // Select element for moving
                selectedElement = FindElementAtPoint(e->Location);
                if (selectedElement != nullptr)
                {
                    isDragging = true;
                    dragOffset = Point(e->X - selectedElement->Location.X, 
                                      e->Y - selectedElement->Location.Y);
                }
            }
        }

        void graphPanel_MouseMove(Object^ sender, MouseEventArgs^ e)
        {
            if (isDragging && selectedElement != nullptr)
            {
                selectedElement->Location = Point(e->X - dragOffset.X, e->Y - dragOffset.Y);
                graphPanel->Invalidate();
            }
            else if (isDrawingEdge && tempEdge != nullptr)
            {
                tempEdge->EndPoint = e->Location;
                graphPanel->Invalidate();
            }
        }

        void graphPanel_MouseUp(Object^ sender, MouseEventArgs^ e)
        {
            if (isDrawingEdge && tempEdge != nullptr && selectedElement != nullptr)
            {
                GraphElement^ targetElement = FindElementAtPoint(e->Location);
                if (targetElement != nullptr && targetElement != tempEdge->Source)
                {
                    tempEdge->Target = targetElement;
                    tempEdge->EndPoint = GetElementConnectionPoint(targetElement, e->Location);
                    edges->Add(tempEdge);
                }
                tempEdge = nullptr;
                graphPanel->Invalidate();
            }
            
            isDragging = false;
            selectedElement = nullptr;
        }

        GraphElement^ FindElementAtPoint(Point point)
        {
            for (int i = graphElements->Count - 1; i >= 0; i--)
            {
                if (graphElements[i]->Bounds.Contains(point))
                {
                    return graphElements[i];
                }
            }
            return nullptr;
        }

        Point GetElementConnectionPoint(GraphElement^ element, Point referencePoint)
        {
            Rectangle bounds = element->Bounds;
            Point center = Point(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);
            
            // Simple implementation - connect to nearest edge
            if (Math::Abs(referencePoint.X - center.X) > Math::Abs(referencePoint.Y - center.Y))
            {
                return Point(
                    referencePoint.X < center.X ? bounds.Left : bounds.Right,
                    center.Y
                );
            }
            else
            {
                return Point(
                    center.X,
                    referencePoint.Y < center.Y ? bounds.Top : bounds.Bottom
                );
            }
        }

        void graphPanel_Paint(Object^ sender, PaintEventArgs^ e)
        {
            Graphics^ g = e->Graphics;
            g->SmoothingMode = System::Drawing::Drawing2D::SmoothingMode::AntiAlias;
            
            // Draw edges first (under nodes)
            for each (GraphEdge^ edge in edges)
            {
                edge->Draw(g);
            }
            
            // Draw temporary edge if in edge mode
            if (tempEdge != nullptr)
            {
                tempEdge->Draw(g);
            }
            
            // Draw elements
            for each (GraphElement^ element in graphElements)
            {
                element->Draw(g);
            }
        }

        void addCustomElementButton_Click(Object^ sender, EventArgs^ e)
        {
            if (!String::IsNullOrEmpty(customElementName->Text))
            {
                toolbox->Items->Add(customElementName->Text);
                customElementName->Text = "";
            }
        }

        void edgeModeButton_Click(Object^ sender, EventArgs^ e)
        {
            isDrawingEdge = !isDrawingEdge;
            edgeModeButton->Text = "Edge Mode " + (isDrawingEdge ? "(On)" : "(Off)");
        }

        void saveToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ saveDialog = gcnew SaveFileDialog();
            saveDialog->Filter = "JSON Files|*.json|All Files|*.*";
            saveDialog->Title = "Save Graph";
            
            if (saveDialog->ShowDialog() == System::Windows::Forms::DialogResult::OK)
            {
                json j;
                
                // Save nodes
                j["nodes"] = json::array();
                for each (GraphElement^ element in graphElements)
                {
                    json node;
                    node["id"] = element->Id;
                    node["type"] = msclr::interop::marshal_as<std::string>(element->Type);
                    node["text"] = msclr::interop::marshal_as<std::string>(element->Text);
                    node["x"] = element->Location.X;
                    node["y"] = element->Location.Y;
                    node["color"] = element->Color.ToArgb();
                    j["nodes"].push_back(node);
                }
                
                // Save edges
                j["edges"] = json::array();
                for each (GraphEdge^ edge in edges)
                {
                    json edgeJson;
                    edgeJson["source"] = edge->Source->Id;
                    edgeJson["target"] = edge->Target->Id;
                    j["edges"].push_back(edgeJson);
                }
                
                // Write to file
                std::ofstream outFile(msclr::interop::marshal_as<std::string>(saveDialog->FileName));
                outFile << j.dump(4);
                outFile.close();
                
                statusLabel->Text = "Graph saved successfully";
            }
        }

        void loadToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            OpenFileDialog^ openDialog = gcnew OpenFileDialog();
            openDialog->Filter = "JSON Files|*.json|All Files|*.*";
            openDialog->Title = "Load Graph";
            
            if (openDialog->ShowDialog() == System::Windows::Forms::DialogResult::OK)
            {
                try
                {
                    // Clear current graph
                    graphElements->Clear();
                    edges->Clear();
                    nodeIdCounter = 1;
                    
                    // Read JSON file
                    std::ifstream inFile(msclr::interop::marshal_as<std::string>(openDialog->FileName));
                    json j;
                    inFile >> j;
                    inFile.close();
                    
                    // Load nodes
                    std::map<int, GraphElement^> nodeMap;
                    for (auto& nodeJson : j["nodes"])
                    {
                        GraphNode^ newNode = gcnew GraphNode();
                        newNode->Id = nodeJson["id"];
                        newNode->Type = msclr::interop::marshal_as<String^>(nodeJson["type"].get<std::string>());
                        newNode->Text = msclr::interop::marshal_as<String^>(nodeJson["text"].get<std::string>());
                        newNode->Location = Point(nodeJson["x"], nodeJson["y"]);
                        newNode->Size = System::Drawing::Size(100, 40);
                        newNode->Color = Color::FromArgb(nodeJson["color"]);
                        
                        graphElements->Add(newNode);
                        nodeMap[nodeJson["id"]] = newNode;
                        
                        // Update ID counter
                        if (newNode->Id >= nodeIdCounter)
                        {
                            nodeIdCounter = newNode->Id + 1;
                        }
                    }
                    
                    // Load edges
                    for (auto& edgeJson : j["edges"])
                    {
                        GraphEdge^ newEdge = gcnew GraphEdge();
                        newEdge->Source = nodeMap[edgeJson["source"]];
                        newEdge->Target = nodeMap[edgeJson["target"]];
                        
                        // Calculate connection points
                        Point centerSource = Point(
                            newEdge->Source->Location.X + newEdge->Source->Size.Width / 2,
                            newEdge->Source->Location.Y + newEdge->Source->Size.Height / 2
                        );
                        Point centerTarget = Point(
                            newEdge->Target->Location.X + newEdge->Target->Size.Width / 2,
                            newEdge->Target->Location.Y + newEdge->Target->Size.Height / 2
                        );
                        
                        newEdge->StartPoint = GetElementConnectionPoint(newEdge->Source, centerTarget);
                        newEdge->EndPoint = GetElementConnectionPoint(newEdge->Target, centerSource);
                        
                        edges->Add(newEdge);
                    }
                    
                    graphPanel->Invalidate();
                    statusLabel->Text = "Graph loaded successfully";
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error loading file: " + ex->Message, "Error", 
                                    MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }
    };
}